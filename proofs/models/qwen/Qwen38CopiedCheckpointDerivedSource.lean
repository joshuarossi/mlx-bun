import models.qwen.Qwen38CopiedCheckpointSource
import models.qwen.CopiedAttentionDerivedNative

namespace Inference.Models.Qwen.Qwen38CopiedCheckpointDerivedSource
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n}
  (step : Qwen38CopiedTokenState.Step p sampling before (RopeInputConstruction.inputs n))
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (supported : n+1≤262144)
  (inputs : CopiedAttentionDerivedNative.Inputs p.graph.stages before.logical.cache
    (p.embedding.forward before.logical.token) (RopeInputConstruction.inputs n)
    step.execution.decode.forward.source step.execution.decode.forward.storage step.execution.decode.forward.chain)

-- The caller gives only native/primitive metadata, local memories and
-- producer-consumer links. All64 finite-stage contracts are constructed
-- from the original checkpoint bounds and reachable cache invariant.
noncomputable def native :=
  CopiedAttentionDerivedNative.native p.graph.stages before.logical.cache (p.embedding.forward before.logical.token)
    (RopeInputConstruction.inputs n) step.execution.decode.forward.source step.execution.decode.forward.storage
    step.execution.decode.forward.chain inputs
    (ReachedSequenceRanges.Token.checked p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
      (ReachedTokenContext.Primitive.graphPrimitives selected other) before.logical.cache before.logical.cacheBound
      before.logical.token (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported).graph.chain supported

theorem parsed : CopiedAttentionChainParsed.Parsed p.graph.stages before.logical.cache
    (p.embedding.forward before.logical.token) (RopeInputConstruction.inputs n)
    step.execution.decode.forward.source step.execution.decode.forward.storage step.execution.decode.forward.chain
    (native step encoded binding selected other supported inputs) :=
  CopiedAttentionChainParsed.checked _ _ _ _ _ _ _ _

theorem source_token (samplingPrimitive : LogSumExpRanges.Primitives sampling) (unsigned : Bool)
    (finalNative : FinalProjectionParsedSource.Native step.execution.decode.forward.finalParameters step.execution.decode.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) :
    QuantizedEmbeddingParsedPipeline.Certificate step.execution.embedding unsigned ∧
    FinalProjectionParsedSource.Certificate step.execution.decode.forward.finalParameters step.execution.decode.forward.allocation finalNative ∧
    Qwen38CopiedAttentionSamplerSource.Certificate step.execution.decode
      (native step encoded binding selected other supported inputs) lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory step.execution.decode.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory step.execution.decode.sampler.selection.destination).toNat)=
      some (Qwen38CopiedCheckpointSource.advance step encoded binding selected other samplingPrimitive supported).index.read :=
  Qwen38CopiedCheckpointSource.source_token step encoded binding selected other samplingPrimitive supported unsigned
    (native step encoded binding selected other supported inputs) finalNative lseNative

end Inference.Models.Qwen.Qwen38CopiedCheckpointDerivedSource
