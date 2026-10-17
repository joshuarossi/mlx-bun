import kernels.attention.RopeDynamicMemory

namespace Inference.Kernels.Attention.RopeCopyMemory
open Contracts.Mlx
abbrev BF := ArrayStorage.BF

-- Partial RoPE uses copy_gpu even when the input itself is donatable.
-- This route covers a contiguous BF16 head copied to a disjoint allocation;
-- copy instruction loads read the evolving heap, not a frozen source view.
structure Copy (x : Fin 256 → BF) where
  source : ArrayStorage.BFBuffer x
  destination : Nat
  aligned : destination%2=0
  bounded : destination+512≤2^64
  trace : Copy2DMemory.Trace (RopeSharedMemory.copyLayout source.base destination) 1 256
  before : trace.before=source.bytes
  separate : CopyExecution.NoAlias
    (Copy2DMemory.programs (RopeSharedMemory.copyLayout source.base destination) 1 256).flatten

theorem copy_no_alias (source destination : Nat) (sourceAligned : source%2=0)
    (destinationAligned : destination%2=0) (separate : MemoryRegions.Disjoint source 512 destination 512) :
    CopyExecution.NoAlias (Copy2DMemory.programs (RopeSharedMemory.copyLayout source destination) 1 256).flatten := by
  apply Copy2DMemory.no_alias
  intro reader writer
  have rr := reader.1.isLt
  have rc := reader.2.isLt
  have wr := writer.1.isLt
  have wc := writer.2.isLt
  dsimp [Copy2D.sourceAddress, Copy2D.destination, RopeSharedMemory.copyLayout]
  rcases separate with h|h <;> omega

def Copy.canonical (source : ArrayStorage.BFBuffer x) (destination : Nat)
    (aligned : destination%2=0) (bounded : destination+512≤2^64)
    (separate : MemoryRegions.Disjoint source.base 512 destination 512) : Copy x where
  source := source
  destination := destination
  aligned := aligned
  bounded := bounded
  trace := CopyExecution.Trace.canonical
    (Copy2DMemory.programs (RopeSharedMemory.copyLayout source.base destination) 1 256) source.bytes
  before := rfl
  separate := copy_no_alias source.base destination source.aligned aligned separate

def Copy.buffer (copy : Copy x) : ArrayStorage.BFBuffer x :=
  RopeSharedMemory.copiedBuffer copy.source copy.destination copy.aligned copy.bounded copy.trace copy.before copy.separate

theorem Copy.buffer_memory (copy : Copy x) : copy.buffer.bytes=copy.trace.memory := rfl

theorem Copy.frame (copy : Copy x) (address : Nat)
    (outside : address<copy.destination ∨ copy.destination+512≤address) :
    copy.buffer.bytes address=copy.source.bytes address := by
  rw [copy.buffer_memory, copy.trace.memory_fixed copy.separate]
  rw [MemoryRegions.execute16_frame _ _ (base := copy.destination) (size := 512) ?_ outside, copy.before]
  intro store member
  obtain ⟨op, present, rfl⟩ := List.mem_map.mp member
  obtain ⟨label, rfl⟩ := Copy2DMemory.member _ op
    ((ThreadgroupWrites.completed_schedule copy.trace.execution copy.trace.completed).mem_iff.mp present)
  have row := label.1.isLt
  have column := label.2.isLt
  have aligned := copy.aligned
  dsimp [CopyExecution.store, Copy2DMemory.operation, RopeSharedMemory.copyLayout, Copy2D.destination]
  omega

structure Execution (p : Rope.Platform) (x : Fin 256 → BF) (theta : Fin 32 → Float32) where
  copy : Copy x
  rotation : RopeDynamicMemory.Execution p copy.buffer theta

def Execution.canonical (p : Rope.Platform) (source : ArrayStorage.BFBuffer x)
    (theta : Fin 32 → Float32) (destination : Nat) (aligned : destination%2=0)
    (bounded : destination+512≤2^64) (separate : MemoryRegions.Disjoint source.base 512 destination 512) :
    Execution p x theta :=
  let copy := Copy.canonical source destination aligned bounded separate
  ⟨copy, RopeDynamicMemory.Execution.canonical copy.buffer p theta⟩

theorem Execution.read (e : Execution p x theta) (i : Fin 256) :
    HalfMemory.load e.rotation.finish.memory (e.copy.destination+2*i.val)=ArrayStorage.bits (Rope.head p x theta i) :=
  e.rotation.read i

theorem Execution.output_eq (e : Execution p x theta) : e.rotation.buffer.read=Rope.head p x theta :=
  e.rotation.output_eq

theorem Execution.frame (e : Execution p x theta) (address : Nat)
    (outside : address<e.copy.destination ∨ e.copy.destination+512≤address) :
    e.rotation.finish.memory address=e.copy.source.bytes address := by
  apply (e.rotation.frame address ?_).trans (e.copy.frame address outside)
  change address<e.copy.destination ∨ e.copy.destination+128≤address
  omega

end Inference.Kernels.Attention.RopeCopyMemory
