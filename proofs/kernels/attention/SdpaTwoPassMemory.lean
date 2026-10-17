import kernels.attention.SdpaTwoPassBytes
import contracts.mlx.MemoryProjection
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.Attention.SdpaTwoPassMemory
open Contracts.Mlx SdpaTwoPassBytes SdpaTwoPassWrites SdpaTwoPassLayout
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000
attribute [local irreducible] SdpaTwoPassBytes.programs summaryPrograms partialPrograms

def write : Event → ByteMemory.Bytes → ByteMemory.Bytes
  | .sum store => MemoryProjection.wordWrite store
  | .maximum store => MemoryProjection.wordWrite store
  | .output store => MemoryProjection.halfWrite store

structure Layout (blocks : Nat) where
  sumBase : Nat
  maxBase : Nat
  outputBase : Nat
  sumAligned : sumBase%4=0
  maxAligned : maxBase%4=0
  outputAligned : outputBase%2=0
  sumBounded : sumBase+4*(24*blocks) ≤ 2^64
  maxBounded : maxBase+4*(24*blocks) ≤ 2^64
  outputBounded : outputBase+2*(24*blocks*256) ≤ 2^64
  sumMax : MemoryRegions.Disjoint sumBase (4*(24*blocks)) maxBase (4*(24*blocks))
  sumOutput : MemoryRegions.Disjoint sumBase (4*(24*blocks)) outputBase (2*(24*blocks*256))
  maxOutput : MemoryRegions.Disjoint maxBase (4*(24*blocks)) outputBase (2*(24*blocks*256))

variable {blocks : Nat} {sums maxima : Fin 24 → Fin blocks → Float32} {values : Fin 24 → Fin blocks → Fin 256 → SdpaTwoPassBytes.BF}

-- A single interleaved first-pass schedule writes all three allocations.
-- The old projected-buffer theorems are recovered from this shared heap.
structure Execution (sums maxima : Fin 24 → Fin blocks → Float32) (values : Fin 24 → Fin blocks → Fin 256 → SdpaTwoPassBytes.BF) where
  trace : SdpaTwoPassBytes.Trace sums maxima values
  maxShared : trace.maxBefore=trace.sumBefore
  outputShared : trace.outputBefore=trace.sumBefore
  sumMax : MemoryRegions.Disjoint trace.sumBase (4*(24*blocks)) trace.maxBase (4*(24*blocks))
  sumOutput : MemoryRegions.Disjoint trace.sumBase (4*(24*blocks)) trace.outputBase (2*(24*blocks*256))
  maxOutput : MemoryRegions.Disjoint trace.maxBase (4*(24*blocks)) trace.outputBase (2*(24*blocks*256))

def canonical (sums maxima : Fin 24 → Fin blocks → Float32) (values : Fin 24 → Fin blocks → Fin 256 → SdpaTwoPassBytes.BF)
    (layout : Layout blocks) (before : ByteMemory.Bytes) : Execution sums maxima values :=
  let programs := SdpaTwoPassBytes.programs layout.sumBase layout.maxBase layout.outputBase sums maxima values
  { trace := {
      sumBefore := before
      maxBefore := before
      outputBefore := before
      sumBase := layout.sumBase
      maxBase := layout.maxBase
      outputBase := layout.outputBase
      sumAligned := layout.sumAligned
      maxAligned := layout.maxAligned
      outputAligned := layout.outputAligned
      sumBounded := layout.sumBounded
      maxBounded := layout.maxBounded
      outputBounded := layout.outputBounded
      schedule := programs.flatten
      remaining := List.replicate programs.length []
      execution := ThreadgroupWrites.canonical programs
      completed := ThreadgroupWrites.canonical_barrier programs }
    maxShared := rfl
    outputShared := rfl
    sumMax := layout.sumMax
    sumOutput := layout.sumOutput
    maxOutput := layout.maxOutput }

def Execution.memory (execution : Execution sums maxima values) : ByteMemory.Bytes :=
  MemoryProjection.execute write execution.trace.schedule execution.trace.sumBefore

theorem sum_stores_inside (trace : SdpaTwoPassBytes.Trace sums maxima values) :
    MemoryRegions.Inside32 trace.sumBase (4*(24*blocks)) (trace.schedule.filterMap sumProject) := by
  have run := ThreadgroupWriteProjection.execution sumProject trace.execution
  rw [sum_programs] at run
  intro store member
  have original := (ThreadgroupWrites.completed_schedule run (ThreadgroupWriteProjection.completed sumProject _ trace.completed)).mem_iff.mp member
  obtain ⟨label, _, rfl⟩ := summary_member _ _ store original
  have bound := summary_bounds blocks label.1 label.2.1
  have aligned := trace.sumAligned
  dsimp only [summaryEntry]
  omega

