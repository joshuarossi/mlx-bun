import kernels.attention.MlxAttentionGateCopySyntax
import kernels.attention.OutputGateDevice
import contracts.mlx.ArrayViews
import contracts.mlx.MemoryRegions

namespace Inference.Kernels.Attention.MlxAttentionGateCopyMemory
open Contracts.Mlx MlxAttentionGateCopySyntax
set_option maxRecDepth 10000
set_option maxHeartbeats 20000
attribute [local irreducible] List.finRange Copy2D.labels

def index (flat : Fin 6144) : Fin 12288 :=
  ⟨(flat.val/256)*512+256+flat.val%256,by have := flat.isLt; omega⟩

def values (queryGate : Fin 12288 → ArrayStorage.BF) : Fin 6144 → ArrayStorage.BF := fun i => queryGate (index i)

structure Execution (queryGate : Fin 12288 → ArrayStorage.BF) where
  source : ArrayStorage.BFBuffer queryGate
  base : Nat
  aligned : base%2=0
  bounded : base+12288≤2^64
  trace : Copy2DMemory.Trace (layout (source.base+512) base) 24 256
  initial : trace.before=source.bytes
  independent : CopyExecution.NoAlias (Copy2DMemory.programs (layout (source.base+512) base) 24 256).flatten

variable {queryGate : Fin 12288 → ArrayStorage.BF}

theorem no_alias (source : ArrayStorage.BFBuffer queryGate) (base : Nat) (aligned : base%2=0)
    (separate : MemoryRegions.Disjoint source.base 24576 base 12288) :
    CopyExecution.NoAlias (Copy2DMemory.programs (layout (source.base+512) base) 24 256).flatten := by
  apply Copy2DMemory.no_alias
  intro reader writer same
  have a := reader.1.isLt
  have b := reader.2.isLt
  have c := writer.1.isLt
  have d := writer.2.isLt
  have sourceAligned := source.aligned
  dsimp [layout,Copy2D.sourceAddress,Copy2D.destination] at same
  rcases separate with left|right <;> omega

def canonical (source : ArrayStorage.BFBuffer queryGate) (base : Nat) (aligned : base%2=0)
    (bounded : base+12288≤2^64) (separate : MemoryRegions.Disjoint source.base 24576 base 12288) : Execution queryGate :=
  ⟨source,base,aligned,bounded,CopyExecution.Trace.canonical _ source.bytes,rfl,no_alias source base aligned separate⟩

theorem read (execution : Execution queryGate) (flat : Fin 6144) :
    HalfMemory.load execution.trace.memory (execution.base+2*flat.val)=ArrayStorage.bits (values queryGate flat) := by
  let label : Label := (OutputGateDevice.headOf flat,OutputGateDevice.coordinate flat)
  have srcAligned : (execution.source.base+512)%2=0 := by have := execution.source.aligned; omega
  have copied := Copy2DMemory.read_correct (layout (execution.source.base+512) execution.base)
    srcAligned execution.aligned (Nat.le_refl 256) execution.trace execution.independent label
  have destination : Copy2D.destination (layout (execution.source.base+512) execution.base).destinationRow label=flat.val := by
    dsimp [Copy2D.destination,layout,label,OutputGateDevice.headOf,OutputGateDevice.coordinate]
    omega
  have source : Copy2D.sourceAddress (layout (execution.source.base+512) execution.base) label=
      execution.source.base+2*(index flat).val := by
    dsimp [Copy2D.sourceAddress,layout,label,OutputGateDevice.headOf,OutputGateDevice.coordinate,index]
    omega
  rw [destination,source,execution.initial] at copied
  exact copied.trans (execution.source.attached (index flat))

def buffer (execution : Execution queryGate) : ArrayStorage.BFBuffer (values queryGate) where
  bytes := execution.trace.memory
  base := execution.base
  aligned := execution.aligned
  bounded := execution.bounded
  attached := read execution

