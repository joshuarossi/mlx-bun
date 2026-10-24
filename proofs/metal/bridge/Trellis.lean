import metal.kernels.GateUp
import metal.kernels.DownPartial
import metal.bridge.DownFold
import metal.bridge.SiluRmsHeads
import metal.bridge.SingleRounding

namespace Metal.Bridge.Trellis
open Metal Metal.Core
open Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics
open Inference.Kernels.Trellis Inference.Layers Inference.Models.Qwen Inference.Models.Qwen.WrittenLayers
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # The Trellis MLP chain: the three launches compute the model's `mlp.forward`

The route's MLP (`KernelContract.trellis`, `GlueKernels.trellis_mlp`) runs gate-up, down-partial and down-fold.
`Metal.Kernels.GateUp.gpu_output_of`, `Metal.Kernels.DownPartial.gpu_output_of` and `Metal.Kernels.DownFold.gpu_output`
state their outputs with the M1 Max operations; this file proves them equal to the model's `GateDown`
(`WrittenLayers.GateDown.intermediate`, `DownFlushToZero.partialSum`, `GateDown.forward`):

* codebook (`codebook_eq`): the core's `trellis_y`/`trellis_unrefined_bits_y` table entry `s` is
  `CodebookLoad.mathematicalCode` of `s` (through `CodebookFlushToZero.decoder_correct`); the core's 12-bit state of a
  block (`trellisCode`) is the model's `Codebook.PackedState.read` (`read_eq`), so each machine weight is
  `C.fmul` of the model's `DownExecution.coefficient` and scale (`code_eq`);
* gate-up rows (`rowSum_eq`): a lane's `gAcc`/`gAcc2` after its columns are the model's `GateUpAccuracy.step` pair
  (`colPair`, `laneAcc_eq`), `acc + acc2` is `laneExpr`, and `simd_sum` is the gate platform's `reduce`, so the row is
  `TrellisCodebookGateUp.raw` (`C.fmul`/`C.fma`/`C.fadd` are the flushed models on the finite operands
  `TrellisCodebookGateUp.Finite` implies);
* gate-up tail (`tail_split`, `tail_float`, `mid_eq`): TAIL = 1 is `GateUpSplitTail.tail C.fastExpAbs` (the sigmoid as
  in silu-rms-heads); TAIL = 0 is `GateUpTailFlushToZero.tail C.expNeg`. **Operation difference (proved equal):** the
  source's two TAIL = 0 products `T(float(gateT) * float(sigmoidT))` and `T(float(siluT) * float(upT))` are compiled to
  bf16 multiplications (the optimizer's `bfloat(op(float(a), float(b)))` narrowing, `metal/Elab.lean`), so the core
  has `C.bfmul` = `BFloat16Arithmetic.mul` (one bf16 rounding) where the model has
  `GateUpTailFlushToZero.roundedMul` = `BFloat16.cast ∘ FlushToZero.mul` (binary32 product, then bf16). They agree on
  every pair the model's `Valid` admits (`narrow_mul`: the binary32 product of two 8-bit significands is exact above
  the flush threshold, both flush the same tiny exact products to the same signed zero), so no model change is
  needed;
* down-partial (`partialVal_eq`): split `y + 32k`'s accumulator is `DownFlushToZero.splitSum`'s expression prefix
  (`splitPre`), and `partial[y][col]` is `DownFlushToZero.partialSum` (same order, `((0 + s_y) + …) + s_{y+96}`);
* down-fold (`outValue_eq`): `T(simd_sum(partial[·][col]))` is `TrellisCodebookDown.value` on the bytes the
  down-partial launch writes (no `TrellisMlpParsedDown.Execution` needed, unlike `Metal.Bridge.DownFold.expected_mlp`);
* bytes (`GateUpDecodes`, `DownDecodes`, `gateUp_decodes_of_values`, `down_decodes_of_values`): MLX's row-major bytes
  of the route's values decode to the model's projections and input (row-major gate/up words, the 3-bit down
  block-pair interleaving, the `half` scales, `x`'s bf16 words);
* composition (`gpu_model`, `gpu_route`) and readback (`mid_readback`, `part_readback`, `readback`).

The finiteness hypothesis is the model's `TrellisMlp.Finite mlp (Blocks.packed input)`, which
`TrellisMlpRanges.finite` provides from the checked scale bounds (`CheckpointTrellis.parameters`), the input bound
`TrellisMlpRanges.InputBound` and the activation's primitives (`Host.Mlx.GlueM1Max.activationPrimitive`). -/

/-! ## Scalar folds -/

section Folds

/-- `scalarRows` peels its last row. -/
theorem scalarRows_succ {α : Type} (f : Nat → α → α) :
    ∀ (start count : Nat) (acc : α),
      DownCodebook.scalarRows f start (count + 1) acc = f (start + count) (DownCodebook.scalarRows f start count acc)
  | start, 0, acc => rfl
  | start, count + 1, acc => by
    change DownCodebook.scalarRows f (start + 1) (count + 1) (f start acc) = _
    rw [scalarRows_succ f (start + 1) count (f start acc), show start + 1 + count = start + (count + 1) by omega]
    rfl

end Folds

/-! ## The codebook: `trellis_unrefined_bits_y(trellis_y(s))` is the model's decoded code -/

section Codebook
open Metal.Kernels.Trellis

theorem mix_toNat (s : Nat) : (Codebook.mix (BitVec.ofNat 32 s)).toNat = (s * 34038481 + 76625530) % 2 ^ 32 := by
  unfold Codebook.mix
  rw [BitVec.toNat_add, BitVec.toNat_mul, BitVec.toNat_ofNat]
  have h1 : (34038481 : BitVec 32).toNat = 34038481 := rfl
  have h2 : (76625530 : BitVec 32).toNat = 76625530 := rfl
  rw [h1, h2]
  generalize (2 : Nat) ^ 32 = M
  rw [Nat.mod_mul_mod, Nat.mod_add_mod]

theorem maskPairs (n : Nat) : n &&& 16711935 = n % 256 + 65536 * (n / 65536 % 256) := by
  have hm := Nat.and_mod_two_pow (a := n) (b := 16711935) (n := 16)
  have hd := Nat.and_div_two_pow (a := n) (b := 16711935) (n := 16)
  simp only [show 2^16 = 65536 from rfl, show 16711935 % 65536 = 255 from rfl,
    show 16711935 / 65536 = 255 from rfl, Nat.and_two_pow_sub_one_eq_mod _ 8] at hm hd
  have he := Nat.mod_add_div (n &&& 16711935) 65536
  omega

theorem byte_sum (x : Nat) :
    (((x &&& 0xFF00FF) + (x / 2 ^ 8 &&& 0xFF00FF)) &&& 0xFFFF) + ((x &&& 0xFF00FF) + (x / 2 ^ 8 &&& 0xFF00FF)) / 2 ^ 16 =
      x % 256 + x / 256 % 256 + x / 65536 % 256 + x / 16777216 % 256 := by
  rw [maskPairs, maskPairs, Nat.and_two_pow_sub_one_eq_mod _ 16]
  have h1 : x / 2 ^ 8 = x / 256 := rfl
  have h2 : x / 256 / 65536 = x / 16777216 := by rw [Nat.div_div_eq_div_mul]
  rw [h1, h2]
  omega

/-- The core's `trellis_y` is the model's `Codebook.implementation` of the same state word. -/
theorem trellisYv_eq (s : Nat) : trellisYv s = Codebook.implementation (BitVec.ofNat 32 s) := by
  have hb := Codebook.packedSum_bound (Codebook.mix (BitVec.ofNat 32 s))
  rw [BitVec.le_def, show (1020 : BitVec 32).toNat = 1020 from rfl] at hb
  have hp := Codebook.packedSum_toNat (Codebook.mix (BitVec.ofNat 32 s))
  rw [mix_toNat] at hp
  unfold Codebook.implementation trellisYv trellisP
  rw [BitVec.toInt_eq_toNat_cond, ite_eq_left (by omega), hp]
  dsimp only
  rw [byte_sum]

theorem lifted_bits (n : Nat) (hn : n < 2 ^ 32) :
    Val.ofF32Bits (0x4B000000 ||| n) = Float32.ofBits (0x4b000000 ||| UInt32.ofInt (n : Int)) := by
  unfold Val.ofF32Bits FloatMemory.decode
  congr 1
  apply UInt32.toBitVec_inj.mp
  rw [UInt32.toBitVec_or, BitVec.ofNat_or]
  congr 1
  unfold UInt32.ofInt
  rw [Int.emod_eq_of_lt (by omega) (by omega), Int.toNat_natCast]
  rfl

theorem representable_finite (v : Float32) (h : Codebook.FloatingPoint.representable v = true) : v.isFinite = true := by
  unfold Codebook.FloatingPoint.representable at h
  change v.toModel.unpack.isFinite = true
  rcases hu : v.toModel.unpack with s | _ | s | ⟨s, m, e, hm⟩ <;> rw [hu] at h <;> first | rfl | (simp at h)

theorem neg_lifted : f32Neg (Val.ofF32Bits 0x4B0001FE) = -8389118 := by decide
theorem neg_lifted_finite : (-8389118 : Float32).isFinite = true := by decide
theorem reciprocal_eq : Val.ofF32Bits 0x3BDDB447 = Codebook.FloatingPoint.reciprocal := by decide +kernel
theorem reciprocal_finite : Codebook.FloatingPoint.reciprocal.isFinite = true := by decide +kernel

/-- **Codebook entry `s` of the core is the model's `mathematicalCode` of the state word `s`**: the core's
`trellis_y` is `Codebook.implementation`, and its `(lifted - 8389118.0f) * (1.0f / 147.800537109375f)` is the
model's flushed initializer `CodebookFlushToZero.value` (both operations on finite operands, which the model's
`representable` decoder output implies). -/
theorem codebook_eq (C : M1Max.Contract) (s : Nat) :
    codebook C s = CodebookLoad.mathematicalCode (BitVec.ofNat 32 s) := by
  have hr := Codebook.range (BitVec.ofNat 32 s)
  have hv := CodebookFlushToZero.decoder_correct (BitVec.ofNat 32 s)
  have hmf := representable_finite _ (CodebookLoad.mathematicalCode_accuracy (BitVec.ofNat 32 s)).1
  rw [← hv] at hmf
  have hLf := (General.ftz_mul_finite_factors _ _ hmf).1
  have hAf : (Float32.ofBits (0x4b000000 ||| UInt32.ofInt (Codebook.implementation (BitVec.ofNat 32 s) + 510))).isFinite
      = true := by
    have h := hLf
    unfold CodebookFlushToZero.liftedFtz FlushToZero.add at h
    rw [FlushToZero.finite_flush_iff] at h
    have := (General.add_finite_factors _ _ h).1
    rwa [FlushToZero.finite_flush_iff] at this
  have hA : Val.ofF32Bits (0x4B000000 ||| (Codebook.implementation (BitVec.ofNat 32 s) + 510).toNat) =
      Float32.ofBits (0x4b000000 ||| UInt32.ofInt (Codebook.implementation (BitVec.ofNat 32 s) + 510)) := by
    rw [lifted_bits _ (by omega), Int.toNat_of_nonneg (by omega)]
  unfold codebook unrefinedBits
  rw [trellisYv_eq, hA, neg_lifted, reciprocal_eq, C.fadd_model _ _ hAf neg_lifted_finite]
  change C.fmul (CodebookFlushToZero.liftedFtz _) _ = _
  rw [C.fmul_model _ _ hLf reciprocal_finite, ← hv]
  rfl

theorem implementation_toNat (lo hi : BitVec 32) (off : Nat) (ho : off < 32) :
    (Codebook.PackedState.implementation lo hi off).toNat = (lo.toNat + 2 ^ 32 * hi.toNat) / 2 ^ off % 2 ^ 12 := by
  have happ : (hi ++ lo).toNat = lo.toNat + 2 ^ 32 * hi.toNat := by
    rw [BitVec.toNat_append, Nat.shiftLeft_eq, Nat.add_comm, Nat.mul_comm]
    exact (Nat.two_pow_add_eq_or_of_lt lo.isLt _).symm
  apply Nat.eq_of_testBit_eq
  intro j
  rw [Nat.testBit_mod_two_pow, Nat.testBit_div_two_pow]
  change (Codebook.PackedState.implementation lo hi off).getLsbD j = _
  by_cases hj : j < 12
  · rw [Codebook.PackedState.correct lo hi off j ho hj, decide_eq_true hj, Bool.true_and,
      show j + off = off + j by omega, ← happ]
    rfl
  · rw [decide_eq_false hj, Bool.false_and]
    unfold Codebook.PackedState.implementation
    rw [BitVec.getLsbD_and, Codebook.PackedState.mask_bit, decide_eq_false hj, Bool.and_false]

