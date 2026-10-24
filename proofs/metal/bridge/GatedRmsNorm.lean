import metal.kernels.GatedRmsNorm
import contracts.mlx.M1MaxCompositePlatforms
import contracts.mlx.FlushOrder
import contracts.mlx.NativeNormalizationDivision
import contracts.mlx.NativeMultiplication
import contracts.mlx.Float32Bounds
import contracts.mlx.Negation
import contracts.mlx.BFloat16Log1p
import kernels.StableSigmoidRanges
import host.mlx.Kernel
import host.mlx.GlueAttention
import metal.bridge.General

namespace Metal.Bridge
open Metal Metal.Core Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

/-! # Machine specs to model values: shared lemmas

Kernel-independent facts relating the M1 Max contract's operations, the core's value encodings and
the host's array views. Used by the three bridges (this file, `ResidualRmsNorm`, `SiluRmsHeads`). -/

/-! ## Binary32 negation, subtraction and flushing -/

/-- The core's `-x` (sign-bit flip of the word) is binary32 negation on finite values. -/
theorem f32Neg_eq (x : Float32) (hx : x.isFinite = true) : f32Neg x = -x := by
  rw [Negation.execution x hx, Model.neg_eq_toggleSign_of_supportsSignedZero _ (by decide)]
  unfold f32Neg Val.ofF32Bits Val.f32Bits FloatMemory.decode FloatMemory.bits
  change Float32.ofModel (Float32.Model.ofBits _) = Float32.ofModel (Float32.Model.pack _)
  congr 2
  congr 1
  apply BitVec.eq_of_toNat_eq
  change (x.toBits.toBitVec.toNat ^^^ 2147483648) % 2 ^ 32 = (x.toBits.toBitVec ^^^ 2147483648#32).toNat
  rw [BitVec.toNat_xor, Nat.mod_eq_of_lt (Nat.xor_lt_two_pow x.toBits.toBitVec.isLt (by norm_num))]
  rfl

theorem unpacked_add_neg (spec : Float.Model.Format) (u v : Float.Model.UnpackedFloat) :
    Float.Model.UnpackedFloat.add spec u v.neg = Float.Model.UnpackedFloat.sub spec u v := by
  cases u <;> cases v <;>
    simp [Float.Model.UnpackedFloat.add, Float.Model.UnpackedFloat.sub, Float.Model.UnpackedFloat.neg]
  rename_i s1 m1 e1 h1 s2 m2 e2 h2
  congr 1
  cases s2 <;> simp [Float.Model.UnpackedFloat.Sign.apply]; omega

theorem unpack_neg (b : Float32) (hb : b.isFinite = true) : (-b).toModel.unpack = b.toModel.unpack.neg := by
  rw [Negation.execution b hb]
  change (Model.toFloat32Model (Model.neg (model b))).unpack = _
  rw [Model.unpack_toFloat32Model, Model.toModel_neg_of_isFinite (by decide) (model b)
    (by simpa only [model, Model.toModel_ofFloat32Model, Float32.isFinite, Float32.Model.isFinite] using hb)]
  rfl

/-- `a + (-b)` is `a - b` (one rounding of the same exact value, the same signed zero). -/
theorem add_neg (a b : Float32) (hb : b.isFinite = true) : a + -b = a - b := by
  change Float32.ofModel (Float32.Model.pack (Float.Model.UnpackedFloat.add _ a.toModel.unpack (-b).toModel.unpack)) =
    Float32.ofModel (Float32.Model.pack (Float.Model.UnpackedFloat.sub _ a.toModel.unpack b.toModel.unpack))
  rw [unpack_neg b hb, unpacked_add_neg]

theorem flush_neg (x : Float32) (hx : x.isFinite = true) : FlushToZero.flush (-x) = -FlushToZero.flush x := by
  unfold FlushToZero.flush
  rw [unpack_neg x hx]
  cases h : x.toModel.unpack with
  | finite s m e hm =>
    simp only [Float.Model.UnpackedFloat.neg]
    split
    · cases s <;> decide
    · rfl
  | _ => rfl

/-- A finite square has a finite operand. -/
theorem finite_of_mul_self (a : Float32) (h : (a * a).isFinite = true) : a.isFinite = true := by
  change (Float32.Model.pack (Float.Model.UnpackedFloat.mul _ a.toModel.unpack a.toModel.unpack)).unpack.isFinite = true at h
  change a.toModel.unpack.isFinite = true
  cases hu : a.toModel.unpack with
  | notANumber => rw [hu] at h; exact absurd h (by decide)
  | infinity s => rw [hu] at h; cases s <;> exact absurd h (by decide)
  | zero s => rfl
  | finite s m e hm => rfl

/-! ## Finiteness through conversions -/

theorem finite_of_cast {src dst : FloatFormat} (hne : src ≠ dst) (hdst : dst.isIEEE = true)
    (hinf : dst.supportsInfinity = true) (x : Model src)
    (h : Model.isFinite (Model.cast src dst x) = true) : Model.isFinite x = true := by
  unfold Model.cast at h
  split at h
  · rw [Model.isFinite_eq_false_of_isNaN (Model.isNaN_propagatedNaN _ _ _
      (by rw [FloatFormat.encoding_eq_ieee_of_isIEEE dst hdst]; decide))] at h
    exact absurd h (by decide)
  · rename_i hnan
    split at h
    · rw [Model.nativeOverflow_eq_signedInf_of_isIEEE _ hdst] at h
      split at h <;> simp [Model.isFinite_negInf _ hinf, Model.isFinite_posInf _ hinf] at h
    · rename_i hinf'
      exact Model.isFinite_eq_true_of_isNaN_eq_false_of_isInf_eq_false x (by simpa using hnan) (by simpa using hinf')

/-! ## The inverse root mean: `· * 2^-7` against `· / D` for D = 128 -/

/-- The core's factor 2^-7 (the word 0x3C000000), as InstCombine writes `x / 128.0f`. -/
abbrev q7 : Float32 := Val.ofF32Bits 0x3C000000

theorem q7_finite : q7.isFinite = true := by decide

theorem q7_real : real q7 = (2:ℝ)^(-7:ℤ) := by
  rw [q7, real_unpack]
  change Model.unpackedToReal (.finite .positive 8388608 (-30) (by decide)) = _
  rw [Model.unpackedToReal_finite]
  norm_num [Model.modelSignBit, FloatLib.Floats.Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix,
    FloatLib.Numerics.Radix.toReal]

theorem flush_q7 : FlushToZero.flush q7 = q7 := FlushToZero.flush_eq_of_threshold_le q7 (by
  rw [q7_real, abs_of_pos (by positivity)]; norm_num [FlushToZero.threshold])

theorem mul_q7_finite (S : Float32) (hS : S.isFinite = true) :
    (FlushToZero.flush S * FlushToZero.flush q7).isFinite = true := by
  have hSf := FlushToZero.finite_flush S hS
  rw [flush_q7, ← finite_model, NativeMultiplication.float32_model _ _ hSf q7_finite]
  apply Model.isFinite_mul_of_abs_mul_le_posMaxFinite _ _ (by decide) (by rw [finite_model]; exact hSf)
    (by rw [finite_model]; exact q7_finite)
  have hmax := Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model (FlushToZero.flush S)) (by decide)
    (by rw [finite_model]; exact hSf)
  change |real (FlushToZero.flush S)| * |real q7| ≤ _
  change |real (FlushToZero.flush S)| ≤ _ at hmax
  rw [q7_real, abs_of_pos (show (0:ℝ) < 2^(-7:ℤ) by positivity)]
  have h0 := abs_nonneg (real (FlushToZero.flush S))
  have h7 : (2:ℝ)^(-7:ℤ) ≤ 1 := by norm_num
  nlinarith

/-- The flushed product by 2^-7 and the flushed quotient by 128 have the same value. -/
theorem mul_q7_real (S w : Float32) (hS : S.isFinite = true) (hw : w.isFinite = true) (hw128 : real w = 128) :
    real (FlushToZero.mul S q7) = real (FlushToZero.div S w) := by
  have fw : FlushToZero.flush w = w := FlushToZero.flush_eq_of_one_le w (by rw [hw128]; norm_num)
  have hd : (FlushToZero.flush S / FlushToZero.flush w).isFinite = true := by
    rw [fw]; exact NativeNormalizationDivision.raw_finite S w hS hw (by rw [hw128]; norm_num)
  rw [FlushToZero.real_mul S q7 (mul_q7_finite S hS), FlushToZero.real_div S w hw hd, flush_q7, fw, q7_real, hw128]
  have e : real (FlushToZero.flush S) * (2:ℝ)^(-7:ℤ) = real (FlushToZero.flush S) / 128 := by
    rw [zpow_neg, zpow_ofNat]; norm_num; ring
  rw [e]

/-- Adding a nonnegative `eps` to two finite values of equal value gives the same word when the sum is
nonzero (signed zeros of the summands are absorbed). -/
theorem add_congr (m1 m2 eps : Float32) (h1 : m1.isFinite = true) (h2 : m2.isFinite = true)
    (he : eps.isFinite = true) (hepos : 0 ≤ real eps) (hr : real m1 = real m2)
    (hpos : 0 < real (FlushToZero.add m2 eps)) : FlushToZero.add m1 eps = FlushToZero.add m2 eps := by
  have hf := NativeNormalizationDivision.flush_real_congr m1 m2 h1 h2 hr
  by_cases h0 : real (FlushToZero.flush m2) = 0
  · have s1 := (Float32Bounds.add_range (FlushToZero.flush m1) eps eps (FlushToZero.finite_flush _ h1) he he
      (by rw [hf, h0, abs_zero, zero_add, abs_of_nonneg hepos])).1
    have s2 := (Float32Bounds.add_range (FlushToZero.flush m2) eps eps (FlushToZero.finite_flush _ h2) he he
      (by rw [h0, abs_zero, zero_add, abs_of_nonneg hepos])).1
    rw [FlushToZero.flush_flush] at s1 s2
    have hreal : real (FlushToZero.add m1 eps) = real (FlushToZero.add m2 eps) := by
      unfold FlushToZero.add
      apply NativeNormalizationDivision.flush_real_congr _ _ s1 s2
      rw [Numerics.add_real _ _ (FlushToZero.finite_flush _ h1) (FlushToZero.finite_flush _ he) s1,
        Numerics.add_real _ _ (FlushToZero.finite_flush _ h2) (FlushToZero.finite_flush _ he) s2, hf]
    exact BFloat16Log1p.eq_of_real _ _ (FlushToZero.finite_flush _ s1) (FlushToZero.finite_flush _ s2) hreal
      (by rw [hreal]; exact ne_of_gt hpos)
  · have : FlushToZero.flush m1 = FlushToZero.flush m2 :=
      BFloat16Log1p.eq_of_real _ _ (FlushToZero.finite_flush _ h1) (FlushToZero.finite_flush _ h2) hf (by rwa [hf])
    unfold FlushToZero.add
    rw [this]

/-- The machine's `rsqrt` argument `S·2^-7 + eps` is the model's `S / width + eps` (`real width = 128`). -/
theorem mean_eps (C : M1Max.Contract) (S w eps : Float32) (hS : S.isFinite = true) (hw : w.isFinite = true)
    (hw128 : real w = 128) (he : eps.isFinite = true) (hepos : 0 ≤ real eps)
    (hmean : (C.fdiv S w).isFinite = true) (hpos : 0 < real (FlushToZero.add (C.fdiv S w) eps)) :
    C.fadd (C.fmul S q7) eps = FlushToZero.add (C.fdiv S w) eps := by
  have hdom : Division.DivisorDomain w := ⟨by rw [hw128]; norm_num, by rw [hw128]; norm_num⟩
  have hdiv := C.fdiv_model S w hS hw hdom
  have hm : (FlushToZero.mul S q7).isFinite = true := FlushToZero.mul_finite _ _ (mul_q7_finite S hS)
  rw [C.fmul_model S q7 hS q7_finite, C.fadd_model _ _ hm he]
  apply add_congr _ _ _ hm hmean he hepos _ hpos
  rw [hdiv]
  exact mul_q7_real S w hS hw hw128

/-! ## Squared sums -/

section SquaredSums
variable {n : Nat} (C : M1Max.Contract)

theorem finite_of_step {c : Bool} {input : Fin n → Float32} {e : SquaredSum.Expr n} {i : Fin n}
    (h : SquaredSum.Finite input (SquaredSum.step c e i)) : SquaredSum.Finite input e := by
  cases c
  · exact h.1
  · exact h.1

/-- One `acc += v * v` of the core (contracted or not) is the model's step on finite operands. -/
theorem step_eq (c : Bool) (input : Fin n → Float32) (e : SquaredSum.Expr n) (i : Fin n) (v acc : Float32)
    (hv : v = input i) (ha : acc = SquaredSum.evaluate input e) (hf : SquaredSum.Finite input (SquaredSum.step c e i)) :
    (if c then C.fma v v acc else C.fadd acc (C.fmul v v)) = SquaredSum.evaluate input (SquaredSum.step c e i) := by
  subst hv ha
  cases c
  · obtain ⟨he, hsq, _⟩ := hf
    have hi : (input i).isFinite = true := by
      rw [← FlushToZero.finite_flush_iff]; exact finite_of_mul_self _ hsq
    rw [ite_eq_right (by decide), C.fmul_model _ _ hi hi,
      C.fadd_model _ _ (SquaredSum.finite_evaluate _ _ he) (FlushToZero.mul_finite _ _ hsq)]
    rfl
  · obtain ⟨he, hi, _⟩ := hf
    rw [ite_eq_left rfl, C.fma_model _ _ _ hi hi (SquaredSum.finite_evaluate _ _ he)]
    rfl

/-- Each index of a finite squared-sum expression has a finite input. -/
theorem finite_of_mem : ∀ (input : Fin n → Float32) (e : SquaredSum.Expr n), SquaredSum.Finite input e →
    ∀ i ∈ SquaredSum.indices e, (input i).isFinite = true
  | _, .zero, _, i, hi => by simp [SquaredSum.indices] at hi
  | input, .square j, hf, i, hi => by
    simp only [SquaredSum.indices, List.mem_singleton] at hi
    subst hi
    rw [← FlushToZero.finite_flush_iff]; exact finite_of_mul_self _ hf
  | input, .fmaSquare j a, hf, i, hi => by
    simp only [SquaredSum.indices, List.mem_cons] at hi
    rcases hi with rfl | hi
    · exact hf.2.1
    · exact finite_of_mem input a hf.1 i hi
  | input, .add a b, hf, i, hi => by
    simp only [SquaredSum.indices, List.mem_append] at hi
    rcases hi with hi | hi
    · exact finite_of_mem input a hf.1 i hi
    · exact finite_of_mem input b hf.2.1 i hi

/-- A finite reduction tree of expressions has finite leaves. -/
theorem finite_of_leaf {m : Nat} (input : Fin n → Float32) (f : Fin m → SquaredSum.Expr n) :
    ∀ (t : Reduction.Tree m), SquaredSum.Finite input (SquaredSum.reduceTree f t) →
      ∀ l ∈ Reduction.leaves t, SquaredSum.Finite input (f l)
  | .leaf i, h, l, hl => by
    simp only [Reduction.leaves, List.mem_singleton] at hl
    subst hl; exact h
  | .add a b, h, l, hl => by
    simp only [Reduction.leaves, List.mem_append] at hl
    rcases hl with hl | hl
    · exact finite_of_leaf input f a h.1 l hl
    · exact finite_of_leaf input f b h.2.1 l hl

end SquaredSums

/-! ## Host views of buffers -/

/-- Byte `b` of a bf16 value's row-major storage decodes, two at a time, to its element. -/
theorem bfAt_storage (v : Host.Mlx.Value) (hv : v.dtype = .bfloat16) (e : Nat) :
    bfAt (Host.Mlx.Value.storageByte v) e = Host.Mlx.bf (v.elems e) := by
  unfold bfAt Host.Mlx.Value.storageByte Host.Mlx.bf Val.ofBf16Bits
  rw [hv]
  congr 1
  apply BitVec.eq_of_toNat_eq
  simp only [bytesWord, List.range_succ, List.range_zero, List.nil_append, List.cons_append, List.map_cons,
    List.map_nil, List.foldr_cons, List.foldr_nil, BitVec.toNat_ofNat, Host.Mlx.Dtype.bytes]
  rw [show (2 * e + 0) / 2 = e by omega, show (2 * e + 1) / 2 = e by omega, show (2 * e + 0) % 2 = 0 by omega,
    show (2 * e + 1) % 2 = 1 by omega]
  omega


/-- Element `j` of a bf16 output buffer viewed at base 0 is `bfAt` of its bytes. -/
theorem halfArray_read (B : ByteMemory.Bytes) (shape : List Nat) (j : Nat) :
    Host.Mlx.bf ((Host.Mlx.halfArray B 0 shape).elems j) = bfAt B j := by
  change Host.Mlx.bf (HalfMemory.load B (0 + 2 * j)).toNat = _
  rw [Host.Mlx.bf_toNat, Nat.zero_add, bfAt_eq_load]


/-! # gated-rms-norm: the machine spec is the model's value

`Metal.Kernels.GatedRmsNorm.outElem` (the bytes `gpu_output` proves) against
`Inference.Kernels.GatedRmsNorm.value (C.gatedPlatform contracted)` (the value `GlueKernels.gated_rms_norm`
consumes), element by element:

* inputs: element `128 h + i` of `x`/`gate` is the bf16 word at bytes `2 (128 h + i)`, `+1`
  (`bfAt`, `bfAt_eq_load`), i.e. `x h i` of the row-major `Flat` value (`bfAt_storage`); `weight[i]` likewise;
* contraction: site 1 (`acc += value * value`) is the model's `contracted`, the core's only fusable site;
* `float(x)` is `C.widen` = `BFloat16.widen`; each lane's four `acc` steps are `SquaredSum.step`, the
  `simd_sum` is `C.simdSum` = `FlushedReduction.evaluate` on its tree (`Delta.SiluRmsHeads.expression`);
* `acc / float(D)` is compiled as `acc * 2^-7` (`fmul`), the model divides by `width` (`fdiv`, real 128):
  equal values (`mul_q7_real`), and after `+ eps` equal words (`mean_eps`);
* `weight[col] * T(...)` is `C.bfmul` = `BFloat16Arithmetic.mul`, `T(...)` is `C.narrow` = `BFloat16.narrow`;
* the sigmoid's `exp(abs(g))` is `C.fastExp (C.fastFabs g)` = `C.gatedExpAbs`, `1 / (1 + e)` is `fdiv`/`fadd`
  (= `StableSigmoid.quotient`: a finite `exp|g|` by `fadd_model` and `fdiv_one_model`, an overflowed one by
  `fadd_posInf` and `fdiv_posInf`),
  `g < 0` compares flushed values against +0 (= `StableSigmoid.negative`), and `1 - y` is `1 + (-y)` with the
  sign-bit negation (= `Arithmetic.sub 1 y`, `add_neg`, `flush_neg`). -/

namespace GatedRmsNorm
open Inference.Kernels
open Inference.Kernels.GatedRmsNorm (NormFinite TailFinite)

variable (C : M1Max.Contract)

/-- The launch's ε: the template word EPS = 0x358637BD reinterpreted (`GlueKernels`' `FloatMemory.decode
(BitVec.ofNat 32 epsWord)`). -/
abbrev eps : Float32 := Val.ofF32Bits 0x358637BD

