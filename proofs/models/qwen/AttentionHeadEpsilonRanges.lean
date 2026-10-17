import models.qwen.AttentionInputRanges
import contracts.mlx.RsqrtEpsilonBounds

namespace Inference.Models.Qwen.AttentionHeadEpsilonRanges
open Contracts.Mlx Contracts.Mlx.Numerics AttentionHeads Kernels.Attention AttentionInputRanges
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value

-- Original Q/K normalization values and attachments, with only reached
-- epsilon-normal rsqrt behavior; no graph/platform replacement is performed.
theorem norm_ranges (norm : AttentionHeads.Norm)
    (division : DivisionDirectedBounds.Contract norm.platform.divide) (root : RsqrtEpsilonBounds.Envelope norm.platform.rsqrt Blocks.eps 2)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ 4)
    (x : Fin 256 → BF) (hx : ∀ i, Model.isFinite (x i) = true ∧ |Model.toReal (x i)| ≤ (2 : ℝ)^(23 : Nat)) :
    norm.Finite x ∧ ∀ i, |Model.toReal (norm.forward x i)| ≤ 256 := by
  have h := RsqrtEpsilonBounds.uniform_ranges_wide normProfile norm.platform.divide norm.platform.divError norm.platform.division
    division norm.platform.rsqrt root (RmsNorm.expression norm.platform 256) (RmsNorm.coverage norm.platform 256)
    (fun i => BFloat16.widen (x i)) norm.weight
    (fun i => ⟨BFloat16.widen_finite _ (hx i).1, by
      rw [BFloat16.widen_real _ (hx i).1]; exact (hx i).2.trans (by norm_num)⟩)
    (fun i => by simpa only [normProfile, weightCap_real] using hw i)
  change NormalizationExecution.Finite norm.platform.divide (fun i => BFloat16.widen (x i)) norm.weight
    (RmsNorm.expression norm.platform 256) (Float32.ofInt ((256 : Nat) : Int)) Blocks.eps norm.platform.rsqrt ∧
      (∀ i, |real (NormalizationExecution.output norm.platform.divide (fun j => BFloat16.widen (x j)) norm.weight
        (RmsNorm.expression norm.platform 256) (Float32.ofInt ((256 : Nat) : Int)) Blocks.eps norm.platform.rsqrt i)| ≤ Model.toReal outputCap) at h
  rw [← width_constructor] at h
  refine ⟨h.1, fun i => ?_⟩
  rw [← BFloat16.widen_real _ (norm.forward_finite x h.1 i)]
  unfold AttentionHeads.Norm.forward Layers.Normalization.value
  simp only [Layers.Normalization.prepare, Bool.false_eq_true, ite_false]
  unfold RmsNorm.value
  rw [RmsNorm.inverse_correct]
  simpa only [outputCap_real, NormalizationExecution.output, NormalizationExecution.normalized] using h.2 i


theorem head_norms (prep : Preparation) (p : Projections) (input : Fin 5120 → BF) (projection : Projected p input)
    (qDivision : DivisionDirectedBounds.Contract prep.qNorm.platform.divide) (qRoot : RsqrtEpsilonBounds.Envelope prep.qNorm.platform.rsqrt Blocks.eps 2)
    (kDivision : DivisionDirectedBounds.Contract prep.kNorm.platform.divide) (kRoot : RsqrtEpsilonBounds.Envelope prep.kNorm.platform.rsqrt Blocks.eps 2)
    (qw : ∀ i, Model.isFinite (prep.qNorm.weight i) = true ∧ |Model.toReal (prep.qNorm.weight i)| ≤ 4)
    (kw : ∀ i, Model.isFinite (prep.kNorm.weight i) = true ∧ |Model.toReal (prep.kNorm.weight i)| ≤ 4) :
    Normalized prep (p.forward input) := by
  have hf := p.forward_finite input projection.finite
  have hq h := norm_ranges prep.qNorm qDivision qRoot qw _ (fun i => ⟨hf.query h i, projection.query h i⟩)
  have hk h := norm_ranges prep.kNorm kDivision kRoot kw _ (fun i => ⟨hf.key h i, projection.key h i⟩)
  exact ⟨fun h => (hq h).1, fun h => (hk h).1,
    ⟨fun h i => prep.qNorm.forward_finite _ (hq h).1 i, fun h i => prep.kNorm.forward_finite _ (hk h).1 i, hf.value, hf.gate⟩,
    fun h i => (hq h).2 i, fun h i => (hk h).2 i⟩

end Inference.Models.Qwen.AttentionHeadEpsilonRanges
