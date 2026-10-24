import metal.bridge.ResidualRmsNorm
import FloatLib.Floats.Formats.IEEE754.Native.AddSub

/-!
# One flushed bf16 addition is the residual kernel's double rounding

`Metal.Bridge.ResidualRmsNorm.SingleRounding` states that `BFloat16Arithmetic.add x u` (flush both
operands, one nearest-even bf16 rounding, flush the result) equals
`Inference.Kernels.ResidualRmsNorm.residual x u` (widen both operands, flush them in binary32, one
binary32 nearest-even addition, flush, narrow to bf16) for every pair `AddFinite` admits. This file
proves it (`Metal.Bridge.ResidualRmsNorm.singleRounding`).

Both sides are finite and are compared by real value and, at zero, by sign bit (`Denotes.eq`). With
`s` the exact sum of the flushed operands (which agree in both formats, `flush32_real`,
`flush32_sign`):
* `s = 0`: both additions return the zero that is negative only when both operands are
  (`denotes_add_zero`); narrowing keeps it.
* `0 < |s| < 2^-126`: `s` is exact in both formats (`sum_generic_of_small`), both sides flush the
  subnormal sum to the zero of its sign.
* `|s| ≥ 2^-126`: no flush applies, and `double_round` shows that rounding `s` to binary32 and then
  to bf16 is rounding it to bf16 once. The bf16 addition cannot overflow because its rounding is the
  finite narrowed value (`roundDyadic_bf_finite`).
-/

namespace Metal.Bridge.SingleRounding
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open Inference.Contracts.Mlx Inference.Contracts.Mlx.Numerics

/-! ## General lemmas -/

abbrev bfFmt := FloatFormat.bfloat16
abbrev f32Fmt := FloatFormat.binary32

/-! ### Finite values by real value and sign -/

/-- `m` is finite with real value `v`, and its sign bit is `s` when `v = 0`. -/
def Denotes {fmt : FloatFormat} (m : Model fmt) (v : ℝ) (s : Bool) : Prop :=
  Model.isFinite m = true ∧ Model.toReal m = v ∧ (v = 0 → Model.signBit m = s)

/-- A finite value is determined by its real value and, at zero, its sign bit. -/
theorem Denotes.eq {fmt : FloatFormat} {x y : Model fmt} {v : ℝ} {s : Bool} (hx : Denotes x v s)
    (hy : Denotes y v s) : x = y := by
  by_cases h0 : v = 0
  · have zx := (Model.isZero_eq_true_iff_toReal_eq_zero x hx.1).mpr (hx.2.1.trans h0)
    have zy := (Model.isZero_eq_true_iff_toReal_eq_zero y hy.1).mpr (hy.2.1.trans h0)
    have dx := Model.toDyadic?_eq_zero_of_isZero_eq_true x zx
    have dy := Model.toDyadic?_eq_zero_of_isZero_eq_true y zy
    rw [hx.2.2 h0] at dx
    rw [hy.2.2 h0] at dy
    exact Model.eq_of_toDyadic?_eq_some dx dy
  · exact Model.eq_of_toReal_eq_of_nonzero hx.1 hy.1 (hx.2.1.trans hy.2.1.symm) (hx.2.1 ▸ h0)

/-- The sign bit of a finite nonzero value is the sign of its real value. -/
theorem signBit_of_ne_zero {fmt : FloatFormat} {x : Model fmt} (hx : Model.isFinite x = true)
    (h0 : Model.toReal x ≠ 0) : Model.signBit x = decide (Model.toReal x < 0) := by
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hx
  have hs := Model.sign_eq_signBit_of_toDyadic?_some hd
  have hr : Model.toReal x = d.toReal := by rw [Model.toReal_eq, hd]
  rw [← hs, hr]
  rw [hr] at h0
  have hp : (0:ℝ) < 2 ^ d.exponent := zpow_pos (by norm_num) _
  unfold Numerics.Dyadic.toReal Numerics.Dyadic.signedSignificand at h0 ⊢
  have hn0 : (0:ℝ) ≤ (d.significand : ℝ) := Nat.cast_nonneg _
  cases hn : d.negative
  · simp only [hn, Bool.false_eq_true, ite_false, Int.ofNat_eq_natCast, Int.cast_natCast] at h0 ⊢
    have : (0:ℝ) ≤ (d.significand : ℝ) * 2 ^ d.exponent := mul_nonneg hn0 hp.le
    simp [not_lt.mpr this]
  · simp only [hn, ite_true, Int.ofNat_eq_natCast, Int.cast_neg, Int.cast_natCast] at h0 ⊢
    have hm : (d.significand : ℝ) ≠ 0 := by
      intro h; apply h0; simp [h]
    have hpos : (0:ℝ) < (d.significand : ℝ) * 2 ^ d.exponent := mul_pos (lt_of_le_of_ne hn0 (Ne.symm hm)) hp
    simpa using hpos

theorem real_toDyadic {fmt : FloatFormat} {x : Model fmt} {d : Numerics.Dyadic}
    (hd : Model.toDyadic? x = some d) : Model.toReal x = d.toReal := by
  rw [Model.toReal_eq, hd]

/-! ### Addition, narrowing and widening -/

/-- An exact dyadic sum with zero significand is the zero that is negative only when both operands are. -/
theorem add_significand_zero (a b : Numerics.Dyadic) (h : (Numerics.Dyadic.add a b).significand = 0) :
    Numerics.Dyadic.add a b = ⟨a.negative && b.negative, 0, 0⟩ := by
  unfold Numerics.Dyadic.add Numerics.Dyadic.addFields at *
  dsimp only at h ⊢
  split_ifs at h ⊢ <;> simp_all

/-- Finite addition is nearest-even rounding of the exact dyadic sum. -/
theorem add_eq_roundDyadic {fmt : FloatFormat} {a b : Model fmt} {da db : Numerics.Dyadic}
    (ha : Model.toDyadic? a = some da) (hb : Model.toDyadic? b = some db) :
    Model.add a b = Model.roundDyadic fmt (Model.addDyadic da db) := by
  simp [Model.Proof.add_eq_spec, Model.Spec.add, ha, hb]

theorem denotes_roundDyadic_zero {fmt : FloatFormat} (hfmt : fmt.isIEEE = true) (s : Bool) (e : ℤ) :
    Denotes (Model.roundDyadic fmt ⟨s, 0, e⟩) 0 s := by
  rw [Model.roundDyadic, ite_eq_left hfmt, Model.ieeeRoundDyadic_significand_zero]
  exact ⟨Model.isFinite_ofModel_zero fmt hfmt _, Model.toReal_ofModel_zero fmt hfmt _,
    fun _ => by rw [Model.signBit_ofModel_zero, Model.modelSignBit_modelSign]⟩

