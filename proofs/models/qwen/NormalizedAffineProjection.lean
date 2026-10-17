import models.qwen.NormalizationUniformBounds
import layers.AffineVerifyLinearShiftedBounds

namespace Inference.Models.Qwen.NormalizedAffineProjection
open Contracts.Mlx Contracts.Mlx.Numerics Layers.AffineVerifyLinear Layers.AffineVerifyLinearBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

def outputCap : BF := BFloat16DyadicBounds.ceiling 1 23
theorem outputCap_finite : Model.isFinite outputCap = true :=
  (BFloat16DyadicBounds.ceiling_range 1 23 (by decide) (by decide) (by decide)).1
theorem outputCap_real : Model.toReal outputCap = (2 : ℝ)^(23 : Nat) := by
  simpa only [outputCap, Nat.cast_one, one_mul, zpow_ofNat] using
    (BFloat16DyadicBounds.ceiling_range 1 23 (by decide) (by decide) (by decide)).2

def profile3 : Profile 10 36 3 where
  inputExponent := 9
  scaleExponent := -4
  biasExponent := -1
  tileExponent := 8
  inputLower := by decide
  inputUpper := by decide
  tileLower := by decide
  tileUpper := by decide
  scaled := by decide
  biased := by decide
  size := by decide
  outputCap := outputCap
  outputFinite := outputCap_finite
  capacity := by rw [outputCap_real]; norm_num

def profile4 : Profile 10 32 4 where
  inputExponent := 9
  scaleExponent := -4
  biasExponent := -1
  tileExponent := 9
  inputLower := by decide
  inputUpper := by decide
  tileLower := by decide
  tileUpper := by decide
  scaled := by decide
  biased := by decide
  size := by decide
  outputCap := outputCap
  outputFinite := outputCap_finite
  capacity := by rw [outputCap_real]; norm_num

-- The parameter predicates require finite scale/bias values bounded by one;
-- the profiles above discharge every internal capacity with concrete numbers.
theorem range3 (norm : Blocks.Norm) (projection : Projection3 10 rows)
    (parameters : Parameters3 projection profile3)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract projection.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ projection.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (projection.forward (norm.forward x) row) = true ∧
        |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) := by
  have hn := NormalizationUniformBounds.ranges_wide norm normDivision root hw x hx
  have hp := Layers.AffineVerifyLinearShiftedBounds.range3 projection profile3 parameters projectDivision (norm.forward x)
    (fun i => ⟨norm.forward_finite x hn.1 i, by simpa only [profile3, show (2 : ℝ)^(9 : Int) = 512 from by norm_num] using hn.2 i⟩)
  exact ⟨hn.1, hp.1, fun row => ⟨projection.forward_finite _ hp.1 row,
    by simpa only [profile3, outputCap_real] using hp.2 row⟩⟩

theorem range4 (norm : Blocks.Norm) (projection : Projection4 10 rows)
    (parameters : Parameters4 projection profile4)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract projection.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ projection.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (projection.forward (norm.forward x) row) = true ∧
        |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) := by
  have hn := NormalizationUniformBounds.ranges_wide norm normDivision root hw x hx
  have hp := Layers.AffineVerifyLinearShiftedBounds.range4 projection profile4 parameters projectDivision (norm.forward x)
    (fun i => ⟨norm.forward_finite x hn.1 i, by simpa only [profile4, show (2 : ℝ)^(9 : Int) = 512 from by norm_num] using hn.2 i⟩)
  exact ⟨hn.1, hp.1, fun row => ⟨projection.forward_finite _ hp.1 row,
    by simpa only [profile4, outputCap_real] using hp.2 row⟩⟩

theorem accuracy3 (norm : Blocks.Norm) (projection : Projection3 10 rows)
    (parameters : Parameters3 projection profile3)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract projection.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat))
    (target error : Fin 5120 → ℝ) (he : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (row : Fin rows) :
    Model.isFinite (projection.forward (norm.forward x) row) = true ∧
      |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) ∧
      |Model.toReal (projection.forward (norm.forward x) row) - projection.target (norm.target target) row| ≤
        projection.budget (norm.forward x) (norm.target target) (norm.errorBudget x target error) row := by
  have h := range3 norm projection parameters normDivision root projectDivision hw x hx
  exact ⟨(h.2.2 row).1, (h.2.2 row).2,
    projection.forward_error _ _ _ (norm.forward_error x target error he (fun i => (hx i).1) (fun i => (hw i).1) h.1) h.2.1 row⟩

theorem accuracy4 (norm : Blocks.Norm) (projection : Projection4 10 rows)
    (parameters : Parameters4 projection profile4)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract projection.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat))
    (target error : Fin 5120 → ℝ) (he : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (row : Fin rows) :
    Model.isFinite (projection.forward (norm.forward x) row) = true ∧
      |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) ∧
      |Model.toReal (projection.forward (norm.forward x) row) - projection.target (norm.target target) row| ≤
        projection.budget (norm.forward x) (norm.target target) (norm.errorBudget x target error) row := by
  have h := range4 norm projection parameters normDivision root projectDivision hw x hx
  exact ⟨(h.2.2 row).1, (h.2.2 row).2,
    projection.forward_error _ _ _ (norm.forward_error x target error he (fun i => (hx i).1) (fun i => (hw i).1) h.1) h.2.1 row⟩

def Parameters : Projection 10 rows → Prop
  | .bits3 p => Parameters3 p profile3
  | .bits4 p => Parameters4 p profile4

def DivisionContract : Projection 10 rows → Prop
  | .bits3 p => DivisionDirectedBounds.Contract p.platform.tile.divide
  | .bits4 p => DivisionDirectedBounds.Contract p.platform.tile.divide

theorem ranges (norm : Blocks.Norm) (projection : Projection 10 rows)
    (parameters : Parameters projection)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtBounds.Envelope norm.platform.rsqrt) (projectDivision : DivisionContract projection)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat)) :
    norm.Finite x ∧ projection.Finite (norm.forward x) ∧
      ∀ row, Model.isFinite (projection.forward (norm.forward x) row) = true ∧
        |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) := by
  cases projection with
  | bits3 p => exact range3 norm p parameters normDivision root projectDivision hw x hx
  | bits4 p => exact range4 norm p parameters normDivision root projectDivision hw x hx

theorem accuracy (norm : Blocks.Norm) (projection : Projection 10 rows)
    (parameters : Parameters projection)
    (normDivision : DivisionDirectedBounds.Contract norm.platform.divide)
    (root : RsqrtBounds.Envelope norm.platform.rsqrt) (projectDivision : DivisionContract projection)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(56 : Nat))
    (target error : Fin 5120 → ℝ) (he : ∀ i, |Model.toReal (x i) - target i| ≤ error i) (row : Fin rows) :
    Model.isFinite (projection.forward (norm.forward x) row) = true ∧
      |Model.toReal (projection.forward (norm.forward x) row)| ≤ (2 : ℝ)^(23 : Nat) ∧
      |Model.toReal (projection.forward (norm.forward x) row) - projection.target (norm.target target) row| ≤
        projection.budget (norm.forward x) (norm.target target) (norm.errorBudget x target error) row := by
  cases projection with
  | bits3 p => exact accuracy3 norm p parameters normDivision root projectDivision hw x hx target error he row
  | bits4 p => exact accuracy4 norm p parameters normDivision root projectDivision hw x hx target error he row

end Inference.Models.Qwen.NormalizedAffineProjection
