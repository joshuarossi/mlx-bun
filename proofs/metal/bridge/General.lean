import metal.Value
import contracts.mlx.Arithmetic
import contracts.mlx.ArithmeticFold
import FloatLib.Floats.Formats.IEEE754.Native.Model.Representation
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.LeanModel.AddSub
import host.mlx.GlueKernels
import contracts.mlx.NativeMultiplication
import contracts.mlx.NativeNormalizationDivision

namespace Metal.Bridge.General
open Metal Metal.Core Inference.Contracts.Mlx Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Float.Model (Format UnpackedFloat)

/-! # General lemmas for the bridges -/

/-! ## Sign flip, negation, subtraction, commutativity -/

theorem unpack_flip (b : BitVec 32) :
    UnpackedFloat.unpack Format.binary32 (b ^^^ 0x80000000#32) = (UnpackedFloat.unpack Format.binary32 b).neg := by
  have hm : UnpackedFloat.unpackMantissa (spec := Format.binary32) (b ^^^ 0x80000000#32) =
      UnpackedFloat.unpackMantissa (spec := Format.binary32) b := by
    simp only [UnpackedFloat.unpackMantissa, BitVec.extractLsb'_xor]
    have : (0x80000000#32).extractLsb' 0 Format.binary32.mantissaBitsWithoutImplicit = 0#_ := by decide
    rw [this, BitVec.xor_zero]
  have he : UnpackedFloat.unpackExponent (spec := Format.binary32) (b ^^^ 0x80000000#32) =
      UnpackedFloat.unpackExponent (spec := Format.binary32) b := by
    simp only [UnpackedFloat.unpackExponent, BitVec.extractLsb'_xor]
    have : (0x80000000#32).extractLsb' Format.binary32.mantissaBitsWithoutImplicit Format.binary32.exponentBits = 0#_ := by
      decide
    rw [this, BitVec.xor_zero]
  have hs : UnpackedFloat.Sign.ofBitVec (UnpackedFloat.unpackSign (spec := Format.binary32) (b ^^^ 0x80000000#32)) =
      -UnpackedFloat.Sign.ofBitVec (UnpackedFloat.unpackSign (spec := Format.binary32) b) := by
    simp only [UnpackedFloat.unpackSign, BitVec.extractLsb'_xor]
    generalize b.extractLsb' (Format.binary32.mantissaBitsWithoutImplicit + Format.binary32.exponentBits) 1 = s
    revert s
    decide
  simp only [UnpackedFloat.unpack, hm, he, hs]
  split_ifs <;> rfl

/-- `f32Neg` (the sign-bit flip the semantics uses for `-` and `a - b`) is Lean's binary32 negation. -/
theorem f32Neg_eq (y : Float32) : f32Neg y = -y := by
  have hb : BitVec.ofNat 32 ((FloatMemory.bits y).toNat ^^^ 0x80000000) = y.toModel.toBits.toBitVec ^^^ 0x80000000#32 := by
    apply BitVec.eq_of_toNat_eq
    rw [BitVec.toNat_ofNat, BitVec.toNat_xor]
    exact Nat.mod_eq_of_lt (Nat.xor_lt_two_pow (FloatMemory.bits y).isLt (by decide))
  change Float32.ofModel (Float32.Model.pack (UnpackedFloat.unpack Format.binary32
      (BitVec.ofNat 32 ((FloatMemory.bits y).toNat ^^^ 0x80000000)))) =
    Float32.ofModel (Float32.Model.pack y.toModel.unpack.neg)
  rw [hb, unpack_flip]
  rfl

theorem unpack_neg (y : Float32) : (-y).toModel.unpack = y.toModel.unpack.neg := by
  change UnpackedFloat.unpack Format.binary32 (UnpackedFloat.pack Format.binary32 y.toModel.unpack.neg) = _
  have h : y.toModel.unpack.neg = UnpackedFloat.unpack Format.binary32 (y.toModel.toBits.toBitVec ^^^ 0x80000000#32) :=
    (unpack_flip _).symm
  rw [h, Model.unpack_pack_unpack]

theorem neg_finite (y : Float32) : (-y).isFinite = y.isFinite := by
  change (-y).toModel.unpack.isFinite = y.toModel.unpack.isFinite
  rw [unpack_neg]
  cases y.toModel.unpack <;> rfl

theorem neg_zero (s : UnpackedFloat.Sign) :
    -(Float32.ofModel (Float32.Model.pack (.zero s))) = Float32.ofModel (Float32.Model.pack (.zero (-s))) := by
  cases s <;> decide

theorem flush_neg (y : Float32) : FlushToZero.flush (-y) = -(FlushToZero.flush y) := by
  unfold FlushToZero.flush
  rw [unpack_neg]
  cases y.toModel.unpack with
  | finite s m e hm =>
    simp only [UnpackedFloat.neg]
    split_ifs
    · exact (neg_zero s).symm
    · rfl
  | _ => rfl

theorem add_neg (a b : Float32) : a + -b = a - b := by
  change Float32.ofModel (Float32.Model.pack (UnpackedFloat.add Format.binary32 a.toModel.unpack (-b).toModel.unpack)) =
    Float32.ofModel (Float32.Model.pack (UnpackedFloat.sub Format.binary32 a.toModel.unpack b.toModel.unpack))
  rw [unpack_neg, Model.unpacked_sub_eq_add_neg]

/-- The semantics' `a - b` (`C.fadd a (f32Neg b)`) is the models' flushed subtraction on finite operands. -/
theorem fadd_f32Neg (C : M1Max.Contract) (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) :
    C.fadd x (f32Neg y) = Arithmetic.sub x y := by
  rw [C.fadd_model x _ hx (by rw [f32Neg_eq, neg_finite]; exact hy), f32Neg_eq]
  unfold FlushToZero.add Arithmetic.sub
  rw [flush_neg, add_neg]

theorem unpacked_add_comm (spec : Format) (a b : UnpackedFloat) :
    UnpackedFloat.add spec a b = UnpackedFloat.add spec b a := by
  cases a with
  | notANumber => cases b <;> rfl
  | infinity s =>
    cases b with
    | infinity t => cases s <;> cases t <;> rfl
    | _ => rfl
  | zero s =>
    cases b with
    | zero t => cases s <;> cases t <;> rfl
    | _ => rfl
  | finite s m e hm =>
    cases b with
    | finite t n f hn =>
      simp only [UnpackedFloat.add]
      rw [min_comm e f, Int.add_comm]
    | _ => rfl

theorem f32_add_comm (x y : Float32) : x + y = y + x := by
  change Float32.ofModel (Float32.Model.pack (UnpackedFloat.add Format.binary32 x.toModel.unpack y.toModel.unpack)) =
    Float32.ofModel (Float32.Model.pack (UnpackedFloat.add Format.binary32 y.toModel.unpack x.toModel.unpack))
  rw [unpacked_add_comm]

theorem add_comm (x y : Float32) : FlushToZero.add x y = FlushToZero.add y x := by
  unfold FlushToZero.add; rw [f32_add_comm]

/-! ## Widening and finiteness -/

/-- A bf16 value whose widening is finite is finite (the converse of `BFloat16.widen_finite`). -/
theorem finite_of_widen (x : BFloat16Arithmetic.Value) (h : (BFloat16.widen x).isFinite = true) :
    Model.isFinite x = true := by
  have hw : (BFloat16.widen x).isFinite = Model.isFinite (Model.cast FloatFormat.bfloat16 FloatFormat.binary32 x) := by
    change (Model.toFloat32Model (Model.cast _ _ x)).unpack.isFinite = _
    rw [Model.unpack_toFloat32Model, Model.isFinite_toModel (by decide)]
  rw [hw] at h
  by_cases hn : Model.isNaN x = true
  · rw [Model.cast_of_isNaN x hn,
      Model.isFinite_eq_false_of_isNaN (Model.isNaN_propagatedNaN FloatFormat.binary32 _ _ (by decide))] at h
    exact absurd h (by decide)
  · by_cases hi : Model.isInf x = true
    · unfold Model.cast at h
      split at h
      · exact absurd ‹_› hn
      · exfalso
        generalize Model.signBit x = s at h
        cases s <;> revert h <;> decide
    · exact Model.isFinite_eq_true_of_isNaN_eq_false_of_isInf_eq_false x
        (Bool.eq_false_of_not_eq_true hn) (Bool.eq_false_of_not_eq_true hi)

theorem widen_eq (C : M1Max.Contract) (x : BFloat16Arithmetic.Value) (h : (BFloat16.widen x).isFinite = true) :
    C.widen x = BFloat16.widen x := C.widen_model x (finite_of_widen x h)

/-- A binary32 value whose bf16 narrowing is finite is finite. -/
theorem finite_of_narrow (x : Float32) (h : Model.isFinite (BFloat16.narrow x) = true) : x.isFinite = true := by
  rw [← finite_model]
  unfold BFloat16.narrow at h
  by_cases hn : Model.isNaN (model x) = true
  · rw [Model.cast_of_isNaN _ hn,
      Model.isFinite_eq_false_of_isNaN (Model.isNaN_propagatedNaN FloatFormat.bfloat16 _ _ (by decide))] at h
    exact absurd h (by decide)
  · by_cases hi : Model.isInf (model x) = true
    · unfold Model.cast at h
      split at h
      · exact absurd ‹_› hn
      · exfalso
        generalize Model.signBit (model x) = s at h
        cases s <;> revert h <;> decide
    · exact Model.isFinite_eq_true_of_isNaN_eq_false_of_isInf_eq_false _
        (Bool.eq_false_of_not_eq_true hn) (Bool.eq_false_of_not_eq_true hi)

/-- A finite binary32 sum has finite operands. -/
theorem add_finite_factors (x y : Float32) (h : (x + y).isFinite = true) : x.isFinite = true ∧ y.isFinite = true := by
  have e : x + y = Float32.ofModel (Float32.Model.pack
      (Float.Model.UnpackedFloat.add Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack)) := rfl
  have hx' : x.isFinite = x.toModel.unpack.isFinite := rfl
  have hy' : y.isFinite = y.toModel.unpack.isFinite := rfl
  rw [e] at h
  rw [hx', hy']
  rcases hx : x.toModel.unpack with s | _ | s | ⟨s, m, ee, hm⟩ <;>
    rcases hy : y.toModel.unpack with t | _ | t | ⟨t, n, f, hn⟩ <;>
    rw [hx, hy] at h <;> simp only [Float.Model.UnpackedFloat.add] at h <;>
    first
    | exact ⟨rfl, rfl⟩
    | (exfalso; revert h; first | decide | (cases s <;> cases t <;> decide))

/-- A finite binary32 product has finite operands. -/
theorem mul_finite_factors (x y : Float32) (h : (x * y).isFinite = true) : x.isFinite = true ∧ y.isFinite = true := by
  have e : x * y = Float32.ofModel (Float32.Model.pack
      (Float.Model.UnpackedFloat.mul Float.Model.Format.binary32 x.toModel.unpack y.toModel.unpack)) := rfl
  have hx' : x.isFinite = x.toModel.unpack.isFinite := rfl
  have hy' : y.isFinite = y.toModel.unpack.isFinite := rfl
  rw [e] at h
  rw [hx', hy']
  rcases hx : x.toModel.unpack with s | _ | s | ⟨s, m, ee, hm⟩ <;>
    rcases hy : y.toModel.unpack with t | _ | t | ⟨t, n, f, hn⟩ <;>
    rw [hx, hy] at h <;> simp only [Float.Model.UnpackedFloat.mul] at h <;>
    first
    | exact ⟨rfl, rfl⟩
    | (exfalso; revert h; first | decide | (cases s <;> cases t <;> decide))

/-- A finite flushed product has finite operands (an underflowing exact product has finite operands too). -/
theorem ftz_mul_finite_factors (x y : Float32) (h : (FlushToZero.mul x y).isFinite = true) :
    x.isFinite = true ∧ y.isFinite = true := by
  unfold FlushToZero.mul FlushToZero.flushExact at h
  split at h
  · rename_i neg hu
    unfold FlushToZero.underflow at hu
    split at hu
    · rename_i n d e he
      unfold FlushToZero.mulExact at he
      split at he
      · rename_i a b ha hb
        have h1 := Model.isFinite_eq_true_of_toDyadic?_some ha
        have h2 := Model.isFinite_eq_true_of_toDyadic?_some hb
        rw [finite_model, FlushToZero.finite_flush_iff] at h1 h2
        exact ⟨h1, h2⟩
      · cases he
    · cases hu
  · have := mul_finite_factors _ _ h
    rw [FlushToZero.finite_flush_iff, FlushToZero.finite_flush_iff] at this
    exact this

/-- The operands of a finite `FlushedDotProduct` step: the code and scale of a finite flushed product. -/
theorem code_scale_finite {c s : Float32} (h : (FlushToZero.flush c * FlushToZero.flush s).isFinite = true) :
    c.isFinite = true ∧ s.isFinite = true := by
  have := mul_finite_factors _ _ h
  rw [FlushToZero.finite_flush_iff, FlushToZero.finite_flush_iff] at this
  exact this

theorem ofF32Bits_zero : Val.ofF32Bits 0 = (0 : Float32) := by decide

/-! ## Machine operations on the operands of a finite expression -/

section Ops
open ArithmeticFold
open Arithmetic (evaluate finite_evaluate)

theorem madd_finite {input : Nat → Float32} {c : Bool} {a b acc : Arithmetic.Expr} (h : Arithmetic.Finite input (madd c a b acc)) :
    Arithmetic.Finite input a ∧ Arithmetic.Finite input b ∧ Arithmetic.Finite input acc := by
  cases c
  · exact ⟨h.2.1.1, h.2.1.2.1, h.1⟩
  · exact ⟨h.1, h.2.1, h.2.2.1⟩

/-- A machine `acc + a * b` at a contraction site whose choice is `c` is the model's `madd c` on finite operands. -/
theorem madd_eq (C : M1Max.Contract) {fuse : Nat → Bool} {site : Nat} {c : Bool} (hs : fuse site = c)
    {input : Nat → Float32} {a b acc : Arithmetic.Expr} (hf : Arithmetic.Finite input (madd c a b acc)) :
    (if fuse site then C.fma (evaluate input a) (evaluate input b) (evaluate input acc)
      else C.fadd (evaluate input acc) (C.fmul (evaluate input a) (evaluate input b))) =
      evaluate input (madd c a b acc) := by
  rw [hs]
  cases c
  · obtain ⟨hacc, ⟨ha, hb, hm⟩, -⟩ := hf
    simp only [Bool.false_eq_true, ite_false, madd, evaluate]
    rw [C.fmul_model _ _ (finite_evaluate _ _ ha) (finite_evaluate _ _ hb),
      C.fadd_model _ _ (finite_evaluate _ _ hacc) (FlushToZero.mul_finite _ _ hm)]
  · obtain ⟨ha, hb, hacc, -⟩ := hf
    simp only [ite_true, madd, evaluate]
    rw [C.fma_model _ _ _ (finite_evaluate _ _ ha) (finite_evaluate _ _ hb) (finite_evaluate _ _ hacc)]

theorem mul_eq (C : M1Max.Contract) {input : Nat → Float32} {a b : Arithmetic.Expr} (hf : Arithmetic.Finite input (.mul a b)) :
    C.fmul (evaluate input a) (evaluate input b) = evaluate input (.mul a b) :=
  C.fmul_model _ _ (finite_evaluate _ _ hf.1) (finite_evaluate _ _ hf.2.1)

theorem add_eq (C : M1Max.Contract) {input : Nat → Float32} {a b : Arithmetic.Expr} (hf : Arithmetic.Finite input (.add a b)) :
    C.fadd (evaluate input a) (evaluate input b) = evaluate input (.add a b) :=
  C.fadd_model _ _ (finite_evaluate _ _ hf.1) (finite_evaluate _ _ hf.2.1)

theorem sub_eq (C : M1Max.Contract) {input : Nat → Float32} {a b : Arithmetic.Expr} (hf : Arithmetic.Finite input (.sub a b)) :
    C.fadd (evaluate input a) (f32Neg (evaluate input b)) = evaluate input (.sub a b) :=
  fadd_f32Neg C _ _ (finite_evaluate _ _ hf.1) (finite_evaluate _ _ hf.2.1)

theorem reduce_finite {input : Nat → Float32} {n : Nat} {lanes : Fin n → Arithmetic.Expr} :
    ∀ {t : Reduction.Tree n}, Arithmetic.Finite input (reduceExpr lanes t) → ∀ l ∈ Reduction.leaves t, Arithmetic.Finite input (lanes l)
  | .leaf i, h, l, hl => by
    rw [show l = i from List.mem_singleton.mp hl]; exact h
  | .add a b, h, l, hl => by
    rcases List.mem_append.mp hl with hl | hl
    · exact reduce_finite h.1 l hl
    · exact reduce_finite h.2.1 l hl

/-- Every lane of a covering reduction tree whose expression is finite is finite. -/
theorem lanes_finite {input : Nat → Float32} {lanes : Fin 32 → Arithmetic.Expr} {t : Reduction.Tree 32}
    (cover : (Reduction.leaves t).Perm (List.finRange 32)) (h : Arithmetic.Finite input (reduceExpr lanes t)) (l : Fin 32) :
    Arithmetic.Finite input (lanes l) :=
  reduce_finite h l (cover.mem_iff.mpr (List.mem_finRange l))

/-- `simd_sum` of the lanes' values is the reduction of the lanes' expressions along the tree of any reduction
contract `R` of `C.simdSum`. -/
theorem simdSum_tree {C : M1Max.Contract} (R : FlushedReduction.SimdContract C.simdSum) {input : Nat → Float32}
    {lanes : Fin 32 → Arithmetic.Expr} (v : Fin 32 → Float32) (hv : ∀ l, v l = evaluate input (lanes l)) :
    C.simdSum v = evaluate input (reduceExpr lanes R.tree) := by
  rw [evaluate_reduce, ← R.execution]
  exact congrArg C.simdSum (funext hv)

/-- `simd_sum` of the lanes' values is the reduction of the lanes' expressions. -/
theorem simdSum_eq (C : M1Max.Contract) {input : Nat → Float32} {lanes : Fin 32 → Arithmetic.Expr} (v : Fin 32 → Float32)
    (hv : ∀ l, v l = evaluate input (lanes l)) :
    C.simdSum v = evaluate input (reduceExpr lanes C.simdSum_tree.tree) :=
  simdSum_tree C.simdSum_tree v hv

end Ops

/-! ## Bytes: input storage and output readback

MLX binds each input as the row-major bytes of its value (`Host.Mlx.Value.storageByte`); the route reads
outputs back as `halfArray`/`wordArray` of the final bytes. -/

section Bytes
open Host.Mlx

theorem storage2 (v : Value) (hv : v.dtype = .bfloat16) (i : Nat) :
    bytesWord ((List.range 2).map fun k => v.storageByte (2 * i + k)) = v.elems i % 2 ^ 16 := by
  rw [show List.range 2 = [0, 1] from rfl]
  simp only [List.map_cons, List.map_nil, bytesWord, List.foldr_cons, List.foldr_nil, Value.storageByte, hv, Dtype.bytes,
    BitVec.toNat_ofNat]
  rw [show (2 * i + 0) / 2 = i by omega, show (2 * i + 1) / 2 = i by omega, show (2 * i + 0) % 2 = 0 by omega,
    show (2 * i + 1) % 2 = 1 by omega]
  simp only [pow_zero, pow_one, Nat.div_one]
  omega

theorem storage4 (v : Value) (hv : v.dtype.bytes = 4) (i : Nat) :
    bytesWord ((List.range 4).map fun k => v.storageByte (4 * i + k)) = v.elems i % 2 ^ 32 := by
  rw [show List.range 4 = [0, 1, 2, 3] from rfl]
  simp only [List.map_cons, List.map_nil, bytesWord, List.foldr_cons, List.foldr_nil, Value.storageByte, hv,
    BitVec.toNat_ofNat]
  rw [show (4 * i + 0) / 4 = i by omega, show (4 * i + 1) / 4 = i by omega, show (4 * i + 2) / 4 = i by omega,
    show (4 * i + 3) / 4 = i by omega, show (4 * i + 0) % 4 = 0 by omega, show (4 * i + 1) % 4 = 1 by omega,
    show (4 * i + 2) % 4 = 2 by omega, show (4 * i + 3) % 4 = 3 by omega]
  simp only [pow_zero, pow_one, Nat.div_one, show (256 : Nat) ^ 2 = 65536 by rfl, show (256 : Nat) ^ 3 = 16777216 by rfl]
  omega

theorem ofBf16Bits_mod (n : Nat) : Val.ofBf16Bits (n % 2 ^ 16) = bf n := by
  unfold Val.ofBf16Bits bf
  congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, Nat.mod_mod]

theorem ofF32Bits_mod (n : Nat) : Val.ofF32Bits (n % 2 ^ 32) = f32 n := by
  unfold Val.ofF32Bits f32
  congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [BitVec.toNat_ofNat, Nat.mod_mod]

theorem wordBytes2_byte (w k : Nat) (hk : k < 2) : (wordBytes 2 w).getD k 0 = HalfMemory.byte (BitVec.ofNat 16 w) k := by
  apply BitVec.eq_of_toNat_eq
  rcases (by omega : k = 0 ∨ k = 1) with rfl | rfl
  · simp [wordBytes, HalfMemory.byte, BitVec.extractLsb'_toNat]
  · simp [wordBytes, HalfMemory.byte, BitVec.extractLsb'_toNat, Nat.shiftRight_eq_div_pow]; omega

theorem wordBytes4_byte (w k : Nat) (hk : k < 4) : (wordBytes 4 w).getD k 0 = ByteMemory.byte (BitVec.ofNat 32 w) k := by
  apply BitVec.eq_of_toNat_eq
  rcases (by omega : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3) with rfl | rfl | rfl | rfl <;>
    simp [wordBytes, ByteMemory.byte, BitVec.extractLsb'_toNat, Nat.shiftRight_eq_div_pow] <;> omega

/-- Four bytes holding a word's little-endian bytes load as that word. -/
theorem load32_wordBytes (M : ByteMemory.Bytes) (e n : Nat) (h : ∀ k < 4, M (4 * e + k) = (wordBytes 4 n).getD k 0) :
    ByteMemory.load32 M (4 * e) = BitVec.ofNat 32 n := by
  unfold ByteMemory.load32
  rw [h 0 (by decide), h 1 (by decide), h 2 (by decide), h 3 (by decide), wordBytes4_byte _ _ (by decide),
    wordBytes4_byte _ _ (by decide), wordBytes4_byte _ _ (by decide), wordBytes4_byte _ _ (by decide),
    ByteMemory.join_bytes]

/-- The kernels' little-endian decoding of four bytes is the contracts' `FloatMemory.decode ∘ load32`. -/
theorem ofF32Bits_bytes (M : ByteMemory.Bytes) (a : Nat) :
    Val.ofF32Bits (bytesWord ((List.range 4).map fun i => M (a + i))) = FloatMemory.decode (ByteMemory.load32 M a) := by
  unfold Val.ofF32Bits
  congr 1
  rw [show (List.range 4).map (fun i => M (a + i)) = [M (a + 0), M (a + 1), M (a + 2), M (a + 3)] from rfl]
  rw [← ByteMemory.join_bytes (BitVec.ofNat 32 _)]
  unfold ByteMemory.load32
  have h : ∀ k < 4, ByteMemory.byte (BitVec.ofNat 32 (bytesWord [M (a + 0), M (a + 1), M (a + 2), M (a + 3)])) k =
      M (a + k) := by
    intro k hk
    rw [← wordBytes4_byte _ _ hk]
    apply BitVec.eq_of_toNat_eq
    have h0 := (M (a + 0)).isLt
    have h1 := (M (a + 1)).isLt
    have h2 := (M (a + 2)).isLt
    have h3 := (M (a + 3)).isLt
    rcases (by omega : k = 0 ∨ k = 1 ∨ k = 2 ∨ k = 3) with rfl | rfl | rfl | rfl <;>
      simp [wordBytes, bytesWord] <;> omega
  rw [h 0 (by decide), h 1 (by decide), h 2 (by decide), h 3 (by decide)]

/-- The bf16 value read back from bytes holding its little-endian word. -/
theorem half_readback (M : ByteMemory.Bytes) (e : Nat) (x : BF)
    (h : ∀ k < 2, M (2 * e + k) = (wordBytes 2 (Val.bf16Bits x)).getD k 0) :
    (Model.ofBits (HalfMemory.load M (2 * e)) : BF) = x := by
  have hb : BitVec.ofNat 16 (Val.bf16Bits x) = x.bits := by
    unfold Val.bf16Bits; rw [BitVec.ofNat_toNat]; exact BitVec.setWidth_eq (x.bits : BitVec 16)
  unfold HalfMemory.load
  rw [show 2 * e + 1 = 2 * e + 1 from rfl, h 1 (by decide), show 2 * e + 0 = 2 * e + 0 from rfl, h 0 (by decide),
    wordBytes2_byte _ _ (by decide), wordBytes2_byte _ _ (by decide), HalfMemory.join_bytes, hb]
  rfl

/-- The binary32 value read back from bytes holding its little-endian word. -/
theorem word_readback (M : ByteMemory.Bytes) (e : Nat) (x : Float32)
    (h : ∀ k < 4, M (4 * e + k) = (wordBytes 4 (Val.f32Bits x)).getD k 0) :
    FloatMemory.decode (ByteMemory.load32 M (4 * e)) = x := by
  have hb : BitVec.ofNat 32 (Val.f32Bits x) = FloatMemory.bits x := by
    unfold Val.f32Bits FloatMemory.bits; rw [BitVec.ofNat_toNat, BitVec.setWidth_eq]
  unfold ByteMemory.load32
  rw [h 0 (by decide), h 1 (by decide), h 2 (by decide), h 3 (by decide), wordBytes4_byte _ _ (by decide),
    wordBytes4_byte _ _ (by decide), wordBytes4_byte _ _ (by decide), wordBytes4_byte _ _ (by decide),
    ByteMemory.join_bytes, hb, FloatMemory.decode_bits]

end Bytes

/-! ## Multiplying by `2^-s` is dividing by `2^s`

The compiler folds MLX's `x / d` (`d` a power of two) to `x * (1/d)`; the models keep the division. With
flushed multiplication and division the two agree on every finite `x`: both flush the same exact value. -/

section Scale
open FlushToZero

/-- What `underflow` decides from an exact result's value alone. -/
noncomputable def canon (v : ℝ) : Option Bool := if v ≠ 0 ∧ |v| < threshold then some (decide (v < 0)) else none

theorem underflow_canon {e : Option (Int × Nat × Int)} {v : ℝ} (h : Exact e v) : underflow e = canon v := by
  match e, h with
  | none, h =>
    change v = 0 at h
    simp [underflow, canon, h]
  | some (n, d, x), ⟨hd, hv⟩ =>
    have hdpos : (0 : ℝ) < d := by exact_mod_cast hd
    have hq : (0 : ℝ) < (2 : ℝ) ^ x / d := div_pos (zpow_pos (by norm_num) x) hdpos
    have hv' : v = (n : ℝ) * ((2 : ℝ) ^ x / d) := by rw [← hv]; ring
    have hb := below_iff n d x hd
    rw [hv] at hb
    have hne : n ≠ 0 ↔ v ≠ 0 := by
      rw [hv']
      constructor
      · intro h; exact mul_ne_zero (by exact_mod_cast h) hq.ne'
      · intro h hn; apply h; rw [hn]; simp
    have hneg : decide (n < 0) = decide (v < 0) := by
      apply decide_eq_decide.mpr
      rw [hv']
      constructor
      · intro h; exact mul_neg_of_neg_of_pos (by exact_mod_cast h) hq
      · intro h; by_contra hn; replace hn := le_of_not_gt hn
        have : (0 : ℝ) ≤ (n : ℝ) * ((2 : ℝ) ^ x / d) := mul_nonneg (by exact_mod_cast hn) hq.le
        linarith
    show (if below n d x = true then some (decide (n < 0)) else none) =
      (if v ≠ 0 ∧ |v| < threshold then some (decide (v < 0)) else none)
    by_cases hbl : below n d x = true
    · obtain ⟨hn0, hlt⟩ := hb.mp hbl
      rw [ite_eq_left hbl, ite_eq_left ⟨hne.mp hn0, hlt⟩, hneg]
    · rw [ite_eq_right hbl]
      symm
      apply ite_eq_right
      rintro ⟨hv0, hlt⟩
      exact hbl (hb.mpr ⟨hne.mpr hv0, hlt⟩)

theorem underflow_congr {e₁ e₂ : Option (Int × Nat × Int)} {v : ℝ} (h₁ : Exact e₁ v) (h₂ : Exact e₂ v) :
    underflow e₁ = underflow e₂ := (underflow_canon h₁).trans (underflow_canon h₂).symm

theorem real_ne_zero_of_unpack {x : Float32} {s : UnpackedFloat.Sign} {m : Nat} {e : Int} {hm : 0 < m}
    (h : x.toModel.unpack = .finite s m e hm) : real x ≠ 0 := by
  rw [real_unpack, h, Model.unpackedToReal_finite]
  have hb : FloatLib.Floats.Formats.Flocq.bpow FloatLib.Numerics.binaryRadix e ≠ 0 :=
    FloatLib.Floats.Formats.Flocq.bpow.ne_zero _ e
  have hm' : (m : ℝ) ≠ 0 := by exact_mod_cast hm.ne'
  split <;> simp [hm', hb]

/-- Equal nonzero real values determine finite binary32 words. -/
theorem eq_of_real (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (h : real x = real y) (h0 : real x ≠ 0) : x = y := by
  have hm : model x = model y := Model.eq_of_toReal_eq_of_nonzero
    (by rw [finite_model]; exact hx) (by rw [finite_model]; exact hy) h h0
  have ht := Model.ofFloat32Model_injective hm
  cases x; cases y
  exact congrArg _ ht

theorem roundAt_ne_zero {v : ℝ} (hv : threshold ≤ |v|) : Model.roundAt FloatFormat.binary32 v ≠ 0 := by
  have hm : Model.roundAt FloatFormat.binary32 threshold = threshold := by
    rw [← real_minNormal]
    exact Model.roundAt_toReal_eq _ (by rw [finite_model]; decide)
  have ht := threshold_pos
  rcases le_or_gt 0 v with h | h
  · rw [abs_of_nonneg h] at hv
    have := Model.roundAt_mono FloatFormat.binary32 hv
    rw [hm] at this
    linarith
  · rw [abs_of_neg h] at hv
    have := Model.roundAt_mono FloatFormat.binary32 (show v ≤ -threshold by linarith)
    rw [Model.roundAt_neg, hm] at this
    linarith

theorem unpack_pos (z : Float32) (hz : z.isFinite = true) (hpos : 0 < real z) :
    ∃ m e hm, z.toModel.unpack = .finite .positive m e hm := by
  have hr := real_unpack z
  cases hu : z.toModel.unpack with
  | zero s => rw [hu, Model.unpackedToReal_zero] at hr; linarith
  | finite s m e hm =>
    cases s with
    | positive => exact ⟨m, e, hm, rfl⟩
    | negative =>
      rw [hu, Model.unpackedToReal_finite] at hr
      have hb := FloatLib.Floats.Formats.Flocq.bpow.pos FloatLib.Numerics.binaryRadix e
      have hm' : (0 : ℝ) < m := by exact_mod_cast hm
      simp only [Model.modelSignBit, ite_true] at hr
      nlinarith
  | notANumber => simp [Float32.isFinite, Float32.Model.isFinite, hu, UnpackedFloat.isFinite] at hz
  | infinity s => simp [Float32.isFinite, Float32.Model.isFinite, hu, UnpackedFloat.isFinite] at hz

/-- Flushed multiplication by `y` is flushed division by `z = 1/y` (`z ≥ 2`). -/
theorem mul_eq_div (x y z : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true) (hz : z.isFinite = true)
    (hfy : flush y = y) (hfz : flush z = z) (hyz : real y = (real z)⁻¹) (hz2 : 2 ≤ real z) :
    FlushToZero.mul x y = FlushToZero.div x z := by
  obtain ⟨my, ey, hmy, huy⟩ := unpack_pos y hy (by rw [hyz]; exact inv_pos.mpr (by linarith))
  obtain ⟨mz, ez, hmz, huz⟩ := unpack_pos z hz (by linarith)
  unfold FlushToZero.mul FlushToZero.div
  rw [hfy, hfz]
  have ha : (flush x).isFinite = true := finite_flush x hx
  have hv : real (flush x) * real y = real (flush x) / real z := by rw [hyz, div_eq_mul_inv]
  have hd := exact_div (model (flush x)) (model z)
  have hu := underflow_congr (exact_mul (model (flush x)) (model y)) (by
    change Exact _ (real (flush x) * real y); rw [hv]; exact hd)
  unfold flushExact
  rw [hu]
  split
  · rfl
  · rename_i hnone
    cases hua : (flush x).toModel.unpack with
    | zero s =>
      have h1 : (flush x * y).toModel = Float32.Model.pack (.zero (s * .positive)) := by
        change Float32.Model.pack (UnpackedFloat.mul _ (flush x).toModel.unpack y.toModel.unpack) = _
        rw [hua, huy]; rfl
      have h2 : (flush x / z).toModel = Float32.Model.pack (.zero (s / .positive)) := by
        change Float32.Model.pack (UnpackedFloat.div _ (flush x).toModel.unpack z.toModel.unpack) = _
        rw [hua, huz]; rfl
      have hs : s * UnpackedFloat.Sign.positive = s / UnpackedFloat.Sign.positive := by cases s <;> rfl
      have := congrArg Float32.ofModel (h1.trans ((congrArg (fun s => Float32.Model.pack (.zero s)) hs).trans h2.symm))
      exact this
    | finite s m e hm =>
      have hra : real (flush x) ≠ 0 := real_ne_zero_of_unpack hua
      have hc : canon (real (flush x) / real z) = none := (underflow_canon hd).symm.trans hnone
      have hzpos : 0 < real z := by linarith
      have hvne : real (flush x) / real z ≠ 0 := div_ne_zero hra hzpos.ne'
      have hge : threshold ≤ |real (flush x) / real z| := by
        unfold canon at hc
        by_contra hlt
        rw [ite_eq_left ⟨hvne, lt_of_not_ge hlt⟩] at hc
        cases hc
      have hdf : (flush x / z).isFinite = true := NativeNormalizationDivision.raw_finite x z hx hz hz2
      have hy1 : |real y| ≤ 1 := by
        rw [hyz, abs_inv, abs_of_pos hzpos]
        exact inv_le_one_of_one_le₀ (by linarith)
      have hmf : (flush x * y).isFinite = true := by
        rw [← finite_model, NativeMultiplication.float32_model _ _ ha hy]
        apply Model.isFinite_mul_of_abs_mul_le_posMaxFinite _ _ (by decide)
          (by rw [finite_model]; exact ha) (by rw [finite_model]; exact hy)
        have hb := Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model (flush x)) (by decide)
          (by rw [finite_model]; exact ha)
        calc |Model.toReal (model (flush x))| * |Model.toReal (model y)|
            ≤ |Model.toReal (model (flush x))| * 1 := mul_le_mul_of_nonneg_left hy1 (abs_nonneg _)
          _ ≤ _ := by rw [mul_one]; exact hb
      have hr1 := Numerics.mul_real (flush x) y hmf
      have hr2 := Numerics.div_real (flush x) z hz hdf
      apply eq_of_real _ _ hmf hdf (by rw [hr1, hr2, hv])
      rw [hr1, hv]
      exact roundAt_ne_zero hge
    | notANumber => simp [Float32.isFinite, Float32.Model.isFinite, hua, UnpackedFloat.isFinite] at ha
    | infinity s => simp [Float32.isFinite, Float32.Model.isFinite, hua, UnpackedFloat.isFinite] at ha

/-- The value of a positive normal power of two from its unpacked form. -/
theorem real_pow2 (x : Float32) (k : Nat) (h : x.toModel.unpack = .finite .positive 8388608 (-(23 + k : Int)) (by decide)) :
    real x = ((2 : ℝ) ^ k)⁻¹ := by
  rw [real_unpack, h, Model.unpackedToReal_finite]
  simp only [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow]
  simp only [Bool.false_eq_true, ite_false, one_mul]
  change (8388608 : ℝ) * (2 : ℝ) ^ (-(23 + k : Int)) = _
  rw [zpow_neg, show (23 + k : Int) = ((23 + k : Nat) : Int) by push_cast; ring, zpow_natCast, pow_add]
  norm_num
  field_simp

end Scale

/-! ## Folds -/

section Folds
open Arithmetic (evaluate)

/-- A fold of expressions whose steps keep their accumulator's finiteness starts finite. -/
theorem fold_finite_init {α : Type} {input : Nat → Float32} (estep : Arithmetic.Expr → α → Arithmetic.Expr)
    (hacc : ∀ e i, Arithmetic.Finite input (estep e i) → Arithmetic.Finite input e) :
    ∀ (l : List α) (e : Arithmetic.Expr), Arithmetic.Finite input (l.foldl estep e) → Arithmetic.Finite input e
  | [], _, h => h
  | i :: rest, e, h => hacc e i (fold_finite_init estep hacc rest (estep e i) h)

/-- A machine fold is the model's expression fold when every step agrees on finite operands. -/
theorem fold_eq {α : Type} {input : Nat → Float32} (mstep : Float32 → α → Float32)
    (estep : Arithmetic.Expr → α → Arithmetic.Expr)
    (hacc : ∀ e i, Arithmetic.Finite input (estep e i) → Arithmetic.Finite input e) :
    ∀ (l : List α) (a : Float32) (e : Arithmetic.Expr), a = evaluate input e →
      (∀ i ∈ l, ∀ (a' : Float32) (e' : Arithmetic.Expr), a' = evaluate input e' → Arithmetic.Finite input (estep e' i) →
        mstep a' i = evaluate input (estep e' i)) →
      Arithmetic.Finite input (l.foldl estep e) → l.foldl mstep a = evaluate input (l.foldl estep e)
  | [], _, _, he, _, _ => he
  | i :: rest, a, e, he, hstep, hf => by
    simp only [List.foldl_cons] at hf ⊢
    exact fold_eq mstep estep hacc rest (mstep a i) (estep e i)
      (hstep i (List.mem_cons_self ..) a e he (fold_finite_init estep hacc rest _ hf))
      (fun j hj => hstep j (List.mem_cons_of_mem _ hj)) hf

theorem finRange4 : List.finRange 4 = [0, 1, 2, 3] := by decide

theorem map_val_finRange (n : Nat) : (List.finRange n).map Fin.val = List.range n := by
  apply List.ext_getElem <;> simp

/-- A fold over `Fin n` that only uses the index's value is a fold over `range n`. -/
theorem foldl_finRange {β : Type} (n : Nat) (g : β → Nat → β) (b : β) :
    (List.finRange n).foldl (fun acc i => g acc i.val) b = (List.range n).foldl g b := by
  rw [← map_val_finRange, List.foldl_map]

theorem madd_acc_finite {input : Nat → Float32} (c : Bool) (a b : Arithmetic.Expr) (e : Arithmetic.Expr)
    (h : Arithmetic.Finite input (ArithmeticFold.madd c a b e)) : Arithmetic.Finite input e := (madd_finite h).2.2

end Folds

end Metal.Bridge.General