/-- An exact zero sum gives the zero that is negative only when both operands are (round to nearest). -/
theorem denotes_add_zero {fmt : FloatFormat} (hfmt : fmt.isIEEE = true) {a b : Model fmt}
    (ha : Model.isFinite a = true) (hb : Model.isFinite b = true)
    (hs : Model.toReal a + Model.toReal b = 0) :
    Denotes (Model.add a b) 0 (Model.signBit a && Model.signBit b) := by
  obtain ⟨da, hda⟩ := Model.exists_toDyadic?_of_isFinite ha
  obtain ⟨db, hdb⟩ := Model.exists_toDyadic?_of_isFinite hb
  have hreal : (Model.addDyadic da db).toReal = 0 := by
    rw [Model.Dyadic.toReal_addDyadic, ← real_toDyadic hda, ← real_toDyadic hdb, hs]
  have hsig := (Model.Dyadic.toReal_eq_zero_iff _).mp hreal
  have heq := add_significand_zero da db hsig
  rw [add_eq_roundDyadic hda hdb, show Model.addDyadic da db = _ from heq,
    ← Model.sign_eq_signBit_of_toDyadic?_some hda, ← Model.sign_eq_signBit_of_toDyadic?_some hdb]
  exact denotes_roundDyadic_zero hfmt _ _

/-- Narrowing a finite binary32 value rounds its exact dyadic once to bf16. -/
theorem narrow_eq_roundDyadic {m : Model f32Fmt} {d : Numerics.Dyadic} (hd : Model.toDyadic? m = some d) :
    Model.cast f32Fmt bfFmt m = Model.roundDyadic bfFmt d := by
  have hx := Model.isFinite_eq_true_of_toDyadic?_some hd
  have hnan := Model.isNaN_eq_false_of_isFinite_eq_true m hx
  have hinf := Model.isInf_eq_false_of_isFinite_eq_true m hx
  have hformat : FloatFormat.binary32 ≠ FloatFormat.bfloat16 := by decide
  have hfrac : ¬ FloatFormat.binary32.fracWidth ≤ FloatFormat.bfloat16.fracWidth := by decide
  simp [Model.cast, hnan, hinf, hformat, hfrac, hd]

/-- Narrowing keeps a signed zero. -/
theorem denotes_narrow_zero {m : Model f32Fmt} (hm : Model.isFinite m = true) (h0 : Model.toReal m = 0) :
    Denotes (Model.cast f32Fmt bfFmt m) 0 (Model.signBit m) := by
  have zm := (Model.isZero_eq_true_iff_toReal_eq_zero m hm).mpr h0
  rw [narrow_eq_roundDyadic (Model.toDyadic?_eq_zero_of_isZero_eq_true m zm)]
  exact denotes_roundDyadic_zero (by decide) _ _

theorem canonicalize_eq {fmt : FloatFormat} (hfmt : fmt.isIEEE = true) {c : Model fmt}
    (hc : Model.isFinite c = true) : Model.canonicalizeModel c = c := by
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hc
  apply Model.eq_of_toDyadic?_eq_some _ hd
  rw [Model.toDyadic?_ieee_eq_model fmt hfmt, Model.toModel_canonicalizeModel,
    ← Model.toDyadic?_ieee_eq_model fmt hfmt, hd]

/-- The binary32 word of `BFloat16.widen v` is the exact cast. -/
theorem model_widen {v : Model bfFmt} (hv : Model.isFinite v = true) :
    model (BFloat16.widen v) = Model.cast bfFmt f32Fmt v := by
  have hc : Model.isFinite (Model.cast bfFmt f32Fmt v) = true := by
    rw [Model.cast_eq_widenExact_of_compatibleWidening v (by decide) (by decide) (by decide) (by decide) hv]
    exact Model.isFinite_widenExact v (by decide) (by decide) (by decide) (by decide) hv
  exact canonicalize_eq (by decide) hc

/-- Widening keeps finiteness, the real value and the sign bit. -/
theorem widen_denotes {v : Model bfFmt} (hv : Model.isFinite v = true) :
    Model.isFinite (model (BFloat16.widen v)) = true ∧ Model.toReal (model (BFloat16.widen v)) = Model.toReal v ∧
      Model.signBit (model (BFloat16.widen v)) = Model.signBit v := by
  rw [model_widen hv,
    Model.cast_eq_widenExact_of_compatibleWidening v (by decide) (by decide) (by decide) (by decide) hv]
  refine ⟨Model.isFinite_widenExact v _ _ _ _ hv, ?_, Model.signBit_widenExact v _ _ _ _⟩
  rw [← Model.cast_eq_widenExact_of_compatibleWidening v (by decide) (by decide) (by decide) (by decide) hv]
  exact Model.cast_exact_of_compatibleWidening v (by decide) (by decide) (by decide) (by decide) hv

/-- Native binary32 addition is the library's binary32 addition. -/
theorem model_add {a b : Float32} (ha : a.isFinite = true) (hb : b.isFinite = true) :
    model (a + b) = Model.add (model a) (model b) := by
  have h := FloatLib.Floats.ExecFloat.Binary.toModel_ofFloat32_add_of_isFinite a b ha hb
  rw [FloatLib.Floats.ExecFloat.Binary.toModel_ofFloat32, FloatLib.Floats.ExecFloat.Binary.toModel_ofFloat32,
    FloatLib.Floats.ExecFloat.Binary.toModel_ofFloat32] at h
  exact h

/-! ### Format constants -/

theorem bpow_eq (e : ℤ) : Formats.Flocq.bpow Numerics.binaryRadix e = (2:ℝ) ^ e := by
  simp [Formats.Flocq.bpow, Numerics.binaryRadix, Numerics.Radix.toReal]

theorem fexp32 (n : ℤ) : Model.fexpOf f32Fmt n = max (n - 24) (-149) := by
  simp only [Model.fexpOf, Formats.Flocq.fltExp]
  rw [show ((FloatFormat.binary32.fracWidth : ℤ) + 1) = 24 by decide,
    show FloatFormat.binary32.minSubnormalExponent = -149 by decide]

theorem fexpBF (n : ℤ) : Model.fexpOf bfFmt n = max (n - 8) (-133) := by
  simp only [Model.fexpOf, Formats.Flocq.fltExp]
  rw [show ((FloatFormat.bfloat16.fracWidth : ℤ) + 1) = 8 by decide,
    show FloatFormat.bfloat16.minSubnormalExponent = -133 by decide]

theorem threshold_eq_bf : (2:ℝ) ^ FloatFormat.bfloat16.minNormalExponent = FlushToZero.threshold := by
  rw [show FloatFormat.bfloat16.minNormalExponent = -126 by decide]; rfl

theorem posMax_bf : Model.toReal (Model.posMaxFinite bfFmt) = 255 * (2:ℝ) ^ (120:ℤ) := by
  rw [Model.toReal_posMaxFinite,
    show Model.pow2 FloatFormat.bfloat16.fracWidth + FloatFormat.bfloat16.maxFiniteFracField = 255 by decide,
    Model.bpow, bpow_eq,
    show FloatFormat.bfloat16.maxNormalExponent - Int.ofNat FloatFormat.bfloat16.fracWidth = 120 by decide]
  norm_num

/-! ### Flushing in both formats -/

