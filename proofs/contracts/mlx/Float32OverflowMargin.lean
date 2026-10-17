import contracts.mlx.Float32Bounds
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Finiteness

namespace Inference.Contracts.Mlx.Float32OverflowMargin
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.Formats.Flocq Model

noncomputable def maximum : ℝ := Model.toReal (Model.posMaxFinite FloatFormat.binary32)

theorem maximum_value : maximum = 16777215 * (2 : ℝ)^(104 : Int) := by
  rw [maximum, Model.toReal_posMaxFinite]
  norm_num [FloatFormat.binary32, FloatFormat.maxFiniteFracField, FloatFormat.fracMaskNat,
    FloatFormat.maxNormalExponent, FloatFormat.ieeeMaxNormalExponent, FloatFormat.bias,
    FloatFormat.maxFiniteExpField, FloatFormat.expAllOnesNat, FloatFormat.Encoding.maxFiniteExponent, pow2,
    Model.bpow, Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]

-- The softmax sentinel is the largest negative finite number. Subtracting a
-- small positive score exceeds its exact magnitude, but remains below the
-- nearest-even overflow threshold. This proves that extra rounding margin.
private theorem leading (d : FloatLib.Numerics.Dyadic)
    (bound : |d.toReal| ≤ maximum + (2 : ℝ)^(100 : Int)) (above : maximum < |d.toReal|) :
    d.significand ≠ 0 ∧ (d.significand.log2 : Int) + d.exponent = 127 := by
  have nonzero : d.toReal ≠ 0 := by
    intro hz
    rw [hz, abs_zero, maximum_value] at above
    norm_num at above
  have hm : d.significand ≠ 0 := by
    intro hz
    apply nonzero
    simp [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand, hz]
  have mag : magnitude FloatLib.Numerics.binaryRadix d.toReal = 128 :=
    magnitude_eq_of_bpow_bounds _ _ 128 nonzero
      (by rw [maximum_value] at above; norm_num [Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix,
        FloatLib.Numerics.Radix.toReal] at above ⊢; linarith)
      (by rw [maximum_value] at bound; norm_num [Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix,
        FloatLib.Numerics.Radix.toReal] at bound ⊢; linarith)
  have hk : (d.significand.log2 : Int) + d.exponent = 127 := by
    rw [Dyadic.magnitude_toReal d hm] at mag
    change (d.significand.log2 : Int) + d.exponent + 1 = 128 at mag
    omega
  exact ⟨hm, hk⟩

