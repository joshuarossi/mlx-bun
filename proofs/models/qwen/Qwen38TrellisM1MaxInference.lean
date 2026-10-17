import models.qwen.CheckpointDictionaryBinding
import models.qwen.RopeInputConstruction

namespace Inference.Models.Qwen.Qwen38TrellisM1MaxInference
open Contracts.Mlx Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- Conditional inference entry point for this written graph. Parameter
-- ranges and position inputs are constructed by proofs. Native tensor
-- identities, host log2/Math.pow results, primitive contracts and compiled
-- execution correspondence remain external obligations. The real reference
-- uses the same emitted tokens; no exact-real token agreement is asserted.
noncomputable def run (p : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (steps : Nat) (supported : steps ≤ 262144) : TokenAutoregressive.State p steps :=
  CheckpointDictionaryBinding.run p encoded binding primitive sampling samplingPrimitive token
    RopeInputConstruction.angles steps supported

theorem cache_invariant (p : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (steps : Nat) (supported : steps ≤ 262144) :
    let state := run p encoded binding primitive sampling samplingPrimitive token steps supported
    DecodeChainSequenceRanges.CachesBound p.graph.stages state.cache ∧
      DecodeChain.CacheErrors p.graph.stages state.cache state.targetCache state.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages state.cache :=
  CheckpointDictionaryBinding.run_invariant p encoded binding primitive sampling samplingPrimitive token
    RopeInputConstruction.angles steps supported

theorem step_execution (p : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (time : Nat) (supported : time+1 ≤ 262144) :
    let before := run p encoded binding primitive sampling samplingPrimitive token time (by omega)
    let after := run p encoded binding primitive sampling samplingPrimitive token (time+1) supported
    after.token.val = (TokenSampledSequenceRanges.run p sampling before.cache before.token (RopeInputConstruction.inputs time)).1 ∧
      after.cache = (p.run before.cache before.token (RopeInputConstruction.inputs time)).2 :=
  TokenAutoregressive.run_step p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    primitive sampling samplingPrimitive token RopeInputConstruction.angles time supported

theorem step_correct (p : TokenInference.Pipeline) (encoded : CheckpointDictionaryBinding.Encoding)
    (binding : CheckpointDictionaryBinding.Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (time : Nat) (supported : time+1 ≤ 262144) :
    let parameters := CheckpointDictionaryBinding.pipeline_parameters p encoded binding
    let before := run p encoded binding primitive sampling samplingPrimitive token time (by omega)
    let after := run p encoded binding primitive sampling samplingPrimitive token (time+1) supported
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (RopeInputConstruction.inputs time)
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (RopeInputConstruction.target time)).1 i| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token (RopeInputConstruction.inputs time) (RopeInputConstruction.inputs_bound time (by omega))
          supported (RopeInputConstruction.target time) RopeInputConstruction.error).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite = true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits after.token) ∧
    (∀ i, GreedySampling.score sampling logits after.token = GreedySampling.score sampling logits i → after.token.val ≤ i.val) :=
  CheckpointDictionaryBinding.run_correct p encoded binding primitive sampling samplingPrimitive token
    RopeInputConstruction.angles time supported

end Inference.Models.Qwen.Qwen38TrellisM1MaxInference
