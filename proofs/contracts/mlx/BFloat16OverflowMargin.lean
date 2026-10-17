import contracts.mlx.BFloat16Arithmetic
import contracts.mlx.BFloat16
import FloatLib.Floats.Formats.BinaryInterchange.Arithmetic.Finiteness

namespace Inference.Contracts.Mlx.BFloat16OverflowMargin
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.Formats.Flocq Model

noncomputable def maximum : ℝ := Model.toReal (Model.posMaxFinite FloatFormat.bfloat16)

theorem maximum_value : maximum = 255 * (2 : ℝ)^(120 : Int) := by
  rw [maximum, Model.toReal_posMaxFinite]
  norm_num [FloatFormat.bfloat16, FloatFormat.maxFiniteFracField, FloatFormat.fracMaskNat,
    FloatFormat.maxNormalExponent, FloatFormat.ieeeMaxNormalExponent, FloatFormat.bias,
    FloatFormat.maxFiniteExpField, FloatFormat.expAllOnesNat, FloatFormat.Encoding.maxFiniteExponent, pow2,
    Model.bpow, Formats.Flocq.bpow, FloatLib.Numerics.binaryRadix, FloatLib.Numerics.Radix.toReal]

-- The softmax sentinel is the largest negative finite number. Subtracting a
-- small positive score exceeds its exact magnitude, but remains below the
-- nearest-even overflow threshold. This proves that extra rounding margin.
private theorem leading (d : FloatLib.Numerics.Dyadic)
    (bound : |d.toReal| ≤ maximum + (2 : ℝ)^(118 : Int)) (above : maximum < |d.toReal|) :
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
    (bound : |d.toReal| ≤ maximum + (2 : ℝ)^(118 : Int))
    (hk : (d.significand.log2 : Int) + d.exponent = 127) :
    Model.roundMantissaToLeadingBitEven d.significand 7 < 256 := by
  let scaled : ℝ := (d.significand : ℝ) * (2 : ℝ)^(d.exponent - 120)
  have habs : |d.toReal| = scaled * (2 : ℝ)^(120 : Int) := by
    rw [Dyadic.abs_toReal]
    change (d.significand : ℝ) * (2 : ℝ)^d.exponent = _
    dsimp only [scaled]
    rw [mul_assoc, ← zpow_add₀ (by norm_num : (2 : ℝ) ≠ 0)]
    congr 2
    omega
  have hscaled : scaled ≤ (255 : ℝ) + 1/4 := by
    rw [habs, maximum_value] at bound
    norm_num at bound ⊢
    linarith
  have hround : nearestEven scaled = (Model.roundMantissaToLeadingBitEven d.significand 7 : Int) := by
    change nearestEven ((d.significand : ℝ) * Formats.Flocq.bpow FloatLib.Numerics.binaryRadix (d.exponent - 120)) = _
    rw [Model.nearestEven_scaledMagnitude]
    have ht : (120 : Int) = (d.significand.log2 : Int) + d.exponent - 7 := by omega
    rw [ht]
    exact congrArg Int.ofNat (Model.roundMantissaAtExponentEven_eq_roundMantissaToLeadingBitEven
      d.significand 7 d.exponent)
  have herror := (abs_le.mp (nearestEven_abs_sub_le_half scaled)).2
  rw [hround] at herror
  have roundedLt : Model.roundMantissaToLeadingBitEven d.significand 7 < 256 := by
    have hreal : ((Model.roundMantissaToLeadingBitEven d.significand 7 : Nat) : ℝ) < 256 := by
      push_cast at herror
      norm_num at herror
      linarith
    exact_mod_cast hreal
  exact roundedLt

