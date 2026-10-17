import contracts.mlx.NativeNormalizationDivision

namespace Inference.Contracts.Mlx.NativeDivisionDomain
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open FloatLib.Floats.Formats.Flocq Float.Model.UnpackedFloat
open Numerics
set_option maxRecDepth 10000

-- Logical IEEE rounding only; no physical native instruction claim.
private theorem top_round_finite (sign : Sign) (mantissa : Nat) (exponent : Int)
    (accuracy : Accuracy) (value : ℝ) (nonzero : mantissa≠0)
    (certified : Model.accuracyRepresents mantissa accuracy value)
    (hle : exponent≤FloatFormat.binary32.toModel.targetExponent (Float.Model.totalExponent mantissa exponent))
    (lower : (2:ℝ)^127≤value*bpow FloatLib.Numerics.binaryRadix exponent)
    (upper : value*bpow FloatLib.Numerics.binaryRadix exponent≤Float32OverflowMargin.maximum) :
    Model.isFinite (Model.ofModel FloatFormat.binary32
      (roundWithAccuracy FloatFormat.binary32.toModel sign mantissa exponent accuracy))=true := by
  let k : Int := (mantissa.log2:Int)+exponent
  let target := FloatFormat.binary32.toModel.targetExponent (Float.Model.totalExponent mantissa exponent)
  let scaled : ℝ := value*bpow FloatLib.Numerics.binaryRadix (exponent-target)
  let rounded := (shiftToTargetExponent FloatFormat.binary32.toModel mantissa exponent accuracy).1.roundedMantissa
  have positive : 0<value := (by exact_mod_cast Nat.pos_of_ne_zero nonzero : (0:ℝ)<mantissa).trans_le
    (Model.accuracyRepresents_bounds certified).1
  have actualPositive : 0<value*bpow FloatLib.Numerics.binaryRadix exponent := mul_pos positive (bpow.pos _ _)
  have magValue : magnitude FloatLib.Numerics.binaryRadix
      (value*bpow FloatLib.Numerics.binaryRadix exponent)=k+1 := by
    dsimp only [k]
    rw [magnitude_mul_bpow _ _ _ positive.ne',Model.magnitude_of_accuracyRepresents nonzero certified]
    simp only [Int.ofNat_eq_natCast]
    omega
  have magnitudeTop : magnitude FloatLib.Numerics.binaryRadix
      (value*bpow FloatLib.Numerics.binaryRadix exponent)=128 := by
    apply magnitude_eq_of_bpow_bounds _ _ _ actualPositive.ne'
    · simpa [abs_of_pos actualPositive,abs_of_pos positive,bpow,FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal] using lower
    · rw [abs_of_pos actualPositive]
      apply upper.trans_lt
      rw [Float32OverflowMargin.maximum_value]
      norm_num [bpow,FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal]
  have top : k=127 := by omega
  have normal : FloatFormat.ieeeMinNormalExponent FloatFormat.binary32≤k := by rw [top]; decide +kernel
  have targetEq : target=104 := by
    have h := Model.targetExponent_eq_normal FloatFormat.binary32 mantissa exponent normal
    change target=k-FloatFormat.binary32.fracWidth at h
    rw [h,top]
    rfl
  have scaledEq : scaled*bpow FloatLib.Numerics.binaryRadix (104:Int)=
      value*bpow FloatLib.Numerics.binaryRadix exponent := by
    dsimp only [scaled]
    rw [targetEq,mul_assoc,← bpow.add_exp]
    congr 1
    ring_nf
  have scaledLower : (8388608:ℝ)≤scaled := by
    apply le_of_mul_le_mul_right (a0 := bpow.pos FloatLib.Numerics.binaryRadix (104:Int))
    rw [scaledEq]
    norm_num [bpow,FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal] at lower ⊢
    exact lower
  have scaledUpper : scaled≤(16777215:ℝ) := by
    apply le_of_mul_le_mul_right (a0 := bpow.pos FloatLib.Numerics.binaryRadix (104:Int))
    rw [scaledEq,Float32OverflowMargin.maximum_value] at *
    exact upper
  have roundedEq : (rounded:Int)=nearestEven scaled :=
    Model.roundedMantissa_shiftToTargetExponent_eq_nearestEven FloatFormat.binary32 mantissa exponent accuracy value certified hle
  have roundedLower : 8388608≤rounded := Int.ofNat_le.mp
    ((Model.natCast_le_nearestEven_of_le scaledLower).trans roundedEq.symm.le)
  have roundedUpper : rounded≤16777215 := Int.ofNat_le.mp
    (roundedEq.trans_le (Model.nearestEven_le_natCast_of_le scaledUpper))
  rw [Model.roundWithAccuracy_eq_finishRoundedMantissa,
    Model.shiftToTargetExponent_eq_of_le_targetExponent FloatFormat.binary32 mantissa exponent accuracy hle]
  change Model.isFinite (Model.ofModel FloatFormat.binary32
    (Model.finishRoundedMantissa FloatFormat.binary32.toModel sign (rounded,target)))=true
  rw [targetEq]
  have finish := Model.finishRoundedMantissa_normalized FloatFormat.binary32 sign rounded (127:Int)
    (by change 8388608≤rounded; exact roundedLower)
    (by change rounded<16777216; omega) (by decide)
  change Model.isFinite (Model.ofModel FloatFormat.binary32
    (Model.finishRoundedMantissa FloatFormat.binary32.toModel sign (rounded,(127:Int)-FloatFormat.binary32.fracWidth)))=true
  rw [finish]
  apply Model.isFinite_ofModel_finite_of_noOverflow FloatFormat.binary32 (by decide) sign _ _ (by omega)
  decide +kernel

private theorem unpacked_top_finite (sx sy : Sign) (mx my : Nat) (ex ey : Int)
    (hmx : 0<mx) (hmy : 0<my)
    (lower : (2:ℝ)^127≤|Model.unpackedToReal (.finite sx mx ex hmx)/Model.unpackedToReal (.finite sy my ey hmy)|)
    (upper : |Model.unpackedToReal (.finite sx mx ex hmx)/Model.unpackedToReal (.finite sy my ey hmy)|≤Float32OverflowMargin.maximum) :
    Model.isFinite (Model.ofModel FloatFormat.binary32 (div FloatFormat.binary32.toModel
      (.finite sx mx ex hmx) (.finite sy my ey hmy)))=true := by
  let target := min (ex-ey) (FloatFormat.binary32.toModel.targetExponent
    (Float.Model.totalExponent mx ex-Float.Model.totalExponent my ey))
  let shift := (ex-ey-target).toNat
  let numerator := mx<<<shift
  let quotient := numerator/my
  let accuracy := accuracyOfFraction (numerator%my) my
  let value : ℝ := (numerator:ℝ)/my
  have core : divCore FloatFormat.binary32.toModel mx ex my ey=(quotient,target,accuracy) := rfl
  have certified : Model.accuracyRepresents quotient accuracy value :=
    Model.accuracyRepresents_accuracyOfFraction numerator my hmy.ne'
  have hle := Model.divCore_exponent_le_targetExponent FloatFormat.binary32.toModel ex ey hmx hmy
  rw [core] at hle
  have targetBound : target≤ex-ey := min_le_left _ _
  have shiftEq : (shift:Int)=ex-ey-target := Int.toNat_of_nonneg (sub_nonneg.mpr targetBound)
  have numeratorEq : (numerator:ℝ)=(mx:ℝ)*bpow FloatLib.Numerics.binaryRadix (shift:Int) := by
    dsimp only [numerator]
    rw [Nat.shiftLeft_eq,Nat.cast_mul,Nat.cast_pow]
    simp [bpow,FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal]
  have scaled : value*bpow FloatLib.Numerics.binaryRadix target=
      ((mx:ℝ)*bpow FloatLib.Numerics.binaryRadix ex)/((my:ℝ)*bpow FloatLib.Numerics.binaryRadix ey) := by
    dsimp only [value]
    rw [numeratorEq,div_mul_eq_mul_div,mul_assoc,← bpow.add_exp,
      show (shift:Int)+target=ex-ey by omega,bpow.sub_exp]
    field_simp
  have hx : 0≤(mx:ℝ)*bpow FloatLib.Numerics.binaryRadix ex := mul_nonneg (Nat.cast_nonneg _) (bpow.pos _ _).le
  have hy : 0≤(my:ℝ)*bpow FloatLib.Numerics.binaryRadix ey := mul_nonneg (Nat.cast_nonneg _) (bpow.pos _ _).le
  have absolute : |Model.unpackedToReal (.finite sx mx ex hmx)/Model.unpackedToReal (.finite sy my ey hmy)|=
      ((mx:ℝ)*bpow FloatLib.Numerics.binaryRadix ex)/((my:ℝ)*bpow FloatLib.Numerics.binaryRadix ey) := by
    rw [abs_div]
    cases sx <;> cases sy <;> simp [Model.unpackedToReal_finite,Model.modelSignBit,abs_of_nonneg hx,abs_of_nonneg hy]
  rw [absolute,← scaled] at lower upper
  have nonzero : quotient≠0 := by
    intro zero
    have bounds := Model.accuracyRepresents_bounds certified
    have floor := (Model.le_targetExponent_totalExponent_iff FloatFormat.binary32.toModel quotient target).mp hle
    rw [zero] at bounds floor
    have floorBound : target≤(-149:Int) := by
      rcases floor with h|h
      · exact h
      · change 2^23≤(0:Nat) at h
        omega
    have power : bpow FloatLib.Numerics.binaryRadix target≤bpow FloatLib.Numerics.binaryRadix (-149:Int) :=
      (bpow_le_bpow_iff _ _ _).mpr floorBound
    have small := mul_le_mul bounds.2.le power (bpow.pos _ _).le (by positivity)
    norm_num [bpow,FloatLib.Numerics.binaryRadix,FloatLib.Numerics.Radix.toReal] at small lower
    linarith
  change Model.isFinite (Model.ofModel FloatFormat.binary32
    (roundWithAccuracy FloatFormat.binary32.toModel (sx/sy) quotient target accuracy))=true
  exact top_round_finite _ _ _ _ _ nonzero certified hle lower upper

theorem raw_finite (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (domain : Division.DivisorDomain y) : (FlushToZero.flush x/y).isFinite=true := by
  let a := FlushToZero.flush x
  have ha : a.isFinite=true := FlushToZero.finite_flush x hx
  have nonzero : real y≠0 := by have := domain.1; linarith
  have bound : |real a/real y|≤Float32OverflowMargin.maximum :=
    (DivisionBounds.quotient_bound x y domain).trans
      (Model.abs_toReal_le_posMaxFinite_of_isIEEE_of_isFinite (model x) (by decide) (by rw [finite_model]; exact hx))
  by_cases small : |real a/real y|<(2:ℝ)^127
  · exact NativeDivisionBounds.finite a y ha hy nonzero small
  have lower : (2:ℝ)^127≤|real a/real y| := le_of_not_gt small
  rw [← finite_model]
  change Model.isFinite (Model.ofFloat32Model (Float32.Model.div a.toModel y.toModel))=true
  rw [Float32.Model.div,Model.ofFloat32Model_pack]
  rw [real_unpack,real_unpack] at lower bound
  rw [real_unpack] at nonzero
  cases hxm : a.toModel.unpack <;> cases hym : y.toModel.unpack <;>
    simp only [hxm,hym,Float32.isFinite,Float32.Model.isFinite,Float.Model.UnpackedFloat.isFinite,Bool.false_eq_true] at ha hy
  case zero.zero sx sy => simp only [hym,Model.unpackedToReal_zero] at nonzero; contradiction
  case finite.zero sx mx ex hmx sy => simp only [hym,Model.unpackedToReal_zero] at nonzero; contradiction
  case zero.finite sx sy my ey hmy =>
    simp only [hxm,Model.unpackedToReal_zero,zero_div,abs_zero] at lower
    norm_num at lower
  case finite.finite sx mx ex hmx sy my ey hmy =>
    apply unpacked_top_finite sx sy mx my ex ey hmx hmy
    · simpa only [hxm,hym] using lower
    · simpa only [hxm,hym] using bound

-- No remaining raw-finiteness premise: the complete original y>=1 domain
-- now has the established IEEE-reference directed bounds for logical FTZ div.
theorem directed : DivisionDirectedBounds.Contract FlushToZero.div :=
  NativeNormalizationDivision.directed_of_finite raw_finite

theorem real_eq_reference (x y : Float32) (hx : x.isFinite=true) (hy : y.isFinite=true)
    (domain : Division.DivisorDomain y) :
    real (FlushToZero.div x y)=real (DivisionBounds.value x y) :=
  NativeNormalizationDivision.real_eq_reference x y hx hy domain (raw_finite x y hx hy domain)

-- Bind a caller scalar function on the admitted inputs. Establishing this
-- equation for compiled M1 Max instructions remains a compiler/platform task;
-- it is not an assumption of a complete kernel or inference output.
theorem of_selection (divide : Float32 → Float32 → Float32)
    (selected : ∀ x y, x.isFinite=true → y.isFinite=true → Division.DivisorDomain y →
      divide x y=FlushToZero.div x y) : DivisionDirectedBounds.Contract divide := by
  refine ⟨⟨?_,?_⟩,?_,?_⟩
  · intro x y hx hy domain
    rw [selected x y hx hy domain]
    exact directed.finite x y hx hy domain
  · intro x y cap hx hy domain hc bound
    rw [selected x y hx hy domain]
    exact directed.bounded x y cap hx hy domain hc bound
  · intro x y cap hx hy domain hc bound
    rw [selected x y hx hy domain]
    exact directed.quotientBounded x y cap hx hy domain hc bound
  · intro x y floor hx hy domain hf normal bound
    rw [selected x y hx hy domain]
    exact directed.lower x y floor hx hy domain hf normal bound

end Inference.Contracts.Mlx.NativeDivisionDomain