/-- **The model's packed-state read is the core's trellis state** of a block whose words `0 … 8K-1` are the
little-endian words of `B` from word `base` (the tail-biting wrap to word 0 on both sides). -/
theorem read_eq (K : Nat) (hK : K = 2 ∨ K = 3 ∨ K = 4) (w : Nat → BitVec 32) (B : ByteMemory.Bytes) (base : Nat)
    (hw : ∀ i < 8 * K, (w i).toNat = word32 B (base + i)) (t : Nat) (ht : t < 256) :
    (Codebook.PackedState.read w K t).toNat = trellisCode K B base t := by
  obtain ⟨_, hwi, hoff, hnext⟩ := Codebook.PackedState.geometry K t hK ht
  have hW : ∀ i < 8 * K + 1, word32 B (base + i % (8 * K)) < 2 ^ 32 := fun i _ => word32_lt B _
  have hsl := runBits_slice hW ((255 - t) * K / 32) 2 (by omega)
  have hn : word32 B (base + ((255 - t) * K / 32 + 1) % (8 * K)) =
      (w (if (255 - t) * K / 32 + 1 = 8 * K then 0 else (255 - t) * K / 32 + 1)).toNat := by
    split
    · rename_i h
      rw [h, Nat.mod_self, ← hw 0 (by omega)]
    · rename_i h
      rw [ite_eq_right h] at hnext
      rw [Nat.mod_eq_of_lt (by omega), hw _ hnext]
  have h0 : word32 B (base + ((255 - t) * K / 32 + 0) % (8 * K)) = (w ((255 - t) * K / 32)).toNat := by
    rw [Nat.add_zero, Nat.mod_eq_of_lt hwi, hw _ hwi]
  unfold Codebook.PackedState.read trellisCode blockBits
  dsimp only
  rw [implementation_toNat _ _ _ hoff]
  have hp : K * (255 - t) = 32 * ((255 - t) * K / 32) + (255 - t) * K % 32 := by
    rw [Nat.mul_comm K]; omega
  rw [hp, Nat.pow_add, ← Nat.div_div_eq_div_mul,
    ← window_mod (runBits (fun i => word32 B (base + i % (8 * K))) (8 * K + 1) / 2 ^ (32 * ((255 - t) * K / 32)))
      ((255 - t) * K % 32) 64 (by omega), show 64 = 32 * 2 from rfl, hsl]
  simp only [runBits]
  rw [h0, hn]
  ring_nf

end Codebook

/-! ## `T(float(a) * float(b))` is the bf16 product -/

section Products
open Metal.Bridge.SingleRounding

/-- Binary32 multiplication with a zero exact product is the zero of the operands' sign product. -/
theorem f32_mul_zero_sign (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (h0 : real x * real y = 0) :
    Model.signBit (model (x * y)) = Bool.xor (Model.signBit (model x)) (Model.signBit (model y)) := by
  have e : x * y = Float32.ofModel (Float32.Model.pack
      (Float.Model.UnpackedFloat.mul Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack)) := rfl
  have hx' : x.toModel.unpack.isFinite = true := hx
  have hy' : y.toModel.unpack.isFinite = true := hy
  have sgn : ∀ (z : Float32) (s : Float.Model.UnpackedFloat.Sign), z.toModel.unpack = .zero s →
      Model.signBit (model z) = Model.modelSignBit s := fun z s hz =>
    (Model.sign_eq_signBit_of_toDyadic?_some (toDyadic_of_unpack_zero hz)).symm
  have sgnf : ∀ (z : Float32) (s : Float.Model.UnpackedFloat.Sign) (m : Nat) (e : Int) (hm : 0 < m),
      z.toModel.unpack = .finite s m e hm → Model.signBit (model z) = Model.modelSignBit s := fun z s m e hm hz =>
    (Model.sign_eq_signBit_of_toDyadic?_some (toDyadic_of_unpack hz)).symm
  have hz : ∀ r, Model.signBit (model (Float32.ofModel (Float32.Model.pack (.zero r)))) = Model.modelSignBit r :=
    fun r => by rw [model_flushed_zero, Model.signBit_ofModel_zero]
  have hxor : ∀ s t : Float.Model.UnpackedFloat.Sign,
      Model.modelSignBit (s * t) = Bool.xor (Model.modelSignBit s) (Model.modelSignBit t) := by
    intro s t; cases s <;> cases t <;> rfl
  rw [e]
  rcases hux : x.toModel.unpack with s | _ | s | ⟨s, m, ee, hm⟩ <;>
    rcases huy : y.toModel.unpack with t | _ | t | ⟨t, n, f, hn⟩ <;>
    rw [hux] at hx' <;> rw [huy] at hy'
  all_goals try first
    | (exfalso; revert hx'; first | decide | (cases s <;> decide))
    | (exfalso; revert hy'; first | decide | (cases t <;> decide))
  · rw [sgn x _ hux, sgn y _ huy]; exact (hz _).trans (hxor _ _)
  · rw [sgn x _ hux, sgnf y _ _ _ _ huy]; exact (hz _).trans (hxor _ _)
  · rw [sgnf x _ _ _ _ hux, sgn y _ huy]; exact (hz _).trans (hxor _ _)
  · exfalso
    rcases mul_eq_zero.mp h0 with h | h
    · exact General.real_ne_zero_of_unpack hux h
    · exact General.real_ne_zero_of_unpack huy h

/-- bf16 multiplication with a zero exact product is the zero of the operands' sign product. -/
theorem bf_mul_zero (X U : BFloat16Arithmetic.Value) (hX : Model.isFinite X = true) (hU : Model.isFinite U = true)
    (h0 : Model.toReal X * Model.toReal U = 0) :
    Denotes (Model.mul X U) 0 (Bool.xor (Model.signBit X) (Model.signBit U)) := by
  obtain ⟨dX, hdX⟩ := Model.exists_toDyadic?_of_isFinite hX
  obtain ⟨dU, hdU⟩ := Model.exists_toDyadic?_of_isFinite hU
  have hz : dX.significand = 0 ∨ dU.significand = 0 := by
    rcases mul_eq_zero.mp h0 with h | h
    · exact Or.inl ((Model.Dyadic.toReal_eq_zero_iff _).mp (real_toDyadic hdX ▸ h))
    · exact Or.inr ((Model.Dyadic.toReal_eq_zero_iff _).mp (real_toDyadic hdU ▸ h))
  have hm : Model.mul X U = Model.zero bfFmt (Bool.xor dX.negative dU.negative) := by
    rcases hz with hz | hz
    · simp [Model.Proof.mul_eq_spec, Model.Spec.mul, hdX, hdU, hz]
    · simp [Model.Proof.mul_eq_spec, Model.Spec.mul, hdX, hdU, hz]
  rw [hm, Model.sign_eq_signBit_of_toDyadic?_some hdX, Model.sign_eq_signBit_of_toDyadic?_some hdU]
  refine ⟨Model.isFinite_eq_true_of_isZero_eq_true _ (Model.isZero_zero _ _), Model.toReal_zero _ _, fun _ => ?_⟩
  rw [Model.signBit_zero, show FloatFormat.bfloat16.supportsSignedZero = true by decide, Bool.and_true]


/-- The product of two bf16-grid values at least `2^-126` in magnitude is on the binary32 grid. -/
theorem product_generic {x u : ℝ}
    (hx : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) x)
    (hu : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) u)
    (hn : FlushToZero.threshold ≤ |x * u|) :
    Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf f32Fmt) (x * u) := by
  obtain ⟨A, ea, hA, hea, rfl⟩ := bf_rep hx
  obtain ⟨B, eb, hB, heb, rfl⟩ := bf_rep hu
  have hvAB : (A : ℝ) * 2 ^ ea * ((B : ℝ) * 2 ^ eb) = ((A * B : ℤ) : ℝ) * (2:ℝ) ^ (ea + eb) := by
    push_cast; rw [zpow_add₀ two_ne_zero]; ring
  have hAB : (A * B).natAbs < 65536 := by
    rw [Int.natAbs_mul]
    have h1 : A.natAbs < 256 := by omega
    have h2 : B.natAbs < 256 := by omega
    calc A.natAbs * B.natAbs < 256 * 256 := Nat.mul_lt_mul'' h1 h2
      _ = 65536 := by norm_num
  have hABr : |((A * B : ℤ) : ℝ)| < 65536 := by
    rw [← Int.cast_abs, Int.abs_eq_natAbs]; exact_mod_cast hAB
  have hexp : -149 ≤ ea + eb := by
    by_contra hc
    push Not at hc
    have h2 : (2:ℝ) ^ (ea + eb) ≤ 2 ^ (-150:ℤ) := zpow_le_zpow_right₀ (by norm_num) (by omega)
    have h3 : |((A * B : ℤ) : ℝ) * (2:ℝ) ^ (ea + eb)| < FlushToZero.threshold := by
      rw [abs_mul, abs_of_pos (two_zpow_pos _)]
      unfold FlushToZero.threshold
      calc |((A * B : ℤ) : ℝ)| * (2:ℝ) ^ (ea + eb) ≤ 65536 * (2:ℝ) ^ (ea + eb) :=
            mul_le_mul_of_nonneg_right hABr.le (two_zpow_pos _).le
        _ ≤ 65536 * 2 ^ (-150:ℤ) := mul_le_mul_of_nonneg_left h2 (by norm_num)
        _ < 2 ^ (-126:ℤ) := by norm_num
    rw [hvAB] at hn
    linarith
  have hprec : (0:ℤ) < (FloatFormat.binary32.fracWidth : ℤ) + 1 := by decide
  rw [hvAB]
  apply (Formats.Flocq.generic_format_FLT_iff _ _ hprec _).mpr
  refine ⟨hprec, ⟨A * B, ea + eb⟩, ?_, ?_, ?_⟩
  · rw [Formats.Flocq.toReal, bpow_eq]
  · have hbase : Numerics.binaryRadix.base ^ ((FloatFormat.binary32.fracWidth : ℤ) + 1).toNat = 16777216 := by
      decide
    rw [hbase]
    change (A * B).natAbs < 16777216
    omega
  · rw [show FloatFormat.binary32.minSubnormalExponent = -149 by decide]
    exact hexp

