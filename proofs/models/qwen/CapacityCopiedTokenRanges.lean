import models.qwen.CapacityCopiedTokenSource
import models.qwen.TokenSampledSequenceRanges
namespace Inference.Models.Qwen.CapacityCopiedTokenRanges
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
  {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : CapacityCopiedTokenSource.Execution p sampling cache token angle)
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)
include parameters primitive cacheBound angleBound supported

-- Original global parameter/primitive attachments remain explicit. The
-- positive capacity chain adds no supplied stage-finite or logit envelope.
noncomputable def ranges : p.Ranges cache token angle :=
  TokenSequenceRanges.checked p parameters primitive cache cacheBound token angle angleBound supported

theorem model_bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
    |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat) :=
  (Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (TokenSequenceRanges.embedding_bound p parameters token) angle angleBound supported).output

theorem source_token (unsigned : Bool)
    (inputs : CapacityAttentionDerivedNative.Inputs p.graph.stages cache (p.embedding.forward token) angle
      execution.forward.source execution.forward.storage execution.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.forward.finalParameters execution.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    CapacityCopiedTokenSource.Certificate execution unsigned
      (CapacityAttentionDerivedNative.native p.graph.stages cache (p.embedding.forward token) angle execution.forward.source
        execution.forward.storage execution.forward.chain inputs (ranges parameters primitive cacheBound angleBound supported).graph.chain supported)
      finalNative lseNative ∧
      (ArgmaxLaunchSourceMemory.tokenMemory execution.final.sampler.selection).map
        (fun memory=>(ByteMemory.load32 memory execution.final.sampler.selection.destination).toNat)=
        some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  CapacityCopiedTokenSource.derived_source_token execution unsigned inputs finalNative
    (ranges parameters primitive cacheBound angleBound supported) supported lseNative samplingPrimitive
    (model_bound parameters primitive cacheBound angleBound supported)

theorem token_read (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    (ByteMemory.load32 execution.final.sampler.memory execution.final.sampler.selection.destination).toNat=
      GreedySampling.sample sampling (p.run cache token angle).1 :=
  CapacityCopiedTokenSource.token_read execution samplingPrimitive (model_bound parameters primitive cacheBound angleBound supported)

theorem logit_error (targetCache cacheError : p.graph.ReferenceCache n)
    (cacheAccuracy : DecodeChain.CacheErrors p.graph.stages cache targetCache cacheError)
    (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
    (baseNonnegative : 0≤aim.base) (column : Fin 248320) :
    |Model.toReal ((Qwen38CapacityAttentionExecution.logitsBuffer execution.forward).read column)-
      (p.targetRun targetCache token aim).1 column| ≤
      (TokenSampledSequenceRanges.budget p parameters primitive cache cacheBound targetCache cacheError
        token angle angleBound supported aim angleError).1 column := by
  rw [CapacityCopiedTokenSource.logits]
  exact (TokenSequenceRanges.run_correct p parameters primitive cache cacheBound targetCache cacheError
    cacheAccuracy token angle angleBound supported aim angleError angleAccuracy baseNonnegative).1 column
end Inference.Models.Qwen.CapacityCopiedTokenRanges