private theorem round_impl_finite (d : FloatLib.Numerics.Dyadic)
    (hm : d.significand ≠ 0) (hk : (d.significand.log2 : Int) + d.exponent = 127)
    (roundedLt : Model.roundMantissaToLeadingBitEven d.significand 7 < 256) :
    Model.isFinite (Model.roundDyadic FloatFormat.bfloat16 d) = true := by
  have raw : (if 7 ≤ d.significand.log2 then
      FloatLib.Numerics.roundShiftRightEven d.significand (d.significand.log2 - 7)
      else d.significand <<< (7 - d.significand.log2)) =
      Model.roundMantissaToLeadingBitEven d.significand 7 := rfl
  have hn : Model.roundMantissaToLeadingBitEven d.significand 7 ≠ 256 := ne_of_lt roundedLt
  rw [Model.roundDyadic_eq_roundDyadicImpl]
  simp only [Model.roundDyadicImpl, show FloatFormat.bfloat16.isIEEE = true from by decide, ite_true]
  simp only [Model.ieeeRoundDyadicImpl, beq_iff_eq, hm, ite_false, hk,
    show FloatFormat.bfloat16.ieeeMinNormalExponent = -126 from rfl,
    show ¬ (127 : Int) < -126 from by decide,
    show FloatFormat.bfloat16.fracWidth = 7 from rfl, raw,
    show pow2 (7+1) = 256 from rfl, hn]
  exact Model.isFinite_ofFields_ieee FloatFormat.bfloat16 (by decide) d.negative 254 _ (by decide)

theorem round_finite (d : FloatLib.Numerics.Dyadic)
    (bound : |d.toReal| ≤ maximum + (2 : ℝ)^(118 : Int)) :
    Model.isFinite (Model.roundDyadic FloatFormat.bfloat16 d) = true := by
  by_cases ordinary : |d.toReal| ≤ maximum
  · exact Model.isFinite_roundDyadic_of_isIEEE_of_abs_toReal_le_posMaxFinite _ (by decide) d ordinary
  have h := leading d bound (lt_of_not_ge ordinary)
  exact round_impl_finite d h.1 h.2 (rounded_mantissa d bound h.2)

theorem add_finite (x y : Model FloatFormat.bfloat16)
    (hx : Model.isFinite x = true) (hy : Model.isFinite y = true)
    (bound : |Model.toReal x + Model.toReal y| ≤ maximum + (2 : ℝ)^(118 : Int)) :
    Model.isFinite (Model.add x y) = true := by
  obtain ⟨dx, hdx⟩ := Model.exists_toDyadic?_of_isFinite hx
  obtain ⟨dy, hdy⟩ := Model.exists_toDyadic?_of_isFinite hy
  have hadd : Model.add x y = Model.roundDyadic FloatFormat.bfloat16 (Model.addDyadic dx dy) := by
    simp [Model.Proof.add_eq_spec, Model.Spec.add, hdx, hdy]
  rw [hadd]
  apply round_finite
  rw [Dyadic.toReal_addDyadic]
  simpa [Model.toReal_eq, hdx, hdy] using bound

-- 1 + y cannot overflow for a finite nonnegative bfloat16 y: below the
-- nearest-even threshold max + ulp/2 = max + 2^119.
theorem one_add_finite (y : BFloat16Arithmetic.Value) (hy : Model.isFinite y = true) (hn : 0 ≤ Model.toReal y) :
    Model.isFinite (Model.add BFloat16Arithmetic.one (BFloat16Arithmetic.flush y)) = true := by
  have hf := BFloat16Arithmetic.finite_flush y hy
  apply add_finite _ _ BFloat16Arithmetic.finite_one hf
  have hm := Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (BFloat16Arithmetic.flush y) (by decide) hf
  change |Model.toReal (BFloat16Arithmetic.flush y)| ≤ maximum at hm
  have hz := BFloat16Arithmetic.flush_nonnegative _ hn
  rw [BFloat16Arithmetic.real_one, abs_of_nonneg (by linarith)]
  rw [abs_of_nonneg hz] at hm
  have ht : (1 : ℝ) ≤ (2 : ℝ)^(118 : Int) := one_le_zpow₀ (by norm_num) (by norm_num)
  linarith

-- Nearest-even narrowing of a finite nonnegative binary32 value is finite
-- or +inf.
private theorem normal_cases (E : Int) (neg : Bool) (hn : neg = false) (M : Nat) :
    Model.isFinite (if E > Int.ofNat FloatFormat.bfloat16.ieeeMaxNormalExponent then
      (if neg = true then negInf FloatFormat.bfloat16 else posInf FloatFormat.bfloat16)
      else ofFields FloatFormat.bfloat16 neg (E + Int.ofNat FloatFormat.bfloat16.bias).toNat M) = true ∨
    (if E > Int.ofNat FloatFormat.bfloat16.ieeeMaxNormalExponent then
      (if neg = true then negInf FloatFormat.bfloat16 else posInf FloatFormat.bfloat16)
      else ofFields FloatFormat.bfloat16 neg (E + Int.ofNat FloatFormat.bfloat16.bias).toNat M) =
      posInf FloatFormat.bfloat16 := by
  subst hn
  by_cases hE : E > Int.ofNat FloatFormat.bfloat16.ieeeMaxNormalExponent
  · right; simp only [hE, ite_true, Bool.false_eq_true, ite_false]
  · left
    simp only [hE, ite_false]
    apply Model.isFinite_ofFields_ieee _ (by decide)
    change _ < 255
    have h127 : Int.ofNat FloatFormat.bfloat16.ieeeMaxNormalExponent = 127 := rfl
    have hb : Int.ofNat FloatFormat.bfloat16.bias = 127 := rfl
    rw [h127] at hE
    rw [hb]
    omega

