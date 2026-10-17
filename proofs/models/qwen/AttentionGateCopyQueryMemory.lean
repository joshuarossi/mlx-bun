import models.qwen.AttentionGateCopyKvMemory
import contracts.mlx.Copy2DMemory

namespace Inference.Models.Qwen.AttentionGateCopyQueryMemory
open Contracts.Mlx
set_option maxRecDepth 10000
attribute [local irreducible] List.finRange Copy2D.labels Copy2DMemory.programs

variable {p : AttentionHeads.Projections} {input : Fin 5120 → ArrayStorage.BF}

def layout (projections : AttentionGateCopyKvMemory.Execution p input) (destination : Nat) : Copy2D.Layout :=
  ⟨projections.queryGateBuffer.base, 512, 1, 2*destination, 256⟩

theorem destination_bounds (projections : AttentionGateCopyKvMemory.Execution p input) (destination : Nat)
    (label : Copy2D.Label 24 256) :
    2*destination ≤ 2*(Copy2DMemory.operation (layout projections destination) label).destination ∧
    2*(Copy2DMemory.operation (layout projections destination) label).destination+2 ≤ 2*destination+12288 := by
  have := label.1.isLt
  have := label.2.isLt
  dsimp [Copy2DMemory.operation, layout, Copy2D.destination]
  omega

theorem source_bounds (projections : AttentionGateCopyKvMemory.Execution p input) (destination : Nat)
    (label : Copy2D.Label 24 256) :
    projections.queryGateBuffer.base ≤ 2*(Copy2DMemory.operation (layout projections destination) label).source ∧
    2*(Copy2DMemory.operation (layout projections destination) label).source+2 ≤ projections.queryGateBuffer.base+24576 := by
  have := label.1.isLt
  have := label.2.isLt
  have := projections.queryGateBuffer.aligned
  dsimp [Copy2DMemory.operation, layout, Copy2D.sourceAddress]
  omega

theorem no_alias (projections : AttentionGateCopyKvMemory.Execution p input) (destination : Nat)
    (separate : MemoryRegions.Disjoint (2*destination) 12288 projections.queryGateBuffer.base 24576) :
    CopyExecution.NoAlias (Copy2DMemory.programs (layout projections destination) 24 256).flatten := by
  apply CopyExecution.no_alias_regions _ (2*destination) 12288
  · intro operation present
    obtain ⟨label, rfl⟩ := Copy2DMemory.member _ operation present
    exact destination_bounds projections destination label
  · intro operation present
    obtain ⟨label, rfl⟩ := Copy2DMemory.member _ operation present
    exact ⟨_, _, (source_bounds projections destination label).1, (source_bounds projections destination label).2, separate⟩

structure Execution (projections : AttentionGateCopyKvMemory.Execution p input) where
  destination : Nat
  bounded : 2*destination+12288 ≤ 2^64
  separate : MemoryRegions.Disjoint (2*destination) 12288 projections.queryGateBuffer.base 24576
  copy : Copy2DMemory.Trace (layout projections destination) 24 256
  initial : copy.before=projections.memory
  gateSeparate : MemoryRegions.Disjoint (2*destination) 12288 projections.gateCopy.base 12288

variable {projections : AttentionGateCopyKvMemory.Execution p input}

def canonical (projections : AttentionGateCopyKvMemory.Execution p input) (destination : Nat)
    (bounded : 2*destination+12288 ≤ 2^64)
    (separate : MemoryRegions.Disjoint (2*destination) 12288 projections.queryGateBuffer.base 24576)
    (gateSeparate : MemoryRegions.Disjoint (2*destination) 12288 projections.gateCopy.base 12288) : Execution projections :=
  ⟨destination, bounded, separate, CopyExecution.Trace.canonical _ projections.memory, rfl,gateSeparate⟩

