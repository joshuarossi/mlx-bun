import models.qwen.NativeCopiedTokenState
import models.qwen.ReachedTokenContext
namespace Inference.Models.Qwen.ReachedNativeCopiedTokenState
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference NativeCopiedTokenRoute
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
set_option maxHeartbeats 800000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages
  NativeCopiedTokenRoute.final NativeCopiedTokenRoute.finalStorage NativeCopiedTokenRoute.finalAllocation
  FinalProjectionSamplerSource.Execution.sampler
variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {before : TokenAutoregressiveMemory.State p n} {angle : RopeAngles.Inputs}
  (step : NativeCopiedTokenState.Step p sampling before angle)
  (parameters : TokenSequenceRanges.Parameters p)
  (primitive : ReachedSequenceRanges.Graph.Primitives p.graph)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)

-- The existing full-primitive state advance cannot be instantiated by a
-- normal-input rsqrt envelope. Reuse its exact physical Step and cache frame,
-- with the already verified reached-input logical advance instead.
noncomputable def ranges : p.Ranges before.logical.cache before.logical.token angle :=
  ReachedSequenceRanges.Token.checked p parameters primitive before.logical.cache before.logical.cacheBound
    before.logical.token angle angleBound supported

include parameters primitive angleBound supported in
theorem model_bound : ∀ i, Model.isFinite ((p.run before.logical.cache before.logical.token angle).1 i)=true ∧
    |Model.toReal ((p.run before.logical.cache before.logical.token angle).1 i)| ≤ (2:ℝ)^(23:Nat) :=
  (ReachedSequenceRanges.Graph.checked p.graph parameters.graph primitive before.logical.cache before.logical.cacheBound
    (p.embedding.forward before.logical.token) (TokenSequenceRanges.embedding_bound p parameters before.logical.token)
    angle angleBound supported).output

def selected : Fin 248320 :=
  ⟨(ByteMemory.load32 (final step.execution).sampler.memory (final step.execution).sampler.selection.destination).toNat,by
    obtain ⟨chosen,same,_,_⟩ := FinalProjectionSamplerSource.lowest_index (final step.execution) samplingPrimitive
      (model_bound parameters primitive angleBound supported)
    change (final step.execution).sampler.selection.token<248320
    rw [same]
    exact chosen.isLt⟩

def index : Inference.State.TokenStorage.Buffer
    (selected step parameters primitive samplingPrimitive angleBound supported) :=
  Inference.State.TokenStorage.Buffer.fromRead
    (selected step parameters primitive samplingPrimitive angleBound supported) (final step.execution).sampler.memory
    (final step.execution).sampler.selection.destination (final step.execution).sampler.selection.output.aligned
    (final step.execution).sampler.selection.output.bounded rfl

variable (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
  (baseNonnegative : 0≤aim.base)

noncomputable def advance : TokenAutoregressiveMemory.State p (n+1) := by
  let reference := ReachedTokenContext.Logical.advance p parameters primitive sampling samplingPrimitive before.logical
    angle angleBound supported aim angleError angleAccuracy baseNonnegative
  have token : selected step parameters primitive samplingPrimitive angleBound supported=reference.token := by
    apply Fin.ext
    exact NativeCopiedTokenRoute.token_read step.execution samplingPrimitive
      (model_bound parameters primitive angleBound supported)
  exact ⟨reference,TokenAutoregressiveMemory.reindexToken token
    (index step parameters primitive samplingPrimitive angleBound supported),
    NativeCopiedTokenMemory.after step.execution step.safe⟩

theorem advance_logical :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).logical=
      ReachedTokenContext.Logical.advance p parameters primitive sampling samplingPrimitive before.logical
        angle angleBound supported aim angleError angleAccuracy baseNonnegative := rfl

theorem advance_heap :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.bytes=
      (final step.execution).sampler.memory := rfl

theorem advance_address :
    (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.base=
      (final step.execution).sampler.selection.destination := rfl

theorem readback :
    let actual := advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative
    let reference := ReachedTokenContext.Logical.advance p parameters primitive sampling samplingPrimitive before.logical
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
    Certificate step.execution unsigned inputs (ranges parameters primitive angleBound supported) supported finalNative lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory (final step.execution).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory (final step.execution).sampler.selection.destination).toNat)=
      some (advance step parameters primitive samplingPrimitive angleBound supported aim angleError angleAccuracy baseNonnegative).index.read := by
  have result := NativeCopiedTokenRoute.source_token step.execution unsigned inputs
    (ranges parameters primitive angleBound supported) supported finalNative lseNative samplingPrimitive
    (model_bound parameters primitive angleBound supported)
  refine ⟨result.1,?_⟩
  rw [result.2,Inference.State.TokenStorage.Buffer.read_correct]
  rfl
end Inference.Models.Qwen.ReachedNativeCopiedTokenState
