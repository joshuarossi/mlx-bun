import models.qwen.CapacityCopiedTokenCache
namespace Inference.Models.Qwen.CapacityCopiedTokenResult
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : CapacityCopiedTokenSource.Execution p sampling cache token angle)

theorem checked (unsigned : Bool)
    (inputs : CapacityAttentionDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (ranges : p.Ranges cache token angle) (supported : n+1≤262144)
    (lseNative : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat))
    (safe : Qwen38CapacityAttentionCache.Safe execution.forward)
    (preserved : CapacityCopiedTokenCache.Safe execution safe) :
    CapacityCopiedTokenSource.Certificate execution unsigned
      (CapacityAttentionDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle
        execution.forward.source execution.forward.storage execution.forward.chain inputs ranges.graph.chain supported)
      finalNative lseNative ∧
    CapacityCopiedTokenCache.readResult execution safe preserved=
      (GreedySampling.sample sampling (p.run cache token angle).1,(p.run cache token angle).2) ∧
    (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token angle).1) := by
  have source := CapacityCopiedTokenSource.derived_source_token execution unsigned inputs finalNative ranges supported
    lseNative primitive bound
  exact ⟨source.1,CapacityCopiedTokenCache.read_result_eq execution safe preserved primitive bound,source.2⟩
end Inference.Models.Qwen.CapacityCopiedTokenResult