/-- **`T(float(a) * float(b))` is the bf16 product.** Narrowing the flushed binary32 product of two widened bf16
values equals the flushed bf16 product (the compiler's `bfloat(float(a) * float(b))` → `fmul bfloat` narrowing is
exact: the binary32 product of two 8-bit significands is exact above the flush threshold, both formats flush the
same tiny exact products to the same signed zero, and a zero product has the same sign in both), whenever the
binary32 product and its narrowing are finite. -/
theorem narrow_mul (a b : BFloat16Arithmetic.Value) (ha : Model.isFinite a = true) (hb : Model.isFinite b = true)
    (hp : (FlushToZero.flush (BFloat16.widen a) * FlushToZero.flush (BFloat16.widen b)).isFinite = true)
    (hn : Model.isFinite (BFloat16.narrow (FlushToZero.mul (BFloat16.widen a) (BFloat16.widen b))) = true) :
    BFloat16.narrow (FlushToZero.mul (BFloat16.widen a) (BFloat16.widen b)) = BFloat16Arithmetic.mul a b := by
  set X := BFloat16Arithmetic.flush a with hXdef
  set U := BFloat16Arithmetic.flush b with hUdef
  have hXf : Model.isFinite X = true := BFloat16Arithmetic.finite_flush a ha
  have hUf : Model.isFinite U = true := BFloat16Arithmetic.finite_flush b hb
  have hwx : (BFloat16.widen a).isFinite = true := BFloat16.widen_finite a ha
  have hwu : (BFloat16.widen b).isFinite = true := BFloat16.widen_finite b hb
  obtain ⟨-, wxr, wxs⟩ := widen_denotes ha
  obtain ⟨-, wur, wus⟩ := widen_denotes hb
  set x32 := FlushToZero.flush (BFloat16.widen a) with hx32def
  set u32 := FlushToZero.flush (BFloat16.widen b) with hu32def
  have hx32f : x32.isFinite = true := FlushToZero.finite_flush _ hwx
  have hu32f : u32.isFinite = true := FlushToZero.finite_flush _ hwu
  have rx : Model.toReal (model x32) = Model.toReal X := by
    have := flush32_real _ hwx
    simp only [real, wxr] at this
    rw [this, hXdef, flushB_real]
  have ru : Model.toReal (model u32) = Model.toReal U := by
    have := flush32_real _ hwu
    simp only [real, wur] at this
    rw [this, hUdef, flushB_real]
  have sx : Model.signBit (model x32) = Model.signBit X := by rw [flush32_sign, wxs, hXdef, flushB_sign]
  have su : Model.signBit (model u32) = Model.signBit U := by rw [flush32_sign, wus, hUdef, flushB_sign]
  have E32 : FlushToZero.Exact (FlushToZero.mulExact (model x32) (model u32)) (Model.toReal X * Model.toReal U) := by
    have := FlushToZero.exact_mul (model x32) (model u32)
    rwa [rx, ru] at this
  have EB : FlushToZero.Exact (FlushToZero.mulExact X U) (Model.toReal X * Model.toReal U) := FlushToZero.exact_mul X U
  have hU := General.underflow_congr E32 EB
  have hL : FlushToZero.mul (BFloat16.widen a) (BFloat16.widen b) =
      FlushToZero.flushExact (FlushToZero.mulExact (model x32) (model u32)) (x32 * u32) := rfl
  have hR : BFloat16Arithmetic.mul a b =
      BFloat16Arithmetic.flushExact (FlushToZero.mulExact X U) (Model.mul X U) := rfl
  rw [hL] at hn ⊢
  rw [hR]
  unfold FlushToZero.flushExact at hn ⊢
  unfold BFloat16Arithmetic.flushExact
  rw [hU] at hn ⊢
  rcases hu : FlushToZero.underflow (FlushToZero.mulExact X U) with _ | neg
  · simp only [hu] at hn ⊢
    have hFf : Model.isFinite (model (x32 * u32)) = true := by rw [finite_model]; exact hp
    have hr32 : Model.toReal (model (x32 * u32)) =
        Model.roundAt f32Fmt (Model.toReal X * Model.toReal U) := by
      have := Numerics.mul_real _ _ hp
      simp only [real] at this
      rw [this, rx, ru]
    rcases FlushToZero.underflow_none EB hu with h0 | hnorm
    · have hR0 := bf_mul_zero X U hXf hUf h0
      have hL0 := denotes_narrow_zero hFf (by rw [hr32, h0, Model.roundAt_zero])
      rw [f32_mul_zero_sign x32 u32 hx32f hu32f (by simp only [real]; rw [rx, ru]; exact h0), sx, su] at hL0
      exact hL0.eq hR0
    · have hgen := product_generic (Model.toReal_genericFormat_of_isFinite X hXf)
        (Model.toReal_genericFormat_of_isFinite U hUf) hnorm
      have hzr : Model.toReal (model (x32 * u32)) = Model.toReal X * Model.toReal U := by
        rw [hr32]; exact Formats.Flocq.round_preserves_generic _ _ hgen
      have hnr : Model.toReal (BFloat16.narrow (x32 * u32)) = Model.roundAt bfFmt (Model.toReal X * Model.toReal U) := by
        unfold BFloat16.narrow
        rw [Model.cast_eq_roundAt (by decide) (by decide) _ hFf hn, hzr]
      obtain ⟨dX, hdX⟩ := Model.exists_toDyadic?_of_isFinite hXf
      obtain ⟨dU, hdU⟩ := Model.exists_toDyadic?_of_isFinite hUf
      have hv0 : Model.toReal X * Model.toReal U ≠ 0 := by
        intro h; rw [h, abs_zero] at hnorm; exact absurd hnorm (not_le.mpr FlushToZero.threshold_pos)
      have hXs : dX.significand ≠ 0 := fun h => hv0 (by
        rw [real_toDyadic hdX, (Model.Dyadic.toReal_eq_zero_iff _).mpr h, zero_mul])
      have hUs : dU.significand ≠ 0 := fun h => hv0 (by
        rw [real_toDyadic hdU, (Model.Dyadic.toReal_eq_zero_iff _).mpr h, mul_zero])
      have hmul : Model.mul X U = Model.roundDyadic bfFmt
          ⟨Bool.xor dX.negative dU.negative, dX.significand * dU.significand, dX.exponent + dU.exponent⟩ := by
        simp [Model.Proof.mul_eq_spec, Model.Spec.mul, hdX, hdU, hXs, hUs]
      have hpr : (Numerics.Dyadic.mk (Bool.xor dX.negative dU.negative) (dX.significand * dU.significand)
          (dX.exponent + dU.exponent)).toReal = Model.toReal X * Model.toReal U := by
        rw [Model.Dyadic.toReal_mul, ← real_toDyadic hdX, ← real_toDyadic hdU]
      have hAf : Model.isFinite (Model.mul X U) = true := by
        rw [hmul]
        apply roundDyadic_bf_finite _ (Nat.mul_ne_zero hXs hUs)
        rw [hpr, ← hnr]
        exact Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite _ (by decide) hn
      have hAr : Model.toReal (Model.mul X U) = Model.roundAt bfFmt (Model.toReal X * Model.toReal U) :=
        Model.toReal_mul_eq_roundAt _ _ (by decide) hXf hUf hAf
      have hne : Model.roundAt bfFmt (Model.toReal X * Model.toReal U) ≠ 0 := by
        intro h0
        have := BFloat16Arithmetic.round_normal _ hnorm
        rw [h0, abs_zero] at this
        exact absurd this (not_le.mpr FlushToZero.threshold_pos)
      exact Model.eq_of_toReal_eq_of_nonzero hn hAf (hnr.trans hAr.symm) (hnr ▸ hne)
  · dsimp only
    cases neg <;> decide

/-- Narrowing a widened finite bf16 value gives it back. -/
theorem narrow_widen (m : BFloat16Arithmetic.Value) (hm : Model.isFinite m = true) :
    BFloat16.narrow (BFloat16.widen m) = m := by
  obtain ⟨hwf, hwr, hws⟩ := widen_denotes hm
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hwf
  have hdr : d.toReal = Model.toReal m := by rw [← real_toDyadic hd, hwr]
  unfold BFloat16.narrow
  rw [narrow_eq_roundDyadic hd]
  by_cases h0 : d.significand = 0
  · have hz : d = ⟨d.negative, 0, d.exponent⟩ := by cases d; simp_all
    have hL := denotes_roundDyadic_zero (fmt := bfFmt) (by decide) d.negative d.exponent
    rw [← hz] at hL
    have hr0 : Model.toReal m = 0 := by rw [← hdr, (Model.Dyadic.toReal_eq_zero_iff _).mpr h0]
    refine hL.eq ⟨hm, hr0, fun _ => ?_⟩
    rw [Model.sign_eq_signBit_of_toDyadic?_some hd, hws]
  · have hgen : Model.roundAt bfFmt (Model.toReal m) = Model.toReal m := Model.roundAt_toReal_eq m hm
    have hfin : Model.isFinite (Model.roundDyadic bfFmt d) = true := by
      apply roundDyadic_bf_finite d h0
      rw [hdr, hgen]
      exact Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite _ (by decide) hm
    have hr : Model.toReal (Model.roundDyadic bfFmt d) = Model.toReal m := by
      rw [Model.toReal_roundDyadic_eq_roundAt _ (by decide) d hfin, hdr, hgen]
    have hne : Model.toReal m ≠ 0 := fun h => h0 ((Model.Dyadic.toReal_eq_zero_iff _).mp (hdr.trans h))
    exact Model.eq_of_toReal_eq_of_nonzero hfin hm hr (hr ▸ hne)

end Products

/-! ## Byte decodings of the kernels' inputs

What the kernel theorems read from their buffers, stated as the model's projections: the little-endian code words
of each block, the half-precision scales, and `x`'s bf16 words. -/

section Decodes
open Metal.Kernels.Trellis

/-- A gate or up buffer pair: block `blk` of row `row` is the `8·K` little-endian words of `Codes` from word
`(20·row + blk)·8K` (row-major, `CheckpointTrellis.gateWords`), and the row's scale is the `half` at `S`. -/
structure ProjDecodes (w : TrellisCodebookGateUp.Projection) (Codes S : ByteMemory.Bytes) : Prop where
  words : ∀ row < 17408, ∀ blk < 20, ∀ i < 8 * w.width,
    (w.words row blk i).toNat = word32 Codes ((20 * row + blk) * (8 * w.width) + i)
  scale : ∀ row < 17408, w.scale row = scale S row

