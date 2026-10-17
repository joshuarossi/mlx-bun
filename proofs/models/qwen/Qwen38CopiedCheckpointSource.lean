import models.qwen.Qwen38CopiedTokenState
import models.qwen.CheckpointDictionaryBinding
import models.qwen.ReachedTokenContext
import models.qwen.RopeInputConstruction

namespace Inference.Models.Qwen.Qwen38CopiedCheckpointSource
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Literal checkpoint certificates and ordered dictionaries derive the
-- original model's parameter bounds. Division selection and normal-input
-- rsqrt envelopes suffice; no universal rsqrt contract is reconstructed.
-- Native checkpoint loading and a global copied-parameter allocation
-- factory remain separate from these numerical/source certificates.
variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n}
  (step : Qwen38CopiedTokenState.Step p sampling before (RopeInputConstruction.inputs n))
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling) (supported : n+1≤262144)

noncomputable def logical :=
  ReachedTokenContext.Logical.advance p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) sampling samplingPrimitive before.logical
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported
    (RopeInputConstruction.target n) RopeInputConstruction.error (RopeInputConstruction.input_error n (by omega))
    (RopeInputConstruction.target_base_nonnegative n)

include binding selected other supported in
theorem model_bound : ∀ i,
    Model.isFinite ((p.run before.logical.cache before.logical.token (RopeInputConstruction.inputs n)).1 i)=true ∧
    |Model.toReal ((p.run before.logical.cache before.logical.token (RopeInputConstruction.inputs n)).1 i)|≤(2:ℝ)^(23:Nat) :=
  (ReachedSequenceRanges.Graph.checked p.graph
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding).graph
    (ReachedTokenContext.Primitive.graphPrimitives selected other) before.logical.cache before.logical.cacheBound
    (p.embedding.forward before.logical.token)
    (TokenSequenceRanges.embedding_bound p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) before.logical.token)
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported).output

noncomputable def index : Inference.State.TokenStorage.Buffer
    (logical encoded binding selected other samplingPrimitive supported (before:=before)).token :=
  Inference.State.TokenStorage.Buffer.fromRead
    (logical encoded binding selected other samplingPrimitive supported (before:=before)).token
    step.execution.decode.sampler.memory step.execution.decode.sampler.selection.destination
    step.execution.decode.sampler.selection.output.aligned step.execution.decode.sampler.selection.output.bounded
    (Qwen38CopiedTokenSource.token_read step.execution samplingPrimitive
      (model_bound encoded binding selected other supported))

noncomputable def advance : TokenAutoregressiveMemory.State p (n+1) :=
  ⟨logical encoded binding selected other samplingPrimitive supported,
    index step encoded binding selected other samplingPrimitive supported,
    Qwen38CopiedTokenCache.after step.execution step.headSafe step.samplerSafe⟩

theorem advance_heap :
    (advance step encoded binding selected other samplingPrimitive supported).index.bytes=
      step.execution.decode.sampler.memory := rfl

theorem readback :
    let actual := advance step encoded binding selected other samplingPrimitive supported
    let reference := logical encoded binding selected other samplingPrimitive supported (before:=before)
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  Prod.ext (Inference.State.TokenStorage.Buffer.read_correct _) (TokenAutoregressiveMemory.State.caches_eq _)

theorem cache_invariant :
    let actual := advance step encoded binding selected other samplingPrimitive supported
    DecodeChainSequenceRanges.CachesBound p.graph.stages actual.readCaches ∧
      DecodeChain.CacheErrors p.graph.stages actual.readCaches actual.logical.targetCache actual.logical.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages actual.readCaches := by
  dsimp only
  rw [TokenAutoregressiveMemory.State.caches_eq]
  let actual := advance step encoded binding selected other samplingPrimitive supported
  exact ⟨actual.logical.cacheBound,actual.logical.cacheError,
    DecodeChainSequenceRanges.caches_finite _ _ actual.logical.cacheBound⟩

theorem source_token (unsigned : Bool)
    (native : CopiedAttentionChainParsed.Native p.graph.stages before.logical.cache (p.embedding.forward before.logical.token)
      (RopeInputConstruction.inputs n) step.execution.decode.forward.source step.execution.decode.forward.storage step.execution.decode.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native step.execution.decode.forward.finalParameters step.execution.decode.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) :
    QuantizedEmbeddingParsedPipeline.Certificate step.execution.embedding unsigned ∧
    FinalProjectionParsedSource.Certificate step.execution.decode.forward.finalParameters step.execution.decode.forward.allocation finalNative ∧
    Qwen38CopiedAttentionSamplerSource.Certificate step.execution.decode native lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory step.execution.decode.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory step.execution.decode.sampler.selection.destination).toNat)=
      some (advance step encoded binding selected other samplingPrimitive supported).index.read := by
  have certified := Qwen38CopiedTokenSource.source_token step.execution unsigned native finalNative
    (ReachedSequenceRanges.Token.checked p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
      (ReachedTokenContext.Primitive.graphPrimitives selected other) before.logical.cache before.logical.cacheBound
      before.logical.token (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported)
    lseNative samplingPrimitive (model_bound encoded binding selected other supported)
  refine ⟨certified.1,certified.2.1,certified.2.2.1,?_⟩
  rw [certified.2.2.2,Inference.State.TokenStorage.Buffer.read_correct]
  rfl

-- This error bound is on logits read after every sampler write, not on a
-- separately supplied expected logit vector.
theorem logit_error (column : Fin 248320) :
    |Model.toReal ((Qwen38CopiedTokenCache.logitsAfter step.execution).read column)-
      (p.targetRun before.logical.targetCache before.logical.token (RopeInputConstruction.target n)).1 column|≤
      (ReachedSequenceRanges.Sample.budget p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
        (ReachedTokenContext.Primitive.graphPrimitives selected other) before.logical.cache before.logical.cacheBound
        before.logical.targetCache before.logical.errorCache before.logical.token (RopeInputConstruction.inputs n)
        (RopeInputConstruction.inputs_bound n (by omega)) supported (RopeInputConstruction.target n)
        RopeInputConstruction.error).1 column := by
  rw [Qwen38CopiedTokenCache.logit_read]
  exact (ReachedSequenceRanges.Token.run_correct p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) before.logical.cache before.logical.cacheBound
    before.logical.targetCache before.logical.errorCache before.logical.cacheError before.logical.token
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported
    (RopeInputConstruction.target n) RopeInputConstruction.error (RopeInputConstruction.input_error n (by omega))
    (RopeInputConstruction.target_base_nonnegative n)).1 column

end Inference.Models.Qwen.Qwen38CopiedCheckpointSource