theorem max_stores_inside (trace : SdpaTwoPassBytes.Trace sums maxima values) :
    MemoryRegions.Inside32 trace.maxBase (4*(24*blocks)) (trace.schedule.filterMap maxProject) := by
  have run := ThreadgroupWriteProjection.execution maxProject trace.execution
  rw [max_programs] at run
  intro store member
  have original := (ThreadgroupWrites.completed_schedule run (ThreadgroupWriteProjection.completed maxProject _ trace.completed)).mem_iff.mp member
  obtain ⟨label, _, rfl⟩ := summary_member _ _ store original
  have bound := summary_bounds blocks label.1 label.2.1
  have aligned := trace.maxAligned
  dsimp only [summaryEntry]
  omega

theorem output_stores_inside (trace : SdpaTwoPassBytes.Trace sums maxima values) :
    MemoryRegions.Inside16 trace.outputBase (2*(24*blocks*256)) (trace.schedule.filterMap outputProject) := by
  have run := ThreadgroupWriteProjection.execution outputProject trace.execution
  rw [output_programs] at run
  intro store member
  have original := (ThreadgroupWrites.completed_schedule run (ThreadgroupWriteProjection.completed outputProject _ trace.completed)).mem_iff.mp member
  obtain ⟨label, offset, rfl⟩ := partial_member _ _ store original
  have bound := partial_bounds blocks label.1 label.2.1 (SdpaLayout.coordinate label.2.2 offset)
  have aligned := trace.outputAligned
  dsimp only [partialEntry]
  omega

theorem Execution.sum_bytes (execution : Execution sums maxima values) (offset : Nat) (bound : offset<4*(24*blocks)) :
    execution.memory (execution.trace.sumBase+offset)=execution.trace.sumMemory (execution.trace.sumBase+offset) := by
  have projected := MemoryProjection.project_at write sumProject MemoryProjection.wordWrite execution.trace.schedule
    (execution.trace.sumBase+offset) (by
      intro event member first second same
      cases event with
      | sum store => exact MemoryProjection.word_congr store first second _ same
      | maximum store =>
        exact (MemoryProjection.word_misses store (max_stores_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.maximum store, member, rfl⟩))
          (MemoryRegions.disjoint_symm execution.sumMax) offset bound first).trans same
      | output store =>
        exact (MemoryProjection.half_misses store (output_stores_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.output store, member, rfl⟩))
          (MemoryRegions.disjoint_symm execution.sumOutput) offset bound first).trans same)
    execution.trace.sumBefore execution.trace.sumBefore rfl
  exact projected.trans (congrFun (MemoryProjection.words _ _) _)

theorem Execution.max_bytes (execution : Execution sums maxima values) (offset : Nat) (bound : offset<4*(24*blocks)) :
    execution.memory (execution.trace.maxBase+offset)=execution.trace.maxMemory (execution.trace.maxBase+offset) := by
  have projected := MemoryProjection.project_at write maxProject MemoryProjection.wordWrite execution.trace.schedule
    (execution.trace.maxBase+offset) (by
      intro event member first second same
      cases event with
      | sum store =>
        exact (MemoryProjection.word_misses store (sum_stores_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.sum store, member, rfl⟩)) execution.sumMax offset bound first).trans same
      | maximum store => exact MemoryProjection.word_congr store first second _ same
      | output store =>
        exact (MemoryProjection.half_misses store (output_stores_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.output store, member, rfl⟩))
          (MemoryRegions.disjoint_symm execution.maxOutput) offset bound first).trans same)
    execution.trace.sumBefore execution.trace.maxBefore (congrFun execution.maxShared _).symm
  exact projected.trans (congrFun (MemoryProjection.words _ _) _)

