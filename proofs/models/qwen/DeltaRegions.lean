import models.qwen.DeltaDevice
import contracts.mlx.ArrayFrame

namespace Inference.Models.Qwen.DeltaRegions
open Contracts.Mlx Kernels.Delta
set_option maxRecDepth 10000

-- Shared byte storage for one layer's convolution history and FP32 state.
-- Address separation is supplied by the allocation contract. This module
-- proves that unrelated completed stores retain both cache attachments.
structure Storage (cache : DeltaNet.Cache) where
  buffers : DeltaDevice.Storage cache
  shared : buffers.recurrent.bytes=buffers.history.bytes
  separate : MemoryRegions.Disjoint buffers.history.base 61440 buffers.recurrent.base 3145728

variable {cache : DeltaNet.Cache}

def Storage.memory (storage : Storage cache) : ByteMemory.Bytes := storage.buffers.history.bytes

theorem state_bounds (head : Fin 48) (row key : Fin 128) :
    4*GatedStores.stateIndex head row key+4 ≤ 3145728 := by
  have := head.isLt; have := row.isLt; have := key.isLt
  dsimp [GatedStores.stateIndex]
  omega

def Storage.reframe (storage : Storage cache) (after : ByteMemory.Bytes)
    (history : ∀ offset < 61440, after (storage.buffers.history.base+offset)=storage.memory (storage.buffers.history.base+offset))
    (recurrent : ∀ offset < 3145728, after (storage.buffers.recurrent.base+offset)=storage.memory (storage.buffers.recurrent.base+offset)) :
    Storage cache where
  buffers := {
    history := ArrayFrame.bf storage.buffers.history after history
    recurrent := {
      bytes := after
      base := storage.buffers.recurrent.base
      aligned := storage.buffers.recurrent.aligned
      bounded := storage.buffers.recurrent.bounded
      attached := by
        intro head row key
        have same := ArrayFrame.word_congr storage.memory after storage.buffers.recurrent.base 3145728 _ recurrent
          (state_bounds head row key)
        unfold FloatMemory.load
        rw [same]
        have read := storage.buffers.recurrent.attached head row key
        rw [storage.shared] at read
        exact read } }
  shared := rfl
  separate := storage.separate

def Storage.after32 (storage : Storage cache) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores)
    (historySeparate : MemoryRegions.Disjoint base size storage.buffers.history.base 61440)
    (stateSeparate : MemoryRegions.Disjoint base size storage.buffers.recurrent.base 3145728) : Storage cache :=
  storage.reframe (ByteMemory.execute stores storage.memory)
    (MemoryRegions.execute32_other _ _ inside historySeparate)
    (MemoryRegions.execute32_other _ _ inside stateSeparate)

def Storage.after16 (storage : Storage cache) (stores : List HalfMemory.Store)
    (inside : MemoryRegions.Inside16 base size stores)
    (historySeparate : MemoryRegions.Disjoint base size storage.buffers.history.base 61440)
    (stateSeparate : MemoryRegions.Disjoint base size storage.buffers.recurrent.base 3145728) : Storage cache :=
  storage.reframe (HalfMemory.execute stores storage.memory)
    (MemoryRegions.execute16_other _ _ inside historySeparate)
    (MemoryRegions.execute16_other _ _ inside stateSeparate)

def Storage.afterWords (storage : Storage cache) {output : Fin n → BitVec 32}
    (trace : WordArrayWrites.Trace base output) (shared : trace.before=storage.memory)
    (historySeparate : MemoryRegions.Disjoint base (4*n) storage.buffers.history.base 61440)
    (stateSeparate : MemoryRegions.Disjoint base (4*n) storage.buffers.recurrent.base 3145728) : Storage cache :=
  storage.reframe trace.memory (by
    intro offset bound
    unfold WordArrayWrites.Trace.memory
    rw [shared]
    exact MemoryRegions.execute32_other _ _ (ArrayFrame.word_stores_inside trace) historySeparate offset bound) (by
    intro offset bound
    unfold WordArrayWrites.Trace.memory
    rw [shared]
    exact MemoryRegions.execute32_other _ _ (ArrayFrame.word_stores_inside trace) stateSeparate offset bound)

theorem Storage.after32_memory (storage : Storage cache) (stores : List ByteMemory.Store)
    (inside : MemoryRegions.Inside32 base size stores)
    (historySeparate : MemoryRegions.Disjoint base size storage.buffers.history.base 61440)
    (stateSeparate : MemoryRegions.Disjoint base size storage.buffers.recurrent.base 3145728) :
    (storage.after32 stores inside historySeparate stateSeparate).memory=ByteMemory.execute stores storage.memory := rfl

theorem Storage.afterWords_memory (storage : Storage cache) {output : Fin n → BitVec 32}
    (trace : WordArrayWrites.Trace base output) (shared : trace.before=storage.memory)
    (historySeparate : MemoryRegions.Disjoint base (4*n) storage.buffers.history.base 61440)
    (stateSeparate : MemoryRegions.Disjoint base (4*n) storage.buffers.recurrent.base 3145728) :
    (storage.afterWords trace shared historySeparate stateSeparate).memory=trace.memory := rfl

end Inference.Models.Qwen.DeltaRegions
