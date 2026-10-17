import models.qwen.NativeCopiedTokenRoute
import models.qwen.InitialCopiedTokenCache
import models.qwen.CapacityCopiedTokenCache
import models.qwen.TokenSampledSequenceRanges

namespace Inference.Models.Qwen.NativeCopiedTokenMemory
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference NativeCopiedTokenRoute
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

structure InitialSafe {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache 0}
    {token : Fin 248320} {angle : RopeAngles.Inputs}
    (run : InitialCopiedTokenSource.Execution p sampling cache token angle) : Prop where
  head : Qwen38InitialCopiedCache.Safe run.forward
  sampler : InitialCopiedTokenCache.Safe run head

structure PositiveSafe {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform} {cache : p.graph.Cache n}
    {token : Fin 248320} {angle : RopeAngles.Inputs}
    (run : CapacityCopiedTokenSource.Execution p sampling cache token angle) : Prop where
  head : Qwen38CapacityAttentionCache.Safe run.forward
  sampler : CapacityCopiedTokenCache.Safe run head

variable {n : Nat} {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}

def Safe (run : Execution p sampling cache token angle) : Prop := match run with
  | .initial run => InitialSafe run
  | .positive run => PositiveSafe run

def after (run : Execution p sampling cache token angle) (safe : Safe run) :
    DecodeFrame.Storage p.graph.stages (p.run cache token angle).2 (final run).sampler.memory := match run,safe with
  | .initial run,safe => InitialCopiedTokenCache.after run safe.head safe.sampler
  | .positive run,safe => CapacityCopiedTokenCache.after run safe.head safe.sampler

def readCaches (run : Execution p sampling cache token angle) (safe : Safe run) : p.graph.Cache (n+1) :=
  DecodeFrameRead.caches p.graph.stages (p.run cache token angle).2 (final run).sampler.memory (after run safe)

theorem caches_eq (run : Execution p sampling cache token angle) (safe : Safe run) :
    readCaches run safe=(p.run cache token angle).2 := DecodeFrameRead.caches_eq _ _ _ _

variable (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)

noncomputable def ranges : p.Ranges cache token angle :=
  TokenSequenceRanges.checked p parameters primitive cache cacheBound token angle angleBound supported

include parameters primitive cacheBound angleBound supported

theorem model_bound : ∀ i, Model.isFinite ((p.run cache token angle).1 i)=true ∧
    |Model.toReal ((p.run cache token angle).1 i)| ≤ (2:ℝ)^(23:Nat) :=
  (Qwen38TrellisM1MaxSequenceRanges.checked p.graph parameters.graph primitive cache cacheBound
    (p.embedding.forward token) (TokenSequenceRanges.embedding_bound p parameters token) angle angleBound supported).output

theorem token_read (run : Execution p sampling cache token angle) (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    (ByteMemory.load32 (final run).sampler.memory (final run).sampler.selection.destination).toNat=
      GreedySampling.sample sampling (p.run cache token angle).1 :=
  NativeCopiedTokenRoute.token_read run samplingPrimitive
    (model_bound parameters primitive cacheBound angleBound supported)

theorem readback (run : Execution p sampling cache token angle) (safe : Safe run)
    (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    ((ByteMemory.load32 (final run).sampler.memory (final run).sampler.selection.destination).toNat,
      readCaches run safe)=TokenSampledSequenceRanges.run p sampling cache token angle :=
  Prod.ext (token_read parameters primitive cacheBound angleBound supported run samplingPrimitive) (caches_eq run safe)

-- Both branches use the original model's range derivation. The certificate
-- does not ask for separately supplied layer-finite or logit-bound witnesses.
theorem source_result (run : Execution p sampling cache token angle) (safe : Safe run)
    (unsigned : Bool) (inputs : Inputs run)
    (finalNative : FinalProjectionParsedSource.Native (finalStorage run) (finalAllocation run))
    (lseNative : LogSumExpSourceHost.Attachment) (samplingPrimitive : LogSumExpRanges.Primitives sampling) :
    Certificate run unsigned inputs (ranges parameters primitive cacheBound angleBound supported) supported finalNative lseNative ∧
    (ArgmaxLaunchSourceMemory.tokenMemory (final run).sampler.selection).map
      (fun memory => (ByteMemory.load32 memory (final run).sampler.selection.destination).toNat)=
      some (GreedySampling.sample sampling (p.run cache token angle).1) ∧
    readCaches run safe=(p.run cache token angle).2 := by
  have result := NativeCopiedTokenRoute.source_token run unsigned inputs
    (ranges parameters primitive cacheBound angleBound supported) supported finalNative lseNative samplingPrimitive
    (model_bound parameters primitive cacheBound angleBound supported)
  exact ⟨result.1,result.2,caches_eq run safe⟩

theorem cache_bound (run : Execution p sampling cache token angle) (safe : Safe run) :
    DecodeChainSequenceRanges.CachesBound p.graph.stages (readCaches run safe) := by
  rw [caches_eq]
  exact TokenSequenceRanges.next_cache p parameters primitive cache cacheBound token angle angleBound supported

end Inference.Models.Qwen.NativeCopiedTokenMemory