theorem eps_eq : eps = FloatMemory.decode (BitVec.ofNat 32 Host.Mlx.epsWord) := rfl

theorem zero_eq : Kernels.GatedRmsNorm.zero = (0 : Float32) := by decide
theorem one_eq : Kernels.GatedRmsNorm.one = (1 : Float32) := by decide
theorem flush_zero : FlushToZero.flush Kernels.GatedRmsNorm.zero = (0 : Float32) := by decide

/-- Lane `lane`'s squared-sum expression after its first `k` columns `4 lane + k`. -/
def pre (c : Bool) (lane : Fin 32) : Nat → SquaredSum.Expr 128
  | 0 => .zero
  | k + 1 => SquaredSum.step c (pre c lane k) ⟨lane.val * 4 + k % 4, by have := lane.isLt; omega⟩

theorem laneExpr_pre (c : Bool) (lane : Fin 32) : Inference.Kernels.Delta.SiluRmsHeads.laneExpr c lane = pre c lane 4 :=
  rfl

theorem finite_step_input {c : Bool} {input : Fin 128 → Float32} {e : SquaredSum.Expr 128} {i : Fin 128}
    (h : SquaredSum.Finite input (SquaredSum.step c e i)) : (input i).isFinite = true := by
  cases c
  · rw [← FlushToZero.finite_flush_iff]; exact finite_of_mul_self _ h.2.1
  · exact h.2.1

