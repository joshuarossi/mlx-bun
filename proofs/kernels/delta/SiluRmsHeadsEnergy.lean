import kernels.delta.SiluRmsHeadsSumBounds
import contracts.mlx.NormalizedCastBounds
import contracts.mlx.RsqrtRelativeBounds

namespace Inference.Kernels.Delta.SiluRmsHeadsEnergy
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators

-- The division equality is a scalar native/logical correspondence boundary.
-- The sum, division rounding, epsilon addition and lower bound are proved.
theorem denominator_lower (divide : Float32 → Float32 → Float32)
    (input : Fin 128 → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (width eps : Float32)
    (hf : NormalizationExecution.ReductionFinite divide input (SiluRmsHeads.expression contracted tree) width eps)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(50 : Nat))
    (epsilonLower : (2 : ℝ)^(-21 : Int) ≤ real eps)
    (native : divide (NormalizationExecution.sum input (SiluRmsHeads.expression contracted tree)) width =
      FlushToZero.div (NormalizationExecution.sum input (SiluRmsHeads.expression contracted tree)) width) :
    (255/256 : ℝ)*((∑ i : Fin 128, (real (input i))^2)/128)+real eps/2 ≤
      real (NormalizationExecution.denominator divide input (SiluRmsHeads.expression contracted tree) width eps) := by
  let sum := NormalizationExecution.sum input (SiluRmsHeads.expression contracted tree)
  let mean := NormalizationExecution.mean divide input (SiluRmsHeads.expression contracted tree) width
  have hw : real width = 128 := hf.hWidthValue
  have wf : FlushToZero.flush width = width := FlushToZero.flush_eq_of_one_le width (by rw [hw]; norm_num)
  have mn : mean = FlushToZero.div sum width := native
  have sf : sum.isFinite = true := SquaredSum.finite_evaluate input _ hf.hSum
  have sn : 0 ≤ real sum := SquaredSum.nonnegative input _ hf.hSum
  have raw : (FlushToZero.flush sum/width).isFinite = true := by
    have h := hf.hMean
    change mean.isFinite = true at h
    rw [mn, FlushToZero.div, wf, FlushToZero.finite_flush_iff] at h
    exact h
  have mp : 0 ≤ real mean := by
    rw [mn]
    apply FlushToZero.div_nonnegative sum width hf.hWidth sn (by rw [hw]; norm_num)
    rwa [wf]
  have ep : 0 < real eps := lt_of_lt_of_le (by positivity : (0 : ℝ) < (2 : ℝ)^(-21 : Int)) epsilonLower
  have hs := SiluRmsHeadsSumBounds.uniform_error input contracted tree coverage hx
  change |real sum - ∑ i : Fin 128, (real (input i))^2| ≤ _ at hs
  have hm := RelativeRounding.division sum width hf.hWidth (by rw [hw]; norm_num) raw
  rw [← mn, hw, abs_of_nonneg sn] at hm
  have hd := RelativeRounding.addition mean eps hf.hMean hf.hEps hf.hDenominator
  rw [abs_of_nonneg mp, abs_of_pos ep] at hd
  have en : 0 ≤ ∑ i : Fin 128, (real (input i))^2 := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  change _ ≤ real (FlushToZero.add mean eps)
  have sl := (abs_le.mp hs).1
  have ml := (abs_le.mp hm).1
  have dl := (abs_le.mp hd).1
  norm_num [FlushToZero.threshold] at sl ml dl epsilonLower ⊢
  linarith

