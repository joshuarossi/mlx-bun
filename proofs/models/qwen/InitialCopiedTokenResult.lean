import models.qwen.InitialCopiedTokenRanges
import models.qwen.InitialCopiedTokenCache
namespace Inference.Models.Qwen.InitialCopiedTokenResult
open Contracts.Mlx Layers DecodeStage DecodeChain Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache 0}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : InitialCopiedTokenSource.Execution p sampling cache token angle)

theorem checked (unsigned : Bool)
    (inputs : InitialCopiedDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (ranges : p.Ranges cache token angle)
    (lseNative : LogSumExpSourceHost.Attachment) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
      |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat))
    (safe : Qwen38InitialCopiedCache.Safe execution.forward)
    (preserved : InitialCopiedTokenCache.Safe execution safe) :
    InitialCopiedTokenSource.Certificate execution unsigned
      (InitialCopiedDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle
        execution.forward.source execution.forward.storage execution.forward.chain inputs ranges.graph.chain)
      finalNative lseNative ∧
    InitialCopiedTokenCache.readResult execution safe preserved=
      (GreedySampling.sample sampling (p.run cache token angle).1,(p.run cache token angle).2) ∧
    (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token angle).1) := by
  have source := InitialCopiedTokenSource.derived_source_token execution unsigned inputs finalNative ranges
    lseNative primitive bound
  exact ⟨source.1,InitialCopiedTokenCache.read_result_eq execution safe preserved primitive bound,source.2⟩

-- Original parameter/primitive ranges discharge every stage finite contract
-- and the sampler envelope; no native output or desired state is an input.
theorem checked_ranges (unsigned : Bool)
    (inputs : InitialCopiedDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (parameters : TokenSequenceRanges.Parameters p)
    (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
    (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
    (angleBound : RopeAnglesRanges.InputsBound angle)
    (lseNative : LogSumExpSourceHost.Attachment) (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (safe : Qwen38InitialCopiedCache.Safe execution.forward)
    (preserved : InitialCopiedTokenCache.Safe execution safe) :
    InitialCopiedTokenSource.Certificate execution unsigned
      (InitialCopiedDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle
        execution.forward.source execution.forward.storage execution.forward.chain inputs
        (InitialCopiedTokenRanges.ranges parameters primitive cacheBound angleBound).graph.chain)
      finalNative lseNative ∧
    InitialCopiedTokenCache.readResult execution safe preserved=
      (GreedySampling.sample sampling (p.run cache token angle).1,(p.run cache token angle).2) ∧
    (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  checked execution unsigned inputs finalNative (InitialCopiedTokenRanges.ranges parameters primitive cacheBound angleBound)
    lseNative samplingPrimitive (InitialCopiedTokenRanges.model_bound parameters primitive cacheBound angleBound) safe preserved
end Inference.Models.Qwen.InitialCopiedTokenResult