/-- The gate-up launch's buffers: `x`'s bf16 words (as the model's `Blocks.packed` words), the gate and up codes and
scales. -/
structure GateUpDecodes (mlp : GateDown) (input : Fin 5120 → BF) (X Gc Gs Uc Us : ByteMemory.Bytes) : Prop where
  x : ∀ c : Fin 5120, half X c.val = (input c).bits.toNat
  gate : ProjDecodes mlp.gate Gc Gs
  up : ProjDecodes mlp.up Uc Us

/-- The down codes and scales: block `blk` of row `row` from word `DownPartial.dbase` (row-major at 2 and 4 bits,
`CheckpointTrellis.downWords`' block-pair interleaving at 3 bits). -/
structure DownDecodes (d : TrellisCodebookDown.Projection) (Codes S : ByteMemory.Bytes) : Prop where
  words : ∀ row < 17408, ∀ blk < 20, ∀ i < 8 * d.width,
    (d.words row blk i).toNat = word32 Codes (Metal.Kernels.DownPartial.dbase d.width (decide (d.width = 3)) row blk + i)
  scale : ∀ row < 17408, d.scale row = scale S row

/-- The core's decoded code of a block is the model's `DownExecution.coefficient`. -/
theorem code_eq (C : M1Max.Contract) {K : Nat} (hK : K = 2 ∨ K = 3 ∨ K = 4) (words : DownExecution.PackedMatrix)
    (Codes : ByteMemory.Bytes) (base : Nat) (r col : Nat)
    (hw : ∀ i < 8 * K, (words r (col / 256) i).toNat = word32 Codes (base + i)) :
    codebook C (trellisCode K Codes base (col % 256)) = DownExecution.coefficient words K r col := by
  unfold DownExecution.coefficient
  rw [← read_eq K hK _ Codes base hw (col % 256) (Nat.mod_lt _ (by decide)), codebook_eq, BitVec.ofNat_toNat,
    BitVec.setWidth_eq]

theorem widen_word (b : BitVec 16) : Val.ofF32Bits (b.toNat * 2 ^ 16) = GateUpExecution.widen b := by
  have hbv : BitVec.ofNat 32 (b.toNat * 2 ^ 16) = BitVec.setWidth 32 b <<< 16 := by
    apply BitVec.eq_of_toNat_eq
    have hb := b.isLt
    rw [BitVec.toNat_ofNat, BitVec.toNat_shiftLeft, BitVec.toNat_setWidth, Nat.shiftLeft_eq,
      Nat.mod_eq_of_lt (show b.toNat < 2 ^ 32 by omega)]
  unfold Val.ofF32Bits FloatMemory.decode GateUpExecution.widen GateUpExecution.asFloat GateUpExecution.widened
  rw [hbv]

/-- `xv` of column `c` (the bf16 word moved up 16 bits) is the model's `GateUpExecution.widen` of the packed word. -/
theorem xval_eq (X : ByteMemory.Bytes) (input : Fin 5120 → BF) (hx : ∀ c : Fin 5120, half X c.val = (input c).bits.toNat)
    (c : Nat) (hc : c < 5120) : Metal.Kernels.GateUp.xval X c = GateUpExecution.widen (Blocks.packed input c) := by
  have hp : Blocks.packed input c = (input ⟨c, hc⟩).bits := dite_eq_left hc
  unfold Metal.Kernels.GateUp.xval
  rw [hp, hx ⟨c, hc⟩]
  exact widen_word _

end Decodes

/-! ## gate-up: a lane's accumulators are the model's lane expressions -/

section GateUpLanes
open Metal.Kernels.GateUp (laneAcc laneCol rowSum weight xval)
open Metal.Kernels.Trellis

/-- The model's lane expressions (`GateUpAccuracy.step` pairs) after the lane's first `n` columns. -/
def colPair (lane : Nat) : Nat → GateUpAccuracy.Pair
  | 0 => (.zero, .zero)
  | n + 1 => GateUpAccuracy.step (lane + 32 * (n / 32)) (n % 32) (colPair lane n)

theorem colPair_run (lane m : Nat) : ∀ j, j ≤ 32 →
    colPair lane (32 * m + j) = DownCodebook.scalarRows (GateUpAccuracy.step (lane + 32 * m)) 0 j (colPair lane (32 * m))
  | 0, _ => rfl
  | j + 1, hj => by
    rw [show 32 * m + (j + 1) = (32 * m + j) + 1 by omega, colPair, colPair_run lane m j (by omega), scalarRows_succ,
      Nat.zero_add, show (32 * m + j) / 32 = m by omega, show (32 * m + j) % 32 = j by omega]

/-- After 160 columns the lane's expressions are the model's `lanePair`. -/
theorem colPair_lane (lane : Nat) : colPair lane 160 = GateUpAccuracy.lanePair lane := by
  have h : ∀ m, colPair lane (32 * m) =
      DownCodebook.scalarRows (fun i => GateUpAccuracy.run (lane + 32 * i)) 0 m (.zero, .zero) := by
    intro m
    induction m with
    | zero => rfl
    | succ m ih =>
      rw [scalarRows_succ, Nat.zero_add, ← ih, show 32 * (m + 1) = 32 * m + 32 by ring, colPair_run lane m 32 le_rfl]
      rfl
  exact h 5

variable {code sc inp : Nat → Float32}

abbrev DotFinite (code sc inp : Nat → Float32) := FlushedDotProduct.Finite code sc inp
abbrev DotEval (code sc inp : Nat → Float32) := FlushedDotProduct.evaluate code sc inp

theorem colPair_finite_pred (lane n : Nat)
    (h : DotFinite code sc inp (colPair lane (n + 1)).1 ∧ DotFinite code sc inp (colPair lane (n + 1)).2) :
    DotFinite code sc inp (colPair lane n).1 ∧ DotFinite code sc inp (colPair lane n).2 := by
  simp only [colPair, GateUpAccuracy.step] at h
  split at h
  · exact ⟨h.1, h.2.1⟩
  · exact ⟨h.1.1, h.2⟩

theorem colPair_finite (lane N : Nat) (h : DotFinite code sc inp (colPair lane N).1 ∧ DotFinite code sc inp (colPair lane N).2) :
    ∀ d n, n + d = N → DotFinite code sc inp (colPair lane n).1 ∧ DotFinite code sc inp (colPair lane n).2
  | 0, n, hn => by rw [Nat.add_zero] at hn; rw [hn]; exact h
  | d + 1, n, hn => colPair_finite_pred lane n (colPair_finite lane N h d (n + 1) (by omega))

/-- A finite model step is the machine `fma(weight, xv, acc)` with the weight's machine product. -/
theorem fma_step (C : M1Max.Contract) {i : Nat} {acc : DotProduct.Expr} {w x a : Float32}
    (hw : w = C.fmul (code i) (sc i)) (hx : x = inp i) (ha : a = DotEval code sc inp acc)
    (hf : DotFinite code sc inp (.fma i acc)) : C.fma w x a = DotEval code sc inp (.fma i acc) := by
  obtain ⟨hacc, hm, hi, -⟩ := hf
  obtain ⟨hc, hs⟩ := General.code_scale_finite hm
  rw [hw, hx, ha, C.fmul_model _ _ hc hs,
    C.fma_model _ _ _ (FlushToZero.mul_finite _ _ hm) hi (FlushedDotProduct.finite_evaluate _ _ _ _ hacc)]
  rfl

/-- **A lane's two accumulators after `n` columns are the model's lane expressions**, given that every machine weight
is the machine product of the model's code and scale, every `xv` the model's input, and the expressions finite. -/
theorem laneAcc_eq (C : M1Max.Contract) (wk xk : Nat → Float32) (lane : Nat)
    (hw : ∀ n < 160, wk (laneCol lane n) = C.fmul (code (laneCol lane n)) (sc (laneCol lane n)))
    (hx : ∀ n < 160, xk (laneCol lane n) = inp (laneCol lane n)) :
    ∀ n ≤ 160, DotFinite code sc inp (colPair lane n).1 → DotFinite code sc inp (colPair lane n).2 →
      laneAcc C wk xk lane 0 n = DotEval code sc inp (colPair lane n).1 ∧
        laneAcc C wk xk lane 1 n = DotEval code sc inp (colPair lane n).2
  | 0, _, _, _ => ⟨General.ofF32Bits_zero, General.ofF32Bits_zero⟩
  | n + 1, hn, h1, h2 => by
    have hprev := colPair_finite_pred lane n ⟨h1, h2⟩
    obtain ⟨ih1, ih2⟩ := laneAcc_eq C wk xk lane hw hx n (by omega) hprev.1 hprev.2
    have hcol : laneCol lane n = (lane + 32 * (n / 32)) * 32 + n % 32 := by unfold laneCol; ring
    have hj : n % 32 % 2 = n % 2 := by omega
    simp only [laneAcc, colPair, GateUpAccuracy.step] at h1 h2 ⊢
    rw [hj] at h1 h2 ⊢
    by_cases hp : n % 2 = 1
    · rw [ite_eq_left hp] at h1 h2 ⊢
      rw [ite_eq_right (by omega), ite_eq_left hp]
      refine ⟨ih1, ?_⟩
      exact fma_step C (hcol ▸ hw n (by omega)) (hcol ▸ hx n (by omega)) ih2 h2
    · rw [ite_eq_right hp] at h1 h2 ⊢
      rw [ite_eq_left (by omega), ite_eq_right (by omega)]
      refine ⟨?_, ih2⟩
      exact fma_step C (hcol ▸ hw n (by omega)) (hcol ▸ hx n (by omega)) ih1 h1

theorem projection_lanes : ∀ (t : Reduction.Tree 32), DotFinite code sc inp (GateUpFlushToZero.projectionExpr t) →
    ∀ l ∈ Reduction.leaves t, DotFinite code sc inp (GateUpAccuracy.laneExpr l.val)
  | .leaf i, h, l, hl => by rw [show l = i from List.mem_singleton.mp hl]; exact h
  | .add a b, h, l, hl => (List.mem_append.mp hl).elim (projection_lanes a h.1 l) (projection_lanes b h.2.1 l)

/-- The model's `raw` reads its codebook through `sourceLane_correct`: it is the reduction of the reference lanes. -/
theorem raw_reference (p : TrellisCodebookGateUp.Platform) (w : TrellisCodebookGateUp.Projection)
    (input : Nat → BitVec 16) (row : Nat) :
    TrellisCodebookGateUp.raw p w input row =
      p.reduce (fun lane => GateUpFlushToZero.referenceLane w.words w.width w.scale input row lane.val) :=
  congrArg p.reduce (funext fun lane =>
    GateUpFlushToZero.sourceLane_correct p.load p.loads _ p.base p.aligned p.bounded
      (TrellisCodebookGateUp.table_initialized p) w.words w.width w.validWidth w.scale input row lane.val lane.isLt)

/-- **Row `r` of a gate-up projection: the core's `simd_sum(acc + acc2)` is the model's `raw`**, for decoded codes
and scales, the model's input words, and a platform reducing with `C.simdSum`, when the model's projection
expression is finite (`TrellisCodebookGateUp.Finite`). -/
theorem rowSum_eq (C : M1Max.Contract) (p : TrellisCodebookGateUp.Platform) (w : TrellisCodebookGateUp.Projection)
    (input : Fin 5120 → BF) (Codes S X : ByteMemory.Bytes) (hd : ProjDecodes w Codes S)
    (hx : ∀ c : Fin 5120, half X c.val = (input c).bits.toNat) (hred : p.reduce = C.simdSum) (r : Nat) (hr : r < 17408)
    (hf : TrellisCodebookGateUp.Finite p w (Blocks.packed input) r) :
    rowSum C w.width Codes S X r = TrellisCodebookGateUp.raw p w (Blocks.packed input) r := by
  rw [raw_reference, hred]
  unfold rowSum
  congr 1
  funext lane
  rw [← GateUpFlushToZero.evaluate_lane]
  have hl := projection_lanes _ hf lane (p.reduction.coverage.mem_iff.mpr (List.mem_finRange lane))
  have hl' := hl
  rw [GateUpAccuracy.laneExpr, ← colPair_lane] at hl'
  obtain ⟨h1, h2, -⟩ := hl'
  have hcol : ∀ n < 160, laneCol lane.val n < 5120 := fun n hn => by have := lane.isLt; unfold laneCol; omega
  obtain ⟨e1, e2⟩ := laneAcc_eq (code := fun col => DownExecution.coefficient w.words w.width r col)
    (sc := fun _ => w.scale r) (inp := fun col => GateUpExecution.widen (Blocks.packed input col)) C
    (weight C w.width Codes S r) (xval X) lane.val
    (fun n hn => by
      unfold weight
      rw [code_eq C w.validWidth w.words Codes _ r _ (fun i hi => hd.words r hr _ (by have := hcol n hn; omega) i hi),
        hd.scale r hr])
    (fun n hn => xval_eq X input hx _ (hcol n hn)) 160 le_rfl h1 h2
  rw [e1, e2, colPair_lane]
  unfold GateUpAccuracy.laneExpr at hl
  exact C.fadd_model _ _ (FlushedDotProduct.finite_evaluate _ _ _ _ hl.1) (FlushedDotProduct.finite_evaluate _ _ _ _ hl.2.1)

end GateUpLanes

/-! ## gate-up: the tail is the model's activation -/

section Tail
open Metal.Kernels.GateUp (tailOut sigY bone bzero one)

theorem one_eq : one = (1 : Float32) := by decide

/-- **`TAIL == 1`** (gate width ≠ up width): `mid = T(gate)·sigmoid·T(up)` in bf16 is the model's
`GateUpSplitTail.tail C.fastExpAbs` on the narrowed sums (the sigmoid as in silu-rms-heads:
`Metal.Bridge.SiluRmsHeads.sigmoid_eq`). -/
theorem tail_split (C : M1Max.Contract) (gate up : Float32) (hg : gate.isFinite = true) (hu : up.isFinite = true)
    (hp : GateUpSplitTail.ProductsFinite C.fastExpAbs (BFloat16.narrow gate) (BFloat16.narrow up)) :
    tailOut C true gate up = GateUpSplitTail.tail C.fastExpAbs (BFloat16.narrow gate) (BFloat16.narrow up) := by
  unfold tailOut
  dsimp only
  rw [C.narrow_model _ hg, C.narrow_model _ hu]
  have hs : (if f32Compare (C.widen (BFloat16.narrow gate)) (C.widen bzero) = some .lt then sigY C (BFloat16.narrow gate)
      else C.bfsub bone (sigY C (BFloat16.narrow gate))) = Metal.Kernels.SiluRmsHeads.sigmoid C (BFloat16.narrow gate) := by
    unfold Metal.Kernels.SiluRmsHeads.sigmoid Metal.Kernels.SiluRmsHeads.isNeg
    simp only [decide_eq_true_eq]
    rfl
  rw [hs, Metal.Bridge.SiluRmsHeads.sigmoid_eq C false _ hp.hGate]
  change C.bfmul (C.bfmul _ (GateUpSplitTail.sigmoidValue C.fastExpAbs _)) _ = _
  have hsf := (SigmoidRanges.ranges _ _ C.fastExpAbs_contract C.fastExpAbs_exponential _ hp.hGate).2.1
  rw [C.bfmul_model _ _ hp.hGate hsf, C.bfmul_model _ _ (BFloat16Arithmetic.mul_finite _ _ hp.hSilu) hp.hUp]
  rfl

/-- **`TAIL == 0`** (equal widths): the core's `sigmoidT = T(1/(1 + precise::exp(-float(gateT))))` and
the two products `T(float(·) * float(·))`, which the compiler narrows to bf16 multiplications (`C.bfmul`), widen to the
model's `GateUpTailFlushToZero.tail C.expNeg` (binary32 products rounded once to bf16): equal by `narrow_mul`. -/
theorem tail_float (C : M1Max.Contract) (gate up : Float32) (hg : gate.isFinite = true) (hu : up.isFinite = true)
    (hgc : Model.isFinite (BFloat16.narrow gate) = true) (huc : Model.isFinite (BFloat16.narrow up) = true)
    (hv : GateUpTailFlushToZero.Valid C.expNeg (BFloat16.cast gate) (BFloat16.cast up)) :
    BFloat16.widen (tailOut C false gate up) = GateUpTailFlushToZero.tail C.expNeg (BFloat16.cast gate) (BFloat16.cast up) ∧
      Model.isFinite (tailOut C false gate up) = true := by
  have hcg : BFloat16.cast gate = BFloat16.widen (BFloat16.narrow gate) := rfl
  have hcu : BFloat16.cast up = BFloat16.widen (BFloat16.narrow up) := rfl
  rw [hcg, hcu] at hv ⊢
  have hgf : (BFloat16.widen (BFloat16.narrow gate)).isFinite = true := BFloat16.widen_finite _ hgc
  have hP : GateUpTailFlushToZero.ProductsFinite C.expNeg (BFloat16.widen (BFloat16.narrow gate))
      (BFloat16.widen (BFloat16.narrow up)) := by
    rcases hv with hf | ⟨-, hp⟩
    · exact ⟨hf.hSilu, hf.hSiluBfloat, hf.hOutput, hf.hOutputBfloat⟩
    · exact hp
  have hq : C.narrow (C.fdiv one (C.fadd one (C.exp (f32Neg (C.widen (BFloat16.narrow gate)))))) =
      BFloat16.narrow (GateUpTailFlushToZero.quotient C.expNeg (BFloat16.widen (BFloat16.narrow gate))) ∧
      Model.isFinite (BFloat16.narrow (GateUpTailFlushToZero.quotient C.expNeg
        (BFloat16.widen (BFloat16.narrow gate)))) = true := by
    rw [C.widen_model _ hgc, General.f32Neg_eq, one_eq]
    change C.narrow (C.fdiv 1 (C.fadd 1 (C.expNeg (BFloat16.widen (BFloat16.narrow gate))))) = _ ∧ _
    rcases hv with hf | ⟨he, -⟩
    · have hE := hf.hExponential
      have hden := GateUpTailFlushToZero.denominator_finite C.expNeg _ hf.hDenominator
      have hge : 1 ≤ real (GateUpTailFlushToZero.denominator C.expNeg (BFloat16.widen (BFloat16.narrow gate))) :=
        FlushToZero.add_one_ge_one _ hE (C.exp_nonnegative _ (Negation.finite_neg _ hgf) hE) hf.hDenominator
      have hqf := GateUpTailFlushToZero.quotient_finite C.expNeg _ hge hf.hQuotient
      rw [C.fadd_model 1 _ (by decide) hE]
      change C.narrow (C.fdiv 1 (GateUpTailFlushToZero.denominator C.expNeg _)) = _ ∧ _
      rw [C.fdiv_one_model _ hden hge]
      exact ⟨C.narrow_model _ hqf, hf.hSigmoid⟩
    · rw [he, C.fadd_posInf 1 (by decide), Metal.Bridge.GatedRmsNorm.add_one_inf, C.fdiv_posInf 1 (by decide)]
      have hq : GateUpTailFlushToZero.quotient C.expNeg (BFloat16.widen (BFloat16.narrow gate)) =
          FlushToZero.div 1 Float32.inf := by
        unfold GateUpTailFlushToZero.quotient GateUpTailFlushToZero.denominator
        rw [he, Metal.Bridge.GatedRmsNorm.add_one_inf]
      rw [hq]
      exact ⟨C.narrow_model _ (by decide +kernel), by decide +kernel⟩
  obtain ⟨hq1, hsT⟩ := hq
  have m1 := narrow_mul _ _ hgc hsT hP.hSilu hP.hSiluBfloat
  have m1f : Model.isFinite (BFloat16Arithmetic.mul (BFloat16.narrow gate)
      (BFloat16.narrow (GateUpTailFlushToZero.quotient C.expNeg (BFloat16.widen (BFloat16.narrow gate))))) = true :=
    m1 ▸ hP.hSiluBfloat
  have hrm : GateUpTailFlushToZero.roundedMul (BFloat16.widen (BFloat16.narrow gate))
      (GateUpTailFlushToZero.roundedSigmoid C.expNeg (BFloat16.widen (BFloat16.narrow gate))) =
      BFloat16.widen (BFloat16Arithmetic.mul (BFloat16.narrow gate)
        (BFloat16.narrow (GateUpTailFlushToZero.quotient C.expNeg (BFloat16.widen (BFloat16.narrow gate))))) := by
    change BFloat16.widen (BFloat16.narrow (FlushToZero.mul _ _)) = _
    rw [← m1]
    rfl
  have hO := hP.hOutput
  have hOb := hP.hOutputBfloat
  rw [hrm] at hO hOb
  have m2 := narrow_mul _ _ m1f huc hO hOb
  unfold tailOut
  dsimp only
  rw [C.narrow_model _ hg, C.narrow_model _ hu, hq1, C.bfmul_model _ _ hgc hsT, C.bfmul_model _ _ m1f huc]
  refine ⟨?_, m2 ▸ hOb⟩
  unfold GateUpTailFlushToZero.tail
  rw [hrm]
  change _ = BFloat16.widen (BFloat16.narrow (FlushToZero.mul _ _))
  rw [m2]

end Tail

/-! ## gate-up: `mid` is the model's intermediate activation -/

section GateUp
open Metal.Kernels.GateUp (midOut)

theorem tail_gateFinite {a : Activation} {p : TrellisCodebookGateUp.Platform} {g u : TrellisCodebookGateUp.Projection}
    {i : Nat → BitVec 16} (h : TrellisMlp.TailFinite a p g u i) : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p g i row := by
  cases a
  · exact (h : TrellisMlp.FloatFinite _ _ _ _ _).gateFinite
  · exact (h : TrellisMlp.SplitFinite _ _ _ _ _).gateFinite

theorem tail_upFinite {a : Activation} {p : TrellisCodebookGateUp.Platform} {g u : TrellisCodebookGateUp.Projection}
    {i : Nat → BitVec 16} (h : TrellisMlp.TailFinite a p g u i) : ∀ row : Fin 17408, TrellisCodebookGateUp.Finite p u i row := by
  cases a
  · exact (h : TrellisMlp.FloatFinite _ _ _ _ _).upFinite
  · exact (h : TrellisMlp.SplitFinite _ _ _ _ _).upFinite

/-- The model's bf16 `mid` row: its intermediate activation narrowed (it is the widening of a bf16 value). -/
noncomputable def midValue (mlp : GateDown) (input : Fin 5120 → BF) (r : Nat) : BF :=
  BFloat16.narrow (mlp.intermediate (Blocks.packed input) r)

variable (C : M1Max.Contract)

/-- **Element `r` of the gate-up kernel's `mid` widens to the model's intermediate activation**
`mlp.intermediate (Blocks.packed input) r` (`GateDown.intermediate`, the value the model's down projection reads),
and is finite: for buffers decoding to the model's projections and input (`GateUpDecodes`), the gate platform
reducing with `C.simdSum`, the route's activation choice (`trellisActivation`: TAIL = 1 exactly when the widths
differ), and the model's finiteness `TrellisMlp.Finite` (its `tail` part). -/
theorem mid_eq (mlp : GateDown) (input : Fin 5120 → BF) (X Gc Gs Uc Us : ByteMemory.Bytes)
    (hd : GateUpDecodes mlp input X Gc Gs Uc Us) (hred : mlp.gatePlatform.reduce = C.simdSum)
    (hact : mlp.activation = Host.Mlx.trellisActivation C mlp.gate.width mlp.up.width)
    (hf : TrellisMlp.Finite mlp (Blocks.packed input)) (r : Nat) (hr : r < 17408) :
    BFloat16.widen (midOut C mlp.gate.width mlp.up.width (decide (mlp.gate.width ≠ mlp.up.width)) X Gc Gs Uc Us r) =
        mlp.intermediate (Blocks.packed input) r ∧
      Model.isFinite (midOut C mlp.gate.width mlp.up.width (decide (mlp.gate.width ≠ mlp.up.width)) X Gc Gs Uc Us r) =
        true := by
  have hgf := tail_gateFinite hf.tail ⟨r, hr⟩
  have huf := tail_upFinite hf.tail ⟨r, hr⟩
  unfold midOut
  rw [rowSum_eq C mlp.gatePlatform mlp.gate input Gc Gs X hd.gate hd.x hred r hr hgf,
    rowSum_eq C mlp.gatePlatform mlp.up input Uc Us X hd.up hd.x hred r hr huf]
  have hg := TrellisCodebookGateUp.raw_finite _ _ _ _ hgf
  have hu := TrellisCodebookGateUp.raw_finite _ _ _ _ huf
  have ht := hf.tail
  unfold GateDown.intermediate
  unfold Host.Mlx.trellisActivation at hact
  by_cases hw : mlp.gate.width ≠ mlp.up.width
  · rw [ite_eq_left hw] at hact
    rw [hact] at ht ⊢
    have hs : TrellisMlp.SplitFinite mlp.gatePlatform mlp.gate mlp.up (Blocks.packed input) C.fastExpAbs := ht
    have hp := hs.products ⟨r, hr⟩
    rw [decide_eq_true hw, tail_split C _ _ hg hu hp]
    exact ⟨rfl, GateUpSplitTail.output_finite _ _ _ hp⟩
  · rw [ite_eq_right hw] at hact
    rw [hact] at ht ⊢
    have hs : TrellisMlp.FloatFinite mlp.gatePlatform mlp.gate mlp.up (Blocks.packed input) C.expNeg := ht
    rw [decide_eq_false hw]
    exact tail_float C _ _ hg hu (hs.gateCast ⟨r, hr⟩) (hs.upCast ⟨r, hr⟩) (hs.tail ⟨r, hr⟩)

/-- The same as the model's bf16 `mid` row `midValue`. -/
theorem mid_value (mlp : GateDown) (input : Fin 5120 → BF) (X Gc Gs Uc Us : ByteMemory.Bytes)
    (hd : GateUpDecodes mlp input X Gc Gs Uc Us) (hred : mlp.gatePlatform.reduce = C.simdSum)
    (hact : mlp.activation = Host.Mlx.trellisActivation C mlp.gate.width mlp.up.width)
    (hf : TrellisMlp.Finite mlp (Blocks.packed input)) (r : Nat) (hr : r < 17408) :
    midOut C mlp.gate.width mlp.up.width (decide (mlp.gate.width ≠ mlp.up.width)) X Gc Gs Uc Us r = midValue mlp input r := by
  obtain ⟨h, hfin⟩ := mid_eq C mlp input X Gc Gs Uc Us hd hred hact hf r hr
  unfold midValue
  rw [← h, narrow_widen _ hfin]

end GateUp

/-! ## down-partial: `partial` is the model's first sum stage -/

section DownPartial
open Metal.Kernels.DownPartial (accSplit partialVal xr dbase)
open Metal.Kernels.Trellis

variable {code sc inp : Nat → Float32}

/-- The model's split expression after its first `n` rows. -/
def splitPre (split n : Nat) : DotProduct.Expr :=
  DownCodebook.scalarRows (fun row acc => .fma row acc) (split * 136) n .zero

theorem accSplit_eq (C : M1Max.Contract) (K : Nat) (il : Bool) (Codes S X : ByteMemory.Bytes) (split col : Nat)
    (hcode : ∀ n < 136, Metal.Kernels.DownPartial.code C K il Codes (136 * split + n) col = code (split * 136 + n))
    (hscale : ∀ n < 136, scale S (136 * split + n) = sc (split * 136 + n))
    (hx : ∀ n < 136, xr C X (136 * split + n) = inp (split * 136 + n)) :
    ∀ n ≤ 136, DotFinite code sc inp (splitPre split n) → accSplit C K il Codes S X split col n = DotEval code sc inp (splitPre split n)
  | 0, _, _ => General.ofF32Bits_zero
  | n + 1, hn, hf => by
    have hpre : splitPre split (n + 1) = .fma (split * 136 + n) (splitPre split n) := scalarRows_succ _ _ _ _
    rw [hpre] at hf ⊢
    exact fma_step C (by rw [hcode n (by omega), hscale n (by omega)]) (hx n (by omega))
      (accSplit_eq C K il Codes S X split col hcode hscale hx n (by omega) hf.1) hf

theorem fadd_eval (C : M1Max.Contract) {a b : DotProduct.Expr} {x y : Float32} (hx : x = DotEval code sc inp a)
    (hy : y = DotEval code sc inp b) (hf : DotFinite code sc inp (.add a b)) : C.fadd x y = DotEval code sc inp (.add a b) := by
  rw [hx, hy]
  exact C.fadd_model _ _ (FlushedDotProduct.finite_evaluate _ _ _ _ hf.1) (FlushedDotProduct.finite_evaluate _ _ _ _ hf.2.1)

theorem partialExpr_eq (y : Nat) : DownFlushToZero.partialExpr y =
    .add (splitPre (y + 96) 136) (.add (splitPre (y + 64) 136) (.add (splitPre (y + 32) 136)
      (.add (splitPre y 136) .zero))) := rfl

theorem projection_partials : ∀ (t : Reduction.Tree 32), DotFinite code sc inp (DownFlushToZero.projectionExpr t) →
    ∀ l ∈ Reduction.leaves t, DotFinite code sc inp (DownFlushToZero.partialExpr l.val)
  | .leaf i, h, l, hl => by rw [show l = i from List.mem_singleton.mp hl]; exact h
  | .add a b, h, l, hl => (List.mem_append.mp hl).elim (projection_partials a h.1 l) (projection_partials b h.2.1 l)

/-- **`partial[y][col]` is the model's first sum stage `DownFlushToZero.partialSum`** of the down projection on
the input `h` (the widened `x` words), for decoded codes and scales, when the model's partial expression is finite. -/
theorem partialVal_eq (C : M1Max.Contract) (d : TrellisCodebookDown.Projection) (h : Nat → Float32)
    (Codes S X : ByteMemory.Bytes) (hdn : DownDecodes d Codes S) (hx : ∀ r < 17408, xr C X r = h r) (y col : Nat)
    (hy : y < 32) (hc : col < 5120)
    (hf : DotFinite (fun row => DownExecution.coefficient d.words d.width row col) d.scale h (DownFlushToZero.partialExpr y)) :
    partialVal C d.width (decide (d.width = 3)) Codes S X y col = DownFlushToZero.partialSum d.words d.width d.scale h y col := by
  rw [← DownFlushToZero.evaluate_partial]
  have hs : ∀ split < 128, DotFinite (fun row => DownExecution.coefficient d.words d.width row col) d.scale h (splitPre split 136) →
      accSplit C d.width (decide (d.width = 3)) Codes S X split col 136 =
        DotEval (fun row => DownExecution.coefficient d.words d.width row col) d.scale h (splitPre split 136) :=
    fun split hsp hfs => accSplit_eq C d.width _ Codes S X split col
      (fun n hn => by
        rw [show 136 * split + n = split * 136 + n by ring]
        exact code_eq C d.validWidth d.words Codes _ _ col
          (fun i hi => hdn.words _ (by omega) _ (by omega) i hi))
      (fun n hn => by rw [show 136 * split + n = split * 136 + n by ring, hdn.scale _ (by omega)])
      (fun n hn => by rw [show 136 * split + n = split * 136 + n by ring]; exact hx _ (by omega)) 136 le_rfl hfs
  rw [partialExpr_eq] at hf ⊢
  unfold partialVal
  exact fadd_eval C (hs _ (by omega) hf.1) (fadd_eval C (hs _ (by omega) hf.2.1.1)
    (fadd_eval C (hs _ (by omega) hf.2.1.2.1.1) (fadd_eval C (hs _ (by omega) hf.2.1.2.1.2.1.1) General.ofF32Bits_zero
      hf.2.1.2.1.2.1) hf.2.1.2.1) hf.2.1) hf

end DownPartial

/-! ## The launches' outputs as the model's values -/

section Bytes
open Metal.Kernels.Trellis

/-- The bytes of `mid` [1, 17408] bf16 holding the model's `midValue`. -/
noncomputable def midBytes (mlp : GateDown) (input : Fin 5120 → BF) (b : Nat) : BitVec 8 :=
  if b < 34816 then (wordBytes 2 (Val.bf16Bits (midValue mlp input (b / 2)))).getD (b % 2) 0 else 0

/-- The bytes of `partial` [1, 32, 5120] f32 holding `f y col` at row `y`, column `col`. -/
def partBytes (f : Nat → Nat → Float32) (b : Nat) : BitVec 8 :=
  if b < 655360 then (wordBytes 4 (Val.f32Bits (f (b / 4 / 5120) (b / 4 % 5120)))).getD (b % 4) 0 else 0

/-- The model's first down sum stage (`DownFlushToZero.partialSum` on the intermediate activation). -/
noncomputable def partialModel (mlp : GateDown) (input : Fin 5120 → BF) (y col : Nat) : Float32 :=
  DownFlushToZero.partialSum mlp.down.words mlp.down.width mlp.down.scale (mlp.intermediate (Blocks.packed input)) y col

/-- Two bytes holding a bf16 word's little-endian bytes are that word as `half` reads it. -/
theorem half_bytes (B : ByteMemory.Bytes) (n : Nat) (m : BF)
    (h : ∀ k < 2, B (2 * n + k) = (wordBytes 2 (Val.bf16Bits m)).getD k 0) : half B n = Val.bf16Bits m := by
  have hb : Val.bf16Bits m < 2 ^ 16 := m.bits.isLt
  have h0 := h 0 (by decide)
  have h1 := h 1 (by decide)
  unfold half cells
  rw [show List.range 2 = [0, 1] from rfl]
  simp only [List.map_cons, List.map_nil, bytesWord, List.foldr_cons, List.foldr_nil]
  rw [h0, h1]
  simp only [wordBytes, show List.range 2 = [0, 1] from rfl, List.map_cons, List.map_nil, List.getD_cons_zero,
    List.getD_cons_succ, BitVec.toNat_ofNat, pow_zero, pow_one, Nat.div_one]
  omega

theorem half_midBytes (mlp : GateDown) (input : Fin 5120 → BF) (r : Nat) (hr : r < 17408) :
    half (midBytes mlp input) r = Val.bf16Bits (midValue mlp input r) := by
  refine half_bytes _ _ _ fun k hk => ?_
  unfold midBytes
  rw [ite_eq_left (by omega), show (2 * r + k) / 2 = r by omega, show (2 * r + k) % 2 = k by omega]

/-- The route rebinds `mid` from its value: the row-major storage of the read-back bytes is the bytes. -/
theorem halfArray_storage (M : ByteMemory.Bytes) (shape : List Nat) (b : Nat) :
    (Host.Mlx.halfArray M 0 shape).storageByte b = M b := by
  have hv : ∀ i, (HalfMemory.load M (0 + 2 * i)).toNat = (M (2 * i)).toNat + 256 * (M (2 * i + 1)).toNat := by
    intro i
    unfold HalfMemory.load
    rw [Nat.zero_add, BitVec.toNat_append, Nat.shiftLeft_eq, Nat.mul_comm,
      ← Nat.two_pow_add_eq_or_of_lt (M (2 * i + 0)).isLt]
    simp only [Nat.add_zero]
    omega
  unfold Host.Mlx.Value.storageByte Host.Mlx.halfArray
  simp only [Host.Mlx.Dtype.bytes]
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_ofNat]
  rcases Nat.even_or_odd' b with ⟨i, rfl | rfl⟩
  · rw [show 2 * i / 2 = i by omega, show 2 * i % 2 = 0 by omega, hv, pow_zero, Nat.div_one]
    have := (M (2 * i)).isLt
    have := (M (2 * i + 1)).isLt
    omega
  · rw [show (2 * i + 1) / 2 = i by omega, show (2 * i + 1) % 2 = 1 by omega, hv, pow_one]
    have := (M (2 * i)).isLt
    have := (M (2 * i + 1)).isLt
    omega

end Bytes

/-! ## The down fold: `out` is the model's MLP output -/

section Fold
open Metal.Kernels.Trellis

/-- Column `c` of the fold, on `partial` bytes holding the model's first sum stage, is the model's output
`TrellisCodebookDown.value` (the platform reducing with `C.simdSum`; the output finite, `TrellisCodebookDown.Finite`'s
`narrowing`). -/
theorem outValue_eq (C : M1Max.Contract) (platform : TrellisCodebookDown.Platform) (d : TrellisCodebookDown.Projection)
    (h : Nat → Float32) (hred : platform.reduce = C.simdSum) (hf : TrellisCodebookDown.Finite platform d h) (c : Fin 5120) :
    Metal.Kernels.DownFold.outValue C (partBytes (DownFlushToZero.partialSum d.words d.width d.scale h)) c.val =
      TrellisCodebookDown.value platform d h c := by
  rw [Metal.Bridge.DownFold.outValue_eq]
  have hr : (fun l : Fin 32 => FloatMemory.decode (ByteMemory.load32
      (partBytes (DownFlushToZero.partialSum d.words d.width d.scale h)) (4 * (l.val * 5120 + c.val)))) =
      fun l => DownFlushToZero.partialSum d.words d.width d.scale h l.val c.val := by
    funext l
    have hl := l.isLt
    have hc := c.isLt
    refine General.word_readback _ _ _ fun k hk => ?_
    unfold partBytes
    rw [ite_eq_left (by omega), show (4 * (l.val * 5120 + c.val) + k) / 4 / 5120 = l.val by omega,
      show (4 * (l.val * 5120 + c.val) + k) / 4 % 5120 = c.val by omega,
      show (4 * (l.val * 5120 + c.val) + k) % 4 = k by omega]
  rw [hr, ← hred]
  exact C.narrow_model _ (General.finite_of_narrow _ (hf.narrowing c))

end Fold

/-! ## The route's widths and texts -/

section Route

/-- The route's gate and up widths (`Host.Load.Run.Full.Expected.stages`): equal at 2, 3, 4 (TAIL = 0), and the mixed
pairs (3, 2), (2, 3), (4, 3), (3, 4) (TAIL = 1), the pairs `GateUp.compile_*` cover. -/
def RouteGateUp (kg ku : Nat) : Prop :=
  (kg = 2 ∧ ku = 2) ∨ (kg = 3 ∧ ku = 3) ∨ (kg = 4 ∧ ku = 4) ∨ (kg = 3 ∧ ku = 2) ∨ (kg = 2 ∧ ku = 3) ∨
    (kg = 4 ∧ ku = 3) ∨ (kg = 3 ∧ ku = 4)

theorem gateUp_compiles {kg ku : Nat} (h : RouteGateUp kg ku) :
    (frontend (Metal.Kernels.GateUp.text kg ku)).bind elaborate =
      some (Metal.Kernels.GateUp.core kg ku (decide (kg ≠ ku))) := by
  rcases h with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
  · exact Metal.Kernels.GateUp.compile_2_2
  · exact Metal.Kernels.GateUp.compile_3_3
  · exact Metal.Kernels.GateUp.compile_4_4
  · exact Metal.Kernels.GateUp.compile_3_2
  · exact Metal.Kernels.GateUp.compile_2_3
  · exact Metal.Kernels.GateUp.compile_4_3
  · exact Metal.Kernels.GateUp.compile_3_4

theorem width_of {K : Nat} (h : K = 2 ∨ K = 3 ∨ K = 4) : Metal.Kernels.GateUp.Width K := Or.inr h

/-- The route's down layouts: 2 and 4 bits row-major, 3 bits shifted and interleaved (`downConfig`). -/
theorem down_compiles {K : Nat} (h : K = 2 ∨ K = 3 ∨ K = 4) :
    ∃ sf, Metal.Kernels.DownPartial.Geo K sf (decide (K = 3)) ∧
      (frontend (Metal.Kernels.DownPartial.text K)).bind elaborate =
        some (Metal.Kernels.DownPartial.core K sf (decide (K = 3))) := by
  rcases h with rfl | rfl | rfl
  · exact ⟨false, Metal.Kernels.DownPartial.geo_2, Metal.Kernels.DownPartial.compile_2⟩
  · exact ⟨true, Metal.Kernels.DownPartial.geo_3, Metal.Kernels.DownPartial.compile_3⟩
  · exact ⟨false, Metal.Kernels.DownPartial.geo_4, Metal.Kernels.DownPartial.compile_4⟩

end Route

/-! ## The GPU runs the model -/

section Gpu
open Metal.Kernels.Trellis
variable {C : M1Max.Contract}

/-- **Under the GPU assumption, the gate-up launch writes the model's `mid`**: the bytes of `midValue` (the bf16
values whose widenings are `mlp.intermediate`), for buffers decoding to the model (`GateUpDecodes`) at the route's
widths. -/
theorem gpu_gateUp (G : Gpu C) (mlp : GateDown) (input : Fin 5120 → BF) (X Gc Gs Uc Us : ByteMemory.Bytes)
    (ax ag as au aus : Nat) (hroute : RouteGateUp mlp.gate.width mlp.up.width)
    (hmax : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width)) (hax : 16 ∣ ax) (hag : 4 ∣ ag)
    (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) (hd : GateUpDecodes mlp input X Gc Gs Uc Us)
    (hred : mlp.gatePlatform.reduce = C.simdSum)
    (hact : mlp.activation = Host.Mlx.trellisActivation C mlp.gate.width mlp.up.width)
    (hf : TrellisMlp.Finite mlp (Blocks.packed input)) :
    G.execute (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width) (1024, 160, 1) (1024, 1, 1)
      [⟨.device, 10240, ax, X⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.gate.width, ag, Gc⟩,
        ⟨.device, 34816, as, Gs⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.up.width, au, Uc⟩,
        ⟨.device, 34816, aus, Us⟩] [34816] = some [midBytes mlp input] := by
  rw [Metal.Kernels.GateUp.gpu_output_of C _ _ _ (width_of mlp.gate.validWidth) (width_of mlp.up.validWidth) _
    (gateUp_compiles hroute) G hmax X Gc Gs Uc Us ax ag as au aus hax hag has hau haus]
  congr 2
  funext b
  unfold Metal.Kernels.GateUp.expected midBytes
  by_cases hb : b < 34816
  · rw [ite_eq_left hb, ite_eq_left hb, mid_value C mlp input X Gc Gs Uc Us hd hred hact hf (b / 2) (by omega)]
  · rw [ite_eq_right hb, ite_eq_right hb]

