import models.qwen.CheckpointConvolutionBinding
import models.qwen.CheckpointAffineDictionary

namespace Inference.Models.Qwen.CheckpointDictionaryBinding
open Contracts.Mlx Qwen38TrellisM1Max Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange

-- The large tensors' ordered indices remain explicit inputs. No assertion
-- here identifies them with native buffers. Once those exact identities
-- hold, every parameter range needed by the whole source model is derived.
structure Encoding where
  embedding : CheckpointAffineDictionary.Encoding 10 248320
  deltaQkv : Fin 48 → CheckpointAffineDictionary.Encoding 10 10240
  deltaZ : Fin 48 → CheckpointAffineDictionary.Encoding 10 6144
  deltaA : Fin 48 → CheckpointAffineDictionary.Encoding 10 48
  deltaB : Fin 48 → CheckpointAffineDictionary.Encoding 10 48
  deltaOutput : Fin 48 → CheckpointAffineDictionary.Encoding 12 5120
  attentionQ : Fin 16 → CheckpointAffineDictionary.Encoding 10 12288
  attentionK : Fin 16 → CheckpointAffineDictionary.Encoding 10 1024
  attentionV : Fin 16 → CheckpointAffineDictionary.Encoding 10 1024
  attentionOutput : Fin 16 → CheckpointAffineDictionary.Encoding 12 5120
  output : CheckpointAffineDictionary.Encoding 10 248320

structure Bindings (p : TokenInference.Pipeline) (encoded : Encoding) : Prop
    extends toConvolution : CheckpointConvolutionBinding.Bindings p.graph where
  embedding : CheckpointAffineDictionary.EmbeddingAttached p.embedding encoded.embedding
  deltaQkv : ∀ i, CheckpointAffineDictionary.Attached (p.graph.delta i).mixer.qkv (encoded.deltaQkv i)
  deltaZ : ∀ i, CheckpointAffineDictionary.Attached (p.graph.delta i).mixer.z (encoded.deltaZ i)
  deltaA : ∀ i, CheckpointAffineDictionary.Attached (p.graph.delta i).mixer.a (encoded.deltaA i)
  deltaB : ∀ i, CheckpointAffineDictionary.Attached (p.graph.delta i).mixer.b (encoded.deltaB i)
  deltaOutput : ∀ i, CheckpointAffineDictionary.Attached (p.graph.delta i).mixer.out (encoded.deltaOutput i)
  attentionQ : ∀ i, CheckpointAffineDictionary.Attached (p.graph.attention i).mixer.projections.q (encoded.attentionQ i)
  attentionK : ∀ i, CheckpointAffineDictionary.Attached (p.graph.attention i).mixer.projections.k (encoded.attentionK i)
  attentionV : ∀ i, CheckpointAffineDictionary.Attached (p.graph.attention i).mixer.projections.v (encoded.attentionV i)
  attentionOutput : ∀ i, CheckpointAffineDictionary.Attached (p.graph.attention i).mixer.output (encoded.attentionOutput i)
  output : CheckpointAffineDictionary.Attached p.graph.output encoded.output

theorem remaining_parameters (p : TokenInference.Pipeline) (encoded : Encoding) (binding : Bindings p encoded) :
    CheckpointConvolutionBinding.RemainingParameters p.graph := {
  deltaProjections := fun i => ⟨
    CheckpointAffineDictionary.normalized _ _ (binding.deltaQkv i),
    CheckpointAffineDictionary.normalized _ _ (binding.deltaZ i),
    CheckpointAffineDictionary.normalized _ _ (binding.deltaA i),
    CheckpointAffineDictionary.normalized _ _ (binding.deltaB i)⟩
  deltaOutput := fun i => CheckpointAffineDictionary.output _ _ (binding.deltaOutput i)
  attentionProjections := fun i => ⟨
    CheckpointAffineDictionary.normalized _ _ (binding.attentionQ i),
    CheckpointAffineDictionary.normalized _ _ (binding.attentionK i),
    CheckpointAffineDictionary.normalized _ _ (binding.attentionV i)⟩
  attentionOutput := fun i => CheckpointAffineDictionary.output _ _ (binding.attentionOutput i)
  output := CheckpointAffineDictionary.normalized _ _ binding.output }

theorem pipeline_parameters (p : TokenInference.Pipeline) (encoded : Encoding) (binding : Bindings p encoded) :
    TokenSequenceRanges.Parameters p :=
  CheckpointConvolutionBinding.pipeline_parameters p binding.toConvolution (remaining_parameters p encoded binding)
    (CheckpointAffineDictionary.embedding _ _ binding.embedding)

noncomputable def run (p : TokenInference.Pipeline) (encoded : Encoding) (binding : Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (steps : Nat) (supported : steps ≤ 262144) :
    TokenAutoregressive.State p steps :=
  TokenAutoregressive.run p (pipeline_parameters p encoded binding) primitive sampling samplingPrimitive token angles steps supported

theorem run_invariant (p : TokenInference.Pipeline) (encoded : Encoding) (binding : Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (steps : Nat) (supported : steps ≤ 262144) :
    let state := run p encoded binding primitive sampling samplingPrimitive token angles steps supported
    DecodeChainSequenceRanges.CachesBound p.graph.stages state.cache ∧
      DecodeChain.CacheErrors p.graph.stages state.cache state.targetCache state.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages state.cache :=
  TokenAutoregressive.run_invariant p (pipeline_parameters p encoded binding) primitive sampling samplingPrimitive token angles steps supported

theorem run_correct (p : TokenInference.Pipeline) (encoded : Encoding) (binding : Bindings p encoded)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (sampling : LogSumExpRanges.Platform) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (token : Fin 248320) (angles : TokenAutoregressive.Angles) (time : Nat) (supported : time+1 ≤ 262144) :
    let parameters := pipeline_parameters p encoded binding
    let before := run p encoded binding primitive sampling samplingPrimitive token angles time (by omega)
    let after := run p encoded binding primitive sampling samplingPrimitive token angles (time+1) supported
    let logits := TokenSampledSequenceRanges.logits p before.cache before.token (angles.value time)
    (∀ i, |Model.toReal (logits i)-(p.targetRun before.targetCache before.token (angles.target time)).1 i| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive before.cache before.cacheBound before.targetCache
        before.errorCache before.token (angles.value time) (angles.ranges time (by omega)) supported
          (angles.target time) (angles.error time)).1 i) ∧
    LogSumExpRanges.Trace sampling (fun i => BFloat16.widen (logits i)) ∧
    (∀ i, (NormalizedScores.value (logits i) (LogSumExpRanges.value sampling logits)).isFinite = true) ∧
    (∀ i, GreedySampling.score sampling logits i ≤ GreedySampling.score sampling logits after.token) ∧
    (∀ i, GreedySampling.score sampling logits after.token = GreedySampling.score sampling logits i → after.token.val ≤ i.val) :=
  TokenAutoregressive.run_correct p (pipeline_parameters p encoded binding) primitive sampling samplingPrimitive token angles time supported

end Inference.Models.Qwen.CheckpointDictionaryBinding