theorem Execution.read_correct (execution : Execution projections) (head : Fin 24) (i : Fin 256) :
    HalfMemory.load execution.copy.memory (2*execution.destination+2*(head.val*256+i.val))=
      ArrayStorage.bits ((p.forward input).query head i) := by
  have read := Copy2DMemory.read_correct (layout projections execution.destination) projections.queryGateBuffer.aligned
    (by dsimp [layout]; omega) (by change 256 ≤ 256; decide) execution.copy (no_alias projections execution.destination execution.separate) (head, i)
  rw [execution.initial] at read
  have address : Copy2D.sourceAddress (layout projections execution.destination) (head, i)=
      projections.queryGateBuffer.base+2*(AttentionHeads.queryIndex head i).val := by
    dsimp [Copy2D.sourceAddress, layout, AttentionHeads.queryIndex]
    omega
  rw [address] at read
  have attached := projections.queryGateBuffer.attached (AttentionHeads.queryIndex head i)
  simpa only [layout, Copy2D.destination, AttentionHeads.Projections.forward, Nat.add_comm] using read.trans attached

def Execution.query (execution : Execution projections) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).query head) where
  bytes := execution.copy.memory
  base := 2*execution.destination+2*(head.val*256)
  aligned := by omega
  bounded := by have := head.isLt; have := execution.bounded; omega
  attached := by
    intro i
    simpa only [Nat.mul_add, Nat.add_assoc] using execution.read_correct head i

theorem Execution.stores_inside (execution : Execution projections) :
    MemoryRegions.Inside16 (2*execution.destination) 12288
      (execution.copy.schedule.map (CopyExecution.store execution.copy.before)) := by
  intro write present
  obtain ⟨operation, member, rfl⟩ := List.mem_map.mp present
  have whole := (ThreadgroupWrites.completed_schedule execution.copy.execution execution.copy.completed).mem_iff.mp member
  obtain ⟨label, rfl⟩ := Copy2DMemory.member _ operation whole
  exact destination_bounds projections execution.destination label

theorem Execution.other_region (execution : Execution projections) {base size : Nat}
    (separate : MemoryRegions.Disjoint (2*execution.destination) 12288 base size) (offset : Nat) (bound : offset<size) :
    execution.copy.memory (base+offset)=projections.memory (base+offset) := by
  rw [execution.copy.memory_fixed (no_alias projections execution.destination execution.separate)]
  exact (MemoryRegions.execute16_other _ _ execution.stores_inside separate offset bound).trans (congrFun execution.initial _)

def Execution.gate (execution : Execution projections) (head : Fin 24) :
    ArrayStorage.BFBuffer ((p.forward input).gate head) :=
  ArrayFrame.bf (projections.gateBuffer head) execution.copy.memory (by
    intro offset bound
    have gateOffset : 2*(head.val*256)+offset<12288 := by have := head.isLt; omega
    have frame := execution.other_region execution.gateSeparate (2*(head.val*256)+offset) gateOffset
    simpa only [AttentionGateCopyKvMemory.Execution.gateBuffer,AttentionParsedGateReshape.gateBuffer,
      ArrayFrame.bf,Nat.add_assoc] using frame)

def Execution.keyBuffer (execution : Execution projections)
    (safe : MemoryRegions.Disjoint (2*execution.destination) 12288 projections.keyBuffer.base 2048) :
    ArrayStorage.BFBuffer (p.k.forward input) :=
  ArrayFrame.bf projections.keyBuffer execution.copy.memory (execution.other_region safe)

def Execution.valueBuffer (execution : Execution projections)
    (safe : MemoryRegions.Disjoint (2*execution.destination) 12288 projections.valueBuffer.base 2048) :
    ArrayStorage.BFBuffer (p.v.forward input) :=
  ArrayFrame.bf projections.valueBuffer execution.copy.memory (execution.other_region safe)

theorem Execution.parsed_programs (execution : Execution projections) :
    ∃ programs, Kernels.Attention.MlxAttentionGateCopyMemory.sourcePrograms
        projections.queryGateBuffer.base (2*execution.destination)=some programs ∧
      ThreadgroupWrites.Executes programs execution.copy.schedule execution.copy.remaining ∧
      ThreadgroupWrites.AtBarrier execution.copy.remaining ∧
      CopyExecution.execute execution.copy.schedule projections.memory=execution.copy.memory := by
  refine ⟨_,Kernels.Attention.MlxAttentionGateCopyMemory.source_programs _ _,execution.copy.execution,execution.copy.completed,?_⟩
  unfold CopyExecution.Trace.memory
  rw [execution.initial]

end Inference.Models.Qwen.AttentionGateCopyQueryMemory
