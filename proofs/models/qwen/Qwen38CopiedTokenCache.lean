import models.qwen.Qwen38CopiedTokenRanges
import models.qwen.Qwen38CopiedAttentionCache
import state.TokenStorage

namespace Inference.Models.Qwen.Qwen38CopiedTokenCache
open Contracts.Mlx Layers Kernels.Attention Kernels.Sampling TokenInference
open FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] Qwen38TrellisM1Max.Graph.stages

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform}
  {cache : p.graph.Cache n} {token : Fin 248320} {angle : RopeAngles.Inputs}
  (execution : Qwen38CopiedTokenSource.Execution p sampling cache token angle)

-- Both obligations concern original live cache spans. No post-sampler
-- cache attachment or expected output heap is supplied.
def Region (base size : Nat) : Prop :=
  MemoryRegions.Disjoint execution.decode.workspace.base NormalizedArgmaxAllocation.bytes base size

def Safe (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward) : Prop :=
  DecodePreservation.Protected (Region execution) p.graph.stages (p.run cache token angle).2
    (Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).bytes
    (Qwen38CopiedAttentionCache.after execution.decode.forward headSafe)

def after (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward)
    (samplerSafe : Safe execution headSafe) :
    DecodeFrame.Storage p.graph.stages (p.run cache token angle).2 execution.decode.sampler.memory :=
  DecodePreservation.reframe (Region execution)
    (Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).bytes execution.decode.sampler.memory
    (fun _ _ region => Qwen38CopiedAttentionSamplerSource.preserve_region execution.decode region)
    p.graph.stages (p.run cache token angle).2
    (Qwen38CopiedAttentionCache.after execution.decode.forward headSafe) samplerSafe

def readCaches (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward)
    (samplerSafe : Safe execution headSafe) : p.graph.Cache (n+1) :=
  DecodeFrameRead.caches p.graph.stages (p.run cache token angle).2 execution.decode.sampler.memory
    (after execution headSafe samplerSafe)

theorem caches_eq (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward)
    (samplerSafe : Safe execution headSafe) : readCaches execution headSafe samplerSafe=(p.run cache token angle).2 :=
  DecodeFrameRead.caches_eq _ _ _ _

theorem owned (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward)
    (samplerSafe : Safe execution headSafe) (allocator : AllocatorOwnership.State)
    (beforeOwned : CacheOwnership.OwnedCaches allocator p.graph.stages (p.run cache token angle).2
      (Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).bytes
      (Qwen38CopiedAttentionCache.after execution.decode.forward headSafe)) :
    CacheOwnership.OwnedCaches allocator p.graph.stages (p.run cache token angle).2
      execution.decode.sampler.memory (after execution headSafe samplerSafe) :=
  DecodePreservation.preserves_ownership allocator (Region execution)
    (Qwen38CopiedAttentionExecution.logitsBuffer execution.decode.forward).bytes execution.decode.sampler.memory
    (fun _ _ region => Qwen38CopiedAttentionSamplerSource.preserve_region execution.decode region)
    p.graph.stages (p.run cache token angle).2
    (Qwen38CopiedAttentionCache.after execution.decode.forward headSafe) samplerSafe beforeOwned

-- The retained logits, uint32 token and cache views all use the sampler's
-- completed memory. The buffer's read theorem comes from its actual bytes.
def logitsAfter := execution.decode.sampler.selection.logitsAfter

theorem logits_shared : (logitsAfter execution).bytes=execution.decode.sampler.memory := rfl

theorem logit_read (column : Fin 248320) :
    (logitsAfter execution).read column=(p.run cache token angle).1 column :=
  ((logitsAfter execution).read_correct column).trans
    (congrFun execution.decode.logits_eq column)

variable (parameters : TokenSequenceRanges.Parameters p)
  (primitive : Qwen38TrellisM1MaxSequenceRanges.Primitives p.graph)
  (cacheBound : DecodeChainSequenceRanges.CachesBound p.graph.stages cache)
  (angleBound : RopeAnglesRanges.InputsBound angle) (supported : n+1≤262144)
  (samplingPrimitive : LogSumExpRanges.Primitives sampling)

include parameters primitive cacheBound angleBound supported samplingPrimitive

def selected : Fin 248320 :=
  ⟨(ByteMemory.load32 execution.decode.sampler.memory execution.decode.sampler.selection.destination).toNat,by
    obtain ⟨selected,same,_,_⟩ := Qwen38CopiedTokenRanges.lowest_index execution parameters primitive
      cacheBound angleBound supported samplingPrimitive
    rw [same]
    exact selected.isLt⟩

def index : Inference.State.TokenStorage.Buffer
    (selected execution parameters primitive cacheBound angleBound supported samplingPrimitive) :=
  Inference.State.TokenStorage.Buffer.fromRead
    (selected execution parameters primitive cacheBound angleBound supported samplingPrimitive)
    execution.decode.sampler.memory execution.decode.sampler.selection.destination
    execution.decode.sampler.selection.output.aligned execution.decode.sampler.selection.output.bounded rfl

theorem index_shared :
    (index execution parameters primitive cacheBound angleBound supported samplingPrimitive).bytes=
      execution.decode.sampler.memory := rfl

theorem readback (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward)
    (samplerSafe : Safe execution headSafe) :
    ((index execution parameters primitive cacheBound angleBound supported samplingPrimitive).read,
      readCaches execution headSafe samplerSafe)=TokenSampledSequenceRanges.run p sampling cache token angle :=
  Prod.ext (Qwen38CopiedTokenRanges.token_read execution parameters primitive cacheBound angleBound supported samplingPrimitive)
    (caches_eq execution headSafe samplerSafe)

omit samplingPrimitive in
theorem cache_bound (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward)
    (samplerSafe : Safe execution headSafe) :
    DecodeChainSequenceRanges.CachesBound p.graph.stages (readCaches execution headSafe samplerSafe) := by
  rw [caches_eq]
  exact TokenSequenceRanges.next_cache p parameters primitive cache cacheBound token angle angleBound supported

omit samplingPrimitive in
theorem cache_error (headSafe : Qwen38CopiedAttentionCache.Safe execution.decode.forward)
    (samplerSafe : Safe execution headSafe) (targetCache cacheError : p.graph.ReferenceCache n)
    (cacheAccuracy : DecodeChain.CacheErrors p.graph.stages cache targetCache cacheError)
    (aim angleError : RopeAngles.Target) (angleAccuracy : RopeAngles.InputError angle aim angleError)
    (baseNonnegative : 0≤aim.base) :
    DecodeChain.CacheErrors p.graph.stages (readCaches execution headSafe samplerSafe)
      (p.targetRun targetCache token aim).2
      (TokenSampledSequenceRanges.budget p parameters primitive cache cacheBound targetCache cacheError
        token angle angleBound supported aim angleError).2 := by
  rw [caches_eq]
  exact (TokenSequenceRanges.run_correct p parameters primitive cache cacheBound targetCache cacheError
    cacheAccuracy token angle angleBound supported aim angleError angleAccuracy baseNonnegative).2.1

end Inference.Models.Qwen.Qwen38CopiedTokenCache
