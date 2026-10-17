import models.qwen.NormalizationEnergy
import models.qwen.NormalizedAffineProjection

namespace Inference.Models.Qwen.NormalizedAffineEnergy
open Contracts.Mlx Contracts.Mlx.Numerics Kernels.Quantization
open Layers.AffineVerifyLinear Layers.AffineVerifyLinearBounds
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

theorem affine_weight (scale bias : ℝ) (code : Nat) (limit : ℝ)
    (hs : |scale| ≤ 1/16) (hb : |bias| ≤ 1/2) (hc : (code : ℝ) ≤ limit) :
    |scale*(code : ℝ)+bias| ≤ limit/16+1/2 := by
  have hn : (0 : ℝ) ≤ code := Nat.cast_nonneg _
  calc
    _ ≤ |scale*(code : ℝ)|+|bias| := abs_add_le _ _
    _ = |scale| * (code : ℝ)+|bias| := by rw [abs_mul, abs_of_nonneg hn]
    _ ≤ (1/16 : ℝ)*(code : ℝ)+1/2 := add_le_add (mul_le_mul_of_nonneg_right hs hn) hb
    _ ≤ _ := by linarith only [hc]

theorem weight3 (p : Projection3 10 rows) (parameters : Parameters3 p NormalizedAffineProjection.profile3)
    (row : Fin rows) (i : Fin 5120) : |AffineRow.weight3 (p.weights row) i| ≤ 15/16 := by
  let position := (AffineLayout.inputEquiv 10).symm i
  have hs := (parameters.scale row (AffineRow.groupIndex position.1 position.2.1)).2
  have hb := (parameters.bias row (AffineRow.groupIndex position.1 position.2.1)).2
  have hc : AffineRow.decode3 ((p.weights row).bytes position.1 position.2.1) position.2.2 ≤ 7 := by
    have h := AffinePacking.field3_bound
      (((p.weights row).bytes position.1 position.2.1) ⟨position.2.2.val/8, by have := position.2.2.isLt; omega⟩)
      ⟨position.2.2.val%8, by omega⟩
    change AffineRow.decode3 ((p.weights row).bytes position.1 position.2.1) position.2.2 < 8 at h
    omega
  norm_num [NormalizedAffineProjection.profile3] at hs hb
  have h := affine_weight _ _ _ 7 hs hb (by exact_mod_cast hc)
  norm_num at h
  exact h

theorem weight4 (p : Projection4 10 rows) (parameters : Parameters4 p NormalizedAffineProjection.profile4)
    (row : Fin rows) (i : Fin 5120) : |AffineRow.weight4 (p.weights row) i| ≤ 23/16 := by
  let position := (AffineLayout.inputEquiv 10).symm i
  have hs := (parameters.scale row (AffineRow.groupIndex position.1 position.2.1)).2
  have hb := (parameters.bias row (AffineRow.groupIndex position.1 position.2.1)).2
  have hc : AffineRow.decode4 ((p.weights row).words position.1 position.2.1) position.2.2 ≤ 15 := by
    have h := AffinePacking.field4_bound
      (((p.weights row).words position.1 position.2.1) ⟨position.2.2.val/4, by have := position.2.2.isLt; omega⟩)
      ⟨position.2.2.val%4, by omega⟩
    change AffineRow.decode4 ((p.weights row).words position.1 position.2.1) position.2.2 < 16 at h
    omega
  norm_num [NormalizedAffineProjection.profile4] at hs hb
  have h := affine_weight _ _ _ 15 hs hb (by exact_mod_cast hc)
  norm_num at h
  exact h

theorem target3 (norm : Blocks.Norm) (p : Projection3 10 rows)
    (parameters : Parameters3 p NormalizedAffineProjection.profile3)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56)
    (row : Fin rows) : |p.target (fun i => Model.toReal (norm.forward x i)) row| ≤ 30720 := by
  have h := NormalizationEnergy.weighted_sum norm division root hw x hx
    (AffineRow.weight3 (p.weights row)) (15/16) (weight3 p parameters row)
  simpa only [Projection3.target, mul_comm, show (15/16 : ℝ)*32768=30720 from by norm_num] using h

theorem target4 (norm : Blocks.Norm) (p : Projection4 10 rows)
    (parameters : Parameters4 p NormalizedAffineProjection.profile4)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56)
    (row : Fin rows) : |p.target (fun i => Model.toReal (norm.forward x i)) row| ≤ 47104 := by
  have h := NormalizationEnergy.weighted_sum norm division root hw x hx
    (AffineRow.weight4 (p.weights row)) (23/16) (weight4 p parameters row)
  simpa only [Projection4.target, mul_comm, show (23/16 : ℝ)*32768=47104 from by norm_num] using h

-- The tighter mathematical magnitude is combined with the actual kernel's
-- rounding budget; it is not asserted as an error-free machine result.
theorem forward3 (norm : Blocks.Norm) (p : Projection3 10 rows)
    (parameters : Parameters3 p NormalizedAffineProjection.profile3)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract p.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56)
    (row : Fin rows) :
    |Model.toReal (p.forward (norm.forward x) row)| ≤ 30720+
      p.budget (norm.forward x) (fun i => Model.toReal (norm.forward x i)) (fun _ => 0) row := by
  have hf := NormalizedAffineProjection.range3 norm p parameters division root projectDivision hw x hx
  have he := p.forward_error (norm.forward x) (fun i => Model.toReal (norm.forward x i)) (fun _ => 0)
    (fun _ => by simp) hf.2.1 row
  have h := NormalizedCastBounds.absolute_of_error _ _ _ he
  linarith only [h, target3 norm p parameters division root hw x hx row]

theorem forward4 (norm : Blocks.Norm) (p : Projection4 10 rows)
    (parameters : Parameters4 p NormalizedAffineProjection.profile4)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (projectDivision : DivisionDirectedBounds.Contract p.platform.tile.divide)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56)
    (row : Fin rows) :
    |Model.toReal (p.forward (norm.forward x) row)| ≤ 47104+
      p.budget (norm.forward x) (fun i => Model.toReal (norm.forward x i)) (fun _ => 0) row := by
  have hf := NormalizedAffineProjection.range4 norm p parameters division root projectDivision hw x hx
  have he := p.forward_error (norm.forward x) (fun i => Model.toReal (norm.forward x i)) (fun _ => 0)
    (fun _ => by simp) hf.2.1 row
  have h := NormalizedCastBounds.absolute_of_error _ _ _ he
  linarith only [h, target4 norm p parameters division root hw x hx row]

end Inference.Models.Qwen.NormalizedAffineEnergy
