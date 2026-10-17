import contracts.mlx.AllocatorRegions
import models.qwen.DecodeFrame

namespace Inference.Models.Qwen.CacheOwnership
open Contracts.Mlx DecodeStage DecodeChain
set_option maxRecDepth 10000

-- Each cache region is a bounded view of a live allocation. The only region
-- without an allocation is the zero-length initial KV cache at base zero.
-- Establishing these witnesses from native array/refcount lifetimes remains
-- an obligation at the native boundary, not an axiom of this definition.
def Owned (allocator : AllocatorOwnership.State) (base size : Nat) : Prop :=
  (base=0 ∧ size=0) ∨ ∃ buffer ∈ allocator.active, ∃ slice : AllocatorRegions.Slice buffer,
    slice.base=base ∧ slice.length=size

theorem owned_zero (allocator : AllocatorOwnership.State) : Owned allocator 0 0 := Or.inl ⟨rfl, rfl⟩

theorem owned_slice (allocator : AllocatorOwnership.State) (buffer : AllocatorOwnership.Buffer)
    (slice : AllocatorRegions.Slice buffer) (active : buffer ∈ allocator.active) :
    Owned allocator slice.base slice.length := Or.inr ⟨buffer, active, slice, rfl, rfl⟩

theorem owned_mono (before after : AllocatorOwnership.State) (subset : before.active ⊆ after.active)
    (owned : Owned before base size) : Owned after base size := by
  rcases owned with empty|⟨buffer, active, slice, sameBase, sameSize⟩
  · exact Or.inl empty
  · exact Or.inr ⟨buffer, subset active, slice, sameBase, sameSize⟩

theorem reused_separate (allocator : AllocatorOwnership.State) (valid : AllocatorOwnership.Valid allocator)
    (allocation : AllocatorOwnership.Buffer) (output : AllocatorRegions.Slice allocation)
    (cached : allocation ∈ allocator.cached) (owned : Owned allocator base size) :
    MemoryRegions.Disjoint output.base output.length base size := by
  rcases owned with ⟨rfl, rfl⟩|⟨buffer, active, slice, sameBase, sameSize⟩
  · exact Or.inr (Nat.zero_le _)
  · simpa only [sameBase, sameSize] using AllocatorRegions.reused_slice allocator valid output slice cached active

def StageOwned (allocator : AllocatorOwnership.State) : (stage : Stage) → (cache : Cache stage n) →
    DecodeFrame.StageStorage stage cache → Prop
  | .delta _, _, storage =>
    Owned allocator storage.buffers.history.base 61440 ∧ Owned allocator storage.buffers.recurrent.base 3145728
  | .attention _, _, storage =>
    Owned allocator storage.layout.keyBase (State.KvRegions.bytes n) ∧
      Owned allocator storage.layout.valueBase (State.KvRegions.bytes n)

theorem stage_reused_separate (allocator : AllocatorOwnership.State) (valid : AllocatorOwnership.Valid allocator)
    (allocation : AllocatorOwnership.Buffer) (output : AllocatorRegions.Slice allocation)
    (cached : allocation ∈ allocator.cached) (stage : Stage) (cache : Cache stage n)
    (storage : DecodeFrame.StageStorage stage cache) (owned : StageOwned allocator stage cache storage) :
    DecodeFrame.StageSeparate stage cache storage output.base output.length := by
  cases stage <;> exact ⟨reused_separate allocator valid allocation output cached owned.1,
    reused_separate allocator valid allocation output cached owned.2⟩

def OwnedCaches (allocator : AllocatorOwnership.State) : (stages : List Stage) → (cache : Caches stages n) →
    (memory : ByteMemory.Bytes) → DecodeFrame.Storage stages cache memory → Prop
  | [], _, _, _ => True
  | stage::rest, cache, memory, storage =>
    StageOwned allocator stage cache.1 storage.1.storage ∧ OwnedCaches allocator rest cache.2 memory storage.2

theorem caches_reused_separate (allocator : AllocatorOwnership.State) (valid : AllocatorOwnership.Valid allocator)
    (allocation : AllocatorOwnership.Buffer) (output : AllocatorRegions.Slice allocation)
    (cached : allocation ∈ allocator.cached) (stages : List Stage) (cache : Caches stages n)
    (memory : ByteMemory.Bytes) (storage : DecodeFrame.Storage stages cache memory)
    (owned : OwnedCaches allocator stages cache memory storage) :
    DecodeFrame.Separate stages cache memory storage output.base output.length := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    exact ⟨stage_reused_separate allocator valid allocation output cached stage cache.1 storage.1.storage owned.1,
      ih cache.2 storage.2 owned.2⟩