/-- A lane's `acc` after `k ≤ 4` steps is its model expression's value. -/
theorem sumSq_pre (c : Bool) (X : ByteMemory.Bytes) (x : Fin 128 → BF) (row : Nat)
    (hX : ∀ i : Fin 128, bfAt X (row * 128 + i.val) = x i) (lane : Fin 32) :
    ∀ k, k ≤ 4 → SquaredSum.Finite (Inference.Kernels.GatedRmsNorm.input x) (pre c lane k) →
      Kernels.GatedRmsNorm.sumSq C c X row lane.val k =
        SquaredSum.evaluate (Inference.Kernels.GatedRmsNorm.input x) (pre c lane k)
  | 0, _, _ => zero_eq
  | k + 1, hk, hf => by
    have ih := sumSq_pre c X x row hX lane k (by omega) (finite_of_step hf)
    have hi := finite_step_input hf
    have hkk : k % 4 = k := Nat.mod_eq_of_lt (by omega)
    show (if c then C.fma _ _ _ else C.fadd _ (C.fmul _ _)) = _
    apply step_eq C c _ _ _ _ _ _ ih hf
    unfold Kernels.GatedRmsNorm.xf
    rw [show row * 128 + (lane.val * 4 + k) = row * 128 + (lane.val * 4 + k % 4) by omega,
      hX ⟨lane.val * 4 + k % 4, by have := lane.isLt; omega⟩, C.widen_model _ (General.finite_of_widen _ hi)]
    rfl

