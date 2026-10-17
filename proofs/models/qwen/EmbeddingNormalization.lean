import models.qwen.EmbeddingRanges
import models.qwen.Blocks
import contracts.mlx.NormalizationBounds

namespace Inference.Models.Qwen.EmbeddingNormalization
open Contracts.Mlx Contracts.Mlx.Numerics
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

theorem width_constructor : Blocks.width = Float32.ofInt ((5120 : Nat) : Int) := by decide +kernel

theorem input_range (l : Layers.QuantizedEmbedding.Layer) (hp : EmbeddingRanges.Parameters l)
    (token : Fin 248320) (i : Fin 5120) :
    (Blocks.widenInput (l.forward token) i).isFinite = true ∧
      |real (Blocks.widenInput (l.forward token) i)| ≤ 1 := by
  have hf := l.forward_finite token (EmbeddingRanges.embedding_finite l hp token) i
  refine ⟨BFloat16.widen_finite _ hf, ?_⟩
  unfold Blocks.widenInput
  rw [BFloat16.widen_real _ hf]
  linarith [EmbeddingRanges.embedding_bounded l hp token i]

theorem ranges (l : Layers.QuantizedEmbedding.Layer) (hp : EmbeddingRanges.Parameters l)
    (norm : Blocks.Norm) (p : NormalizationBounds.Profile) (heps : p.eps = Blocks.eps)
    (division : DivisionBounds.Contract norm.platform.divide)
    (root : NormalizationBounds.RsqrtRange norm.platform.rsqrt p.eps p.inverseCap)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ Model.toReal p.weightCap)
    (token : Fin 248320) :
    norm.Finite (l.forward token) ∧
      ∀ i, |Model.toReal (norm.forward (l.forward token) i)| ≤ Model.toReal p.outputCap := by
  have h := p.ranges norm.platform division root (Blocks.widenInput (l.forward token)) norm.weight
    (input_range l hp token) hw (by decide) (by decide)
  rw [heps, ← width_constructor] at h
  refine ⟨h.1, ?_⟩
  intro i
  have hf := norm.forward_finite (l.forward token) h.1 i
  rw [← BFloat16.widen_real _ hf]
  unfold Blocks.Norm.forward Layers.Normalization.value
  simp only [Layers.Normalization.prepare, Bool.false_eq_true, ite_false]
  unfold RmsNorm.value
  rw [RmsNorm.inverse_correct]
  exact h.2 i

theorem accuracy (l : Layers.QuantizedEmbedding.Layer) (hp : EmbeddingRanges.Parameters l)
    (norm : Blocks.Norm) (p : NormalizationBounds.Profile) (heps : p.eps = Blocks.eps)
    (division : DivisionBounds.Contract norm.platform.divide)
    (root : NormalizationBounds.RsqrtRange norm.platform.rsqrt p.eps p.inverseCap)
    (hw : ∀ i, Model.isFinite (norm.weight i) = true ∧ |Model.toReal (norm.weight i)| ≤ Model.toReal p.weightCap)
    (token : Fin 248320) (i : Fin 5120) :
    Model.isFinite (norm.forward (l.forward token) i) = true ∧
      |Model.toReal (norm.forward (l.forward token) i) - norm.target (l.target token) i| ≤
        norm.errorBudget (l.forward token) (l.target token) (l.budget token) i := by
  have hr := ranges l hp norm p heps division root hw token
  have he := EmbeddingRanges.embedding_finite l hp token
  exact ⟨norm.forward_finite _ hr.1 i,
    norm.forward_error _ (l.target token) (l.budget token) (l.forward_error token he)
      (l.forward_finite token he) (fun j => (hw j).1) hr.1 i⟩

end Inference.Models.Qwen.EmbeddingNormalization