theorem flushB_real (x : BFloat16Arithmetic.Value) : Model.toReal (BFloat16Arithmetic.flush x) =
    if |Model.toReal x| < FlushToZero.threshold then 0 else Model.toReal x := by
  unfold BFloat16Arithmetic.flush
  split
  · rename_i hs
    have hb := (Model.isSubnormal_iff_abs_toReal x).mp hs
    rw [threshold_eq_bf] at hb
    rw [Model.toReal_zero, ite_eq_left hb.2.2]
  · rename_i hs
    split
    · rename_i hlt
      by_cases hf : Model.isFinite x = true
      · by_contra hne
        exact hs ((Model.isSubnormal_iff_abs_toReal x).mpr
          ⟨hf, abs_pos.mpr hne, by rw [threshold_eq_bf]; exact hlt⟩)
      · rw [Model.toReal_eq]
        cases hd : Model.toDyadic? x
        · rfl
        · exact absurd (Model.isFinite_eq_true_of_toDyadic?_some hd) hf
    · rfl

theorem flushB_sign (x : BFloat16Arithmetic.Value) :
    Model.signBit (BFloat16Arithmetic.flush x) = Model.signBit x := by
  unfold BFloat16Arithmetic.flush
  split
  · rw [Model.signBit_zero, show FloatFormat.bfloat16.supportsSignedZero = true by decide, Bool.and_true]
  · rfl

theorem denotes_flushB_zero {m : BFloat16Arithmetic.Value} {s : Bool} (hm : Denotes m 0 s) :
    Denotes (BFloat16Arithmetic.flush m) 0 s := by
  refine ⟨BFloat16Arithmetic.finite_flush m hm.1, ?_, fun _ => by rw [flushB_sign]; exact hm.2.2 rfl⟩
  rw [flushB_real, hm.2.1]; simp

theorem toDyadic_of_unpack {x : Float32} {s : Float.Model.UnpackedFloat.Sign} {m : ℕ} {e : ℤ} {hm : 0 < m}
    (hu : x.toModel.unpack = .finite s m e hm) :
    Model.toDyadic? (model x) = some ⟨Model.modelSignBit s, m, e⟩ := by
  rw [Model.toDyadic?_ieee_eq_model _ (by decide)]
  change Model.unpackedToDyadic? x.toModel.unpack = _
  rw [hu]; rfl

theorem toDyadic_of_unpack_zero {x : Float32} {s : Float.Model.UnpackedFloat.Sign}
    (hu : x.toModel.unpack = .zero s) :
    Model.toDyadic? (model x) = some ⟨Model.modelSignBit s, 0, 0⟩ := by
  rw [Model.toDyadic?_ieee_eq_model _ (by decide)]
  change Model.unpackedToDyadic? x.toModel.unpack = _
  rw [hu]; rfl

theorem model_flushed_zero (s : Float.Model.UnpackedFloat.Sign) :
    model (Float32.ofModel (Float32.Model.pack (.zero s))) = Model.ofModel f32Fmt (.zero s) := rfl

/-- A binary32 value that `FlushToZero.flush` keeps (not a subnormal encoding) is at least `2^-126`. -/
theorem threshold_le_of_unpack {x : Float32} {s : Float.Model.UnpackedFloat.Sign} {m : ℕ} {e : ℤ} {hm : 0 < m}
    (hu : x.toModel.unpack = .finite s m e hm) (hn : ¬ (m < 8388608 ∧ e = -149)) :
    FlushToZero.threshold ≤ |real x| := by
  have hd := toDyadic_of_unpack hu
  have hr : real x = (⟨Model.modelSignBit s, m, e⟩ : Numerics.Dyadic).toReal := real_toDyadic hd
  have habs : |real x| = (m : ℝ) * (2:ℝ) ^ e := by
    rw [hr, Model.Dyadic.abs_toReal, bpow_eq]
  have hmin : (-149:ℤ) ≤ e := by
    have h := Model.minSubnormalExponent_le_toDyadic? (model x) hd
    rwa [show FloatFormat.binary32.minSubnormalExponent = -149 by decide] at h
  unfold FlushToZero.threshold
  by_cases he : e = -149
  · have hm' : 8388608 ≤ m := by omega
    rw [habs, he]
    have : (8388608 : ℝ) ≤ m := by exact_mod_cast hm'
    calc (2:ℝ) ^ (-126:ℤ) = 8388608 * (2:ℝ) ^ (-149:ℤ) := by norm_num
      _ ≤ (m:ℝ) * (2:ℝ) ^ (-149:ℤ) := by gcongr
  · have hc : Formats.Flocq.cexp Numerics.binaryRadix (Model.fexpOf f32Fmt) (real x) = e := by
      have h := Model.cexp_toDyadic? hd (Nat.pos_iff_ne_zero.mp hm)
      rw [← hr] at h; exact h
    have hx0 : real x ≠ 0 := by
      intro h0
      rw [h0, abs_zero] at habs
      have : (0:ℝ) < (m:ℝ) * (2:ℝ) ^ e := by
        have : (0:ℝ) < m := by exact_mod_cast hm
        positivity
      linarith
    unfold Formats.Flocq.cexp at hc
    rw [fexp32] at hc
    have hk : Formats.Flocq.magnitude Numerics.binaryRadix (real x) - 24 = e := by omega
    have hb := Formats.Flocq.bpow_magnitude_sub_one_le Numerics.binaryRadix (real x) hx0
    rw [bpow_eq] at hb
    calc (2:ℝ) ^ (-126:ℤ) ≤ (2:ℝ) ^ (Formats.Flocq.magnitude Numerics.binaryRadix (real x) - 1) :=
          zpow_le_zpow_right₀ (by norm_num) (by omega)
      _ ≤ |real x| := hb

/-- `FlushToZero.flush` zeroes exactly the finite values below `2^-126` in magnitude. -/
theorem flush32_real (x : Float32) (hx : x.isFinite = true) :
    real (FlushToZero.flush x) = if |real x| < FlushToZero.threshold then 0 else real x := by
  by_cases hlt : |real x| < FlushToZero.threshold
  · rw [ite_eq_left hlt]
    by_cases h0 : real x = 0
    · rw [FlushToZero.flush_eq_of_real_zero x h0, h0]
    · unfold FlushToZero.flush
      rcases hu : x.toModel.unpack with s | _ | s | ⟨s, m, e, hm⟩
      · exfalso
        simp [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite] at hx
      · exfalso
        simp [Float32.isFinite, Float32.Model.isFinite, hu, Float.Model.UnpackedFloat.isFinite] at hx
      · exact absurd (by rw [real, real_toDyadic (toDyadic_of_unpack_zero hu)]; simp [Numerics.Dyadic.toReal,
          Numerics.Dyadic.signedSignificand]) h0
      · dsimp only
        split
        · exact FlushToZero.real_signed_zero s
        · rename_i hn
          exact absurd hlt (not_lt.mpr (threshold_le_of_unpack hu hn))
  · rw [ite_eq_right hlt, FlushToZero.flush_eq_of_threshold_le x (not_lt.mp hlt)]

/-- `FlushToZero.flush` keeps the sign bit. -/
theorem flush32_sign (x : Float32) :
    Model.signBit (model (FlushToZero.flush x)) = Model.signBit (model x) := by
  unfold FlushToZero.flush
  rcases hu : x.toModel.unpack with s | _ | s | ⟨s, m, e, hm⟩
  · rfl
  · rfl
  · rfl
  · dsimp only
    split
    · rw [model_flushed_zero, Model.signBit_ofModel_zero]
      exact Model.sign_eq_signBit_of_toDyadic?_some (toDyadic_of_unpack hu)
    · rfl