/-- The row's `simd_sum` is the model's squared sum `SquaredSum.evaluate … (expression p)`. -/
theorem rowSum_eq (c : Bool) (X : ByteMemory.Bytes) (x : Fin 128 → BF) (row : Nat)
    (hX : ∀ i : Fin 128, bfAt X (row * 128 + i.val) = x i)
    (hf : SquaredSum.Finite (Inference.Kernels.GatedRmsNorm.input x)
      (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c))) :
    Kernels.GatedRmsNorm.rowSum C c X row =
      SquaredSum.evaluate (Inference.Kernels.GatedRmsNorm.input x) (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c)) := by
  unfold Kernels.GatedRmsNorm.rowSum
  rw [C.simdSum_tree.execution]
  change _ = SquaredSum.evaluate _ (SquaredSum.reduceTree (Inference.Kernels.Delta.SiluRmsHeads.laneExpr c) C.simdSum_tree.tree)
  rw [NormalizationReduction.evaluate_reduceTree]
  congr 1
  funext lane
  rw [laneExpr_pre]
  apply sumSq_pre C c X x row hX lane 4 le_rfl
  rw [← laneExpr_pre]
  exact finite_of_leaf _ _ _ hf lane (C.simdSum_tree.coverage.mem_iff.mpr (List.mem_finRange lane))

