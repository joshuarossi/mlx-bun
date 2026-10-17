import models.qwen.Qwen38TrellisM1MaxSequenceRanges
import models.qwen.EmbeddingRanges

namespace Inference.Models.Qwen.TokenSequenceRanges
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Attention TokenInference
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

structure Parameters (p : Pipeline) : Prop where
  embedding : EmbeddingRanges.Parameters p.embedding
  graph : Qwen38TrellisM1MaxSequenceRanges.Parameters p.graph

theorem embedding_bound (p : Pipeline) (parameters : Parameters p) (token : Fin 248320) :
    ResidualMlpRanges.InputBound 0 (p.embedding.forward token) := by
  intro i
  refine ⟨p.embedding.forward_finite token (EmbeddingRanges.embedding_finite p.embedding parameters.embedding token) i,
    (EmbeddingRanges.embedding_bounded p.embedding parameters.embedding token i).trans ?_⟩
  norm_num [ResidualMlpRanges.inputCeiling]

noncomputable def checked (p : Pipeline) (parameters : Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (cache : p.graph.Cache time) (hc : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) : p.Ranges cache token angle :=
  ⟨EmbeddingRanges.embedding_finite p.embedding parameters.embedding token,
    (Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive cache hc (p.embedding.forward token)
      (embedding_bound p parameters token) angle ha supported).finite⟩

theorem next_cache (p : Pipeline) (parameters : Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (cache : p.graph.Cache time) (hc : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) : DecodeChainSequenceRanges.CachesBound p.graph.stages (p.run cache token angle).2 :=
  (Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive cache hc (p.embedding.forward token)
    (embedding_bound p parameters token) angle ha supported).cacheBound

-- Every call consumes the preceding cache contract and produces its
-- successor. Numerical errors in that cache are propagated independently.
theorem run_correct (p : Pipeline) (parameters : Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (cache : p.graph.Cache time) (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (ct ce : p.graph.ReferenceCache time) (hc : DecodeChain.CacheErrors p.graph.stages cache ct ce)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) (aim ae : RopeAngles.Target)
    (he : RopeAngles.InputError angle aim ae) (hb : 0 ≤ aim.base) :
    (∀ i, |Model.toReal ((p.run cache token angle).1 i)-(p.targetRun ct token aim).1 i| ≤
      (p.budgetRun cache ct ce token angle aim ae (checked p parameters primitive cache cacheBound token angle ha supported)).1 i) ∧
    DecodeChain.CacheErrors p.graph.stages (p.run cache token angle).2 (p.targetRun ct token aim).2
      (p.budgetRun cache ct ce token angle aim ae (checked p parameters primitive cache cacheBound token angle ha supported)).2 ∧
    (∀ i, Model.isFinite ((p.run cache token angle).1 i) = true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2 : ℝ)^(23 : Nat)) ∧
    DecodeChainSequenceRanges.CachesBound p.graph.stages (p.run cache token angle).2 := by
  have hf := EmbeddingRanges.embedding_finite p.embedding parameters.embedding token
  have h := Qwen38TrellisM1MaxSequenceRanges.run_correct p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (embedding_bound p parameters token) angle ha supported ct ce hc
    (p.embedding.target token) (p.embedding.budget token) (p.embedding.forward_error token hf) aim ae he hb
  have ranges := Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (embedding_bound p parameters token) angle ha supported
  exact ⟨h.1, h.2.1, ranges.output, ranges.cacheBound⟩

end Inference.Models.Qwen.TokenSequenceRanges