/-! ### Rounding on the real grids -/

local notation "mag" => Formats.Flocq.magnitude Numerics.binaryRadix
local notation "cexpOf" fmt => Formats.Flocq.cexp Numerics.binaryRadix (Model.fexpOf fmt)

theorem roundAt_eq_scaled (fmt : FloatFormat) (x : ℝ) :
    Model.roundAt fmt x =
      (Formats.Flocq.nearestEven (x * (2:ℝ) ^ (-(cexpOf fmt) x)) : ℝ) * (2:ℝ) ^ ((cexpOf fmt) x) := by
  simp only [Model.roundAt, Formats.Flocq.round, Formats.Flocq.toReal, Formats.Flocq.scaledMantissa, bpow_eq]

theorem nearestEven_eq_of_near {x : ℝ} {n : ℤ} (h : |x - n| < 1/2) : Formats.Flocq.nearestEven x = n := by
  have h1 := Formats.Flocq.nearestEven_is_nearest_integer x n
  rw [abs_sub_comm (n:ℝ) x] at h1
  have h2 : |((Formats.Flocq.nearestEven x - n : ℤ) : ℝ)| < 1 := by
    push_cast
    calc |(Formats.Flocq.nearestEven x : ℝ) - n| = |((Formats.Flocq.nearestEven x : ℝ) - x) + (x - n)| := by
          ring_nf
      _ ≤ |(Formats.Flocq.nearestEven x : ℝ) - x| + |x - n| := abs_add_le _ _
      _ < 1 := by linarith
  have h3 : |Formats.Flocq.nearestEven x - n| < 1 := by exact_mod_cast h2
  have := abs_lt.mp h3
  omega

theorem zpow_split (e d : ℤ) (h : d ≤ e) : (2:ℝ) ^ e = ((2 ^ (e - d).toNat : ℕ) : ℝ) * (2:ℝ) ^ d := by
  rw [Nat.cast_pow, Nat.cast_ofNat, ← zpow_natCast, Int.toNat_of_nonneg (by omega), ← zpow_add₀ two_ne_zero]
  ring_nf

theorem two_zpow_pos (e : ℤ) : (0:ℝ) < (2:ℝ) ^ e := zpow_pos (by norm_num) e

theorem two_zpow_mul_neg (e : ℤ) : (2:ℝ) ^ e * (2:ℝ) ^ (-e) = 1 := by
  rw [← zpow_add₀ two_ne_zero, add_neg_cancel, zpow_zero]

theorem roundAt_pow (fmt : FloatFormat) (j : ℤ) (h : Model.fexpOf fmt (j + 1) ≤ j) :
    Model.roundAt fmt ((2:ℝ) ^ j) = (2:ℝ) ^ j := by
  rw [← bpow_eq]
  exact Formats.Flocq.round_preserves_generic Formats.Flocq.nearestEven _
    (Formats.Flocq.generic_format_bpow (β := Numerics.binaryRadix) (fexp := Model.fexpOf fmt) j h)

theorem cexp_bf (x : ℝ) : (cexpOf bfFmt) x = max (mag x - 8) (-133) := fexpBF _
theorem cexp_32 (x : ℝ) : (cexpOf f32Fmt) x = max (mag x - 24) (-149) := fexp32 _

/-- A bf16-grid value is `A·2^ea` with `|A| < 2^8` and `ea ≥ -133`. -/
theorem bf_rep {a : ℝ} (ha : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) a) :
    ∃ A ea : ℤ, (-256 < A ∧ A < 256) ∧ -133 ≤ ea ∧ a = (A:ℝ) * 2 ^ ea := by
  have hprec : (0:ℤ) < (FloatFormat.bfloat16.fracWidth : ℤ) + 1 := by decide
  obtain ⟨-, fa, hfa, hma, hea⟩ := (Formats.Flocq.generic_format_FLT_iff _ _ hprec a).mp ha
  have hbase : Numerics.binaryRadix.base ^ ((FloatFormat.bfloat16.fracWidth : ℤ) + 1).toNat = 256 := by decide
  rw [hbase] at hma
  rw [show FloatFormat.bfloat16.minSubnormalExponent = -133 by decide] at hea
  rw [Formats.Flocq.toReal, bpow_eq] at hfa
  exact ⟨fa.mantissa, fa.exponent, by omega, hea, hfa⟩

/-- A sum of two bf16-grid values is an integer multiple of `2^-133`. -/
theorem sum_scaled (A B ea eb : ℤ) (hea : -133 ≤ ea) (heb : -133 ≤ eb) :
    (A:ℝ) * 2 ^ ea + (B:ℝ) * 2 ^ eb =
      ((A * 2 ^ (ea + 133).toNat + B * 2 ^ (eb + 133).toNat : ℤ) : ℝ) * (2:ℝ) ^ (-133:ℤ) := by
  rw [zpow_split ea (-133) hea, zpow_split eb (-133) heb]
  push_cast; ring_nf

/-- A positive sum of two bf16-grid values is at least `2^-133`, so its magnitude is at least `-132`. -/
theorem sum_magnitude (A B ea eb : ℤ) (hea : -133 ≤ ea) (heb : -133 ≤ eb) (s : ℝ)
    (hsd : s = (A:ℝ) * 2 ^ ea + (B:ℝ) * 2 ^ eb) (hs : 0 < s) : -132 ≤ mag s := by
  have hN := hsd.trans (sum_scaled A B ea eb hea heb)
  have hNpos : (0:ℝ) < ((A * 2 ^ (ea + 133).toNat + B * 2 ^ (eb + 133).toNat : ℤ) : ℝ) := by
    rw [hN] at hs
    exact pos_of_mul_pos_left hs (two_zpow_pos _).le
  have hN1 : (1:ℝ) ≤ ((A * 2 ^ (ea + 133).toNat + B * 2 ^ (eb + 133).toNat : ℤ) : ℝ) := by
    have : (0:ℤ) < A * 2 ^ (ea + 133).toNat + B * 2 ^ (eb + 133).toNat := by exact_mod_cast hNpos
    exact_mod_cast this
  have hlow : (2:ℝ) ^ (-133:ℤ) ≤ s := by
    rw [hN]; nlinarith [two_zpow_pos (-133)]
  have hk2 := Formats.Flocq.abs_lt_bpow_magnitude Numerics.binaryRadix s hs.ne'
  rw [bpow_eq, abs_of_pos hs] at hk2
  by_contra hc
  have : (2:ℝ) ^ (mag s) ≤ (2:ℝ) ^ (-133:ℤ) := zpow_le_zpow_right₀ (by norm_num) (by omega)
  linarith

