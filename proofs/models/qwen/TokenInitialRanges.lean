import models.qwen.Qwen38TrellisM1MaxInitialRanges
import models.qwen.EmbeddingRanges

namespace Inference.Models.Qwen.TokenInitialRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention TokenInference
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Parameters (p : Pipeline) : Prop where
  embedding : EmbeddingRanges.Parameters p.embedding
  graph : Qwen38TrellisM1MaxInitialRanges.Parameters p.graph

theorem embedding_bound (p : Pipeline) (parameters : Parameters p) (token : Fin 248320) :
    ResidualMlpRanges.InputBound 0 (p.embedding.forward token) := by
  intro i
  refine ⟨p.embedding.forward_finite token (EmbeddingRanges.embedding_finite p.embedding parameters.embedding token) i,
    (EmbeddingRanges.embedding_bounded p.embedding parameters.embedding token i).trans ?_⟩
  norm_num [ResidualMlpRanges.inputCeiling]

noncomputable def checked (p : Pipeline) (parameters : Parameters p)
    (primitive : Qwen38TrellisM1MaxInitialRanges.Primitives p.graph) (token : Fin 248320)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0) :
    p.Ranges (InitialState.caches p.graph.stages) token angle :=
  ⟨EmbeddingRanges.embedding_finite p.embedding parameters.embedding token,
    (Qwen38TrellisM1MaxInitialRanges.checked p.graph parameters.graph primitive (p.embedding.forward token)
      (embedding_bound p parameters token) angle ha position).finite⟩

-- First token, all 64 written stages, final normalization and every logit,
-- plus every returned cache slot. The remaining premises describe loaded
-- parameter data and scalar/platform conformance, not intermediate results.
-- Checkpoint/loader and native binary correspondence remain separate work.
theorem run_correct (p : Pipeline) (parameters : Parameters p)
    (primitive : Qwen38TrellisM1MaxInitialRanges.Primitives p.graph) (token : Fin 248320)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (position : real angle.position = 0)
    (aim ae : RopeAngles.Target) (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal ((p.run (InitialState.caches p.graph.stages) token angle).1 i)-
        (p.targetRun (InitialState.references p.graph.stages) token aim).1 i| ≤
      (p.budgetRun (InitialState.caches p.graph.stages) (InitialState.references p.graph.stages)
        (InitialState.references p.graph.stages) token angle aim ae (checked p parameters primitive token angle ha position)).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (p.run (InitialState.caches p.graph.stages) token angle).2
      (p.targetRun (InitialState.references p.graph.stages) token aim).2
      (p.budgetRun (InitialState.caches p.graph.stages) (InitialState.references p.graph.stages)
        (InitialState.references p.graph.stages) token angle aim ae (checked p parameters primitive token angle ha position)).2 ∧
    (∀ i, Model.isFinite ((p.run (InitialState.caches p.graph.stages) token angle).1 i) = true ∧
      |Model.toReal ((p.run (InitialState.caches p.graph.stages) token angle).1 i)| ≤ (2 : ℝ)^(23 : Nat)) ∧
    DecodeChain.CachesFinite p.graph.stages (p.run (InitialState.caches p.graph.stages) token angle).2 := by
  have hf := EmbeddingRanges.embedding_finite p.embedding parameters.embedding token
  have h := Qwen38TrellisM1MaxInitialRanges.run_correct p.graph parameters.graph primitive
    (p.embedding.forward token) (embedding_bound p parameters token) angle ha position
    (InitialState.references p.graph.stages) (InitialState.references p.graph.stages)
    (InitialState.caches_error p.graph.stages) (p.embedding.target token) (p.embedding.budget token)
    (p.embedding.forward_error token hf) aim ae he hb
  have ranges := Qwen38TrellisM1MaxInitialRanges.checked p.graph parameters.graph primitive
    (p.embedding.forward token) (embedding_bound p parameters token) angle ha position
  exact ⟨h.1, h.2.1, ranges.output, h.2.2.2⟩

end Inference.Models.Qwen.TokenInitialRanges
