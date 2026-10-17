import contracts.mlx.NormalizedCastBounds
import contracts.mlx.NormalizationEnergyScale

namespace Inference.Contracts.Mlx.NormalizedVectorEnergy
open Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

-- The energy estimate supplies a tight product bound even when the input
-- and reciprocal root separately have very different magnitudes.
theorem component (x inverse : Float32) (weight : BF)
    (hx : x.isFinite = true) (hi : inverse.isFinite = true) (hw : Model.isFinite weight = true)
    (xb : |real x| ≤ (2 : ℝ)^56) (ib : |real inverse| ≤ (2 : ℝ)^21)
    (wb : |Model.toReal weight| ≤ 1) (productBound : |real x| * |real inverse| ≤ 512) :
    Model.isFinite (NormalizedCastBounds.value x inverse weight) = true ∧
      |Model.toReal (NormalizedCastBounds.value x inverse weight)| ≤
        (17/16 : ℝ)*|Model.toReal weight| * (|real x| * |real inverse|)+(2 : ℝ)^(-60 : Int) := by
  let product := FlushToZero.mul x inverse
  let converted := BFloat16.narrow product
  let a := |real x| * |real inverse|
  have an : 0 ≤ a := mul_nonneg (abs_nonneg _) (abs_nonneg _)
  have fc := DyadicBounds.ceiling_range 1 9 (by decide) (by decide) (by decide)
  have bc := BFloat16DyadicBounds.ceiling_range 1 9 (by decide) (by decide) (by decide)
  norm_num at fc bc
  have pr := NativeMultiplication.range x inverse (DyadicBounds.ceiling 1 9) hx hi fc.1
    (by rw [fc.2]; exact productBound)
  have pf : product.isFinite = true := FlushToZero.finite_flush _ pr.1
  have pb : |real product| ≤ 512 := by simpa only [fc.2] using pr.2
  have cr := BFloat16ConversionBounds.narrow_range product (BFloat16DyadicBounds.ceiling 1 9) pf bc.1
    (by rw [bc.2]; exact pb)
  have cf : Model.isFinite converted = true := cr.1
  have cb : |Model.toReal converted| ≤ 512 := by simpa only [bc.2] using cr.2
  have wr := BFloat16Bounds.mul_range weight converted (BFloat16DyadicBounds.ceiling 1 9) hw cf bc.1 (by
    rw [bc.2]
    simpa only [one_mul] using mul_le_mul wb cb (abs_nonneg _) (by norm_num : (0 : ℝ) ≤ 1))
  refine ⟨BFloat16Arithmetic.finite_flush _ wr.1, ?_⟩
  have pe := RelativeRounding.multiplication x inverse pr.1
  have pt : (2 : ℝ)^(-150 : Int)+FlushToZero.threshold*(1+|real x|+|real inverse|) ≤
      (2 : ℝ)^(-68 : Int) := by
    norm_num [FlushToZero.threshold] at xb ib ⊢
    linarith only [xb, ib]
  have pab : |real product| ≤ (1+(2 : ℝ)^(-24 : Int))*a+(2 : ℝ)^(-68 : Int) := by
    have h := NormalizedCastBounds.absolute_of_error _ _ _ pe
    rw [abs_mul] at h
    change |real product| ≤ a+_ at h
    linarith only [h, pt]
  have ce := (BFloat16.narrow_error product pf cf).trans (RelativeRounding.bfloat16_epsilon (real product))
  have cab : |Model.toReal converted| ≤ (129/128 : ℝ)*a+(2 : ℝ)^(-66 : Int) := by
    have h := NormalizedCastBounds.absolute_of_error _ _ _ ce
    change |Model.toReal converted| ≤ _ at h
    norm_num at pab h ⊢
    linarith only [pab, h, an]
  have we := (BFloat16Arithmetic.mul_error weight converted hw cf wr.1).trans
    (RelativeRounding.bfloat16_multiplication_budget weight converted)
  have wt : (2 : ℝ)^(-134 : Int)+FlushToZero.threshold*(1+|Model.toReal weight|+|Model.toReal converted|) ≤
      (2 : ℝ)^(-115 : Int) := by
    norm_num [FlushToZero.threshold]
    linarith only [wb, cb]
  have wa := NormalizedCastBounds.absolute_of_error _ _ _ we
  rw [abs_mul] at wa
  have scaled := mul_le_mul_of_nonneg_left cab (abs_nonneg (Model.toReal weight))
  have tail := mul_le_mul_of_nonneg_right wb (by positivity : (0 : ℝ) ≤ (2 : ℝ)^(-66 : Int))
  have wan := mul_nonneg (abs_nonneg (Model.toReal weight)) an
  change |Model.toReal (BFloat16Arithmetic.mul weight converted)| ≤ _
  norm_num at wa wt scaled tail ⊢
  nlinarith only [wa, wt, scaled, tail, wan]