/-- A sum of two bf16-grid values below `2^-126` in magnitude is itself on the bf16 grid. -/
theorem sum_generic_of_small {a b : ℝ}
    (ha : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) a)
    (hb : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) b)
    (hs : |a + b| < FlushToZero.threshold) :
    Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) (a + b) := by
  obtain ⟨A, ea, -, hea, rfl⟩ := bf_rep ha
  obtain ⟨B, eb, -, heb, rfl⟩ := bf_rep hb
  have hN := sum_scaled A B ea eb hea heb
  set N : ℤ := A * 2 ^ (ea + 133).toNat + B * 2 ^ (eb + 133).toNat
  have hNr : |(N:ℝ)| < 128 := by
    rw [hN, abs_mul, abs_of_pos (two_zpow_pos _)] at hs
    unfold FlushToZero.threshold at hs
    have h1 : (2:ℝ) ^ (-126:ℤ) = 128 * 2 ^ (-133:ℤ) := by norm_num
    rw [h1] at hs
    exact lt_of_mul_lt_mul_right hs (two_zpow_pos _).le
  have hNi : |N| < 128 := by exact_mod_cast hNr
  have hprec : (0:ℤ) < (FloatFormat.bfloat16.fracWidth : ℤ) + 1 := by decide
  apply (Formats.Flocq.generic_format_FLT_iff _ _ hprec _).mpr
  refine ⟨hprec, ⟨N, -133⟩, ?_, ?_, ?_⟩
  · rw [Formats.Flocq.toReal, bpow_eq, hN]
  · have hbase : Numerics.binaryRadix.base ^ ((FloatFormat.bfloat16.fracWidth : ℤ) + 1).toNat = 256 := by
      decide
    rw [hbase]
    have := abs_lt.mp hNi
    change N.natAbs < 256
    omega
  · rw [show FloatFormat.bfloat16.minSubnormalExponent = -133 by decide]

/-! ### Double rounding -/

/-- The main case: the smaller operand `B·2^eb` lies below the binary32 grid of the sum `s`. Then it is
below `2^(e-9)` for the bf16 exponent `e` of `s`, the larger operand is a multiple of `2^e`, and both
`s` and its binary32 rounding are within a quarter unit of that multiple, so both round to it. -/
theorem dr_main (A B ea eb : ℤ) (hA : -256 < A ∧ A < 256) (hB : -256 < B ∧ B < 256)
    (hea : -133 ≤ ea) (heb : -133 ≤ eb) (s : ℝ)
    (hsd : s = (A:ℝ) * 2 ^ ea + (B:ℝ) * 2 ^ eb) (hs : 0 < s)
    (hsmall : eb < max (mag s - 8) (-133) - 16) :
    Model.roundAt bfFmt (Model.roundAt f32Fmt s) = Model.roundAt bfFmt s := by
  have hk132 := sum_magnitude A B ea eb hea heb s hsd hs
  set k := mag s with hk
  set e := max (k - 8) (-133) with he
  have hs0 : s ≠ 0 := hs.ne'
  have hk1 := Formats.Flocq.bpow_magnitude_sub_one_le Numerics.binaryRadix s hs0
  have hk2 := Formats.Flocq.abs_lt_bpow_magnitude Numerics.binaryRadix s hs0
  rw [bpow_eq, abs_of_pos hs] at hk1 hk2
  -- the small operand
  have hBabs : |(B:ℝ)| ≤ 255 := abs_le.mpr ⟨by exact_mod_cast (show (-255:ℤ) ≤ B by omega),
    by exact_mod_cast (show B ≤ 255 by omega)⟩
  have hb_small : |(B:ℝ) * 2 ^ eb| < 2 ^ (e - 9) := by
    rw [abs_mul, abs_of_pos (two_zpow_pos _)]
    have h1 : (2:ℝ) ^ eb ≤ 2 ^ (e - 17) := zpow_le_zpow_right₀ (by norm_num) (by omega)
    have h2 : (2:ℝ) ^ (e - 9) = 256 * 2 ^ (e - 17) := by
      rw [show e - 9 = 8 + (e - 17) by ring, zpow_add₀ two_ne_zero]; norm_num
    rw [h2]
    have := two_zpow_pos (e - 17)
    nlinarith [abs_nonneg (B:ℝ), two_zpow_pos eb]
  -- the large operand is a multiple of `2^e`
  have h6 : e ≤ ea := by
    by_contra hc
    have hek : e = k - 8 := by omega
    have hAr : (A:ℝ) ≤ 255 := by exact_mod_cast (show A ≤ 255 by omega)
    have h1 : (2:ℝ) ^ ea ≤ 2 ^ (e - 1) := zpow_le_zpow_right₀ (by norm_num) (by omega)
    have h2 : (A:ℝ) * 2 ^ ea ≤ 255 * 2 ^ (e - 1) := by nlinarith [two_zpow_pos ea]
    have h3 : (2:ℝ) ^ (e - 9) ≤ 2 ^ (e - 1) := zpow_le_zpow_right₀ (by norm_num) (by omega)
    have h4 : (2:ℝ) ^ (k - 1) = 256 * 2 ^ (e - 1) := by
      rw [show k - 1 = 8 + (e - 1) by omega, zpow_add₀ two_ne_zero]; norm_num
    have h5 := le_abs_self ((B:ℝ) * 2 ^ eb)
    linarith
  set I : ℤ := A * 2 ^ (ea - e).toNat with hIdef
  have hI : (A:ℝ) * 2 ^ ea = (I:ℝ) * 2 ^ e := by
    rw [zpow_split ea e h6, hIdef]; push_cast; ring
  have hsI : s * 2 ^ (-e) - I = ((B:ℝ) * 2 ^ eb) * 2 ^ (-e) := by
    rw [hsd, add_mul, hI, mul_assoc, two_zpow_mul_neg]; ring
  have hsnear : |s * 2 ^ (-e) - I| < 2 ^ (-9:ℤ) := by
    rw [hsI, abs_mul, abs_of_pos (two_zpow_pos _)]
    calc |(B:ℝ) * 2 ^ eb| * 2 ^ (-e) < 2 ^ (e - 9) * 2 ^ (-e) :=
          mul_lt_mul_of_pos_right hb_small (two_zpow_pos _)
      _ = 2 ^ (-9:ℤ) := by rw [← zpow_add₀ two_ne_zero, show e - 9 + -e = -9 by ring]
  have hsnear2 : |s * 2 ^ (-e) - I| < 1/2 := by
    have : (2:ℝ) ^ (-9:ℤ) < 1/2 := by norm_num
    exact lt_trans hsnear this
  have hRs : Model.roundAt bfFmt s = (I:ℝ) * 2 ^ e := by
    rw [roundAt_eq_scaled, cexp_bf, ← hk, ← he, nearestEven_eq_of_near hsnear2]
  -- the binary32 rounding
  set t := Model.roundAt f32Fmt s with htdef
  have hc32 : (cexpOf f32Fmt) s = e - 16 := by rw [cexp_32, ← hk]; omega
  have hts : |t - s| ≤ 2 ^ (e - 16) / 2 := by
    have := Formats.Flocq.error_bound_ulp (β := Numerics.binaryRadix) (fexp := Model.fexpOf f32Fmt)
      Formats.Flocq.nearestEven s
    simp only [Formats.Flocq.ulp, hs0, ite_false, bpow_eq, hc32] at this
    exact this
  have hlo : (2:ℝ) ^ (k - 1) ≤ t := by
    have h := Model.roundAt_mono f32Fmt hk1
    rwa [roundAt_pow f32Fmt (k - 1) (by rw [fexp32]; omega)] at h
  have hhi : t ≤ (2:ℝ) ^ k := by
    have h := Model.roundAt_mono f32Fmt hk2.le
    rwa [roundAt_pow f32Fmt k (by rw [fexp32]; omega)] at h
  have htnear : |t * 2 ^ (-e) - I| < 1/2 := by
    have h1 : t * 2 ^ (-e) - I = (t - s) * 2 ^ (-e) + (s * 2 ^ (-e) - I) := by ring
    have h2 : |(t - s) * 2 ^ (-e)| ≤ 2 ^ (-17:ℤ) := by
      rw [abs_mul, abs_of_pos (two_zpow_pos _)]
      calc |t - s| * 2 ^ (-e) ≤ 2 ^ (e - 16) / 2 * 2 ^ (-e) :=
            mul_le_mul_of_nonneg_right hts (two_zpow_pos _).le
        _ = 2 ^ (-17:ℤ) := by
          rw [div_mul_eq_mul_div, ← zpow_add₀ two_ne_zero, show e - 16 + -e = -16 by ring]; norm_num
    rw [h1]
    calc |(t - s) * 2 ^ (-e) + (s * 2 ^ (-e) - I)| ≤ |(t - s) * 2 ^ (-e)| + |s * 2 ^ (-e) - I| :=
          abs_add_le _ _
      _ < 2 ^ (-17:ℤ) + 2 ^ (-9:ℤ) := by linarith
      _ < 1/2 := by norm_num
  rw [hRs]
  rcases lt_or_eq_of_le hhi with hlt | heq
  · -- `t` stays in the binade of `s`, so it is rounded at the same exponent `e`
    have hmt : mag t = k := Formats.Flocq.magnitude_eq_of_bpow_bounds Numerics.binaryRadix t k
      (ne_of_gt (lt_of_lt_of_le (two_zpow_pos _) hlo))
      (by rw [bpow_eq, abs_of_pos (lt_of_lt_of_le (two_zpow_pos _) hlo)]; exact hlo)
      (by rw [bpow_eq, abs_of_pos (lt_of_lt_of_le (two_zpow_pos _) hlo)]; exact hlt)
    rw [roundAt_eq_scaled, cexp_bf, hmt, ← he, nearestEven_eq_of_near htnear]
  · -- `t = 2^k` is on the bf16 grid and is the multiple of `2^e` nearest to `s`
    rw [heq, roundAt_pow bfFmt k (by rw [fexpBF]; omega)]
    have hP := zpow_split k e (by omega)
    set P : ℕ := 2 ^ (k - e).toNat
    have hPe : (2:ℝ) ^ k * 2 ^ (-e) = (P:ℝ) := by rw [hP, mul_assoc, two_zpow_mul_neg, mul_one]
    rw [heq, hPe] at htnear
    have h1 := nearestEven_eq_of_near (x := ((P:ℤ):ℝ)) (n := I) (by exact_mod_cast htnear)
    have h2 : Formats.Flocq.nearestEven (((P:ℤ)):ℝ) = (P:ℤ) := Formats.Flocq.ValidRnd.id _
    rw [h2] at h1
    rw [hP, show ((P:ℕ):ℝ) = ((P:ℤ):ℝ) by norm_cast, h1]

