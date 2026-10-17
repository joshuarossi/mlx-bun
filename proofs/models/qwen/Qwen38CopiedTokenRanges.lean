import models.qwen.Qwen38CopiedTokenSource
import models.qwen.TokenSampledSequenceRanges

namespace Inference.Models.Qwen.Qwen38CopiedTokenRanges
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- Range obligations come from original parameter and primitive contracts.
-- The copied execution retains its native attachment and cache-route
-- obligations; these numerical lemmas do not construct that attachment.
variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : Qwen38CopiedTokenSource.Execution p sampling cache token angle)
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)

include parameters primitive cacheBound angleBound supported

theorem model_bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
    |Model.toReal ((p.run cache token angle).1 i)|≤(2:ℝ)^(23:Nat) :=
  (Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (TokenSequenceRanges.embedding_bound p parameters token)
    angle angleBound supported).output

theorem logit_bound (column : Fin 248320) :
    Model.isFinite ((Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).read column)=true ∧
    |Model.toReal ((Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).read column)|≤(2:ℝ)^(23:Nat) := by
  rw [Qwen38CopiedTokenSource.logits]
  exact model_bound parameters primitive cacheBound angleBound supported column

theorem source_token (unsigned : Bool)
    (native : CopiedAttentionChainParsed.Native p.graph.stages cache (p.embedding.forward token) angle
      execution.decode.forward.source execution.decode.forward.storage execution.decode.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native execution.decode.forward.finalParameters execution.decode.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    QuantizedEmbeddingParsedPipeline.Certificate execution.embedding unsigned ∧
    FinalProjectionParsedSource.Certificate execution.decode.forward.finalParameters execution.decode.forward.allocation finalNative ∧
    Qwen38CopiedAttentionSamplerSource.Certificate execution.decode native lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory execution.decode.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory execution.decode.sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token angle).1) :=
  Qwen38CopiedTokenSource.source_token execution unsigned native finalNative
    (TokenSequenceRanges.checked p parameters primitive cache cacheBound token angle angleBound supported)
    lseNative samplingPrimitive (model_bound parameters primitive cacheBound angleBound supported)

theorem token_read (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    (ByteMemory.load32 execution.decode.sampler.memory execution.decode.sampler.selection.destination).toNat=
      GreedySampling.sample sampling (p.run cache token angle).1 :=
  Qwen38CopiedTokenSource.token_read execution samplingPrimitive
    (model_bound parameters primitive cacheBound angleBound supported)

-- The error is about actual final-logit loads, retaining the existing
-- reference-cache and rounding-error recurrence.
theorem logit_error (targetCache cacheError : p.graph.ReferenceCache n)
    (cacheAccuracy : DecodeChain.CacheErrors p.graph.stages cache targetCache cacheError)
    (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
    (baseNonnegative : 0≤aim.base) (column : Fin 248320) :
    |Model.toReal ((Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).read column)-
      (p.targetRun targetCache token aim).1 column|≤
      (TokenSampledSequenceRanges.budget p parameters primitive cache cacheBound targetCache cacheError
        token angle angleBound supported aim angleError).1 column := by
  rw [Qwen38CopiedTokenSource.logits]
  exact (TokenSequenceRanges.run_correct p parameters primitive cache cacheBound targetCache cacheError
    cacheAccuracy token angle angleBound supported aim angleError angleAccuracy baseNonnegative).1 column

theorem lowest_index (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    ∃ selected : Fin 248320,
      (ByteMemory.load32 execution.decode.sampler.memory execution.decode.sampler.selection.destination).toNat=selected.val ∧
      (∀ i, GreedySampling.score sampling (p.run cache token angle).1 i≤
        GreedySampling.score sampling (p.run cache token angle).1 selected) ∧
      (∀ i, GreedySampling.score sampling (p.run cache token angle).1 selected=
        GreedySampling.score sampling (p.run cache token angle).1 i → selected.val ≤ i.val) :=
  Qwen38CopiedAttentionSamplerSource.lowest_index execution.decode samplingPrimitive
    (model_bound parameters primitive cacheBound angleBound supported)

-- Exact-real winner agreement still requires a margin exceeding the
-- propagated logit and normalized-score errors.
theorem target_winner (samplingPrimitive : LogSumExpRanges.Primitives sampling)
    (targetCache cacheError : p.graph.ReferenceCache n)
    (cacheAccuracy : DecodeChain.CacheErrors p.graph.stages cache targetCache cacheError)
    (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
    (baseNonnegative : 0≤aim.base) (winner : Fin 248320)
    (margin : ∀ i, i≠winner →
      (p.targetRun targetCache token aim).1 i+GreedySampling.error sampling (p.run cache token angle).1
        (TokenSampledSequenceRanges.budget p parameters primitive cache cacheBound targetCache cacheError
          token angle angleBound supported aim angleError).1 i <
      (p.targetRun targetCache token aim).1 winner-GreedySampling.error sampling (p.run cache token angle).1
        (TokenSampledSequenceRanges.budget p parameters primitive cache cacheBound targetCache cacheError
          token angle angleBound supported aim angleError).1 winner) :
    (ByteMemory.load32 execution.decode.sampler.memory execution.decode.sampler.selection.destination).toNat=winner.val := by
  rw [token_read execution parameters primitive cacheBound angleBound supported samplingPrimitive]
  exact TokenSampledSequenceRanges.target_winner p parameters primitive sampling samplingPrimitive cache cacheBound
    targetCache cacheError cacheAccuracy token angle angleBound supported aim angleError angleAccuracy baseNonnegative winner margin

end Inference.Models.Qwen.Qwen38CopiedTokenRanges
