import models.qwen.Qwen38CopiedTokenCache
import models.qwen.TokenAutoregressiveMemory

namespace Inference.Models.Qwen.Qwen38CopiedTokenState
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

-- The copied route consumes the preceding state's actual token and cache
-- views. Allocation and original global parameter construction remain
-- separate: this type is a linked step, not a per-sequence constructor.
structure Step (p : Pipeline) (sampling : LogSumExpRanges.Platform)
    (before : TokenAutoregressiveMemory.State p n) (angle : RopeAngles.Inputs) where
  execution : Qwen38CopiedTokenSource.Execution p sampling before.logical.cache before.logical.token angle
  tokenLinked : execution.embedding.tokenBuffer=before.index
  embeddingSafe : DecodePreservation.Protected execution.embedding.regions.Live p.graph.stages
    before.logical.cache before.index.bytes before.caches
  cacheLinked : execution.decode.forward.storage=
    TokenAutoregressiveMemory.transportCaches (congrArg ArrayStorage.BFBuffer.bytes execution.linked).symm
      (TokenAutoregressiveMemory.embeddingCaches before execution.embedding tokenLinked embeddingSafe)
  headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward
  samplerSafe : Qwen38CopiedTokenCache.Safe execution headSafe

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n} {angle : RopeAngles.Inputs}
  (step : Step p sampling before angle)

theorem entry_token : step.execution.embedding.tokenBuffer.read=before.index.read := by
  rw [step.tokenLinked]

theorem entry_heap : step.execution.embedding.tokenBuffer.bytes=before.index.bytes :=
  congrArg Inference.State.TokenStorage.Buffer.bytes step.tokenLinked

variable (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)
  (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
  (baseNonnegative : 0≤aim.base)

noncomputable def advance : TokenAutoregressiveMemory.State p (n+1) := by
  let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical
    angle angleBound supported aim angleError angleAccuracy baseNonnegative
  have token : Qwen38CopiedTokenCache.selected step.execution parameters primitive before.logical.cacheBound
      angleBound supported samplingPrimitive=reference.token := by
    apply Fin.ext
    exact Qwen38CopiedTokenRanges.token_read step.execution parameters primitive before.logical.cacheBound
      angleBound supported samplingPrimitive
  exact ⟨reference,TokenAutoregressiveMemory.reindexToken token
    (Qwen38CopiedTokenCache.index step.execution parameters primitive before.logical.cacheBound
      angleBound supported samplingPrimitive),Qwen38CopiedTokenCache.after step.execution step.headSafe step.samplerSafe⟩

theorem advance_logical :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).logical=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical
        angle angleBound supported aim angleError angleAccuracy baseNonnegative := rfl

theorem advance_heap :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.bytes=
      step.execution.decode.sampler.memory := rfl

theorem readback :
    let actual := advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative
    let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical
      angle angleBound supported aim angleError angleAccuracy baseNonnegative
    (actual.index.read,actual.readCaches)=(reference.token.val,reference.cache) :=
  Prod.ext (Inference.State.TokenStorage.Buffer.read_correct _) (TokenAutoregressiveMemory.State.caches_eq _)

theorem cache_invariant :
    let actual := advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative
    DecodeChainSequenceRanges.CachesBound p.graph.stages actual.readCaches ∧
      DecodeChain.CacheErrors p.graph.stages actual.readCaches actual.logical.targetCache actual.logical.errorCache ∧
      DecodeChain.CachesFinite p.graph.stages actual.readCaches := by
  dsimp only
  rw [TokenAutoregressiveMemory.State.caches_eq]
  let actual := advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative
  exact ⟨actual.logical.cacheBound,actual.logical.cacheError,
    DecodeChainSequenceRanges.caches_finite _ _ actual.logical.cacheBound⟩

-- Parsed entry/model/head/sampler certificates and actual token readback
-- share the same retained step. Native descriptors and ownership selection
-- are still explicit; no cache or parameter allocation is inferred here.
theorem source_token (unsigned : Bool)
    (native : CopiedAttentionChainParsed.Native p.graph.stages before.logical.cache (p.embedding.forward before.logical.token) angle
      step.execution.decode.forward.source step.execution.decode.forward.storage step.execution.decode.forward.chain)
    (finalNative : FinalProjectionParsedSource.Native step.execution.decode.forward.finalParameters step.execution.decode.forward.allocation)
    (lseNative : LogSumExpSourceHost.Attachment) :
    QuantizedEmbeddingParsedPipeline.Certificate step.execution.embedding unsigned ∧
    FinalProjectionParsedSource.Certificate step.execution.decode.forward.finalParameters step.execution.decode.forward.allocation finalNative ∧
    Qwen38CopiedAttentionSamplerSource.Certificate step.execution.decode native lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory step.execution.decode.sampler.selection).map
      (fun memory=>(ByteMemory.load32 memory step.execution.decode.sampler.selection.destination).toNat)=
      some (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.read := by
  have certified := Qwen38CopiedTokenRanges.source_token step.execution parameters primitive before.logical.cacheBound
    angleBound supported unsigned native finalNative lseNative samplingPrimitive
  refine ⟨certified.1,certified.2.1,certified.2.2.1,?_⟩
  rw [certified.2.2.2,Inference.State.TokenStorage.Buffer.read_correct]
  rfl

end Inference.Models.Qwen.Qwen38CopiedTokenState