theorem normalizer_bounds (divide : Float32 → Float32 → Float32) (rsqrt : Float32 → Float32)
    (input : Fin 128 → Float32) (contracted : Bool) (tree : Reduction.Tree 32)
    (coverage : (Reduction.leaves tree).Perm (List.finRange 32)) (width eps : Float32)
    (hf : NormalizationExecution.ReductionFinite divide input (SiluRmsHeads.expression contracted tree) width eps)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(50 : Nat))
    (epsilonLower : (2 : ℝ)^(-21 : Int) ≤ real eps)
    (native : divide (NormalizationExecution.sum input (SiluRmsHeads.expression contracted tree)) width =
      FlushToZero.div (NormalizationExecution.sum input (SiluRmsHeads.expression contracted tree)) width)
    (root : RsqrtRelativeBounds.Envelope rsqrt (17/16)) :
    let inverse := NormalizationExecution.normalizer divide input (SiluRmsHeads.expression contracted tree) width eps rsqrt
    inverse.isFinite = true ∧ |real inverse| ≤ (2 : ℝ)^(12 : Nat) ∧
      real inverse^2*(∑ i : Fin 128, (real (input i))^2) ≤ (36992/255 : ℝ) := by
  let denominator := NormalizationExecution.denominator divide input (SiluRmsHeads.expression contracted tree) width eps
  let inverse := rsqrt denominator
  let energy := ∑ i : Fin 128, (real (input i))^2
  have en : 0 ≤ energy := Finset.sum_nonneg (fun i _ => sq_nonneg _)
  have lower := denominator_lower divide input contracted tree coverage width eps hf hx epsilonLower native
  change (255/256 : ℝ)*(energy/128)+real eps/2 ≤ real denominator at lower
  have floor : (2 : ℝ)^(-22 : Int) ≤ real denominator := by
    norm_num at epsilonLower ⊢
    linarith only [lower, en, epsilonLower]
  have dp : 0 < real denominator := lt_of_lt_of_le (by positivity) floor
  have df : denominator.isFinite = true := NormalizationExecution.denominator_finite divide input _ width eps hf
  have squared := RsqrtRelativeBounds.squared rsqrt (17/16) root denominator df dp
  change real inverse^2*real denominator ≤ (17/16 : ℝ)^2 at squared
  have inverseBound : |real inverse| ≤ (2 : ℝ)^(12 : Nat) := by
    have lo := mul_le_mul_of_nonneg_right floor (sq_nonneg (real inverse))
    norm_num at lo squared ⊢
    nlinarith only [lo, squared, sq_abs (real inverse), abs_nonneg (real inverse)]
  refine ⟨root.finite denominator df dp, inverseBound, ?_⟩
  change real inverse^2*energy ≤ (36992/255 : ℝ)
  have weighted := mul_le_mul_of_nonneg_right lower (sq_nonneg (real inverse))
  have ep : 0 ≤ real eps := le_trans (by positivity) epsilonLower
  have nonnegative := mul_nonneg ep (sq_nonneg (real inverse))
  nlinarith only [weighted, squared, nonnegative]

theorem square_with_allowance (value main allowance : ℝ) (bound : |value| ≤ main+allowance) :
    value^2 ≤ (9/8 : ℝ)*main^2+9*allowance^2 := by
  have h := mul_self_le_mul_self (abs_nonneg value) bound
  rw [← sq, sq_abs, ← sq] at h
  nlinarith only [h, sq_nonneg (main-8*allowance)]

