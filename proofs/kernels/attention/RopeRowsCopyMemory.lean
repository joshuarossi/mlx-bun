import kernels.attention.RopeRowsDynamicMemory

namespace Inference.Kernels.Attention.RopeRowsCopyMemory
open Contracts.Mlx
open RopeRowsMemory
abbrev BF := ArrayStorage.BF
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
variable {rows base : Nat} {x : Fin rows → Fin 256 → BF}

def layout (source destination : Nat) : Copy2D.Layout := ⟨source,256,1,destination,256⟩

theorem no_alias (source destination : Nat) (sourceAligned : source%2=0) (destinationAligned : destination%2=0)
    (separate : MemoryRegions.Disjoint source (512*rows) destination (512*rows)) :
    CopyExecution.NoAlias (Copy2DMemory.programs (layout source destination) rows 256).flatten := by
  apply Copy2DMemory.no_alias
  intro reader writer
  have rr := reader.1.isLt
  have rc := reader.2.isLt
  have wr := writer.1.isLt
  have wc := writer.2.isLt
  dsimp [Copy2D.sourceAddress,Copy2D.destination,layout]
  rcases separate with h|h <;> omega

structure Copy (source : Input x base) where
  destination : Nat
  aligned : destination%2=0
  bounded : destination+512*rows≤2^64
  trace : Copy2DMemory.Trace (layout base destination) rows 256
  before : trace.before=source.memory
  separate : CopyExecution.NoAlias (Copy2DMemory.programs (layout base destination) rows 256).flatten

variable {source : Input x base}

def Copy.output (copy : Copy source) : Input x copy.destination where
  memory := copy.trace.memory
  aligned := copy.aligned
  bounded := copy.bounded
  attached := by
    intro head i
    have result := Copy2DMemory.read_correct (layout base copy.destination) source.aligned copy.aligned
      (by simp [layout]) copy.trace copy.separate (head,i)
    simp only [layout,Copy2D.destination,Copy2D.sourceAddress,Nat.mul_one] at result
    rw [show copy.destination+2*(i.val+head.val*256)=copy.destination+512*head.val+2*i.val by omega,
      show base+2*(i.val+head.val*256)=base+512*head.val+2*i.val by omega,copy.before] at result
    exact result.trans (source.attached head i)

def Copy.canonical (source : Input x base) (destination : Nat) (aligned : destination%2=0)
    (bounded : destination+512*rows≤2^64)
    (separate : MemoryRegions.Disjoint base (512*rows) destination (512*rows)) : Copy source where
  destination := destination
  aligned := aligned
  bounded := bounded
  trace := CopyExecution.Trace.canonical (Copy2DMemory.programs (layout base destination) rows 256) source.memory
  before := rfl
  separate := no_alias base destination source.aligned aligned separate

theorem Copy.frame (copy : Copy source) (address : Nat)
    (outside : address<copy.destination ∨ copy.destination+512*rows≤address) :
    copy.output.memory address=source.memory address := by
  change copy.trace.memory address=source.memory address
  rw [copy.trace.memory_fixed copy.separate]
  rw [MemoryRegions.execute16_frame _ _ (base := copy.destination) (size := 512*rows) ?_ outside,copy.before]
  intro store member
  obtain ⟨op,present,rfl⟩ := List.mem_map.mp member
  obtain ⟨label,rfl⟩ := Copy2DMemory.member _ op
    ((ThreadgroupWrites.completed_schedule copy.trace.execution copy.trace.completed).mem_iff.mp present)
  have row := label.1.isLt
  have column := label.2.isLt
  have aligned := copy.aligned
  dsimp [CopyExecution.store,Copy2DMemory.operation,layout,Copy2D.destination]
  omega

structure Execution (p : Rope.Platform) (source : Input x base) (theta : Fin rows → Fin 32 → Float32) where
  copy : Copy source
  rotation : RopeRowsDynamicMemory.Execution p copy.output theta

variable {p : Rope.Platform} {theta : Fin rows → Fin 32 → Float32}

def Execution.canonical (p : Rope.Platform) (source : Input x base)
    (theta : Fin rows → Fin 32 → Float32) (destination : Nat) (aligned : destination%2=0)
    (bounded : destination+512*rows≤2^64)
    (separate : MemoryRegions.Disjoint base (512*rows) destination (512*rows)) : Execution p source theta :=
  let copy := Copy.canonical source destination aligned bounded separate
  ⟨copy,RopeRowsDynamicMemory.Execution.canonical p copy.output theta⟩

def Execution.output (execution : Execution p source theta) :
    Input (fun head => Rope.head p (x head) (theta head)) execution.copy.destination := execution.rotation.output

theorem Execution.frame (execution : Execution p source theta) (address : Nat)
    (outside : address<execution.copy.destination ∨ execution.copy.destination+512*rows≤address) :
    execution.output.memory address=source.memory address :=
  (execution.rotation.frame address outside).trans (execution.copy.frame address outside)

end Inference.Kernels.Attention.RopeRowsCopyMemory
