import models.qwen.Qwen38TrellisM1MaxInference
import models.qwen.NormalizedAffineProjectionMagnitude

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxMagnitude
open Contracts.Mlx Contracts.Mlx.Numerics DecodeStage Kernels.Sampling Kernels.Attention
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- The 64-layer invariant supplies the final normalization input. The sharper
-- projection bound includes every tile, reduction and final BF16 store.
theorem graph_output (g : Qwen38TrellisM1Max.Graph)
    (parameters : Qwen38TrellisM1MaxSequenceRanges.Parameters g)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives g)
    (cache : g.Cache time) (hc : DecodeChainSequenceRanges.CachesBound g.stages cache)
    (x : Row BF) (hx : ResidualMlpRanges.InputBound 0 x)
    (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle) (supported : time+1 ≤ 262144) :
    ∀ i, Model.isFinite (g.forward cache x angle i) = true ∧
      |Model.toReal (g.forward cache x angle i)| ≤ (2 : ℝ)^18 := by
  have size : 0+g.stages.length ≤ 64 := by rw [g.layer_count]
  have nonempty : g.stages ≠ [] := by
    intro h
    have hn := g.layer_count
    rw [h] at hn
    contradiction
  have next := DecodeChainSequenceRanges.next_input g.stages
    (Qwen38TrellisM1MaxSequenceRanges.chainParameters g parameters)
    (Qwen38TrellisM1MaxSequenceRanges.chainPrimitives g primitive) 0 size cache hc x hx angle ha supported
  have bound := DecodeChainSequenceRanges.output_bounded g.stages
    (Qwen38TrellisM1MaxSequenceRanges.chainParameters g parameters)
    (Qwen38TrellisM1MaxSequenceRanges.chainPrimitives g primitive) 0 size nonempty cache hc x hx angle ha supported
  exact (NormalizedAffineProjectionMagnitude.ranges g.finalNorm g.output parameters.output primitive.normalization
    primitive.root primitive.output parameters.normalization (g.hidden cache x angle)
    (fun i => ⟨(next i).1, bound i⟩)).2.2

theorem pipeline_output (p : TokenInference.Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (cache : p.graph.Cache time) (hc : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (token : Fin 248320) (angle : RopeAngles.Inputs) (ha : RopeAnglesRanges.InputsBound angle)
    (supported : time+1 ≤ 262144) :
    ∀ i, Model.isFinite ((p.run cache token angle).1 i) = true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2 : ℝ)^18 :=
  graph_output p.graph parameters.graph primitive cache hc (p.embedding.forward token)
    (TokenSequenceRanges.embedding_bound p parameters token) angle ha supported

-- The cache proof is carried by the preceding autoregressive step, including
-- the selected token and returned cache. No extra range premise is required.
theorem autoregressive_output (p : TokenInference.Pipeline) (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time (by omega)
    ∀ i, Model.isFinite (TokenSampledSequenceRanges.logits p before.cache before.token (angles.value time) i) = true ∧
      |Model.toReal (TokenSampledSequenceRanges.logits p before.cache before.token (angles.value time) i)| ≤ (2 : ℝ)^18 := by
  let before := TokenAutoregressive.run p parameters primitive sampling samplingPrimitive token angles time (by omega)
  simpa only [TokenSampledSequenceRanges.logits] using
    pipeline_output p parameters primitive before.cache before.cacheBound before.token
      (angles.value time) (angles.ranges time (by omega)) supported

theorem inference_output (p : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := Qwen38TrellisM1MaxInference.run p encoded binding primitive sampling samplingPrimitive token time (by omega)
    ∀ i, Model.isFinite (TokenSampledSequenceRanges.logits p before.cache before.token (RopeInputConstruction.inputs time) i) = true ∧
      |Model.toReal (TokenSampledSequenceRanges.logits p before.cache before.token (RopeInputConstruction.inputs time) i)| ≤ (2 : ℝ)^18 :=
  autoregressive_output p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive token RopeInputConstruction.angles time supported

end Inference.Models.Qwen.Qwen38TrellisM1MaxMagnitude