private theorem subnormal_cases (neg : Bool) (F : Nat) :
    Model.isFinite (if F = 0 then (if neg = true then negZero FloatFormat.bfloat16 else posZero FloatFormat.bfloat16)
      else if F = pow2 FloatFormat.bfloat16.fracWidth then ofFields FloatFormat.bfloat16 neg 1 0
      else ofFields FloatFormat.bfloat16 neg 0 F) = true := by
  split
  · cases neg <;> decide
  · split
    · exact Model.isFinite_ofFields_ieee _ (by decide) _ _ _ (by decide)
    · exact Model.isFinite_ofFields_ieee _ (by decide) _ _ _ (by decide)

theorem round_cases (d : FloatLib.Numerics.Dyadic) (hs : d.significand ≠ 0 → d.negative = false) :
    Model.isFinite (Model.roundDyadic FloatFormat.bfloat16 d) = true ∨
      Model.roundDyadic FloatFormat.bfloat16 d = Model.posInf FloatFormat.bfloat16 := by
  rw [Model.roundDyadic_eq_roundDyadicImpl]
  simp only [Model.roundDyadicImpl, show FloatFormat.bfloat16.isIEEE = true from by decide, ite_true,
    Model.ieeeRoundDyadicImpl]
  by_cases h0 : d.significand = 0
  · left; simp only [h0, beq_self_eq_true, ite_true]; cases d.negative <;> decide
  · have hn := hs h0
    simp only [h0, beq_iff_eq, ite_false]
    split
    · exact Or.inl (subnormal_cases _ _)
    · exact normal_cases _ _ hn _

theorem narrow_cases (x : Float32) (hx : x.isFinite = true) (hn : 0 ≤ Numerics.real x) :
    Model.isFinite (BFloat16.narrow x) = true ∨ BFloat16.narrow x = Model.posInf FloatFormat.bfloat16 := by
  have hf : Model.isFinite (Numerics.model x) = true := by rw [Numerics.finite_model]; exact hx
  have hN := Model.isNaN_eq_false_of_isFinite_eq_true (Numerics.model x) hf
  have hI := Model.isInf_eq_false_of_isFinite_eq_true (Numerics.model x) hf
  obtain ⟨d, hd⟩ := Model.exists_toDyadic?_of_isFinite hf
  have hcast : BFloat16.narrow x = Model.roundDyadic FloatFormat.bfloat16 d := by
    simp [BFloat16.narrow, Model.cast, hN, hI, hd,
      show FloatFormat.binary32 ≠ FloatFormat.bfloat16 from by decide,
      show ¬FloatFormat.binary32.fracWidth ≤ FloatFormat.bfloat16.fracWidth from by decide]
  rw [hcast]
  apply round_cases
  intro hs
  have hr : Numerics.real x = d.toReal := by simp only [Numerics.real, Model.toReal_eq, hd]
  cases hneg : d.negative
  · rfl
  · exfalso
    have hp : (0 : ℝ) < (d.significand : ℝ) := by exact_mod_cast Nat.pos_of_ne_zero hs
    have : d.toReal < 0 := by
      simp only [FloatLib.Numerics.Dyadic.toReal, FloatLib.Numerics.Dyadic.signedSignificand, hneg, ite_true]
      have hc : (((Int.ofNat d.significand : ℤ)) : ℝ) = (d.significand : ℝ) := by simp
      have := zpow_pos (by norm_num : (0:ℝ) < 2) d.exponent
      push_cast
      rw [hc]
      nlinarith
    linarith

theorem narrow_inf : BFloat16.narrow Float32.inf = Model.posInf FloatFormat.bfloat16 := by decide

end Inference.Contracts.Mlx.BFloat16OverflowMargin