/-- Positive sums of two bf16-grid values: either the sum is exact in binary32, or `dr_main` applies
with the operand roles chosen so that the smaller one lies below the binary32 grid. -/
theorem dr_pos (A B ea eb : ℤ) (hA : -256 < A ∧ A < 256) (hB : -256 < B ∧ B < 256)
    (hea : -133 ≤ ea) (heb : -133 ≤ eb) (s : ℝ)
    (hsd : s = (A:ℝ) * 2 ^ ea + (B:ℝ) * 2 ^ eb) (hs : 0 < s) :
    Model.roundAt bfFmt (Model.roundAt f32Fmt s) = Model.roundAt bfFmt s := by
  by_cases h1 : eb < max (mag s - 8) (-133) - 16
  · exact dr_main A B ea eb hA hB hea heb s hsd hs h1
  by_cases h2 : ea < max (mag s - 8) (-133) - 16
  · exact dr_main B A eb ea hB hA heb hea s (by rw [hsd]; ring) hs h2
  rw [not_lt] at h1 h2
  have hk132 := sum_magnitude A B ea eb hea heb s hsd hs
  set e := max (mag s - 8) (-133) with he
  have hc32 : (cexpOf f32Fmt) s = e - 16 := by rw [cexp_32]; omega
  have hgen : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf f32Fmt) s := by
    apply Formats.Flocq.generic_format_of_scaled_mantissa_int s
      (A * 2 ^ (ea - (e - 16)).toNat + B * 2 ^ (eb - (e - 16)).toNat)
    rw [Formats.Flocq.scaledMantissa, hc32, bpow_eq, hsd, zpow_split ea (e - 16) h2,
      zpow_split eb (e - 16) h1]
    push_cast
    have := two_zpow_mul_neg (e - 16)
    linear_combination ((A:ℝ) * 2 ^ (ea - (e - 16)).toNat + B * 2 ^ (eb - (e - 16)).toNat) * this
  rw [show Model.roundAt f32Fmt s = s from Formats.Flocq.round_preserves_generic _ s hgen]

/-- **Innocuous double rounding.** For two values on the bf16 grid (gradual underflow, no exponent
bound), rounding their exact sum to binary32 and then to bf16 equals rounding it to bf16 once. -/
theorem double_round {a b : ℝ}
    (ha : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) a)
    (hb : Formats.Flocq.genericFormat Numerics.binaryRadix (Model.fexpOf bfFmt) b) :
    Model.roundAt bfFmt (Model.roundAt f32Fmt (a + b)) = Model.roundAt bfFmt (a + b) := by
  obtain ⟨A, ea, hA, hea, hfa⟩ := bf_rep ha
  obtain ⟨B, eb, hB, heb, hfb⟩ := bf_rep hb
  rcases lt_trichotomy (a + b) 0 with hn | hz | hp
  · have hneg := dr_pos (-A) (-B) ea eb (by omega) (by omega) hea heb
      (-(a + b)) (by rw [hfa, hfb]; push_cast; ring) (by linarith)
    rw [Model.roundAt_neg, Model.roundAt_neg, Model.roundAt_neg] at hneg
    linarith
  · rw [hz, Model.roundAt_zero]
  · exact dr_pos A B ea eb hA hB hea heb (a + b) (by rw [hfa, hfb]) hp

/-! ### Finiteness of bf16 rounding -/