theorem product_bound (input : Fin n → Float32) (inverse : Float32) (size : n ≤ 7680)
    (normalized : real inverse^2*NormalizationEnergyScale.energy input ≤ 16*(n : ℝ)) (i : Fin n) :
    |real (input i)| * |real inverse| ≤ 512 := by
  have he : real (input i)^2 ≤ NormalizationEnergyScale.energy input :=
    Finset.single_le_sum (fun j _ => sq_nonneg (real (input j))) (Finset.mem_univ i)
  have hs := (mul_le_mul_of_nonneg_left he (sq_nonneg (real inverse))).trans normalized
  have sn : (n : ℝ) ≤ 7680 := by exact_mod_cast size
  have eq : (|real (input i)| * |real inverse|)^2 = real inverse^2*real (input i)^2 := by
    rw [mul_pow, sq_abs, sq_abs]
    ring
  nlinarith only [hs, sn, eq, mul_nonneg (abs_nonneg (real (input i))) (abs_nonneg (real inverse))]

theorem square_with_allowance (value main allowance : ℝ) (bound : |value| ≤ main+allowance) :
    value^2 ≤ (9/8 : ℝ)*main^2+9*allowance^2 := by
  have h := mul_self_le_mul_self (abs_nonneg value) bound
  rw [← sq, sq_abs, ← sq] at h
  nlinarith only [h, sq_nonneg (main-8*allowance)]

theorem stored_energy (input : Fin n → Float32) (inverse : Float32) (weight : Fin n → BF)
    (size : n ≤ 7680) (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^56)
    (hi : inverse.isFinite = true) (ib : |real inverse| ≤ (2 : ℝ)^21)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ 1)
    (normalized : real inverse^2*NormalizationEnergyScale.energy input ≤ 16*(n : ℝ)) :
    (∀ i, Model.isFinite (NormalizedCastBounds.value (input i) inverse (weight i)) = true) ∧
      (∑ i, Model.toReal (NormalizedCastBounds.value (input i) inverse (weight i))^2) ≤ 32*(n : ℝ) := by
  have point i := component (input i) inverse (weight i) (hx i).1 hi (hw i).1
    (hx i).2 ib (hw i).2 (product_bound input inverse size normalized i)
  refine ⟨fun i => (point i).1, ?_⟩
  let coefficient := (17/16 : ℝ)*|real inverse|
  have each (i : Fin n) :
      Model.toReal (NormalizedCastBounds.value (input i) inverse (weight i))^2 ≤
        (9/8 : ℝ)*coefficient^2*real (input i)^2+9*((2 : ℝ)^(-60 : Int))^2 := by
    have scaled := mul_le_mul_of_nonneg_right (hw i).2
      (by positivity : (0 : ℝ) ≤ (17/16 : ℝ)*(|real (input i)| * |real inverse|))
    have bound : |Model.toReal (NormalizedCastBounds.value (input i) inverse (weight i))| ≤
        coefficient*|real (input i)|+(2 : ℝ)^(-60 : Int) := by
      dsimp [coefficient]
      nlinarith only [(point i).2, scaled]
    simpa only [mul_pow, sq_abs, mul_assoc] using square_with_allowance _ _ _ bound
  have summed := Finset.sum_le_sum (s := Finset.univ) (fun i _ => each i)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at summed
  have bound := mul_le_mul_of_nonneg_left normalized
    (by positivity : (0 : ℝ) ≤ (9/8 : ℝ)*(17/16 : ℝ)^2)
  have equality : (9/8 : ℝ)*coefficient^2*(∑ i, real (input i)^2) =
      (9/8 : ℝ)*(17/16 : ℝ)^2*(real inverse^2*NormalizationEnergyScale.energy input) := by
    simp only [coefficient, mul_pow, sq_abs, NormalizationEnergyScale.energy]
    ring
  rw [equality] at summed
  norm_num at summed bound ⊢
  linarith only [summed, bound, Nat.cast_nonneg (α := ℝ) n]

