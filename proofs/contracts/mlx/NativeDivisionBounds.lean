import contracts.mlx.Float32Bounds
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.SqrtSemantics

namespace Inference.Contracts.Mlx.NativeDivisionBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.Formats.Flocq Float.Model.UnpackedFloat

-- These theorems concern Lean's logical Float32 operation. They discharge
-- software range obligations; compiled scalar division still needs its
-- separate hardware/compiler correspondence contract.

private theorem round_zero_finite (fmt : FloatFormat) (hfmt : fmt.isIEEE = true)
    (sign : Sign) (exponent : Int) (accuracy : Accuracy) (value : ℝ)
    (ha : Model.accuracyRepresents 0 accuracy value)
    (he : exponent ≤ fmt.toModel.targetExponent (Float.Model.totalExponent 0 exponent)) :
    Model.isFinite (Model.ofModel fmt (roundWithAccuracy fmt.toModel sign 0 exponent accuracy)) = true := by
  have hfloor : exponent ≤ FloatFormat.ieeeMinSubnormalExponent fmt := by
    rw [← Model.toModel_minExponent]
    exact ((Model.le_targetExponent_totalExponent_iff _ 0 exponent).mp he).resolve_right
      (Nat.not_le.mpr (Nat.two_pow_pos _))
  have htarget : fmt.toModel.targetExponent (Float.Model.totalExponent 0 exponent) =
      FloatFormat.ieeeMinSubnormalExponent fmt := by
    apply Model.targetExponent_eq_minSubnormal_of_lt_minNormal
    have hw := fmt.fracWidth_pos
    unfold FloatFormat.ieeeMinSubnormalExponent at hfloor
    unfold FloatFormat.ieeeMinNormalExponent
    simp only [Nat.log2_zero, Int.ofNat_eq_natCast, Nat.cast_zero] at hfloor ⊢
    omega
  let rounded := (shiftToTargetExponent fmt.toModel 0 exponent accuracy).1.roundedMantissa
  have hr : Int.ofNat rounded = nearestEven
      (value * bpow FloatLib.Numerics.binaryRadix (exponent - FloatFormat.ieeeMinSubnormalExponent fmt)) := by
    rw [← htarget]
    exact Model.roundedMantissa_shiftToTargetExponent_eq_nearestEven fmt 0 exponent accuracy value ha he
  have hv : 0 ≤ value ∧ value < 1 := by
    simpa using Model.accuracyRepresents_bounds ha
  have hp := bpow.pos FloatLib.Numerics.binaryRadix
    (exponent - FloatFormat.ieeeMinSubnormalExponent fmt)
  have hu : bpow FloatLib.Numerics.binaryRadix
      (exponent - FloatFormat.ieeeMinSubnormalExponent fmt) ≤ 1 := by
    have h := (bpow_le_bpow_iff FloatLib.Numerics.binaryRadix
      (exponent - FloatFormat.ieeeMinSubnormalExponent fmt) 0).mpr (by omega)
    simpa [bpow] using h
  have hscaled : value * bpow FloatLib.Numerics.binaryRadix
      (exponent - FloatFormat.ieeeMinSubnormalExponent fmt) ≤ ((1 : Nat) : ℝ) := by
    rw [Nat.cast_one]
    exact (mul_le_mul hv.2.le hu hp.le zero_le_one).trans_eq (one_mul 1)
  have hsmall : rounded ≤ Model.pow2 fmt.fracWidth := by
    have hone : rounded ≤ 1 :=
      Int.ofNat_le.mp (hr.trans_le (Model.nearestEven_le_natCast_of_le hscaled))
    exact hone.trans (by rw [Model.pow2_eq_two_pow]; exact Nat.one_le_two_pow)
  rw [Model.roundWithAccuracy_eq_finishRoundedMantissa,
    Model.shiftToTargetExponent_eq_of_le_targetExponent fmt 0 exponent accuracy he]
  change Model.isFinite (Model.ofModel fmt
    (Model.finishRoundedMantissa fmt.toModel sign
      (rounded, fmt.toModel.targetExponent (Float.Model.totalExponent 0 exponent)))) = true
  rw [htarget]
  by_cases hz : rounded = 0
  · rw [hz, Model.finishRoundedMantissa_zero]
    exact Model.isFinite_ofModel_zero fmt hfmt sign
  · rw [Model.finishRoundedMantissa_at_minSubnormal fmt sign rounded hz hsmall]
    apply Model.isFinite_ofModel_finite_of_noOverflow fmt hfmt sign rounded _ hz
    have hbias := FloatFormat.two_pow_expWidth_eq_two_mul_bias_add_two fmt
    have hfour : 4 ≤ 2 ^ fmt.expWidth :=
      Nat.pow_le_pow_right (by decide : 0 < 2) fmt.expWidth_ge_two
    change ¬2 ^ fmt.expWidth ≤
      (FloatFormat.ieeeMinSubnormalExponent fmt + fmt.bias + fmt.fracWidth).toNat + 1
    simp only [FloatFormat.ieeeMinSubnormalExponent, Int.ofNat_eq_natCast]
    omega