/-- Nearest-even rounding of a nonzero dyadic to bf16 is finite whenever its real rounding is within
the finite range (the library's `isFinite_roundDyadic_of_isIEEE_of_abs_toReal_le_posMaxFinite` bounds
the exact value instead, which excludes sums just above the largest finite value). -/
theorem roundDyadic_bf_finite (d : Numerics.Dyadic) (hm : d.significand ≠ 0)
    (hb : |Model.roundAt bfFmt d.toReal| ≤ Model.toReal (Model.posMaxFinite bfFmt)) :
    Model.isFinite (Model.roundDyadic bfFmt d) = true := by
  have hM := posMax_bf
  have hmin : FloatFormat.ieeeMinNormalExponent bfFmt = -126 := by decide
  by_cases hsub : (d.significand.log2 : ℤ) + d.exponent < FloatFormat.ieeeMinNormalExponent bfFmt
  · apply Model.isFinite_roundDyadic_of_isIEEE_of_abs_toReal_le_posMaxFinite _ (by decide)
    rw [Model.Dyadic.abs_toReal, bpow_eq, hM]
    rw [hmin] at hsub
    have h1 : (d.significand : ℝ) < 2 ^ ((d.significand.log2 + 1 : ℕ) : ℤ) := by
      rw [zpow_natCast]; exact_mod_cast Nat.lt_log2_self
    have h2 : (d.significand : ℝ) * 2 ^ d.exponent ≤
        2 ^ ((d.significand.log2 + 1 : ℕ) : ℤ) * 2 ^ d.exponent :=
      mul_le_mul_of_nonneg_right h1.le (two_zpow_pos _).le
    rw [← zpow_add₀ two_ne_zero] at h2
    have h3 : (2:ℝ) ^ (((d.significand.log2 + 1 : ℕ) : ℤ) + d.exponent) ≤ 2 ^ (-126:ℤ) :=
      zpow_le_zpow_right₀ (by norm_num) (by push_cast; omega)
    have h4 : (2:ℝ) ^ (-126:ℤ) ≤ 255 * 2 ^ (120:ℤ) := by norm_num
    linarith
  · have hnormal := le_of_not_gt hsub
    have hr := Model.roundAt_dyadic_eq bfFmt d (by decide) hm
    simp only [Model.targetExponent_eq_normal _ _ _ hnormal,
      Model.roundMantissaAtExponentEven_eq_roundMantissaToLeadingBitEven] at hr
    rw [Model.roundDyadic, ite_eq_left (by decide), Model.ieeeRoundDyadic,
      Model.round_exact_eq_finishRoundedMantissa _ _ _ _ hm,
      Model.targetExponent_eq_normal _ _ _ hnormal,
      Model.roundMantissaAtExponentEven_eq_roundMantissaToLeadingBitEven]
    have hlo := Model.pow2_le_roundMantissaToLeadingBitEven d.significand bfFmt.fracWidth hm
    have hhi := Model.roundMantissaToLeadingBitEven_le_pow2_succ d.significand bfFmt.fracWidth
    have hfw : ((FloatFormat.bfloat16.fracWidth : ℕ) : ℤ) = 7 := by decide
    have habs : |Model.roundAt bfFmt d.toReal| =
        (Model.roundMantissaToLeadingBitEven d.significand bfFmt.fracWidth : ℝ) *
          2 ^ ((d.significand.log2 : ℤ) + d.exponent - 7) := by
      rw [hr, bpow_eq, hfw]
      cases d.negative <;> simp [abs_mul, abs_of_pos (two_zpow_pos _)]
    rw [habs, hM] at hb
    have hp7 : Model.pow2 bfFmt.fracWidth = 128 := by decide
    have hp8 : Model.pow2 (bfFmt.fracWidth + 1) = 256 := by decide
    have hbits : (FloatFormat.toModel bfFmt).exponentBits = 8 := by decide
    have hbias : (FloatFormat.toModel bfFmt).exponentBias = 127 := by decide
    have hmb : (FloatFormat.toModel bfFmt).mantissaBitsWithoutImplicit = 7 := by decide
    rw [hmin] at hnormal
    rcases lt_or_eq_of_le hhi with hlt | heq
    · rw [Model.finishRoundedMantissa_normalized _ _ _ _ hlo hlt (by rw [hmin]; exact hnormal)]
      have hm' : Model.roundMantissaToLeadingBitEven d.significand bfFmt.fracWidth ≠ 0 := by
        rw [hp7] at hlo; omega
      apply Model.isFinite_ofModel_finite_of_noOverflow _ (by decide) _ _ _ hm'
      have hk : (d.significand.log2 : ℤ) + d.exponent ≤ 127 := by
        by_contra hc
        have h1 : (128:ℝ) ≤ (Model.roundMantissaToLeadingBitEven d.significand bfFmt.fracWidth : ℝ) := by
          rw [hp7] at hlo; exact_mod_cast hlo
        have h2 : (2:ℝ) ^ (121:ℤ) ≤ 2 ^ ((d.significand.log2 : ℤ) + d.exponent - 7) :=
          zpow_le_zpow_right₀ (by norm_num) (by omega)
        have h3 : (128:ℝ) * 2 ^ (121:ℤ) ≤ 255 * 2 ^ (120:ℤ) := by nlinarith [two_zpow_pos (121:ℤ)]
        norm_num at h3
      rw [hbits, hbias, hmb, hfw]
      omega
    · rw [heq, Model.finishRoundedMantissa_normalized_carry _ _ _ (by rw [hmin]; exact hnormal)]
      apply Model.isFinite_ofModel_finite_of_noOverflow _ (by decide) _ _ _ (by rw [hp7]; decide)
      have hk : (d.significand.log2 : ℤ) + d.exponent ≤ 126 := by
        by_contra hc
        rw [heq, hp8] at hb
        have h2 : (2:ℝ) ^ (120:ℤ) ≤ 2 ^ ((d.significand.log2 : ℤ) + d.exponent - 7) :=
          zpow_le_zpow_right₀ (by norm_num) (by omega)
        push_cast at hb
        nlinarith [two_zpow_pos (120:ℤ)]
      rw [hbits, hbias, hmb, hfw]
      omega

/-! ## The bf16 addition is the residual kernel's double rounding -/

