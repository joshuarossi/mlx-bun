import models.qwen.CapacityCopiedCheckpointSource
namespace Inference.Models.Qwen.CapacityCopiedCheckpointParameters
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320}
  (execution : CapacityCopiedTokenSource.Execution p sampling cache token (RopeInputConstruction.inputs n))
  (encoded : CheckpointDictionaryBinding.Encoding) (binding : CheckpointDictionaryBinding.Bindings p encoded)
  (selected : ReachedTokenContext.Primitive.Selections p.graph)
  (other : ReachedTokenContext.Primitive.Other p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache) (supported : n+1≤262144)
  (inputs : CapacityAttentionDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token)
    (RopeInputConstruction.inputs n) execution.forward.source execution.forward.storage execution.forward.chain)
  (original : TokenParameterMemory.Storage p execution.embedding.tokenBuffer.bytes)
  (parametersSafe : original.Protected (CapacityCopiedTokenParameterFrame.Safe execution))

def after : TokenParameterMemory.Storage p execution.final.sampler.memory :=
  CapacityCopiedTokenParameterFrame.after execution original parametersSafe

theorem checked (unsigned : Bool)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives sampling)
    (safe : Qwen38CapacityAttentionCache.Safe execution.forward)
    (preserved : CapacityCopiedTokenCache.Safe execution safe) :
    CapacityCopiedTokenSource.Certificate execution unsigned
      (CapacityCopiedCheckpointSource.native execution encoded binding selected other cacheBound supported inputs)
      finalNative lseNative ∧
    CapacityCopiedTokenCache.readResult execution safe preserved=
      (GreedySampling.sample sampling (p.run cache token (RopeInputConstruction.inputs n)).1,
        (p.run cache token (RopeInputConstruction.inputs n)).2) ∧
    (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token (RopeInputConstruction.inputs n)).1) ∧
    (∀ base size, TokenParameterConstruction.Region original base size → ∀ offset<size,
      execution.final.sampler.memory (base+offset)=execution.embedding.tokenBuffer.bytes (base+offset)) ∧
    (∀ property : Nat → Nat → Prop,
      (after execution original parametersSafe).Protected property ↔ original.Protected property) := by
  have source := CapacityCopiedCheckpointSource.checked execution encoded binding selected other cacheBound supported
    inputs unsigned finalNative lseNative primitive safe preserved
  exact ⟨source.1,source.2.1,source.2.2,
    fun _ _ region _ inside => CapacityCopiedTokenParameterFrame.original_bytes execution original parametersSafe region _ inside,
    fun property => CapacityCopiedTokenParameterFrame.parameters_preserved execution original parametersSafe property⟩
end Inference.Models.Qwen.CapacityCopiedCheckpointParameters