/-- **Under the GPU assumption, the down-partial launch writes the model's first sum stage** of the down projection
`d` on any input `h` that the bf16 words of `x` widen to, for decoded codes and scales, at the route's layouts. -/
theorem gpu_downPartial (G : Gpu C) (platform : TrellisCodebookDown.Platform) (d : TrellisCodebookDown.Projection)
    (h : Nat → Float32) (M Dc Ds : ByteMemory.Bytes) (am ac ads : Nat)
    (hmax : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text d.width)) (ham : 2 ∣ am) (hac : 4 ∣ ac) (hads : 2 ∣ ads)
    (hM : ∀ r < 17408, C.widen (Val.ofBf16Bits (half M r)) = h r) (hdn : DownDecodes d Dc Ds)
    (hf : TrellisCodebookDown.Finite platform d h) :
    G.execute (Metal.Kernels.DownPartial.text d.width) (256, 160, 1) (256, 1, 1)
      [⟨.device, 34816, am, M⟩, ⟨.device, Metal.Kernels.DownPartial.codesBytes d.width, ac, Dc⟩,
        ⟨.device, 34816, ads, Ds⟩] [655360] =
      some [partBytes (DownFlushToZero.partialSum d.words d.width d.scale h)] := by
  obtain ⟨sf, hG, hc⟩ := down_compiles d.validWidth
  rw [Metal.Kernels.DownPartial.gpu_output_of C _ _ _ hG _ hc G hmax M Dc Ds am ac ads ham hac hads]
  have he : Metal.Kernels.DownPartial.expected C d.width (decide (d.width = 3)) M Dc Ds =
      partBytes (DownFlushToZero.partialSum d.words d.width d.scale h) := by
    funext b
    unfold Metal.Kernels.DownPartial.expected partBytes
    by_cases hb : b < 655360
    · rw [ite_eq_left hb, ite_eq_left hb]
      have hcol : b / 4 % 5120 < 5120 := Nat.mod_lt _ (by decide)
      have hfin := projection_partials _ (hf.reduction ⟨b / 4 % 5120, hcol⟩) ⟨b / 4 / 5120, by omega⟩
        (platform.reduction.coverage.mem_iff.mpr (List.mem_finRange _))
      rw [partialVal_eq C d h Dc Ds M hdn hM _ _ (by omega) hcol hfin]
    · rw [ite_eq_right hb, ite_eq_right hb]
  rw [he]

