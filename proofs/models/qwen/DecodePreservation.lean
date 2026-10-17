import models.qwen.CacheOwnership

namespace Inference.Models.Qwen.DecodePreservation
open Contracts.Mlx DecodeStage DecodeChain
set_option maxRecDepth 10000

-- A launch composition supplies a region-level frame theorem. This lifts
-- it to every retained Delta/KV cache without assuming output attachments.
def StageProtected (region : Nat → Nat → Prop) : (stage : Stage) → (cache : Cache stage n) →
    DecodeFrame.StageStorage stage cache → Prop
  | .delta _, _, storage => region storage.buffers.history.base 61440 ∧ region storage.buffers.recurrent.base 3145728
  | .attention _, _, storage =>
    region storage.layout.keyBase (State.KvRegions.bytes n) ∧ region storage.layout.valueBase (State.KvRegions.bytes n)

def stageReframe (region : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset < size, after (base+offset)=before (base+offset)) :
    (stage : Stage) → (cache : Cache stage n) → (buffer : DecodeFrame.StageBuffer stage cache before) →
    StageProtected region stage cache buffer.storage → DecodeFrame.StageBuffer stage cache after
  | .delta _, _, buffer, safe =>
    ⟨buffer.storage.reframe after
      (by
        intro offset bound
        exact (frame _ _ safe.1 offset bound).trans
          (congrFun buffer.shared (buffer.storage.buffers.history.base+offset)).symm)
      (by
        intro offset bound
        exact (frame _ _ safe.2 offset bound).trans
          (congrFun buffer.shared (buffer.storage.buffers.recurrent.base+offset)).symm), rfl⟩
  | .attention _, _, buffer, safe =>
    ⟨buffer.storage.reframe after
      (by
        intro offset bound
        exact (frame _ _ safe.1 offset bound).trans
          (congrFun buffer.shared (buffer.storage.layout.keyBase+offset)).symm)
      (by
        intro offset bound
        exact (frame _ _ safe.2 offset bound).trans
          (congrFun buffer.shared (buffer.storage.layout.valueBase+offset)).symm), rfl⟩

def Protected (region : Nat → Nat → Prop) : (stages : List Stage) → (cache : Caches stages n) →
    (memory : ByteMemory.Bytes) → DecodeFrame.Storage stages cache memory → Prop
  | [], _, _, _ => True
  | stage::rest, cache, memory, storage =>
    StageProtected region stage cache.1 storage.1.storage ∧ Protected region rest cache.2 memory storage.2

def reframe (region : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset < size, after (base+offset)=before (base+offset)) :
    (stages : List Stage) → (cache : Caches stages n) → (storage : DecodeFrame.Storage stages cache before) →
    Protected region stages cache before storage → DecodeFrame.Storage stages cache after
  | [], _, _, _ => ⟨⟩
  | stage::rest, cache, storage, safe =>
    ⟨stageReframe region before after frame stage cache.1 storage.1 safe.1,
      reframe region before after frame rest cache.2 storage.2 safe.2⟩

theorem stage_preserves_geometry (region next : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stage : Stage) (cache : Cache stage n) (buffer : DecodeFrame.StageBuffer stage cache before)
    (safe : StageProtected region stage cache buffer.storage)
    (nextProtected : StageProtected next stage cache buffer.storage) :
    StageProtected next stage cache (stageReframe region before after frame stage cache buffer safe).storage := by
  cases stage <;> exact nextProtected

theorem preserves_geometry (region next : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache before)
    (safe : Protected region stages cache before storage) (nextProtected : Protected next stages cache before storage) :
    Protected next stages cache after (reframe region before after frame stages cache storage safe) := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    exact ⟨stage_preserves_geometry region next before after frame stage cache.1 storage.1 safe.1 nextProtected.1,
      ih cache.2 storage.2 safe.2 nextProtected.2⟩

theorem stage_preserves_ownership (allocator : AllocatorOwnership.State) (region : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stage : Stage) (cache : Cache stage n) (buffer : DecodeFrame.StageBuffer stage cache before)
    (safe : StageProtected region stage cache buffer.storage)
    (owned : CacheOwnership.StageOwned allocator stage cache buffer.storage) :
    CacheOwnership.StageOwned allocator stage cache (stageReframe region before after frame stage cache buffer safe).storage := by
  cases stage <;> exact owned

theorem preserves_ownership (allocator : AllocatorOwnership.State) (region : Nat → Nat → Prop) (before after : ByteMemory.Bytes)
    (frame : ∀ base size, region base size → ∀ offset < size, after (base+offset)=before (base+offset))
    (stages : List Stage) (cache : Caches stages n) (storage : DecodeFrame.Storage stages cache before)
    (safe : Protected region stages cache before storage) (owned : CacheOwnership.OwnedCaches allocator stages cache before storage) :
    CacheOwnership.OwnedCaches allocator stages cache after (reframe region before after frame stages cache storage safe) := by
  induction stages with
  | nil => trivial
  | cons stage rest ih =>
    exact ⟨stage_preserves_ownership allocator region before after frame stage cache.1 storage.1 safe.1 owned.1,
      ih cache.2 storage.2 safe.2 owned.2⟩

end Inference.Models.Qwen.DecodePreservation
