import models.qwen.NormalizationEnergy
import models.qwen.NormalizedAffineProjection
import kernels.quantization.AffineTileMagnitude
import kernels.quantization.AffineRowMagnitude

namespace Inference.Models.Qwen.NormalizedAffineMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Quantization
open Layers.AffineVerifyLinear Layers.AffineVerifyLinearBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

-- Use the stored normalization energy in the actual tiled machine reduction,
-- including grouped BF16 sums, input division, FMA choice and final BF16 cast.
theorem range4 (norm : Blocks.Norm) (p : Projection4 10 rows)
    (parameters : Parameters4 p NormalizedAffineProjection.profile4)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract p.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56) :
    norm.Finite x ∧ p.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (p.forward (norm.forward x) row) = true ∧
        |Model.toReal (p.forward (norm.forward x) row)| ≤ (2 : ℝ)^18 := by
  have ranges := NormalizedAffineProjection.range4 norm p parameters division root projectDivision hw x hx
  have normalized := NormalizationUniformBounds.ranges_wide norm division root hw x hx
  refine ⟨ranges.1, ranges.2.1, fun row => ⟨(ranges.2.2 row).1, ?_⟩⟩
  have tile (step : Fin 10) (lane : Fin 32) :
      |real (AffineRow.tiles4 p.platform (norm.forward x) (p.weights row) step lane)| ≤
        4*(∑ i, |Model.toReal (norm.forward x (AffineLayout.inputIndex step lane i))|)+(2 : ℝ)^(-40 : Int) := by
    apply AffineTileMagnitude.value4_bound p.platform.tile projectDivision _ _ _ _
    · intro i
      exact ⟨norm.forward_finite x normalized.1 _, normalized.2 _⟩
    · simpa only [NormalizedAffineProjection.profile4, show (2 : ℝ)^(-4 : Int)=1/16 from by norm_num] using
        (parameters.scale row (AffineRow.groupIndex step lane)).2
    · simpa only [NormalizedAffineProjection.profile4, show (2 : ℝ)^(-1 : Int)=1/2 from by norm_num] using
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
      (AffineRow.tiles4 p.platform (norm.forward x) (p.weights row))) = true := by
    simpa only [Projection4.forward] using ranges.2.1.cast row
  have output := AffineRowMagnitude.output_bound (steps := 10) p.platform
    (AffineRow.tiles4 p.platform (norm.forward x) (p.weights row))
    (by decide) (ranges.2.1.reduction row) cast
  change |Model.toReal (p.forward (norm.forward x) row)| ≤ _ at output
  have tileBound : (∑ lane, ∑ step,
      |real (AffineRow.tiles4 p.platform (norm.forward x) (p.weights row) step lane)|) ≤
      4*32768+10*(32*(2 : ℝ)^(-40 : Int)) := by
    calc
      _ ≤ 4*(∑ i, |Model.toReal (norm.forward x i)|)+10*(32*(2 : ℝ)^(-40 : Int)) := collapsed
      _ ≤ _ := add_le_add (mul_le_mul_of_nonneg_left absolute (by norm_num : (0 : ℝ) ≤ 4)) le_rfl
  calc
    _ ≤ (9/8 : ℝ)*(∑ lane, ∑ step,
      |real (AffineRow.tiles4 p.platform (norm.forward x) (p.weights row) step lane)|)+(2 : ℝ)^(-96 : Int) := output
    _ ≤ (9/8 : ℝ)*(4*32768+10*(32*(2 : ℝ)^(-40 : Int)))+(2 : ℝ)^(-96 : Int) :=
      add_le_add (mul_le_mul_of_nonneg_left tileBound (by norm_num : (0 : ℝ) ≤ 9/8)) le_rfl
    _ ≤ _ := by norm_num

end Inference.Models.Qwen.NormalizedAffineMagnitude