/-- **Under the GPU assumption, the fold launch writes the model's output** `TrellisCodebookDown.value` on `partial`
bytes holding the model's first sum stage. -/
theorem gpu_downFold (G : Gpu C) (hmax : 256 ≤ G.maxThreads Metal.Elab.Tests.downFoldText)
    (platform : TrellisCodebookDown.Platform) (d : TrellisCodebookDown.Projection) (h : Nat → Float32)
    (hred : platform.reduce = C.simdSum) (hf : TrellisCodebookDown.Finite platform d h) :
    G.execute Metal.Elab.Tests.downFoldText (40960, 1, 1) (256, 1, 1)
      [⟨.device, 655360, 16, partBytes (DownFlushToZero.partialSum d.words d.width d.scale h)⟩] [10240] =
      some [Metal.Bridge.DownFold.foldBytes (TrellisCodebookDown.value platform d h)] := by
  rw [Metal.Kernels.DownFold.gpu_output C G hmax]
  congr 2
  funext b
  unfold Metal.Kernels.DownFold.expected Metal.Bridge.DownFold.foldBytes
  by_cases hb : b < 10240
  · rw [ite_eq_left hb, dite_eq_left hb, outValue_eq C platform d h hred hf ⟨b / 2, by omega⟩]
  · rw [ite_eq_right hb, dite_eq_right hb]