open Inference.Kernels.ResidualRmsNorm in
/-- One flushed bf16 addition equals the residual kernel's widened, flushed binary32 addition
followed by narrowing, for every pair of operands `AddFinite` admits. -/
theorem add_eq_residual (x u : BFloat16Arithmetic.Value) (h : AddFinite x u) :
    BFloat16Arithmetic.add x u = residual x u := by
  have hx := h.input
  have hu := h.updateFinite
  set X := BFloat16Arithmetic.flush x with hXdef
  set U := BFloat16Arithmetic.flush u with hUdef
  have hXf : Model.isFinite X = true := BFloat16Arithmetic.finite_flush x hx
  have hUf : Model.isFinite U = true := BFloat16Arithmetic.finite_flush u hu
  have hwx : (BFloat16.widen x).isFinite = true := BFloat16.widen_finite x hx
  have hwu : (BFloat16.widen u).isFinite = true := BFloat16.widen_finite u hu
  obtain ⟨-, wxr, wxs⟩ := widen_denotes hx
  obtain ⟨-, wur, wus⟩ := widen_denotes hu
  set x32 := FlushToZero.flush (BFloat16.widen x) with hx32def
  set u32 := FlushToZero.flush (BFloat16.widen u) with hu32def
  have hx32f : x32.isFinite = true := FlushToZero.finite_flush _ hwx
  have hu32f : u32.isFinite = true := FlushToZero.finite_flush _ hwu
  -- the flushed operands agree in value and sign across the two formats
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
  have hmx : Model.isFinite (model x32) = true := by rw [finite_model]; exact hx32f
  have hmu : Model.isFinite (model u32) = true := by rw [finite_model]; exact hu32f
  have hG : model (x32 + u32) = Model.add (model x32) (model u32) := model_add hx32f hu32f
  have hGf : Model.isFinite (model (x32 + u32)) = true := by rw [finite_model]; exact h.sum
  have hcast : Model.isFinite (residual x u) = true := h.cast
  have hres : residual x u = Model.cast f32Fmt bfFmt (model (FlushToZero.flush (x32 + u32))) := rfl
  have hadd : BFloat16Arithmetic.add x u = BFloat16Arithmetic.flush (Model.add X U) := rfl
  rw [hres] at hcast ⊢
  rw [hadd]
  set s := Model.toReal X + Model.toReal U with hsdef
  have hs32 : Model.toReal (model x32) + Model.toReal (model u32) = s := by rw [rx, ru]
  have hgX := Model.toReal_genericFormat_of_isFinite X hXf
  have hgU := Model.toReal_genericFormat_of_isFinite U hUf
  have hGr : Model.toReal (model (x32 + u32)) = Model.roundAt f32Fmt s := by
    rw [hG, Model.toReal_add_eq_roundAt _ _ (by decide) hmx hmu (hG ▸ hGf), hs32]
  by_cases hz : s = 0
  · -- exact cancellation or two zeros: both sides are the zero of the round-to-nearest sign rule
    have hL := denotes_flushB_zero (denotes_add_zero (by decide) hXf hUf hz)
    have hR0 := denotes_add_zero (by decide) hmx hmu (hs32.trans hz)
    rw [← hG] at hR0
    rw [FlushToZero.flush_eq_of_real_zero _ hR0.2.1] at hcast ⊢
    have hR := denotes_narrow_zero hR0.1 hR0.2.1
    rw [hR0.2.2 rfl, sx, su] at hR
    exact hL.eq hR
  by_cases hsmall : |s| < FlushToZero.threshold
  · -- the exact sum is a nonzero bf16 subnormal: both sides flush it to the zero of its sign
    have hgs := sum_generic_of_small hgX hgU hsmall
    have hbound : |s| ≤ Model.toReal (Model.posMaxFinite bfFmt) := by
      rw [posMax_bf]; unfold FlushToZero.threshold at hsmall
      have : (2:ℝ) ^ (-126:ℤ) ≤ 255 * 2 ^ (120:ℤ) := by norm_num
      linarith
    have hAf := Model.isFinite_add_of_abs_toReal_add_le_posMaxFinite X U (by decide) hXf hUf hbound
    have hAr : Model.toReal (Model.add X U) = s := by
      rw [Model.toReal_add_eq_roundAt _ _ (by decide) hXf hUf hAf]
      exact Formats.Flocq.round_preserves_generic _ _ hgs
    have hL : Denotes (BFloat16Arithmetic.flush (Model.add X U)) 0 (decide (s < 0)) := by
      refine ⟨BFloat16Arithmetic.finite_flush _ hAf, ?_, fun _ => ?_⟩
      · rw [flushB_real, hAr, ite_eq_left hsmall]
      · rw [flushB_sign, signBit_of_ne_zero hAf (hAr ▸ hz), hAr]
    have hg32 := Model.genericFormat_of_compatibleWidening (src := bfFmt) (dst := f32Fmt)
      (by decide) (by decide) hgs
    have hGs : Model.toReal (model (x32 + u32)) = s := by
      rw [hGr]; exact Formats.Flocq.round_preserves_generic _ _ hg32
    have hF0 : real (FlushToZero.flush (x32 + u32)) = 0 := by
      rw [flush32_real _ h.sum]
      show (if |Model.toReal (model (x32 + u32))| < FlushToZero.threshold then 0
        else Model.toReal (model (x32 + u32))) = 0
      rw [hGs, ite_eq_left hsmall]
    have hFf : Model.isFinite (model (FlushToZero.flush (x32 + u32))) = true := by
      rw [finite_model]; exact FlushToZero.finite_flush _ h.sum
    have hR := denotes_narrow_zero hFf hF0
    rw [flush32_sign, signBit_of_ne_zero hGf (hGs ▸ hz), hGs] at hR
    exact hL.eq hR
  · -- normal range: the flushes are identities and the two roundings agree (`double_round`)
    have hnorm : FlushToZero.threshold ≤ |s| := not_lt.mp hsmall
    have hGn : FlushToZero.threshold ≤ |Model.toReal (model (x32 + u32))| := by
      rw [hGr]; exact FlushToZero.round_normal s hnorm
    rw [FlushToZero.flush_eq_of_threshold_le _ hGn] at hcast ⊢
    have hRr : Model.toReal (Model.cast f32Fmt bfFmt (model (x32 + u32))) = Model.roundAt bfFmt s := by
      rw [Model.cast_eq_roundAt (by decide) (by decide) _ hGf hcast, hGr]
      exact double_round hgX hgU
    -- the bf16 addition does not overflow, since its rounding is the finite right-hand side
    obtain ⟨dX, hdX⟩ := Model.exists_toDyadic?_of_isFinite hXf
    obtain ⟨dU, hdU⟩ := Model.exists_toDyadic?_of_isFinite hUf
    have hdS : (Model.addDyadic dX dU).toReal = s := by
      rw [Model.Dyadic.toReal_addDyadic, ← real_toDyadic hdX, ← real_toDyadic hdU]
    have hAf : Model.isFinite (Model.add X U) = true := by
      rw [add_eq_roundDyadic hdX hdU]
      apply roundDyadic_bf_finite
      · intro h0
        exact hz (hdS ▸ (Model.Dyadic.toReal_eq_zero_iff _).mpr h0)
      · rw [hdS, ← hRr]
        exact Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite _ (by decide) hcast
    have hAr : Model.toReal (Model.add X U) = Model.roundAt bfFmt s :=
      Model.toReal_add_eq_roundAt _ _ (by decide) hXf hUf hAf
    have hAn : FlushToZero.threshold ≤ |Model.toReal (Model.add X U)| := by
      rw [hAr]; exact BFloat16Arithmetic.round_normal s hnorm
    rw [BFloat16Arithmetic.flush_eq_of_normal _ (Or.inr hAn)]
    have hne : Model.roundAt bfFmt s ≠ 0 := by
      intro h0; rw [hAr, h0, abs_zero] at hAn; exact absurd hAn (not_le.mpr FlushToZero.threshold_pos)
    exact Model.eq_of_toReal_eq_of_nonzero hAf hcast (hAr.trans hRr.symm) (hAr ▸ hne)

end Metal.Bridge.SingleRounding

namespace Metal.Bridge.ResidualRmsNorm

/-- The hypothesis `SingleRounding` of the residual bridge holds. -/
theorem singleRounding : SingleRounding :=
  fun x u h => Metal.Bridge.SingleRounding.add_eq_residual x u h

end Metal.Bridge.ResidualRmsNorm