theorem Execution.output_bytes (execution : Execution sums maxima values) (offset : Nat) (bound : offset<2*(24*blocks*256)) :
    execution.memory (execution.trace.outputBase+offset)=execution.trace.outputMemory (execution.trace.outputBase+offset) := by
  have projected := MemoryProjection.project_at write outputProject MemoryProjection.halfWrite execution.trace.schedule
    (execution.trace.outputBase+offset) (by
      intro event member first second same
      cases event with
      | sum store =>
        exact (MemoryProjection.word_misses store (sum_stores_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.sum store, member, rfl⟩)) execution.sumOutput offset bound first).trans same
      | maximum store =>
        exact (MemoryProjection.word_misses store (max_stores_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.maximum store, member, rfl⟩)) execution.maxOutput offset bound first).trans same
      | output store => exact MemoryProjection.half_congr store first second _ same)
    execution.trace.sumBefore execution.trace.outputBefore (congrFun execution.outputShared _).symm
  exact projected.trans (congrFun (MemoryProjection.halves _ _) _)

def Execution.sumRead (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) : Float32 :=
  FloatMemory.decode (ByteMemory.load32 execution.memory (execution.trace.sumBase+4*summaryAddress blocks head block))
def Execution.maxRead (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) : Float32 :=
  FloatMemory.decode (ByteMemory.load32 execution.memory (execution.trace.maxBase+4*summaryAddress blocks head block))
def Execution.outputRead (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) (i : Fin 256) : SdpaTwoPassBytes.BF :=
  Model.ofBits (HalfMemory.load execution.memory (execution.trace.outputBase+2*partialAddress blocks head block i))

theorem Execution.sum_correct (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) :
    execution.sumRead head block=sums head block := by
  unfold Execution.sumRead
  rw [ArrayFrame.word_congr execution.trace.sumMemory execution.memory execution.trace.sumBase (4*(24*blocks))
    _ execution.sum_bytes (by have := summary_bounds blocks head block; omega)]
  exact execution.trace.sum_correct head block

theorem Execution.max_correct (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) :
    execution.maxRead head block=maxima head block := by
  unfold Execution.maxRead
  rw [ArrayFrame.word_congr execution.trace.maxMemory execution.memory execution.trace.maxBase (4*(24*blocks))
    _ execution.max_bytes (by have := summary_bounds blocks head block; omega)]
  exact execution.trace.max_correct head block

theorem Execution.output_correct (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    execution.outputRead head block i=values head block i := by
  unfold Execution.outputRead
  rw [ArrayFrame.half_congr execution.trace.outputMemory execution.memory execution.trace.outputBase (2*(24*blocks*256))
    _ execution.output_bytes (by have := partial_bounds blocks head block i; omega)]
  exact execution.trace.output_correct head block i

def Execution.readState (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) (i : Fin 256) : SdpaUpdate.State :=
  ⟨execution.maxRead head block, execution.sumRead head block, BFloat16.widen (execution.outputRead head block i)⟩

theorem Execution.readState_projected (execution : Execution sums maxima values) (head : Fin 24) (block : Fin blocks) (i : Fin 256) :
    execution.readState head block i=execution.trace.readState head block i := by
  unfold Execution.readState SdpaTwoPassBytes.Trace.readState
  rw [execution.sum_correct, execution.max_correct, execution.output_correct,
    execution.trace.sum_correct, execution.trace.max_correct, execution.trace.output_correct]

theorem Execution.other_region (execution : Execution sums maxima values) {base size : Nat}
    (sumSeparate : MemoryRegions.Disjoint execution.trace.sumBase (4*(24*blocks)) base size)
    (maxSeparate : MemoryRegions.Disjoint execution.trace.maxBase (4*(24*blocks)) base size)
    (outputSeparate : MemoryRegions.Disjoint execution.trace.outputBase (2*(24*blocks*256)) base size)
    (offset : Nat) (bound : offset<size) : execution.memory (base+offset)=execution.trace.sumBefore (base+offset) := by
  apply MemoryProjection.frame
  intro event member memory
  cases event with
  | sum store => exact MemoryProjection.word_misses store (sum_stores_inside execution.trace store
      (List.mem_filterMap.mpr ⟨.sum store, member, rfl⟩)) sumSeparate offset bound memory
  | maximum store => exact MemoryProjection.word_misses store (max_stores_inside execution.trace store
      (List.mem_filterMap.mpr ⟨.maximum store, member, rfl⟩)) maxSeparate offset bound memory
  | output store => exact MemoryProjection.half_misses store (output_stores_inside execution.trace store
      (List.mem_filterMap.mpr ⟨.output store, member, rfl⟩)) outputSeparate offset bound memory

end Inference.Kernels.Attention.SdpaTwoPassMemory
