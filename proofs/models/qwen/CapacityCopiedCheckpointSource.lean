import models.qwen.CapacityCopiedTokenParameterFrame
import models.qwen.CheckpointDictionaryBinding
import models.qwen.ReachedTokenContext
import models.qwen.RopeInputConstruction
namespace Inference.Models.Qwen.CapacityCopiedCheckpointSource
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320}
  (execution : CapacityCopiedTokenSource.Execution p sampling cache token (RopeInputConstruction.inputs n))
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache) (supported : n+1≤262144)

-- Finite stage contracts and the logit envelope are consequences of the
-- original encoded checkpoint and reached-cache invariant. Native bindings,
-- source descriptors, local memories and compiler attachment remain explicit.
noncomputable def ranges : p.Ranges cache token (RopeInputConstruction.inputs n) :=
  ReachedSequenceRanges.Token.checked p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding)
    (ReachedTokenContext.Primitive.graphPrimitives selected other) cache cacheBound token
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported

include binding selected other cacheBound supported in
theorem model_bound : ∀ i,
    Model.isFinite ((p.run cache token (RopeInputConstruction.inputs n)).1 i)=true ∧
    |Model.toReal ((p.run cache token (RopeInputConstruction.inputs n)).1 i)|≤(2:ℝ)^(23:Nat) :=
  (ReachedSequenceRanges.Graph.checked p.graph
    (CheckpointDictionaryBinding.pipeline_parameters p encoded binding).graph
    (ReachedTokenContext.Primitive.graphPrimitives selected other) cache cacheBound
    (p.embedding.forward token)
    (TokenSequenceRanges.embedding_bound p (CheckpointDictionaryBinding.pipeline_parameters p encoded binding) token)
    (RopeInputConstruction.inputs n) (RopeInputConstruction.inputs_bound n (by omega)) supported).output

variable (inputs : CapacityAttentionDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token)
  (RopeInputConstruction.inputs n) execution.forward.source execution.forward.storage execution.forward.chain)

noncomputable def native := CapacityAttentionDerivedNative.native p.graph.stages cache (p.embedding.forward token)
  (RopeInputConstruction.inputs n) execution.forward.source execution.forward.storage execution.forward.chain inputs
  (ranges encoded binding selected other cacheBound supported).graph.chain supported

theorem checked (unsigned : Bool)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives sampling)
    (safe : Qwen38CapacityAttentionCache.Safe execution.forward)
    (preserved : CapacityCopiedTokenCache.Safe execution safe) :
    CapacityCopiedTokenSource.Certificate execution unsigned
      (native execution encoded binding selected other cacheBound supported inputs) finalNative lseNative ∧
    CapacityCopiedTokenCache.readResult execution safe preserved=
      (GreedySampling.sample sampling (p.run cache token (RopeInputConstruction.inputs n)).1,
        (p.run cache token (RopeInputConstruction.inputs n)).2) ∧
    (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token (RopeInputConstruction.inputs n)).1) :=
  CapacityCopiedTokenResult.checked execution unsigned inputs finalNative
    (ranges encoded binding selected other cacheBound supported) supported lseNative primitive
    (model_bound encoded binding selected other cacheBound supported) safe preserved
end Inference.Models.Qwen.CapacityCopiedCheckpointSource