/-- The row's inverse root is the model's normalizer. -/
theorem invRms_eq (c : Bool) (X : ByteMemory.Bytes) (x : Fin 128 → BF) (weight : Fin 128 → BF) (width : Float32)
    (row : Nat) (hX : ∀ i : Fin 128, bfAt X (row * 128 + i.val) = x i)
    (hn : NormFinite (C.gatedPlatform c) x weight width eps) :
    Kernels.GatedRmsNorm.invRms C c X row = NormalizationExecution.normalizer C.fdiv (Inference.Kernels.GatedRmsNorm.input x)
      (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c)) width eps C.rsqrt := by
  have hf : NormalizationExecution.Finite C.fdiv (Inference.Kernels.GatedRmsNorm.input x) weight
      (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c)) width eps C.rsqrt := hn
  unfold Kernels.GatedRmsNorm.invRms
  rw [rowSum_eq C c X x row hX hf.hSum]
  unfold NormalizationExecution.normalizer NormalizationExecution.denominator NormalizationExecution.mean
    NormalizationExecution.sum
  congr 1
  exact mean_eps C _ width eps (SquaredSum.finite_evaluate _ _ hf.hSum) hf.hWidth (by rw [hf.hWidthValue]; norm_num)
    hf.hEps (le_of_lt (lt_trans FlushToZero.threshold_pos hf.hNormalEps)) hf.hMean
    (NormalizationExecution.denominator_positive C.fdiv FlushToZero.divBudget C.division _ _ _ _ hf.toReductionFinite)

