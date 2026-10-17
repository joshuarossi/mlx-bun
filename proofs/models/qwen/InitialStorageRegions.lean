import models.qwen.InitialStorage
import contracts.mlx.MemoryRegions

namespace Inference.Models.Qwen.InitialStorageRegions
open Contracts.Mlx Kernels.Delta
set_option maxRecDepth 10000

-- The allocator supplies two aligned, addressable, disjoint regions.
-- Both returned buffers refer to the same final global memory image.
structure Layout where
  historyBase : Nat
  recurrentBase : Nat
  historyAligned : historyBase%2=0
  recurrentAligned : recurrentBase%4=0
  historyBound : historyBase+61440 ≤ 2^64
  recurrentBound : recurrentBase+3145728 ≤ 2^64
  separate : MemoryRegions.Disjoint historyBase 61440 recurrentBase 3145728

def Layout.contiguous (base : Nat) (aligned : base%4=0) (bounded : base+3207168 ≤ 2^64) : Layout where
  historyBase := base
  recurrentBase := base+61440
  historyAligned := by clear bounded; omega
  recurrentAligned := by clear bounded; omega
  historyBound := (Nat.add_le_add_left (by decide : 61440 ≤ 3207168) base).trans bounded
  recurrentBound := by simpa only [Nat.add_assoc] using bounded
  separate := Or.inl (Nat.le_refl _)

variable (trace : InitialStorage.DeltaTrace) (layout : Layout)

theorem history_inside : MemoryRegions.Inside16 0 61440 trace.history.schedule := by
  intro store member
  have original := (ThreadgroupWrites.completed_schedule trace.history.execution trace.history.completed).mem_iff.mp member
  obtain ⟨i, rfl⟩ := HalfArrayWrites.member _ _ store original
  have := i.isLt
  dsimp only [HalfArrayWrites.entry]
  omega

theorem recurrent_inside : MemoryRegions.Inside32 0 3145728 trace.recurrent.schedule := by
  intro store member
  have original := (ThreadgroupWrites.completed_schedule trace.recurrent.execution trace.recurrent.completed).mem_iff.mp member
  obtain ⟨thread, offset, rfl⟩ := CopyFloatContiguous.member _ _ store original
  have := (CopyFloatContiguous.index thread offset).isLt
  dsimp only [CopyFloatContiguous.entry]
  omega

def historyStores := trace.history.schedule.map (MemoryRegions.shift16 layout.historyBase)
def recurrentStores := trace.recurrent.schedule.map (MemoryRegions.shift32 layout.recurrentBase)

theorem shifted_history_inside : MemoryRegions.Inside16 layout.historyBase 61440 (historyStores trace layout) :=
  MemoryRegions.shift16_inside _ (history_inside trace) _ layout.historyAligned
theorem shifted_recurrent_inside : MemoryRegions.Inside32 layout.recurrentBase 3145728 (recurrentStores trace layout) :=
  MemoryRegions.shift32_inside _ (recurrent_inside trace) _ layout.recurrentAligned

def afterHistory (before : ByteMemory.Bytes) : ByteMemory.Bytes := HalfMemory.execute (historyStores trace layout) before
def memory (before : ByteMemory.Bytes) : ByteMemory.Bytes := ByteMemory.execute (recurrentStores trace layout) (afterHistory trace layout before)

theorem local_history (before : HalfMemory.Bytes) (i : Fin 30720) :
    HalfMemory.load (HalfMemory.execute trace.history.schedule before) (2*i.val)=ArrayStorage.bits (InitialStorage.historyZero 0) :=
  InitialStorage.DeltaTrace.history_read { trace with history := { trace.history with before := before } } i

theorem local_recurrent (before : ByteMemory.Bytes) (i : Fin 786432) :
    FloatMemory.load (ByteMemory.execute trace.recurrent.schedule before) (4*i.val)=0 :=
  InitialStorage.DeltaTrace.recurrent_read { trace with recurrent := { trace.recurrent with before := before } } i

theorem after_history_read (before : ByteMemory.Bytes) (i : Fin 30720) :
    HalfMemory.load (afterHistory trace layout before) (layout.historyBase+2*i.val)=ArrayStorage.bits (InitialStorage.historyZero 0) := by
  rw [← MemoryRegions.load16_view]
  unfold afterHistory historyStores
  rw [MemoryRegions.execute16_view _ _ _ layout.historyAligned]
  exact local_history trace _ i

theorem history_byte_preserved (before : ByteMemory.Bytes) (offset : Nat) (bound : offset<61440) :
    memory trace layout before (layout.historyBase+offset)=afterHistory trace layout before (layout.historyBase+offset) :=
  MemoryRegions.execute32_other _ _ (shifted_recurrent_inside trace layout)
    (MemoryRegions.disjoint_symm layout.separate) offset bound

theorem history_read (before : ByteMemory.Bytes) (i : Fin 30720) :
    HalfMemory.load (memory trace layout before) (layout.historyBase+2*i.val)=ArrayStorage.bits (InitialStorage.historyZero 0) := by
  calc
    _ = HalfMemory.load (afterHistory trace layout before) (layout.historyBase+2*i.val) := by
      unfold HalfMemory.load
      rw [Nat.add_assoc, history_byte_preserved trace layout before _ (by have := i.isLt; omega),
        Nat.add_assoc, history_byte_preserved trace layout before _ (by have := i.isLt; omega)]
    _ = _ := after_history_read trace layout before i

theorem recurrent_read (before : ByteMemory.Bytes) (i : Fin 786432) :
    FloatMemory.load (memory trace layout before) (layout.recurrentBase+4*i.val)=0 := by
  unfold FloatMemory.load
  rw [← MemoryRegions.load32_view]
  unfold memory recurrentStores
  rw [MemoryRegions.execute32_view _ _ _ layout.recurrentAligned]
  exact local_recurrent trace _ i

def storage (before : ByteMemory.Bytes) : DeltaDevice.Storage InitialState.delta where
  history := {
    bytes := memory trace layout before
    base := layout.historyBase
    aligned := layout.historyAligned
    bounded := layout.historyBound
    attached := by
      intro i
      simpa only [State.ConvolutionStorage.flatten, InitialState.delta, InitialStorage.historyZero] using history_read trace layout before i }
  recurrent := {
    bytes := memory trace layout before
    base := layout.recurrentBase
    aligned := layout.recurrentAligned
    bounded := layout.recurrentBound
    attached := by
      intro head row key
      let i : Fin 786432 := ⟨GatedStores.stateIndex head row key, by
        have := head.isLt; have := row.isLt; have := key.isLt
        dsimp [GatedStores.stateIndex]
        omega⟩
      simpa only [i, InitialState.delta] using recurrent_read trace layout before i }

theorem shared_memory (before : ByteMemory.Bytes) :
    (storage trace layout before).history.bytes=(storage trace layout before).recurrent.bytes := rfl

theorem history_pointer (before : ByteMemory.Bytes) : (storage trace layout before).history.base=layout.historyBase := rfl
theorem recurrent_pointer (before : ByteMemory.Bytes) : (storage trace layout before).recurrent.base=layout.recurrentBase := rfl

end Inference.Models.Qwen.InitialStorageRegions