/-- **The three launches compose to the model's MLP**: gate-up on (x, gate codes and scales, up codes and scales)
writes `midBytes` (the model's bf16 `mid`); down-partial on (`mid`, down codes and scales) writes the model's first
sum stage; the fold on it writes `foldBytes (mlp.forward (Blocks.packed input))`. Hypotheses: the route's widths, the
pipelines' thread limits, the buffers' alignments, buffers decoding to the model (`GateUpDecodes`, `DownDecodes`), the
platform equalities of `KernelContract.trellis` (both reductions `C.simdSum`, `trellisActivation`), and the model's
finiteness `TrellisMlp.Finite` (`TrellisMlpRanges.finite`). -/
theorem gpu_model (G : Gpu C) (mlp : GateDown) (input : Fin 5120 → BF) (X Gc Gs Uc Us Dc Ds : ByteMemory.Bytes)
    (ax ag as au aus am ac ads : Nat) (hroute : RouteGateUp mlp.gate.width mlp.up.width)
    (hmax1 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width))
    (hmax2 : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text mlp.down.width))
    (hmax3 : 256 ≤ G.maxThreads Metal.Elab.Tests.downFoldText)
    (hax : 16 ∣ ax) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) (ham : 2 ∣ am) (hac : 4 ∣ ac)
    (hads : 2 ∣ ads) (hd : GateUpDecodes mlp input X Gc Gs Uc Us) (hdn : DownDecodes mlp.down Dc Ds)
    (gateReduce : mlp.gatePlatform.reduce = C.simdSum) (downReduce : mlp.downPlatform.reduce = C.simdSum)
    (activation : mlp.activation = Host.Mlx.trellisActivation C mlp.gate.width mlp.up.width)
    (hf : TrellisMlp.Finite mlp (Blocks.packed input)) :
    G.execute (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width) (1024, 160, 1) (1024, 1, 1)
        [⟨.device, 10240, ax, X⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.gate.width, ag, Gc⟩,
          ⟨.device, 34816, as, Gs⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.up.width, au, Uc⟩,
          ⟨.device, 34816, aus, Us⟩] [34816] = some [midBytes mlp input] ∧
      G.execute (Metal.Kernels.DownPartial.text mlp.down.width) (256, 160, 1) (256, 1, 1)
        [⟨.device, 34816, am, midBytes mlp input⟩, ⟨.device, Metal.Kernels.DownPartial.codesBytes mlp.down.width, ac, Dc⟩,
          ⟨.device, 34816, ads, Ds⟩] [655360] = some [partBytes (partialModel mlp input)] ∧
      G.execute Metal.Elab.Tests.downFoldText (40960, 1, 1) (256, 1, 1)
        [⟨.device, 655360, 16, partBytes (partialModel mlp input)⟩] [10240] =
          some [Metal.Bridge.DownFold.foldBytes (mlp.forward (Blocks.packed input))] := by
  have hM : ∀ r < 17408, C.widen (Val.ofBf16Bits (half (midBytes mlp input) r)) = mlp.intermediate (Blocks.packed input) r := by
    intro r hr
    obtain ⟨he, hfin⟩ := mid_eq C mlp input X Gc Gs Uc Us hd gateReduce activation hf r hr
    rw [half_midBytes mlp input r hr, ofBf16Bits_bf16Bits, ← mid_value C mlp input X Gc Gs Uc Us hd gateReduce activation hf r hr,
      C.widen_model _ hfin, he]
  exact ⟨gpu_gateUp G mlp input X Gc Gs Uc Us ax ag as au aus hroute hmax1 hax hag has hau haus hd gateReduce activation hf,
    gpu_downPartial G mlp.downPlatform mlp.down _ _ Dc Ds am ac ads hmax2 ham hac hads hM hdn hf.down,
    gpu_downFold G hmax3 mlp.downPlatform mlp.down _ downReduce hf.down⟩

end Gpu

/-! ## Readback and the route's values -/

section Values
open Metal.Kernels.Trellis Host.Mlx

/-- `mid` read back as the route reads it holds the model's bf16 `mid` row. -/
theorem mid_readback (mlp : GateDown) (input : Fin 5120 → BF) :
    Flat (halfArray (midBytes mlp input) 0 [1, 17408]) [1, 17408] (fun r : Fin 17408 => midValue mlp input r.val) := by
  refine ⟨rfl, rfl, fun j => ?_⟩
  change bf (HalfMemory.load (midBytes mlp input) (0 + 2 * j.val)).toNat = _
  rw [bf_toNat, Nat.zero_add]
  refine General.half_readback _ _ _ fun k hk => ?_
  unfold midBytes
  rw [ite_eq_left (by omega), show (2 * j.val + k) / 2 = j.val by omega, show (2 * j.val + k) % 2 = k by omega]

/-- `partial` read back as the route reads it holds the model's first sum stage. -/
theorem part_readback (f : Nat → Nat → Float32) :
    FlatF32 (wordArray .float32 (partBytes f) 0 [1, 32, 5120]) [1, 32, 5120]
      (fun i : Fin 163840 => f (i.val / 5120) (i.val % 5120)) := by
  refine ⟨rfl, rfl, fun i => ?_⟩
  change f32 (ByteMemory.load32 (partBytes f) (0 + 4 * i.val)).toNat = _
  rw [f32_toNat, Nat.zero_add]
  refine General.word_readback _ _ _ fun k hk => ?_
  have hi := i.isLt
  unfold partBytes
  rw [ite_eq_left (by omega), show (4 * i.val + k) / 4 / 5120 = i.val / 5120 by omega,
    show (4 * i.val + k) / 4 % 5120 = i.val % 5120 by omega, show (4 * i.val + k) % 4 = k by omega]

/-- **The readback in `GlueKernels.trellis_mlp`'s conclusion form**: `mid` has shape [1, 17408] and `out` is
`Flat [1, 5120] (mlp.forward (Blocks.packed input))`. -/
theorem readback (mlp : GateDown) (input : Fin 5120 → BF) :
    (halfArray (midBytes mlp input) 0 [1, 17408]).shape = [1, 17408] ∧
      Flat (halfArray (Metal.Bridge.DownFold.foldBytes (mlp.forward (Blocks.packed input))) 0 [1, 5120]) [1, 5120]
        (mlp.forward (Blocks.packed input)) :=
  ⟨rfl, Metal.Bridge.DownFold.readback _⟩