theorem input_finite (c : Bool) (x weight : Fin 128 → BF) (width : Float32)
    (hn : NormFinite (C.gatedPlatform c) x weight width eps) (i : Fin 128) : Model.isFinite (x i) = true := by
  have hf : NormalizationExecution.Finite C.fdiv (Inference.Kernels.GatedRmsNorm.input x) weight
      (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c)) width eps C.rsqrt := hn
  exact General.finite_of_widen _ (finite_of_mem _ _ hf.hSum i
    ((Inference.Kernels.Delta.SiluRmsHeads.expression_coverage c C.simdSum_tree.tree C.simdSum_tree.coverage).mem_iff.mpr
      (List.mem_finRange i)))

/-- `weight[col] * T(float(x[index]) * inv)` is the model's normalized coordinate. -/
theorem normalized_eq (c : Bool) (X W : ByteMemory.Bytes) (x weight : Fin 128 → BF) (width : Float32) (h : Nat)
    (hX : ∀ i : Fin 128, bfAt X (h * 128 + i.val) = x i)
    (hW : ∀ i : Fin 128, bfAt W i.val = weight i)
    (hn : NormFinite (C.gatedPlatform c) x weight width eps) (i : Fin 128) :
    Kernels.GatedRmsNorm.normalized C c X W (h * 128 + i.val) =
      Inference.Kernels.GatedRmsNorm.normalized (C.gatedPlatform c) x weight width eps i := by
  have hf : NormalizationExecution.Finite C.fdiv (Inference.Kernels.GatedRmsNorm.input x) weight
      (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c)) width eps C.rsqrt := hn
  have hxi := input_finite C c x weight width hn i
  unfold Kernels.GatedRmsNorm.normalized Kernels.GatedRmsNorm.xf
  rw [show (h * 128 + i.val) % 128 = i.val by omega, show (h * 128 + i.val) / 128 = h by omega, hW i, hX i,
    C.widen_model _ hxi, invRms_eq C c X x weight width h hX hn]
  rw [C.fmul_model _ _ (BFloat16.widen_finite _ hxi) hf.hNormalizer]
  have hm : (FlushToZero.mul (BFloat16.widen (x i)) (NormalizationExecution.normalizer C.fdiv
      (Inference.Kernels.GatedRmsNorm.input x) (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c)) width eps
      C.rsqrt)).isFinite = true := FlushToZero.mul_finite _ _ (hf.hNormalized i)
  rw [C.narrow_model _ hm]
  have hb : Model.isFinite (BFloat16.narrow (FlushToZero.mul (BFloat16.widen (x i)) (NormalizationExecution.normalizer C.fdiv
      (Inference.Kernels.GatedRmsNorm.input x) (Inference.Kernels.GatedRmsNorm.expression (C.gatedPlatform c)) width eps
      C.rsqrt))) = true := hf.hNarrow i
  rw [C.bfmul_model _ _ (hf.hWeight i) hb]
  rfl

theorem add_one_inf : FlushToZero.add 1 Float32.inf = Float32.inf := by decide

/-- `y = 1 / (1 + exp(abs(g)))` is `StableSigmoid.quotient` (finite) on every finite `g`: with a finite
exponential by `fdiv_one_model` (the divisor is at least 1), with `+inf` by `fadd_posInf`/`fdiv_posInf`. -/
theorem quotient_eq (c : Bool) (g : Float32) (hg : g.isFinite = true) :
    Kernels.GatedRmsNorm.yOf C g = StableSigmoid.quotient (C.gatedPlatform c).expAbs g ∧
      (StableSigmoid.quotient (C.gatedPlatform c).expAbs g).isFinite = true := by
  unfold Kernels.GatedRmsNorm.yOf
  rw [one_eq]
  change C.fdiv 1 (C.fadd 1 ((C.gatedPlatform c).expAbs g)) = _ ∧ _
  rcases C.fastExp_overflow _ (C.fastFabs_value g hg).1 with he | he
  · have he : ((C.gatedPlatform c).expAbs g).isFinite = true := he
    have hs := (Inference.Kernels.StableSigmoidRanges.finite_branch _ _ (C.gatedPlatform c).exponential g hg he).1
    have hden := StableSigmoid.denominator_finite (C.gatedPlatform c).expAbs g hs
    have hge := StableSigmoid.denominator_ge_one _ _ (C.gatedPlatform c).exponential g hs
    rw [C.fadd_model 1 _ (by decide) he]
    change C.fdiv 1 (StableSigmoid.denominator (C.gatedPlatform c).expAbs g) = _ ∧ _
    rw [C.fdiv_one_model _ hden hge]
    exact ⟨rfl, StableSigmoid.quotient_finite _ _ (C.gatedPlatform c).exponential g hs⟩
  · have hinf : (C.gatedPlatform c).expAbs g = Float32.inf := he
    rw [hinf, C.fadd_posInf 1 (by decide), add_one_inf, C.fdiv_posInf 1 (by decide),
      StableSigmoid.quotient_overflow _ _ hinf]
    refine ⟨?_, by decide⟩
    rw [← StableSigmoid.quotient_overflow _ _ hinf]
    unfold StableSigmoid.quotient StableSigmoid.denominator
    rw [hinf, add_one_inf]

