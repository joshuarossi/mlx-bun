import models.qwen.InitialCopiedTokenSource
import models.qwen.TokenSampledSequenceRanges
namespace Inference.Models.Qwen.InitialCopiedTokenRanges
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache 0}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : InitialCopiedTokenSource.Execution p sampling cache token angle)
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
  (angleBound : RopeAnglesRanges.InputsBound angle)
include parameters primitive cacheBound angleBound

-- Original global parameter/primitive attachments remain explicit. The
-- initial direct-zero chain adds no supplied stage-finite or logit envelope.
noncomputable def ranges : p.Ranges cache token angle :=
  TokenSequenceRanges.checked p parameters primitive cache cacheBound token angle angleBound (by decide)

theorem model_bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
    |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat) :=
  (Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (TokenSequenceRanges.embedding_bound p parameters token) angle angleBound (by decide)).output

theorem source_token (unsigned : Bool)
    (inputs : InitialCopiedDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    InitialCopiedTokenSource.Certificate execution unsigned
      (InitialCopiedDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle execution.forward.source
        execution.forward.storage execution.forward.chain inputs (ranges parameters primitive cacheBound angleBound).graph.chain)
      finalNative lseNative ∧
      (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
        (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
        some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  InitialCopiedTokenSource.derived_source_token execution unsigned inputs finalNative
    (ranges parameters primitive cacheBound angleBound) lseNative samplingPrimitive
    (model_bound parameters primitive cacheBound angleBound)

theorem token_read (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    (ByteMemory.load32 execution.final.sampler.memory execution.final.sampler.selection.destination).toNat=
      GreedySampling.sample sampling (p.run cache token angle).1 :=
  InitialCopiedTokenSource.token_read execution samplingPrimitive (model_bound parameters primitive cacheBound angleBound)

theorem logit_error (targetCache cacheError : p.graph.ReferenceCache 0)
    (cacheAccuracy : DecodeChain.CacheErrors p.graph.stages cache targetCache cacheError)
    (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
    (baseNonnegative : 0≤aim.base) (column : Fin 248320) :
    |Model.toReal ((Qwen38InitialCopiedExecution.logitsBuffer execution.forward).read column)-
      (p.targetRun targetCache token aim).1 column| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive cache cacheBound targetCache cacheError
        token angle angleBound (by decide) aim angleError).1 column := by
  rw [InitialCopiedTokenSource.logits]
  exact (TokenSequenceRanges.run_correct p parameters primitive cache cacheBound targetCache cacheError
    cacheAccuracy token angle angleBound (by decide) aim angleError angleAccuracy baseNonnegative).1 column
end Inference.Models.Qwen.InitialCopiedTokenRanges
