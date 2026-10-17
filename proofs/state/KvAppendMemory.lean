import state.KvCopy
import contracts.mlx.Copy2DMemory

namespace Inference.State.KvAppendMemory
open Contracts.Mlx KvBytes
set_option maxRecDepth 10000
attribute [local irreducible] Copy2DMemory.programs

def sourceBytes (source : KvCopy.Source next) : Nat := 2*(3*source.rowStride+255*source.columnStride+1)

theorem source_bounds (source : KvCopy.Source next) (base capacity n : Nat) (label : Copy2D.Label 4 256) :
    source.base ≤ Copy2D.sourceAddress (KvCopy.layout source base capacity n) label ∧
      Copy2D.sourceAddress (KvCopy.layout source base capacity n) label+2 ≤ source.base+sourceBytes source := by
  have head : label.1.val ≤ 3 := by have := label.1.isLt; omega
  have column : label.2.val ≤ 255 := by have := label.2.isLt; omega
  have hr := Nat.mul_le_mul_right source.rowStride head
  have hc := Nat.mul_le_mul_right source.columnStride column
  dsimp [Copy2D.sourceAddress, KvCopy.layout, sourceBytes]
  omega

def reframe (source : KvCopy.Source next) (after : ByteMemory.Bytes)
    (same : ∀ offset < sourceBytes source, after (source.base+offset)=source.bytes (source.base+offset)) : KvCopy.Source next where
  bytes := after
  base := source.base
  rowStride := source.rowStride
  columnStride := source.columnStride
  aligned := source.aligned
  attached := by
    intro head i
    have bound := source_bounds source 0 0 0 (head, i)
    dsimp [Copy2D.sourceAddress, KvCopy.layout] at bound
    rw [ArrayFrame.half_congr source.bytes after source.base (sourceBytes source)
      (2*(i.val*source.columnStride+head.val*source.rowStride)) same (by omega)]
    exact source.attached head i

theorem no_alias (source : KvCopy.Source next) (base capacity n : Nat) (aligned : base%2=0) (room : n<capacity)
    (separate : MemoryRegions.Disjoint base (2*(4*capacity*256)) source.base (sourceBytes source)) :
    CopyExecution.NoAlias (Copy2DMemory.programs (KvCopy.layout source base capacity n) 4 256).flatten := by
  apply CopyExecution.no_alias_regions _ base (2*(4*capacity*256))
  · intro op inside
    obtain ⟨label, rfl⟩ := Copy2DMemory.member _ op inside
    have address := KvCopy.destination_word source base capacity n label
    have bound := Kv.address_bounds capacity label.1 n label.2 room
    dsimp only [Copy2DMemory.operation]
    rw [address]
    omega
  · intro op inside
    obtain ⟨label, rfl⟩ := Copy2DMemory.member _ op inside
    have address := Copy2DMemory.source_aligned (KvCopy.layout source base capacity n) source.aligned label
    have bounds := source_bounds source base capacity n label
    refine ⟨source.base, sourceBytes source, ?_, ?_, separate⟩
    all_goals dsimp only [Copy2DMemory.operation]; omega

structure Execution (old : History n) (next : Row) where
  source : KvCopy.Source next
  base : Nat
  capacity : Nat
  aligned : base%2=0
  room : n<capacity
  separate : MemoryRegions.Disjoint base (2*(4*capacity*256)) source.base (sourceBytes source)
  copy : Copy2DMemory.Trace (KvCopy.layout source base capacity n) 4 256
  shared : copy.before=source.bytes
  attached : ∀ head time i, HalfMemory.load copy.before (base+2*Kv.address capacity head time.val i)=bits (old head time i)

variable {n : Nat} {old : History n} {next : Row}

def Execution.input (execution : Execution old next) : KvCopy.Source next where
  bytes := execution.copy.before
  base := execution.source.base
  rowStride := execution.source.rowStride
  columnStride := execution.source.columnStride
  aligned := execution.source.aligned
  attached := by intro head i; rw [execution.shared]; exact execution.source.attached head i

def Execution.toBytes (execution : Execution old next) : KvBytes.Trace old next :=
  KvCopy.fromCopy execution.input execution.base execution.capacity old execution.room execution.aligned
    (Copy2DMemory.toCopy _ execution.source.aligned (by dsimp [KvCopy.layout]; have := execution.aligned; omega)
      (by dsimp [KvCopy.layout]; have := execution.room; omega) execution.copy) execution.attached

theorem Execution.memory_equal (execution : Execution old next) : execution.copy.memory=execution.toBytes.memory :=
  execution.copy.memory_fixed (no_alias execution.source execution.base execution.capacity n execution.aligned execution.room execution.separate)

theorem Execution.load_correct (execution : Execution old next) (head : Fin 4) (time : Fin (n+1)) (i : Fin 256) :
    HalfMemory.load execution.copy.memory (execution.base+2*Kv.address execution.capacity head time.val i)=
      bits (Kv.appendRows (fun t => old head t i) (next head i) time) := by
  rw [execution.memory_equal]
  exact execution.toBytes.load_correct head time i

theorem Execution.stores_inside (execution : Execution old next) :
    MemoryRegions.Inside16 execution.base (2*(4*execution.capacity*256))
      (execution.copy.schedule.map (CopyExecution.store execution.copy.before)) := by
  intro write inside
  obtain ⟨op, opMember, rfl⟩ := List.mem_map.mp inside
  have original := (ThreadgroupWrites.completed_schedule execution.copy.execution execution.copy.completed).mem_iff.mp opMember
  obtain ⟨label, rfl⟩ := Copy2DMemory.member _ op original
  have address := KvCopy.destination_word execution.source execution.base execution.capacity n label
  have bound := Kv.address_bounds execution.capacity label.1 n label.2 execution.room
  dsimp only [CopyExecution.store, Copy2DMemory.operation]
  rw [address]
  have := execution.aligned
  omega

theorem Execution.other_region (execution : Execution old next) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.base (2*(4*execution.capacity*256)) base size)
    (offset : Nat) (bound : offset<size) :
    execution.copy.memory (base+offset)=execution.copy.before (base+offset) := by
  rw [execution.copy.memory_fixed (no_alias execution.source execution.base execution.capacity n
    execution.aligned execution.room execution.separate)]
  exact MemoryRegions.execute16_other _ _ execution.stores_inside separate offset bound

def Execution.canonical (old : History n) (next : Row) (source : KvCopy.Source next)
    (base capacity : Nat) (aligned : base%2=0) (room : n<capacity)
    (separate : MemoryRegions.Disjoint base (2*(4*capacity*256)) source.base (sourceBytes source))
    (attached : ∀ head time i, HalfMemory.load source.bytes (base+2*Kv.address capacity head time.val i)=bits (old head time i)) :
    Execution old next :=
  ⟨source, base, capacity, aligned, room, separate, CopyExecution.Trace.canonical _ source.bytes, rfl, attached⟩

end Inference.State.KvAppendMemory