theorem stage_after32_owned (allocator : AllocatorOwnership.State) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores) (stage : Stage) (cache : Cache stage n)
    (storage : DecodeFrame.StageStorage stage cache) (separate : DecodeFrame.StageSeparate stage cache storage base size)
    (owned : StageOwned allocator stage cache storage) :
    StageOwned allocator stage cache (DecodeFrame.stageAfter32 stores inside stage cache storage separate) := by
  cases stage <;> exact owned

theorem stage_after16_owned (allocator : AllocatorOwnership.State) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores) (stage : Stage) (cache : Cache stage n)
    (storage : DecodeFrame.StageStorage stage cache) (separate : DecodeFrame.StageSeparate stage cache storage base size)
    (owned : StageOwned allocator stage cache storage) :
    StageOwned allocator stage cache (DecodeFrame.stageAfter16 stores inside stage cache storage separate) := by
  cases stage <;> exact owned

theorem after32_owned (allocator : AllocatorOwnership.State) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores) (stages : List Stage) (cache : Caches stages n)
    (memory : ByteMemory.Bytes) (storage : DecodeFrame.Storage stages cache memory)
    (separate : DecodeFrame.Separate stages cache memory storage base size)
    (owned : OwnedCaches allocator stages cache memory storage) :
    OwnedCaches allocator stages cache (ByteMemory.execute stores memory)
      (DecodeFrame.after32 stores inside stages cache memory storage separate) := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    exact ⟨stage_after32_owned allocator stores inside stage cache.1 storage.1.storage separate.1 owned.1,
      ih cache.2 storage.2 separate.2 owned.2⟩

theorem after16_owned (allocator : AllocatorOwnership.State) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores) (stages : List Stage) (cache : Caches stages n)
    (memory : ByteMemory.Bytes) (storage : DecodeFrame.Storage stages cache memory)
    (separate : DecodeFrame.Separate stages cache memory storage base size)
    (owned : OwnedCaches allocator stages cache memory storage) :
    OwnedCaches allocator stages cache (HalfMemory.execute stores memory)
      (DecodeFrame.after16 stores inside stages cache memory storage separate) := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    exact ⟨stage_after16_owned allocator stores inside stage cache.1 storage.1.storage separate.1 owned.1,
      ih cache.2 storage.2 separate.2 owned.2⟩

-- The output allocation comes from the cache and all retained inference
-- caches remain live. Separation for every stage follows from allocator
-- invariants; no per-stage disjointness hypothesis is needed here.
def afterReusedWords (allocator : AllocatorOwnership.State) (valid : AllocatorOwnership.Valid allocator)
    (allocation : AllocatorOwnership.Buffer) (output : AllocatorRegions.Slice allocation)
    (cached : allocation ∈ allocator.cached) {values : Fin m → BitVec 32}
    (trace : WordArrayWrites.Trace output.base values) (size : output.length=4*m)
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache trace.before)
    (owned : OwnedCaches allocator stages cache trace.before storage) :
    DecodeFrame.Storage stages cache trace.memory :=
  DecodeFrame.after32 trace.schedule (ArrayFrame.word_stores_inside trace) stages cache trace.before storage
    (by simpa only [size] using caches_reused_separate allocator valid allocation output cached stages cache trace.before storage owned)

def afterReusedHalves (allocator : AllocatorOwnership.State) (valid : AllocatorOwnership.Valid allocator)
    (allocation : AllocatorOwnership.Buffer) (output : AllocatorRegions.Slice allocation)
    (cached : allocation ∈ allocator.cached) {values : Fin m → BitVec 16}
    (trace : HalfArrayWrites.Trace output.base values) (size : output.length=2*m)
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache trace.before)
    (owned : OwnedCaches allocator stages cache trace.before storage) :
    DecodeFrame.Storage stages cache trace.memory :=
  DecodeFrame.after16 trace.schedule (ArrayFrame.half_stores_inside trace) stages cache trace.before storage
    (by simpa only [size] using caches_reused_separate allocator valid allocation output cached stages cache trace.before storage owned)

end Inference.Models.Qwen.CacheOwnership