theorem ofNat8_byte (w : BitVec 32) (k : Nat) : BitVec.ofNat 8 (w.toNat / 256 ^ k) = ByteMemory.byte w k := by
  apply BitVec.eq_of_toNat_eq
  rw [BitVec.toNat_ofNat]
  unfold ByteMemory.byte
  rw [BitVec.extractLsb'_toNat, Nat.shiftRight_eq_div_pow, show (256 : Nat) ^ k = 2 ^ (8 * k) by rw [pow_mul]; norm_num]

/-- The route rebinds `partial` from its value: the row-major storage of the read-back words is the bytes. -/
theorem wordArray_storage (M : ByteMemory.Bytes) (shape : List Nat) (b : Nat) :
    (wordArray .float32 M 0 shape).storageByte b = M b := by
  unfold Value.storageByte wordArray
  simp only [Dtype.bytes]
  rw [ofNat8_byte, ByteMemory.byte_load32 _ _ _ (Nat.mod_lt _ (by decide)), Nat.zero_add,
    show 4 * (b / 4) + b % 4 = b by omega]

theorem storage_word32 (v : Value) (n : Nat) :
    word32 v.storageByte n = (v.storageByte (4 * n)).toNat + 256 * (v.storageByte (4 * n + 1)).toNat +
      65536 * (v.storageByte (4 * n + 2)).toNat + 16777216 * (v.storageByte (4 * n + 3)).toNat := by
  unfold word32 cells
  rw [show List.range 4 = [0, 1, 2, 3] from rfl]
  simp only [List.map_cons, List.map_nil, bytesWord, List.foldr_cons, List.foldr_nil, Nat.add_zero]
  ring

theorem gateWords_toNat (w : Nat) (valid : w = 2 ∨ w = 3 ∨ w = 4) (v : Value) (row blk i : Nat) (hr : row < 17408)
    (hb : blk < 20) (hi : i < 8 * w) :
    (CheckpointTrellis.gateWords w valid (codes w v) row blk i).toNat = word32 v.storageByte ((20 * row + blk) * (8 * w) + i) := by
  rw [CheckpointTrellis.gate_word w valid _ row blk i hr hb hi, TensorWords.readWord32_value, storage_word32]
  have : DownCodebook.rowMajor row blk i w = (20 * row + blk) * (8 * w) + i := by unfold DownCodebook.rowMajor; ring
  simp only [codes, this]

theorem downWords_toNat (w : Nat) (valid : w = 2 ∨ w = 3 ∨ w = 4) (v : Value) (row blk i : Nat) (hr : row < 17408)
    (hb : blk < 20) (hi : i < 8 * w) :
    (CheckpointTrellis.downWords w valid (codes w v) row blk i).toNat =
      word32 v.storageByte (Metal.Kernels.DownPartial.dbase w (decide (w = 3)) row blk + i) := by
  by_cases h3 : w = 3
  · subst h3
    have : Metal.Kernels.DownPartial.dbase 3 (decide (3 = 3)) row blk + i = DownCodebook.interleaved row blk i := by
      simp [Metal.Kernels.DownPartial.dbase, Metal.Kernels.DownPartial.wpb, Metal.Kernels.DownPartial.roww,
        DownCodebook.interleaved]
      ring
    rw [CheckpointTrellis.down_interleaved valid _ row blk i hr hb hi, TensorWords.readWord32_value, storage_word32, this]
    rfl
  · rw [CheckpointTrellis.down_row_major w valid h3 _ row blk i hr hb hi, TensorWords.readWord32_value, storage_word32]
    have : Metal.Kernels.DownPartial.dbase w (decide (w = 3)) row blk + i = DownCodebook.rowMajor row blk i w := by
      simp [Metal.Kernels.DownPartial.dbase, Metal.Kernels.DownPartial.wpb, Metal.Kernels.DownPartial.roww,
        DownCodebook.rowMajor, h3]
      ring
    simp only [codes, this]

theorem scale_storage (v : Value) (row : Nat) (hr : row < 17408) :
    CheckpointTrellis.scale (trellisScales v) row = scale v.storageByte row := by
  rw [CheckpointTrellis.scale_exact _ ⟨row, hr⟩]
  unfold scale TensorWords.readFloat16 TensorWords.readWord TensorWords.littleEndian16 Val.ofF16Bits half cells
  rw [show List.range 2 = [0, 1] from rfl]
  simp only [List.map_cons, List.map_nil, bytesWord, List.foldr_cons, List.foldr_nil, Nat.mul_zero, Nat.add_zero, trellisScales]

/-- **Buffers holding MLX's row-major bytes of `GlueKernels.trellis_mlp`'s values decode to the model**: `x`'s bf16
words are `input`'s, and the gate/up codes and scales are `CheckpointTrellis.gateUp`'s (`Trellis.gate`, `.up`). -/
theorem gateUp_decodes_of_values (mlp : GateDown) (input : Fin 5120 → BF) (x gc gs uc us dc ds : Value)
    (hw : Host.Mlx.Trellis mlp gc gs uc us dc ds) (hx : Flat x [1, 5120] input) :
    GateUpDecodes mlp input x.storageByte gc.storageByte gs.storageByte uc.storageByte us.storageByte where
  x c := by
    have h2 := General.storage2 x hx.1 c.val
    unfold half cells
    rw [h2, ← hx.2.2 c]
    exact (BitVec.toNat_ofNat (x.elems c.val) 16).symm
  gate :=
    have hwd : mlp.gate.words = CheckpointTrellis.gateWords mlp.gate.width mlp.gate.validWidth (codes _ gc) :=
      (congrArg TrellisCodebookGateUp.Projection.words hw.gate).symm
    have hsc : mlp.gate.scale = CheckpointTrellis.scale (trellisScales gs) :=
      (congrArg TrellisCodebookGateUp.Projection.scale hw.gate).symm
    ⟨fun row hr blk hb i hi => by rw [hwd]; exact gateWords_toNat _ _ gc row blk i hr hb hi,
      fun row hr => by rw [hsc]; exact scale_storage gs row hr⟩
  up :=
    have hwd : mlp.up.words = CheckpointTrellis.gateWords mlp.up.width mlp.up.validWidth (codes _ uc) :=
      (congrArg TrellisCodebookGateUp.Projection.words hw.up).symm
    have hsc : mlp.up.scale = CheckpointTrellis.scale (trellisScales us) :=
      (congrArg TrellisCodebookGateUp.Projection.scale hw.up).symm
    ⟨fun row hr blk hb i hi => by rw [hwd]; exact gateWords_toNat _ _ uc row blk i hr hb hi,
      fun row hr => by rw [hsc]; exact scale_storage us row hr⟩

/-- The down codes and scales the same way (`Trellis.down`, `CheckpointTrellis.downWords`' layouts). -/
theorem down_decodes_of_values (mlp : GateDown) (gc gs uc us dc ds : Value) (hw : Host.Mlx.Trellis mlp gc gs uc us dc ds) :
    DownDecodes mlp.down dc.storageByte ds.storageByte :=
  have hwd : mlp.down.words = CheckpointTrellis.downWords mlp.down.width mlp.down.validWidth (codes _ dc) :=
    (congrArg TrellisCodebookDown.Projection.words hw.down).symm
  have hsc : mlp.down.scale = CheckpointTrellis.scale (trellisScales ds) :=
    (congrArg TrellisCodebookDown.Projection.scale hw.down).symm
  ⟨fun row hr blk hb i hi => by rw [hwd]; exact downWords_toNat _ _ dc row blk i hr hb hi,
    fun row hr => by rw [hsc]; exact scale_storage ds row hr⟩

end Values

/-! ## The route: `KernelContract.trellis`'s launches on MLX's bytes of its values -/

section RouteValues
open Metal.Kernels.Trellis Host.Mlx
variable {C : M1Max.Contract}

/-- **Under the GPU assumption, the route's three Trellis launches, on MLX's row-major bytes of the values
`GlueKernels.trellis_mlp` receives (and of the values read back from each launch), produce the model's MLP**: `mid`
holds the model's bf16 activation (widening to `mlp.intermediate`), `partial` the model's first down sum stage, and
`out` is `Flat [1, 5120] (mlp.forward (Blocks.packed input))` with `mid.shape = [1, 17408]` (the consumer's form).
Hypotheses beyond `GlueKernels.trellis_mlp`'s: the route's gate and up widths, the pipelines' thread limits, the
buffers' alignments, and the model's finiteness `TrellisMlp.Finite` (`TrellisMlpRanges.finite`). -/
theorem gpu_route (G : Gpu C) (mlp : GateDown) (input : Fin 5120 → BF) (x gc gs uc us dc ds : Value)
    (ax ag as au aus am ac ads : Nat) (hroute : RouteGateUp mlp.gate.width mlp.up.width)
    (hmax1 : 1024 ≤ G.maxThreads (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width))
    (hmax2 : 256 ≤ G.maxThreads (Metal.Kernels.DownPartial.text mlp.down.width))
    (hmax3 : 256 ≤ G.maxThreads Metal.Elab.Tests.downFoldText)
    (hax : 16 ∣ ax) (hag : 4 ∣ ag) (has : 2 ∣ as) (hau : 4 ∣ au) (haus : 2 ∣ aus) (ham : 2 ∣ am) (hac : 4 ∣ ac)
    (hads : 2 ∣ ads) (gateReduce : mlp.gatePlatform.reduce = C.simdSum) (downReduce : mlp.downPlatform.reduce = C.simdSum)
    (activation : mlp.activation = trellisActivation C mlp.gate.width mlp.up.width)
    (weights : Trellis mlp gc gs uc us dc ds) (hx : Flat x [1, 5120] input)
    (hf : TrellisMlp.Finite mlp (Blocks.packed input)) :
    G.execute (Metal.Kernels.GateUp.text mlp.gate.width mlp.up.width) (1024, 160, 1) (1024, 1, 1)
        [⟨.device, 10240, ax, x.storageByte⟩, ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.gate.width, ag, gc.storageByte⟩,
          ⟨.device, 34816, as, gs.storageByte⟩,
          ⟨.device, Metal.Kernels.GateUp.codesBytes mlp.up.width, au, uc.storageByte⟩,
          ⟨.device, 34816, aus, us.storageByte⟩] [34816] = some [midBytes mlp input] ∧
      G.execute (Metal.Kernels.DownPartial.text mlp.down.width) (256, 160, 1) (256, 1, 1)
        [⟨.device, 34816, am, (halfArray (midBytes mlp input) 0 [1, 17408]).storageByte⟩,
          ⟨.device, Metal.Kernels.DownPartial.codesBytes mlp.down.width, ac, dc.storageByte⟩,
          ⟨.device, 34816, ads, ds.storageByte⟩] [655360] = some [partBytes (partialModel mlp input)] ∧
      G.execute Metal.Elab.Tests.downFoldText (40960, 1, 1) (256, 1, 1)
        [⟨.device, 655360, 16, (wordArray .float32 (partBytes (partialModel mlp input)) 0 [1, 32, 5120]).storageByte⟩]
        [10240] = some [Metal.Bridge.DownFold.foldBytes (mlp.forward (Blocks.packed input))] ∧
      Flat (halfArray (midBytes mlp input) 0 [1, 17408]) [1, 17408] (fun r : Fin 17408 => midValue mlp input r.val) ∧
      (∀ r : Fin 17408, BFloat16.widen (midValue mlp input r.val) = mlp.intermediate (Blocks.packed input) r.val) ∧
      FlatF32 (wordArray .float32 (partBytes (partialModel mlp input)) 0 [1, 32, 5120]) [1, 32, 5120]
        (fun i : Fin 163840 => partialModel mlp input (i.val / 5120) (i.val % 5120)) ∧
      (halfArray (midBytes mlp input) 0 [1, 17408]).shape = [1, 17408] ∧
      Flat (halfArray (Metal.Bridge.DownFold.foldBytes (mlp.forward (Blocks.packed input))) 0 [1, 5120]) [1, 5120]
        (mlp.forward (Blocks.packed input)) := by
  have hd := gateUp_decodes_of_values mlp input x gc gs uc us dc ds weights hx
  have hdn := down_decodes_of_values mlp gc gs uc us dc ds weights
  obtain ⟨h1, h2, h3⟩ := gpu_model G mlp input _ _ _ _ _ _ _ ax ag as au aus am ac ads hroute hmax1 hmax2 hmax3
    hax hag has hau haus ham hac hads hd hdn gateReduce downReduce activation hf
  have hs1 : (halfArray (midBytes mlp input) 0 [1, 17408]).storageByte = midBytes mlp input :=
    funext (halfArray_storage _ _)
  have hs2 : (wordArray .float32 (partBytes (partialModel mlp input)) 0 [1, 32, 5120]).storageByte =
      partBytes (partialModel mlp input) := funext (wordArray_storage _ _)
  rw [hs1, hs2]
  refine ⟨h1, h2, h3, mid_readback mlp input, fun r => ?_, part_readback _, (readback mlp input).1, (readback mlp input).2⟩
  obtain ⟨he, -⟩ := mid_eq C mlp input _ _ _ _ _ hd gateReduce activation hf r.val r.isLt
  rw [← mid_value C mlp input _ _ _ _ _ hd gateReduce activation hf r.val r.isLt, he]

end RouteValues

end Metal.Bridge.Trellis
