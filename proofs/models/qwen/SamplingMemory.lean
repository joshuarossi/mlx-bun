import models.qwen.DecodeFrame
import models.qwen.CacheOwnership
import state.SampledToken
import layers.QuantizedEmbeddingIndex

namespace Inference.Models.Qwen.SamplingMemory
open Contracts.Mlx TokenInference Kernels.Sampling
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

-- Final sampler write into the shared heap after the argmax reduction.
-- Earlier sampling scratch launches still need their own allocation frames.
structure Execution (p : Pipeline) (sampling : LogSumExpRanges.Platform)
    (cache : p.graph.Cache n) (logits : Fin 248320 → ArrayStorage.BF) where
  sampler : GreedyDevice.Execution sampling logits
  memory : ByteMemory.Bytes
  caches : DecodeFrame.Storage p.graph.stages cache memory
  tokenBase : Nat
  aligned : tokenBase%4=0
  bounded : tokenBase+4 ≤ 2^64
  separate : DecodeFrame.Separate p.graph.stages cache memory caches tokenBase 4

variable {p : Pipeline} {sampling : LogSumExpRanges.Platform} {n : Nat}
  {cache : p.graph.Cache n} {logits : Fin 248320 → ArrayStorage.BF}

-- For a cached allocator buffer, the retained caches' live ownership
-- derives every separation premise of the final token store.
def Execution.fromReused (sampler : GreedyDevice.Execution sampling logits)
    (memory : ByteMemory.Bytes) (caches : DecodeFrame.Storage p.graph.stages cache memory)
    (allocator : AllocatorOwnership.State) (valid : AllocatorOwnership.Valid allocator)
    (allocation : AllocatorOwnership.Buffer) (output : AllocatorRegions.Slice allocation)
    (cached : allocation ∈ allocator.cached) (aligned : output.base%4=0) (size : output.length=4)
    (owned : CacheOwnership.OwnedCaches allocator p.graph.stages cache memory caches) :
    Execution p sampling cache logits where
  sampler := sampler
  memory := memory
  caches := caches
  tokenBase := output.base
  aligned := aligned
  bounded := by
    simpa only [size] using output.addressable (valid.ranges allocation (Finset.mem_union_right _ cached))
  separate := by
    simpa only [size] using CacheOwnership.caches_reused_separate allocator valid allocation output cached
      p.graph.stages cache memory caches owned

def Execution.stores (execution : Execution p sampling cache logits) :=
  State.SampledToken.stores execution.sampler execution.memory execution.tokenBase execution.aligned execution.bounded

def Execution.after (execution : Execution p sampling cache logits) :
    DecodeFrame.Storage p.graph.stages cache execution.stores.memory :=
  DecodeFrame.after32 execution.stores.schedule (State.SampledToken.stores_inside _ _ _ _ _)
    p.graph.stages cache execution.memory execution.caches execution.separate

theorem Execution.after_owned (execution : Execution p sampling cache logits) (allocator : AllocatorOwnership.State)
    (owned : CacheOwnership.OwnedCaches allocator p.graph.stages cache execution.memory execution.caches) :
    CacheOwnership.OwnedCaches allocator p.graph.stages cache execution.stores.memory execution.after :=
  CacheOwnership.after32_owned allocator execution.stores.schedule (State.SampledToken.stores_inside _ _ _ _ _)
    p.graph.stages cache execution.memory execution.caches execution.separate owned

def Execution.cacheStorage (execution : Execution p sampling cache logits) : DecodeStorage.Storage p.graph.stages cache :=
  DecodeFrame.localStorage p.graph.stages cache execution.stores.memory execution.after

def Execution.index (execution : Execution p sampling cache logits) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) :
    State.TokenStorage.Buffer (State.SampledToken.selected execution.sampler primitive bound) :=
  State.SampledToken.buffer execution.sampler primitive bound execution.memory execution.tokenBase execution.aligned execution.bounded

theorem Execution.index_bytes (execution : Execution p sampling cache logits) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) :
    (execution.index primitive bound).bytes=execution.stores.memory := rfl

theorem Execution.index_read (execution : Execution p sampling cache logits) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat)) :
    (execution.index primitive bound).read=GreedySampling.sample sampling logits :=
  State.SampledToken.buffer_read _ _ _ _ _ _ _

-- The gathered row uses the retained token store directly. Cache values are
-- unchanged by that write, and their views refer to the same updated heap.
def Execution.nextEmbedding (execution : Execution p sampling cache logits) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (weights : Layers.QuantizedEmbeddingDevice.Storage p.embedding) :
    Layers.QuantizedEmbeddingIndex.Execution p.embedding (State.SampledToken.selected execution.sampler primitive bound) :=
  Layers.QuantizedEmbeddingIndex.Execution.fromStorage p.embedding _ (execution.index primitive bound) weights

theorem Execution.embedding_index_bytes (execution : Execution p sampling cache logits) (primitive : LogSumExpRanges.Primitives sampling)
    (bound : ∀ i, Model.isFinite (logits i)=true ∧ |Model.toReal (logits i)| ≤ (2 : ℝ)^(23 : Nat))
    (weights : Layers.QuantizedEmbeddingDevice.Storage p.embedding) :
    (execution.nextEmbedding primitive bound weights).index.bytes=execution.stores.memory := rfl

end Inference.Models.Qwen.SamplingMemory