private theorem unpacked_div_finite (fmt : FloatFormat) (hfmt : fmt.isIEEE = true)
    (sx sy : Sign) (mx my : Nat) (ex ey : Int) (hmx : 0 < mx) (hmy : 0 < my)
    (hb : |Model.unpackedToReal (.finite sx mx ex hmx) /
      Model.unpackedToReal (.finite sy my ey hmy)| <
      bpow FloatLib.Numerics.binaryRadix (Int.ofNat (FloatFormat.ieeeMaxNormalExponent fmt))) :
    Model.isFinite (Model.ofModel fmt (div fmt.toModel
      (.finite sx mx ex hmx) (.finite sy my ey hmy))) = true := by
  let target := min (ex - ey) (fmt.toModel.targetExponent
    (Float.Model.totalExponent mx ex - Float.Model.totalExponent my ey))
  let shift := (ex - ey - target).toNat
  let numerator := mx <<< shift
  let quotient := numerator / my
  let accuracy := accuracyOfFraction (numerator % my) my
  have hcore : divCore fmt.toModel mx ex my ey = (quotient, target, accuracy) := rfl
  have ha : Model.accuracyRepresents quotient accuracy ((numerator : ℝ) / my) :=
    Model.accuracyRepresents_accuracyOfFraction numerator my hmy.ne'
  have he := Model.divCore_exponent_le_targetExponent fmt.toModel ex ey hmx hmy
  rw [hcore] at he
  change Model.isFinite (Model.ofModel fmt
    (roundWithAccuracy fmt.toModel (sx / sy) quotient target accuracy)) = true
  by_cases hz : quotient = 0
  · rw [hz] at ha he ⊢
    exact round_zero_finite fmt hfmt _ _ _ _ ha he
  · apply Model.isFinite_ofModel_roundWithAccuracy_of_lt_bpow fmt hfmt _ _ _ _ _ hz ha he
    have ht : target ≤ ex - ey := min_le_left _ _
    have hs : (shift : Int) = ex - ey - target := Int.toNat_of_nonneg (sub_nonneg.mpr ht)
    have hn : (numerator : ℝ) = (mx : ℝ) * bpow FloatLib.Numerics.binaryRadix (shift : Int) := by
      dsimp only [numerator]
      rw [Nat.shiftLeft_eq, Nat.cast_mul, Nat.cast_pow]
      simp [bpow, FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]
    have hscale : ((numerator : ℝ) / my) * bpow FloatLib.Numerics.binaryRadix target =
        ((mx : ℝ) * bpow FloatLib.Numerics.binaryRadix ex) /
          ((my : ℝ) * bpow FloatLib.Numerics.binaryRadix ey) := by
      rw [hn, div_mul_eq_mul_div, mul_assoc, ← bpow.add_exp,
        show (shift : Int) + target = ex - ey by omega, bpow.sub_exp]
      field_simp
    rw [hscale]
    have hx : 0 ≤ (mx : ℝ) * bpow FloatLib.Numerics.binaryRadix ex :=
      mul_nonneg (Nat.cast_nonneg _) (bpow.pos _ _).le
    have hy : 0 ≤ (my : ℝ) * bpow FloatLib.Numerics.binaryRadix ey :=
      mul_nonneg (Nat.cast_nonneg _) (bpow.pos _ _).le
    have habs : |Model.unpackedToReal (.finite sx mx ex hmx) /
        Model.unpackedToReal (.finite sy my ey hmy)| =
        ((mx : ℝ) * bpow FloatLib.Numerics.binaryRadix ex) /
          ((my : ℝ) * bpow FloatLib.Numerics.binaryRadix ey) := by
      rw [abs_div]
      cases sx <;> cases sy <;>
        simp [Model.unpackedToReal_finite, Model.modelSignBit, abs_of_nonneg hx, abs_of_nonneg hy]
    rwa [← habs]

theorem finite (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (nonzero : Numerics.real y ≠ 0) (bound : |Numerics.real x / Numerics.real y| < (2 : ℝ)^127) :
    (x / y).isFinite = true := by
  rw [← Numerics.finite_model]
  change Model.isFinite (Model.ofFloat32Model (Float32.Model.div x.toModel y.toModel)) = true
  rw [Float32.Model.div, Model.ofFloat32Model_pack]
  rw [Numerics.real_unpack] at nonzero
  rw [Numerics.real_unpack, Numerics.real_unpack] at bound
  change x.toModel.unpack.isFinite = true at hx
  change y.toModel.unpack.isFinite = true at hy
  cases hxm : x.toModel.unpack <;> cases hym : y.toModel.unpack <;>
    simp only [hxm, hym, Float.Model.UnpackedFloat.isFinite, Bool.false_eq_true] at hx hy
  case zero.zero sx sy => simp [hym, Model.unpackedToReal_zero] at nonzero
  case finite.zero sx mx ex hmx sy => simp [hym, Model.unpackedToReal_zero] at nonzero
  case zero.finite sx sy my ey hmy =>
    simp only [div]
    exact Model.isFinite_ofModel_zero _ (by decide) _
  case finite.finite sx mx ex hmx sy my ey hmy =>
    apply unpacked_div_finite FloatFormat.binary32 (by decide) sx sy mx my ex ey hmx hmy
    have hmax : bpow FloatLib.Numerics.binaryRadix
        (Int.ofNat (FloatFormat.ieeeMaxNormalExponent FloatFormat.binary32)) = (2 : ℝ)^127 := by
      norm_num [FloatFormat.ieeeMaxNormalExponent, FloatFormat.binary32,
        bpow, FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal, FloatFormat.bias]
    rw [hmax]
    simpa only [hxm, hym] using bound

theorem reciprocal_finite : ∀ x : Float32, x.isFinite = true → 1 ≤ Numerics.real x →
    ((1 : Float32) / x).isFinite = true := by
  intro x hx lower
  apply finite 1 x (by decide) hx (by linarith)
  rw [Numerics.real_one, abs_of_nonneg (by positivity : 0 ≤ (1 : ℝ) / Numerics.real x)]
  exact ((div_le_one (by linarith : 0 < Numerics.real x)).mpr lower).trans_lt (by norm_num)

end Inference.Contracts.Mlx.NativeDivisionBounds
