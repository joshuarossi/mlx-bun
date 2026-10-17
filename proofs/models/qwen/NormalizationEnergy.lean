import models.qwen.NormalizationUniformBounds
import contracts.mlx.NormalizedVectorEnergy
import Mathlib.Algebra.Order.BigOperators.Ring.Finset

namespace Inference.Models.Qwen.NormalizationEnergy
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
open scoped BigOperators
abbrev BF := BFloat16Arithmetic.Value

theorem energy (norm : Blocks.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56) :
    norm.Finite x ∧ (∑ i, Model.toReal (norm.forward x i)^2) ≤ 163840 := by
  have ranges := NormalizationUniformBounds.ranges_wide norm division root hw x hx
  have h := NormalizedVectorEnergy.rms_energy norm.platform division root (Blocks.widenInput x) norm.weight
    Blocks.width Blocks.eps (by decide) ranges.1.toReductionFinite
    (NormalizationRanges.widened x 56 (fun i => by simpa only [zpow_ofNat] using hx i)) hw
    (by rw [Blocks.eps_value]; norm_num) norm.scratch norm.base
  refine ⟨ranges.1, ?_⟩
  simpa only [Blocks.Norm.forward, Layers.Normalization.value, Layers.Normalization.prepare,
    Bool.false_eq_true, ite_false, Nat.cast_ofNat, show (32 : ℝ)*5120=163840 from by norm_num] using h.2

-- Cauchy-Schwarz turns the stored-vector energy bound into the magnitude
-- used by dot-product bounds. This covers every element, including tails.
theorem absolute_sum (norm : Blocks.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56) :
    (∑ i, |Model.toReal (norm.forward x i)|) ≤ 32768 := by
  have h := (energy norm division root hw x hx).2
  have cs := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i : Fin 5120 => |Model.toReal (norm.forward x i)|) (fun _ => (1 : ℝ))
  simp only [mul_one, sq_abs, one_pow, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, Nat.cast_ofNat] at cs
  have positive : 0 ≤ ∑ i, |Model.toReal (norm.forward x i)| :=
    Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  nlinarith only [h, cs, positive]

theorem weighted_sum (norm : Blocks.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtBounds.Envelope norm.platform.rsqrt)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 1)
    (x : Fin 5120 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^56)
    (weight : Fin 5120 → ℝ) (cap : ℝ) (wc : ∀ i, |weight i| ≤ cap) :
    |∑ i, weight i*Model.toReal (norm.forward x i)| ≤ cap*32768 := by
  have cn : 0 ≤ cap := (abs_nonneg (weight 0)).trans (wc 0)
  calc
    _ ≤ ∑ i, |weight i*Model.toReal (norm.forward x i)| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, cap*|Model.toReal (norm.forward x i)| := by
      apply Finset.sum_le_sum
      intro i _
      rw [abs_mul]
      exact mul_le_mul_of_nonneg_right (wc i) (abs_nonneg _)
    _ = cap*(∑ i, |Model.toReal (norm.forward x i)|) := by rw [Finset.mul_sum]
    _ ≤ _ := mul_le_mul_of_nonneg_left (absolute_sum norm division root hw x hx) cn

end Inference.Models.Qwen.NormalizationEnergy