theorem stored_energy (input : Fin 128 → Float32) (inverse : Float32)
    (weight : Fin 128 → BFloat16Arithmetic.Value) (scale : ℝ)
    (hx : ∀ i, (input i).isFinite = true ∧ |real (input i)| ≤ (2 : ℝ)^(50 : Nat))
    (hi : inverse.isFinite = true) (ib : |real inverse| ≤ (2 : ℝ)^(12 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ scale)
    (sb : scale ≤ 1)
    (normalized : real inverse^2*(∑ i : Fin 128, (real (input i))^2) ≤ (36992/255 : ℝ)) :
    (∀ i, Model.isFinite (NormalizedCastBounds.value (input i) inverse (weight i)) = true) ∧
      (∑ i : Fin 128, Model.toReal (NormalizedCastBounds.value (input i) inverse (weight i))^2) ≤
        (9/8 : ℝ)*(17/16 : ℝ)^2*scale^2*(36992/255 : ℝ)+1152*(2 : ℝ)^(-120 : Int) := by
  have point i := NormalizedCastBounds.component (input i) inverse (weight i) (hx i).1 hi (hw i).1
    (hx i).2 ib ((hw i).2.trans sb)
  refine ⟨fun i => (point i).1, ?_⟩
  let coefficient := (17/16 : ℝ)*scale*|real inverse|
  have each (i : Fin 128) :
      Model.toReal (NormalizedCastBounds.value (input i) inverse (weight i))^2 ≤
        (9/8 : ℝ)*coefficient^2*(real (input i))^2+9*((2 : ℝ)^(-60 : Int))^2 := by
    have scaled := mul_le_mul_of_nonneg_right (hw i).2
      (by positivity : (0 : ℝ) ≤ (17/16 : ℝ)*(|real (input i)| * |real inverse|))
    have bound : |Model.toReal (NormalizedCastBounds.value (input i) inverse (weight i))| ≤
        coefficient*|real (input i)|+(2 : ℝ)^(-60 : Int) := by
      dsimp [coefficient]
      nlinarith only [(point i).2, scaled]
    have h := square_with_allowance _ _ _ bound
    simpa only [mul_pow, sq_abs, mul_assoc] using h
  have summed := Finset.sum_le_sum (s := Finset.univ) (fun i _ => each i)
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] at summed
  have bound := mul_le_mul_of_nonneg_left normalized
    (by positivity : (0 : ℝ) ≤ (9/8 : ℝ)*(17/16 : ℝ)^2*scale^2)
  have equality : (9/8 : ℝ)*coefficient^2*(∑ i : Fin 128, (real (input i))^2) =
      (9/8 : ℝ)*(17/16 : ℝ)^2*scale^2*(real inverse^2*(∑ i : Fin 128, (real (input i))^2)) := by
    simp only [coefficient, mul_pow, sq_abs]
    ring
  rw [equality] at summed
  norm_num at summed ⊢
  linarith only [summed, bound]

theorem normalized_energy (p : SiluRmsHeads.Platform)
    (input weight : Fin 128 → BFloat16Arithmetic.Value) (width eps : Float32) (scale : ℝ)
    (hf : NormalizationExecution.ReductionFinite p.divide (SiluRmsHeads.activated p input)
      (SiluRmsHeads.expression p.contracted p.reduction.tree) width eps)
    (hx : ∀ i, (SiluRmsHeads.activated p input i).isFinite = true ∧
      |real (SiluRmsHeads.activated p input i)| ≤ (2 : ℝ)^(50 : Nat))
    (hw : ∀ i, Model.isFinite (weight i) = true ∧ |Model.toReal (weight i)| ≤ scale)
    (sb : scale ≤ 1) (epsilonLower : (2 : ℝ)^(-21 : Int) ≤ real eps)
    (native : p.divide (NormalizationExecution.sum (SiluRmsHeads.activated p input)
        (SiluRmsHeads.expression p.contracted p.reduction.tree)) width =
      FlushToZero.div (NormalizationExecution.sum (SiluRmsHeads.activated p input)
        (SiluRmsHeads.expression p.contracted p.reduction.tree)) width)
    (root : RsqrtRelativeBounds.Envelope p.rsqrt (17/16)) :
    (∀ i, Model.isFinite (SiluRmsHeads.normalized p input weight width eps i) = true) ∧
      (∑ i : Fin 128, Model.toReal (SiluRmsHeads.normalized p input weight width eps i)^2) ≤
        (9/8 : ℝ)*(17/16 : ℝ)^2*scale^2*(36992/255 : ℝ)+1152*(2 : ℝ)^(-120 : Int) := by
  have hn := normalizer_bounds p.divide p.rsqrt (SiluRmsHeads.activated p input) p.contracted
    p.reduction.tree p.reduction.coverage width eps hf hx epsilonLower native root
  exact stored_energy (SiluRmsHeads.activated p input) _ weight scale hx hn.1 hn.2.1 hw sb hn.2.2

end Inference.Kernels.Delta.SiluRmsHeadsEnergy
