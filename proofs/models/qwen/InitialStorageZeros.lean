import models.qwen.InitialStorageRegions

namespace Inference.Models.Qwen.InitialStorageZeros
open Contracts.Mlx InitialStorageRegions
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

private theorem zero_half : ArrayStorage.bits (InitialStorage.historyZero 0)=0 := by decide +kernel
private theorem zero_word : FloatMemory.bits (0 : Float32)=0 := by decide +kernel

private theorem half_preserves_zero (stores : List HalfMemory.Store) (before : HalfMemory.Bytes)
    (zero : ∀ store ∈ stores, store.value=0) (address : Nat) (already : before address=0) :
    HalfMemory.execute stores before address=0 := by
  induction stores generalizing before with
  | nil => exact already
  | cons store rest ih =>
    apply ih _ (fun s h => zero s (List.mem_cons_of_mem _ h))
    simp [HalfMemory.store, zero store List.mem_cons_self, HalfMemory.byte, already]

private theorem word_preserves_zero (stores : List ByteMemory.Store) (before : ByteMemory.Bytes)
    (zero : ∀ store ∈ stores, store.value=0) (address : Nat) (already : before address=0) :
    ByteMemory.execute stores before address=0 := by
  induction stores generalizing before with
  | nil => exact already
  | cons store rest ih =>
    apply ih _ (fun s h => zero s (List.mem_cons_of_mem _ h))
    simp [ByteMemory.store32, zero store List.mem_cons_self, ByteMemory.byte, already]

variable (trace : InitialStorage.DeltaTrace) (layout : Layout)

theorem history_stores_zero (store : HalfMemory.Store) (member : store ∈ historyStores trace layout) : store.value=0 := by
  obtain ⟨original, originalMember, rfl⟩ := List.mem_map.mp member
  have included := (ThreadgroupWrites.completed_schedule trace.history.execution trace.history.completed).mem_iff.mp originalMember
  obtain ⟨i, rfl⟩ := HalfArrayWrites.member _ _ original included
  have source := trace.historyScalar.attached (0 : Fin 1)
  rw [zero_half] at source
  simpa only [MemoryRegions.shift16, HalfArrayWrites.entry, Fin.val_zero, Nat.mul_zero, Nat.add_zero] using source

theorem recurrent_stores_zero (store : ByteMemory.Store) (member : store ∈ recurrentStores trace layout) : store.value=0 := by
  obtain ⟨original, originalMember, rfl⟩ := List.mem_map.mp member
  have included := (ThreadgroupWrites.completed_schedule trace.recurrent.execution trace.recurrent.completed).mem_iff.mp originalMember
  obtain ⟨thread, offset, rfl⟩ := CopyFloatContiguous.member _ _ original included
  have source := trace.recurrentScalar.attached (0 : Fin 1)
  have equal : FloatMemory.load trace.recurrentScalar.bytes trace.recurrentScalar.base=0 := by
    simpa only [Fin.val_zero, Nat.mul_zero, Nat.add_zero, InitialStorage.recurrentZero] using source
  change FloatMemory.bits (FloatMemory.load trace.recurrentScalar.bytes trace.recurrentScalar.base)=0
  rw [equal, zero_word]

theorem preserves_zero (before : ByteMemory.Bytes) (address : Nat) (already : before address=0) :
    memory trace layout before address=0 :=
  word_preserves_zero _ _ (recurrent_stores_zero trace layout) address
    (half_preserves_zero _ before (history_stores_zero trace layout) address already)

theorem history_byte (before : ByteMemory.Bytes) (offset : Nat) (bound : offset<61440) :
    memory trace layout before (layout.historyBase+offset)=0 := by
  let i : Fin 30720 := ⟨offset/2, by omega⟩
  have read := congrArg (fun word => HalfMemory.byte word (offset%2)) (history_read trace layout before i)
  rw [HalfMemory.byte_load _ _ _ (by omega)] at read
  have address : layout.historyBase+2*i.val+offset%2=layout.historyBase+offset := by dsimp [i]; omega
  rw [address] at read
  simpa [zero_half, HalfMemory.byte] using read

theorem recurrent_raw (before : ByteMemory.Bytes) (i : Fin 786432) :
    ByteMemory.load32 (memory trace layout before) (layout.recurrentBase+4*i.val)=0 := by
  rw [← MemoryRegions.load32_view]
  unfold memory recurrentStores
  rw [MemoryRegions.execute32_view _ _ _ layout.recurrentAligned]
  let changed : CopyFloatContiguous.Trace 0 (fun _ : Fin (2*393216) =>
      FloatMemory.load trace.recurrentScalar.bytes trace.recurrentScalar.base) :=
    { trace.recurrent with before := MemoryRegions.view (afterHistory trace layout before) layout.recurrentBase }
  have read := changed.raw_read i
  have source := trace.recurrentScalar.attached (0 : Fin 1)
  have equal : FloatMemory.load trace.recurrentScalar.bytes trace.recurrentScalar.base=0 := by
    simpa only [Fin.val_zero, Nat.mul_zero, Nat.add_zero, InitialStorage.recurrentZero] using source
  simpa only [Nat.zero_add, changed, CopyFloatContiguous.Trace.memory] using
    read.trans ((congrArg FloatMemory.bits equal).trans zero_word)

theorem recurrent_byte (before : ByteMemory.Bytes) (offset : Nat) (bound : offset<3145728) :
    memory trace layout before (layout.recurrentBase+offset)=0 := by
  let i : Fin 786432 := ⟨offset/4, by omega⟩
  have read := congrArg (fun word => ByteMemory.byte word (offset%4)) (recurrent_raw trace layout before i)
  rw [ByteMemory.byte_load32 _ _ _ (by omega)] at read
  have address : layout.recurrentBase+4*i.val+offset%4=layout.recurrentBase+offset := by dsimp [i]; omega
  rw [address] at read
  simpa [ByteMemory.byte] using read

end Inference.Models.Qwen.InitialStorageZeros
