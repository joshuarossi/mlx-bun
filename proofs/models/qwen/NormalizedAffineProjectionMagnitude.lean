import models.qwen.NormalizedAffineMagnitude
import kernels.quantization.AffineTile3Magnitude

namespace Inference.Models.Qwen.NormalizedAffineProjectionMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Quantization
open Layers.AffineVerifyLinear Layers.AffineVerifyLinearBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

theorem range3 (norm : Blocks.Norm) (p : Projection3 10 rows)
    (parameters : Parameters3 p NormalizedAffineProjection.profile3)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract p.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56) :
    norm.Finite x ∧ p.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (p.forward (norm.forward x) row) = true ∧
        |Model.toReal (p.forward (norm.forward x) row)| ≤ (2 : ℝ)^18 := by
  have ranges := NormalizedAffineProjection.range3 norm p parameters division root projectDivision hw x hx
  have normalized := NormalizationUniformBounds.ranges_wide norm division root hw x hx
  refine ⟨ranges.1, ranges.2.1, fun row => ⟨(ranges.2.2 row).1, ?_⟩⟩
  have tile (step : Fin 10) (lane : Fin 32) :
      |real (AffineRow.tiles3 p.platform (norm.forward x) (p.weights row) step lane)| ≤
        4*(∑ i, |Model.toReal (norm.forward x (AffineLayout.inputIndex step lane i))|)+(2 : ℝ)^(-40 : Int) := by
    apply AffineTile3Magnitude.value_bound p.platform.tile projectDivision _ _ _ _
    · intro i
      exact ⟨norm.forward_finite x normalized.1 _, normalized.2 _⟩
    · simpa only [NormalizedAffineProjection.profile3, show (2 : ℝ)^(-4 : Int)=1/16 from by norm_num] using
        (parameters.scale row (AffineRow.groupIndex step lane)).2
    · simpa only [NormalizedAffineProjection.profile3, show (2 : ℝ)^(-1 : Int)=1/2 from by norm_num] using
        (parameters.bias row (AffineRow.groupIndex step lane)).2
    · exact ranges.2.1.tiles row step lane
  have sumBound := Finset.sum_le_sum (s := Finset.univ) (fun lane _ =>
    Finset.sum_le_sum (s := Finset.univ) (fun step _ => tile step lane))
  simp only [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
    Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, Nat.cast_ofNat] at sumBound
  have coverage := AffineLayout.lane_coverage (fun i : Fin (10*512) => |Model.toReal (norm.forward x i)|)
  have collapsed := sumBound.trans_eq (congrArg (fun total : ℝ => 4*total+10*(32*(2 : ℝ)^(-40 : Int))) coverage)
  have absolute := NormalizationEnergy.absolute_sum norm division root hw x hx
  have cast : Model.isFinite (AffineRow.output p.platform
      (AffineRow.tiles3 p.platform (norm.forward x) (p.weights row))) = true := by
    simpa only [Projection3.forward] using ranges.2.1.cast row
  have output := AffineRowMagnitude.output_bound (steps := 10) p.platform
    (AffineRow.tiles3 p.platform (norm.forward x) (p.weights row))
    (by decide) (ranges.2.1.reduction row) cast
  change |Model.toReal (p.forward (norm.forward x) row)| ≤ _ at output
  have tileBound : (∑ lane, ∑ step,
      |real (AffineRow.tiles3 p.platform (norm.forward x) (p.weights row) step lane)|) ≤
      4*32768+10*(32*(2 : ℝ)^(-40 : Int)) := by
    calc
      _ ≤ 4*(∑ i, |Model.toReal (norm.forward x i)|)+10*(32*(2 : ℝ)^(-40 : Int)) := collapsed
      _ ≤ _ := add_le_add (mul_le_mul_of_nonneg_left absolute (by norm_num : (0 : ℝ) ≤ 4)) le_rfl
  calc
    _ ≤ (9/8 : ℝ)*(∑ lane, ∑ step,
      |real (AffineRow.tiles3 p.platform (norm.forward x) (p.weights row) step lane)|)+(2 : ℝ)^(-96 : Int) := output
    _ ≤ (9/8 : ℝ)*(4*32768+10*(32*(2 : ℝ)^(-40 : Int)))+(2 : ℝ)^(-96 : Int) :=
      add_le_add (mul_le_mul_of_nonneg_left tileBound (by norm_num : (0 : ℝ) ≤ 9/8)) le_rfl
    _ ≤ _ := by norm_num

-- This static sum-type elimination covers both packed formats; it introduces
-- no numerical fit checks or branches into the inference implementation.
theorem ranges (norm : Blocks.Norm) (p : Projection 10 rows)
    (parameters : NormalizedAffineProjection.Parameters p)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : NormalizedAffineProjection.DivisionContract p)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56) :
    norm.Finite x ∧ p.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (p.forward (norm.forward x) row) = true ∧
        |Model.toReal (p.forward (norm.forward x) row)| ≤ (2 : ℝ)^18 := by
  cases p with
  | bits3 p => exact range3 norm p parameters division root projectDivision hw x hx
  | bits4 p => exact NormalizedAffineMagnitude.range4 norm p parameters division root projectDivision hw x hx

theorem accuracy (norm : Blocks.Norm) (p : Projection 10 rows)
    (parameters : NormalizedAffineProjection.Parameters p)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : NormalizedAffineProjection.DivisionContract p)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56)
    (target error : Fin 5120 → ℝ) (he : ∀ i, |Model.toReal (x i)-target i| ≤ error i) (row : Fin rows) :
    Model.isFinite (p.forward (norm.forward x) row) = true ∧
      |Model.toReal (p.forward (norm.forward x) row)| ≤ (2 : ℝ)^18 ∧
      |Model.toReal (p.forward (norm.forward x) row)-p.target (norm.target target) row| ≤
        p.budget (norm.forward x) (norm.target target) (norm.errorBudget x target error) row := by
  have h := ranges norm p parameters division root projectDivision hw x hx
  exact ⟨(h.2.2 row).1, (h.2.2 row).2,
    p.forward_error _ _ _ (norm.forward_error x target error he (fun i => (hx i).1) (fun i => (hw i).1) h.1) h.2.1 row⟩

end Inference.Models.Qwen.NormalizedAffineProjectionMagnitude