def headBuffer (execution : Execution queryGate) (head : Fin 24) :
    ArrayStorage.BFBuffer (fun i : Fin 256 => values queryGate ⟨head.val*256+i.val,by have := head.isLt; have := i.isLt; omega⟩) :=
  ArrayViews.slice (buffer execution) (head.val*256) 256 (by have := head.isLt; omega)

theorem head_layout (execution : Execution queryGate) (head : Fin 24) :
    (headBuffer execution head).base=execution.base+2*(head.val*256) := rfl

theorem parsed_operation (execution : Execution queryGate) (label : Label) :
    (parse sourceBody).bind (fun code => operation code (execution.source.base+512) execution.base label)=
      some (Copy2DMemory.operation (layout (execution.source.base+512) execution.base) label) := by
  rw [parsed]
  exact operation_eq _ _ label

def programs (_ : Program) (sourceBase destinationBase : Nat) (labels : List Label) : List (List CopyExecution.Operation) :=
  labels.map (fun label => [⟨(sourceBase+2*(label.1.val*512+label.2.val))/2,
    destinationBase/2+(label.1.val*256+label.2.val)⟩])

def sourcePrograms (sourceBase destinationBase : Nat) : Option (List (List CopyExecution.Operation)) := do
  let code ←parse sourceBody
  pure (programs code sourceBase destinationBase (Copy2D.labels 24 256))

private theorem programs_map (sourceBase destinationBase : Nat) (labels : List Label) :
    programs .general2D sourceBase destinationBase labels=
      labels.map (fun label => [Copy2DMemory.operation (layout sourceBase destinationBase) label]) := by
  unfold programs
  apply congrArg (List.map · labels)
  funext label
  simp [Copy2DMemory.operation,layout,Copy2D.sourceAddress,Copy2D.destination,Nat.add_comm]

theorem source_programs (sourceBase destinationBase : Nat) :
    sourcePrograms sourceBase destinationBase=some (Copy2DMemory.programs (layout sourceBase destinationBase) 24 256) := by
  unfold sourcePrograms
  rw [parsed]
  change some (programs .general2D sourceBase destinationBase (Copy2D.labels 24 256))=_
  apply congrArg some
  exact programs_map sourceBase destinationBase (Copy2D.labels 24 256)

theorem checked (execution : Execution queryGate) :
    ∃ programs, sourcePrograms (execution.source.base+512) execution.base=some programs ∧
      ThreadgroupWrites.Executes programs execution.trace.schedule execution.trace.remaining ∧
      ThreadgroupWrites.AtBarrier execution.trace.remaining ∧
      CopyExecution.execute execution.trace.schedule execution.source.bytes=execution.trace.memory := by
  refine ⟨_,source_programs _ _,execution.trace.execution,execution.trace.completed,?_⟩
  unfold CopyExecution.Trace.memory
  rw [execution.initial]

theorem other_region (execution : Execution queryGate) {base size : Nat}
    (separate : MemoryRegions.Disjoint execution.base 12288 base size) (offset : Nat) (bound : offset<size) :
    execution.trace.memory (base+offset)=execution.source.bytes (base+offset) := by
  have inside : MemoryRegions.Inside16 execution.base 12288
      (execution.trace.schedule.map (CopyExecution.store execution.trace.before)) := by
    intro store member
    obtain ⟨op,present,rfl⟩ := List.mem_map.mp member
    have contained := (ThreadgroupWrites.completed_schedule execution.trace.execution execution.trace.completed).mem_iff.mp present
    obtain ⟨label,rfl⟩ := Copy2DMemory.member _ op contained
    have head := label.1.isLt
    have i := label.2.isLt
    have aligned := execution.aligned
    dsimp only [CopyExecution.store,Copy2DMemory.operation,layout,Copy2D.destination]
    omega
  rw [execution.trace.memory_fixed execution.independent]
  exact (MemoryRegions.execute16_other _ _ inside separate offset bound).trans (congrFun execution.initial _)

end Inference.Kernels.Attention.MlxAttentionGateCopyMemory