theorem inverse_bound (divide : Float32 → Float32 → Float32)
    (divError : Float32 → Float32 → ℝ) (accuracy : Division.Contract divide divError)
    (input : Fin n → Float32) (expr : SquaredSum.Expr n) (width eps : Float32)
    (hf : NormalizationExecution.ReductionFinite divide input expr width eps)
    (epsLower : (2 : ℝ)^(-40 : Int) ≤ real eps)
    (rsqrt : Float32 → Float32) (root : RsqrtBounds.Envelope rsqrt) :
    |real (NormalizationExecution.normalizer divide input expr width eps rsqrt)| ≤ (2 : ℝ)^21 := by
  have hm : 0 ≤ real (NormalizationExecution.mean divide input expr width) := accuracy.nonnegative _ _
    (SquaredSum.finite_evaluate input expr hf.hSum) hf.hWidth
    (SquaredSum.nonnegative input expr hf.hSum)
    ⟨by rw [hf.hWidthValue]; exact_mod_cast hf.hPositiveWidth, hf.hWidthUpper⟩ hf.hMean
  have epsBound := FlushToZero.add_ge_normal_right (NormalizationExecution.mean divide input expr width) eps
    hf.hMean hf.hEps hm hf.hNormalEps hf.hDenominator
  have fc := DyadicBounds.ceiling_range 1 21 (by decide) (by decide) (by decide)
  norm_num at fc
  have hr := RsqrtBounds.range rsqrt root eps (DyadicBounds.ceiling 1 21)
    (FlushToZero.threshold_pos.trans hf.hNormalEps) (by rw [fc.2]; positivity) (by
      rw [fc.2]
      norm_num at epsLower ⊢
      linarith only [epsLower])
  have h := hr.range _ (NormalizationExecution.denominator_finite divide input expr width eps hf) epsBound
  norm_num only [NormalizationExecution.normalizer, fc.2, pow_succ, pow_zero] at h ⊢
  exact h.2

theorem rms_energy (platform : RmsNorm.Platform)
    (division : DivisionDirectedBounds.Contract platform.divide) (root : RsqrtBounds.Envelope platform.rsqrt)
    (input : Fin n → Float32) (weight : Fin n → BF) (width eps : Float32)
    (size : n ≤ 7680)
    (hf : NormalizationExecution.ReductionFinite platform.divide input (RmsNorm.expression platform n) width eps)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^56)
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ 1)
    (epsLower : (2 : ℝ)^(-40 : Int) ≤ real eps) (before : M1Max.WordMemory) (base : Nat) :
    (∀ i, Model.isFinite (RmsNorm.value platform input weight width eps before base i) = true) ∧
      (∑ i, Model.toReal (RmsNorm.value platform input weight width eps before base i)^2) ≤ 32*(n : ℝ) := by
  have hs : SquaredSumEnergyBounds.sites (RmsNorm.expression platform n) ≤ 16384 := by
    have h := NormalizationEnergyBounds.expression_sites platform.contracted platform.groups n
      platform.groupsPositive platform.groupsBounded platform.reduction.tree platform.reduction.tree
      platform.reduction.coverage platform.reduction.coverage
    change SquaredSumEnergyBounds.sites (RmsNorm.expression platform n) ≤ _ at h
    omega
  have hn := NormalizationEnergyScale.normalizer_energy platform.divide platform.divError platform.division
    division input (RmsNorm.expression platform n) width eps hf (fun i => (hx i).2) hs
    (RmsNorm.coverage platform n) epsLower platform.rsqrt root
  have ib := inverse_bound platform.divide platform.divError platform.division input
    (RmsNorm.expression platform n) width eps hf epsLower platform.rsqrt root
  have stored := stored_energy input _ weight size hx hn.1 ib hw hn.2
  simpa only [NormalizedCastBounds.value, RmsNorm.value, RmsNorm.inverse_correct] using stored

end Inference.Contracts.Mlx.NormalizedVectorEnergy