private theorem rounded_mantissa (d : FloatLib.Numerics.Dyadic)
    (bound : |d.toReal| ≤ maximum + (2 : ℝ)^(100 : Int))
    (hk : (d.significand.log2 : Int) + d.exponent = 127) :
    Model.roundMantissaToLeadingBitEven d.significand 23 < 16777216 := by
  let scaled : ℝ := (d.significand : ℝ) * (2 : ℝ)^(d.exponent - 104)
  have habs : |d.toReal| = scaled * (2 : ℝ)^(104 : Int) := by
    rw [Dyadic.abs_toReal]
    change (d.significand : ℝ) * (2 : ℝ)^d.exponent = _
    dsimp only [scaled]
    rw [mul_assoc, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    congr 2
    omega
  have hscaled : scaled ≤ (16777215 : ℝ) + 1/16 := by
    rw [habs, maximum_value] at bound
    norm_num at bound ⊢
    linarith
  have hround : nearestEven scaled = (Model.roundMantissaToLeadingBitEven d.significand 23 : Int) := by
    change nearestEven ((d.significand : ℝ) * Formats.Flocq.bpow FloatLib.Numerics.binaryRadix (d.exponent - 104)) = _
    rw [Model.nearestEven_scaledMagnitude]
    have ht : (104 : Int) = (d.significand.log2 : Int) + d.exponent - 23 := by omega
    rw [ht]
    exact congrArg Int.ofNat (Model.roundMantissaAtExponentEven_eq_roundMantissaToLeadingBitEven
      d.significand 23 d.exponent)
  have herror := (abs_le.mp (nearestEven_abs_sub_le_half scaled)).2
  rw [hround] at herror
  have roundedLt : Model.roundMantissaToLeadingBitEven d.significand 23 < 16777216 := by
    have hreal : ((Model.roundMantissaToLeadingBitEven d.significand 23 : Nat) : ℝ) < 16777216 := by
      push_cast at herror
      norm_num at herror
      linarith
    exact_mod_cast hreal
  exact roundedLt

private theorem round_impl_finite (d : FloatLib.Numerics.Dyadic)
    (hm : d.significand ≠ 0) (hk : (d.significand.log2 : Int) + d.exponent = 127)
    (roundedLt : Model.roundMantissaToLeadingBitEven d.significand 23 < 16777216) :
    Model.isFinite (Model.roundDyadic FloatFormat.binary32 d) = true := by
  have raw : (if 23 ≤ d.significand.log2 then
      FloatLib.Numerics.roundShiftRightEven d.significand (d.significand.log2 - 23)
      else d.significand <<< (23 - d.significand.log2)) =
      Model.roundMantissaToLeadingBitEven d.significand 23 := rfl
  have hn : Model.roundMantissaToLeadingBitEven d.significand 23 ≠ 16777216 := ne_of_lt roundedLt
  rw [Model.roundDyadic_eq_roundDyadicImpl]
  simp only [Model.roundDyadicImpl, show FloatFormat.binary32.isIEEE = true from by decide, ite_true]
  simp only [Model.ieeeRoundDyadicImpl, beq_iff_eq, hm, ite_false, hk,
    show FloatFormat.binary32.ieeeMinNormalExponent = -126 from rfl,
    show ¬ (127 : Int) < -126 from by decide,
    show FloatFormat.binary32.fracWidth = 23 from rfl, raw,
    show pow2 (23+1) = 16777216 from rfl, hn]
  exact Model.isFinite_ofFields_ieee FloatFormat.binary32 (by decide) d.negative 254 _ (by decide)

theorem round_finite (d : FloatLib.Numerics.Dyadic)
    (bound : |d.toReal| ≤ maximum + (2 : ℝ)^(100 : Int)) :
    Model.isFinite (Model.roundDyadic FloatFormat.binary32 d) = true := by
  by_cases ordinary : |d.toReal| ≤ maximum
  · exact Model.isFinite_roundDyadic_of_isIEEE_of_abs_toReal_le_posMaxFinite _ (by decide) d ordinary
  have h := leading d bound (lt_of_not_ge ordinary)
  exact round_impl_finite d h.1 h.2 (rounded_mantissa d bound h.2)

theorem add_finite (x y : Model FloatFormat.binary32)
    (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (bound : |Model.toReal x + Model.toReal y| ≤ maximum + (2 : ℝ)^(100 : Int)) :
    Model.isFinite (Model.add x y) = true := by
  obtain ⟨dx, hdx⟩ := Model.exists_toDyadic?_of_isFinite hx
  obtain ⟨dy, hdy⟩ := Model.exists_toDyadic?_of_isFinite hy
  have hadd : Model.add x y = Model.roundDyadic FloatFormat.binary32 (Model.addDyadic dx dy) := by
    simp [Model.Proof.add_eq_spec, Model.Spec.add, hdx, hdy]
  rw [hadd]
  apply round_finite
  rw [Dyadic.toReal_addDyadic]
  simpa [Model.toReal_eq, hdx, hdy] using bound

theorem sub_finite (x y : Float32) (hx : x.isFinite = true) (hy : y.isFinite = true)
    (bound : |Numerics.real x - Numerics.real y| ≤ maximum + (2 : ℝ)^(100 : Int)) :
    (x-y).isFinite = true := by
  rw [← Numerics.finite_model, Float32Bounds.sub_model _ _ hx hy]
  have hsub : Model.sub (Numerics.model x) (Numerics.model y) =
      Model.add (Numerics.model x) (Model.neg (Numerics.model y)) := by
    rw [Model.Proof.sub_eq_spec, Model.Proof.add_eq_spec]
    rfl
  rw [hsub]
  apply add_finite _ _ (by rw [Numerics.finite_model]; exact hx)
    (by simpa only [Model.isFinite_neg, Numerics.finite_model] using hy)
  rw [Model.toReal_neg _ (by rw [Numerics.finite_model]; exact hy)]
  simpa only [sub_eq_add_neg, Numerics.real] using bound

end Inference.Contracts.Mlx.Float32OverflowMargin