/-- The core's sigmoid is `StableSigmoid.value` on every finite `g`. -/
theorem sigmoid_eq (c : Bool) (g : Float32) (hg : g.isFinite = true) :
    Kernels.GatedRmsNorm.sigmoidOf C g = StableSigmoid.value (C.gatedPlatform c).expAbs g := by
  obtain ⟨hq, hqf⟩ := quotient_eq C c g hg
  have hcmp : (f32Compare g Kernels.GatedRmsNorm.zero = some .lt) = StableSigmoid.negative g := by
    unfold f32Compare StableSigmoid.negative
    rw [flush_zero]
  unfold Kernels.GatedRmsNorm.sigmoidOf StableSigmoid.value
  rw [hq]
  by_cases hn : StableSigmoid.negative g
  · rw [ite_eq_left (hcmp ▸ hn), ite_eq_left hn]
  · rw [ite_eq_right (hcmp ▸ hn), ite_eq_right hn, one_eq, f32Neg_eq _ hqf,
      C.fadd_model 1 _ (by decide) (Negation.finite_neg _ hqf)]
    unfold FlushToZero.add Arithmetic.sub
    rw [FlushToZero.flush_one, flush_neg _ hqf, add_neg 1 _ (FlushToZero.finite_flush _ hqf)]

/-- **Element bridge.** With the compiler's choice at site 1 the model's `contracted`, every output element of
the machine spec is the model's value, given the model's finiteness predicates for the row (`NormFinite`) and
the element (`TailFinite`). -/
theorem outElem_eq (fuse : Nat → Bool) (contracted : Bool) (hc : fuse 1 = contracted)
    (X Gt W : ByteMemory.Bytes) (x gate : Fin 48 → Fin 128 → BF) (weight : Fin 128 → BF) (width : Float32)
    (hX : ∀ h i, bfAt X (h.val * 128 + i.val) = x h i)
    (hG : ∀ h i, bfAt Gt (h.val * 128 + i.val) = gate h i)
    (hW : ∀ i : Fin 128, bfAt W i.val = weight i) (h : Fin 48) (i : Fin 128)
    (hn : NormFinite (C.gatedPlatform contracted) (x h) weight width eps)
    (ht : TailFinite (C.gatedPlatform contracted) (BFloat16.widen (gate h i))
      (BFloat16.widen (Inference.Kernels.GatedRmsNorm.normalized (C.gatedPlatform contracted) (x h) weight width eps i))) :
    Kernels.GatedRmsNorm.outElem C (fuse 1) X Gt W (h.val * 128 + i.val) =
      Inference.Kernels.GatedRmsNorm.value (C.gatedPlatform contracted) (x h) (gate h) weight width eps i := by
  subst hc
  have hg : Model.isFinite (gate h i) = true := General.finite_of_widen _ ht.gateFinite
  have hnf := Inference.Kernels.GatedRmsNorm.normalized_finite _ _ _ _ _ hn i
  have hsf := (Inference.Kernels.StableSigmoidRanges.ranges _ _ (C.gatedPlatform (fuse 1)).exponential
    C.gatedExpAbs_exponential _ ht.gateFinite).2.1
  unfold Kernels.GatedRmsNorm.outElem Kernels.GatedRmsNorm.gateF
  rw [hG h i, C.widen_model _ hg, sigmoid_eq C (fuse 1) _ ht.gateFinite,
    normalized_eq C (fuse 1) X W (x h) weight width h.val (hX h) hW hn i, C.widen_model _ hnf,
    C.fmul_model _ _ ht.gateFinite hsf]
  have hp : (FlushToZero.mul (BFloat16.widen (gate h i))
      (StableSigmoid.value (C.gatedPlatform (fuse 1)).expAbs (BFloat16.widen (gate h i)))).isFinite = true :=
    FlushToZero.mul_finite _ _ ht.activation
  rw [C.fmul_model _ _ hp (BFloat16.widen_finite _ hnf)]
  have hq : (FlushToZero.mul (FlushToZero.mul (BFloat16.widen (gate h i))
      (StableSigmoid.value (C.gatedPlatform (fuse 1)).expAbs (BFloat16.widen (gate h i))))
      (BFloat16.widen (Inference.Kernels.GatedRmsNorm.normalized (C.gatedPlatform (fuse 1)) (x h) weight width eps i))).isFinite = true :=
    FlushToZero.mul_finite _ _ ht.product
  rw [C.narrow_model _ hq]
  rfl

