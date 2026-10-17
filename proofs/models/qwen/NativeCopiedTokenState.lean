import models.qwen.NativeCopiedTokenMemory
import models.qwen.TokenAutoregressiveMemory

namespace Inference.Models.Qwen.NativeCopiedTokenState
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference NativeCopiedTokenRoute
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenRoute.final NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation
  FinalProjectionSamplerSource.Execution.sampler

-- Both native routes consume the preceding state's actual uint32 token and
-- cache views. This links a reached step; allocations remain explicit.
structure Step {n : Nat} (p : Pipeline) (sampling : LogSumExpRanges.Platform)
    (before : TokenAutoregressiveMemory.State p n) (angle : RopeAngles.Inputs) where
  execution : Execution p sampling before.logical.cache before.logical.token angle
  tokenLinked : (embedding execution).tokenBuffer=before.index
  embeddingSafe : DecodePreservation.Protected (embedding execution).regions.Live p.graph.stages
    before.logical.cache before.index.bytes before.caches
  cacheLinked : storage execution=
    TokenAutoregressiveMemory.transportCaches (congrArg ArrayStorage.BFBuffer.bytes (linked execution)).symm
      (TokenAutoregressiveMemory.embeddingCaches before (embedding execution) tokenLinked embeddingSafe)
  safe : NativeCopiedTokenMemory.Safe execution

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n} {angle : RopeAngles.Inputs}
  (step : Step p sampling before angle)

theorem entry_token : (embedding step.execution).tokenBuffer.read=before.index.read := by rw [step.tokenLinked]

theorem entry_heap : (embedding step.execution).tokenBuffer.bytes=before.index.bytes :=
  congrArg Inference.State.TokenStorage.Buffer.bytes step.tokenLinked

variable (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)
  (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
  (baseNonnegative : 0≤aim.base)

def selected : Fin 248320 :=
  ⟨(ByteMemory.load32 (final step.execution).sampler.memory (final step.execution).sampler.selection.destination).toNat,by
    obtain ⟨chosen,same,_,_⟩ := FinalProjectionSamplerSource.lowest_index (final step.execution) samplingPrimitive
      (NativeCopiedTokenMemory.model_bound parameters primitive before.logical.cacheBound angleBound supported)
    change (final step.execution).sampler.selection.token<248320
    rw [same]
    exact chosen.isLt⟩

def index : Inference.State.TokenStorage.Buffer
    (selected step parameters primitive samplingPrimitive angleBound supported) :=
  Inference.State.TokenStorage.Buffer.fromRead
    (selected step parameters primitive samplingPrimitive angleBound supported) (final step.execution).sampler.memory
    (final step.execution).sampler.selection.destination (final step.execution).sampler.selection.output.aligned
    (final step.execution).sampler.selection.output.bounded rfl

noncomputable def advance : TokenAutoregressiveMemory.State p (n+1) := by
  let reference := TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical
    angle angleBound supported aim angleError angleAccuracy baseNonnegative
  have token : selected step parameters primitive samplingPrimitive angleBound supported=reference.token := by
    apply Fin.ext
    exact NativeCopiedTokenMemory.token_read parameters primitive before.logical.cacheBound angleBound supported
      step.execution samplingPrimitive
  exact ⟨reference,TokenAutoregressiveMemory.reindexToken token
    (index step parameters primitive samplingPrimitive angleBound supported),
    NativeCopiedTokenMemory.after step.execution step.safe⟩

theorem advance_logical :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).logical=
      TokenAutoregressive.advance p parameters primitive sampling samplingPrimitive before.logical
        angle angleBound supported aim angleError angleAccuracy baseNonnegative := rfl

theorem advance_heap :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.bytes=
      (final step.execution).sampler.memory := rfl

theorem advance_address :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.base=
      (final step.execution).sampler.selection.destination := rfl

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

theorem source_token (unsigned : Bool) (inputs : Inputs step.execution)
    (finalNative : FinalProjectionParsedSource.Native (finalStorage step.execution) (finalAllocation step.execution))
    (lseNative : LogSumExpSourceHost.Attachment) :
    Certificate step.execution unsigned inputs
      (NativeCopiedTokenMemory.ranges parameters primitive before.logical.cacheBound angleBound supported)
      supported finalNative lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory (final step.execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory (final step.execution).sampler.selection.destination).toNat)=
      some (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.read := by
  have result := NativeCopiedTokenMemory.source_result parameters primitive before.logical.cacheBound angleBound supported
    step.execution step.safe unsigned inputs finalNative lseNative samplingPrimitive
  refine ⟨result.1,?_⟩
  rw [result.2.1,Inference.State.TokenStorage.Buffer.read_correct]
  rfl

end Inference.Models.Qwen.NativeCopiedTokenState