/-- **Byte bridge.** The machine spec's output buffer, read as the host's bf16 [1, 1, 48, 128] array, is the
model's value in the `Flat` form `GlueKernels.gated_rms_norm` concludes. -/
theorem expected_flat (fuse : Nat → Bool) (contracted : Bool) (hc : fuse 1 = contracted)
    (X Gt W : ByteMemory.Bytes) (x gate : Fin 48 → Fin 128 → BF) (weight : Fin 128 → BF) (width : Float32)
    (hX : ∀ h i, bfAt X (h.val * 128 + i.val) = x h i)
    (hG : ∀ h i, bfAt Gt (h.val * 128 + i.val) = gate h i)
    (hW : ∀ i : Fin 128, bfAt W i.val = weight i)
    (hn : ∀ h, NormFinite (C.gatedPlatform contracted) (x h) weight width eps)
    (ht : ∀ h i, TailFinite (C.gatedPlatform contracted) (BFloat16.widen (gate h i))
      (BFloat16.widen (Inference.Kernels.GatedRmsNorm.normalized (C.gatedPlatform contracted) (x h) weight width eps i))) :
    Host.Mlx.Flat (Host.Mlx.halfArray (Kernels.GatedRmsNorm.expected C fuse X Gt W) 0 [1,1,48,128]) [1,1,48,128]
      (Inference.Kernels.Delta.GatedInputs.flatten fun h =>
        Inference.Kernels.GatedRmsNorm.value (C.gatedPlatform contracted) (x h) (gate h) weight width eps) := by
  refine ⟨rfl, rfl, fun j => ?_⟩
  rw [halfArray_read]
  apply bfAt_of
  intro k hk
  have hj := j.isLt
  unfold Kernels.GatedRmsNorm.expected
  rw [ite_eq_left (by omega), show (2 * j.val + k) / 2 = j.val by omega, show (2 * j.val + k) % 2 = k by omega]
  have he := outElem_eq C fuse contracted hc X Gt W x gate weight width hX hG hW ⟨j.val / 128, by omega⟩
    ⟨j.val % 128, by omega⟩ (hn _) (ht _ _)
  rw [show j.val / 128 * 128 + j.val % 128 = j.val by omega] at he
  rw [he]
  rfl

/-- **End to end.** MLX's launch on the row-major storage of `Flat`/`Vector` inputs returns a buffer that,
as the host's bf16 array, is the model's gated RMS norm (`GlueKernels.gated_rms_norm`'s value), when the
compiler's site-1 choice is the model's flag. -/
theorem gpu_value (G : Gpu C) (hmax : 32 ≤ G.maxThreads Metal.Elab.Tests.gatedRmsNormText)
    (xv gv wv : Host.Mlx.Value) (x gate : Fin 48 → Fin 128 → BF) (weight : Fin 128 → BF)
    (hxv : Host.Mlx.Flat xv [1,1,48,128] (Inference.Kernels.Delta.GatedInputs.flatten x))
    (hgv : Host.Mlx.Flat gv [1,1,48,128] (Inference.Kernels.Delta.GatedInputs.flatten gate))
    (hwv : Host.Mlx.GlueAttention.Vector wv 128 weight) (ax ag aw : Nat) (hax : 2 ∣ ax) (hag : 2 ∣ ag) (haw : 2 ∣ aw)
    (contracted : Bool) (hc : G.fusion Metal.Elab.Tests.gatedRmsNormText 1 = contracted) (width : Float32)
    (hn : ∀ h, NormFinite (C.gatedPlatform contracted) (x h) weight width eps)
    (ht : ∀ h i, TailFinite (C.gatedPlatform contracted) (BFloat16.widen (gate h i))
      (BFloat16.widen (Inference.Kernels.GatedRmsNorm.normalized (C.gatedPlatform contracted) (x h) weight width eps i))) :
    ∃ out, G.execute Metal.Elab.Tests.gatedRmsNormText (1536, 1, 1) (32, 1, 1)
        [⟨.device, 12288, ax, xv.storageByte⟩, ⟨.device, 12288, ag, gv.storageByte⟩, ⟨.device, 256, aw, wv.storageByte⟩]
        [12288] = some [out] ∧
      Host.Mlx.Flat (Host.Mlx.halfArray out 0 [1,1,48,128]) [1,1,48,128]
        (Inference.Kernels.Delta.GatedInputs.flatten fun h =>
          Inference.Kernels.GatedRmsNorm.value (C.gatedPlatform contracted) (x h) (gate h) weight width eps) := by
  refine ⟨_, Kernels.GatedRmsNorm.gpu_output C G hmax _ _ _ ax ag aw hax hag haw, ?_⟩
  apply expected_flat C _ contracted hc _ _ _ x gate weight width _ _ _ hn ht
  · intro h i
    rw [bfAt_storage _ hxv.1, ← Inference.Kernels.Delta.GatedInputs.flatten_index x h i]
    exact hxv.2.2 (Inference.Kernels.Delta.GatedInputs.index h i)
  · intro h i
    rw [bfAt_storage _ hgv.1, ← Inference.Kernels.Delta.GatedInputs.flatten_index gate h i]
    exact hgv.2.2 (Inference.Kernels.Delta.GatedInputs.index h i)
  · intro i
    rw [bfAt_storage _ hwv.1]
    exact hwv.2.2 i

end GatedRmsNorm
end Metal.Bridge
