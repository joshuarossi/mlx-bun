import kernels.delta.GatedDevice
import contracts.mlx.MemoryProjection
import contracts.mlx.ArrayFrame

namespace Inference.Kernels.Delta.GatedMemory
open Contracts.Mlx GatedBytes GatedStores
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
set_option maxRecDepth 10000

def write : Event → ByteMemory.Bytes → ByteMemory.Bytes
  | .state store => MemoryProjection.wordWrite store
  | .output store => MemoryProjection.halfWrite store

structure Execution (state : GatedDevice.State) (output : Fin 48 → Fin 128 → GatedBytes.BF) where
  trace : GatedBytes.Trace state output
  shared : trace.outputBefore=trace.stateBefore
  separate : MemoryRegions.Disjoint trace.stateBase 3145728 trace.outputBase 12288

def canonical (state : GatedDevice.State) (output : Fin 48 → Fin 128 → GatedBytes.BF) (before : ByteMemory.Bytes)
    (stateBase outputBase : Nat) (stateAligned : stateBase%4=0) (outputAligned : outputBase%2=0)
    (stateBound : stateBase+3145728 ≤ 2^64) (outputBound : outputBase+12288 ≤ 2^64)
    (separate : MemoryRegions.Disjoint stateBase 3145728 outputBase 12288) : Execution state output :=
  let programs := GatedBytes.programs stateBase outputBase state output
  ⟨⟨before, before, stateBase, outputBase, stateAligned, outputAligned, stateBound, outputBound,
    programs.flatten, List.replicate programs.length [], ThreadgroupWrites.canonical programs, ThreadgroupWrites.canonical_barrier programs⟩,
    rfl, separate⟩

variable {state : GatedDevice.State} {output : Fin 48 → Fin 128 → GatedBytes.BF}

def Execution.memory (execution : Execution state output) : ByteMemory.Bytes :=
  MemoryProjection.execute write execution.trace.schedule execution.trace.stateBefore

theorem state_inside (trace : GatedBytes.Trace state output) :
    MemoryRegions.Inside32 trace.stateBase 3145728 (trace.schedule.filterMap stateProject) := by
  have run := ThreadgroupWriteProjection.execution stateProject trace.execution
  rw [GatedBytes.state_programs] at run
  intro store member
  have original := (ThreadgroupWrites.completed_schedule run (ThreadgroupWriteProjection.completed stateProject _ trace.completed)).mem_iff.mp member
  obtain ⟨label, offset, rfl⟩ := state_member _ _ store original
  have bound := GatedStores.state_bounds label.1 label.2.1 (Gated.laneIndex label.2.2 offset)
  have aligned := trace.stateAligned
  dsimp only [stateEntry]
  omega

theorem output_inside (trace : GatedBytes.Trace state output) :
    MemoryRegions.Inside16 trace.outputBase 12288 (trace.schedule.filterMap outputProject) := by
  have run := ThreadgroupWriteProjection.execution outputProject trace.execution
  rw [GatedBytes.output_programs] at run
  intro store member
  have original := (ThreadgroupWrites.completed_schedule run (ThreadgroupWriteProjection.completed outputProject _ trace.completed)).mem_iff.mp member
  obtain ⟨label, rfl, _⟩ := output_member _ _ store original
  have bound := GatedStores.output_bounds label.1 label.2.1
  have aligned := trace.outputAligned
  dsimp only [outputEntry]
  omega

theorem Execution.state_bytes (execution : Execution state output) (offset : Nat) (bound : offset<3145728) :
    execution.memory (execution.trace.stateBase+offset)=execution.trace.stateMemory (execution.trace.stateBase+offset) := by
  have projected := MemoryProjection.project_at write stateProject MemoryProjection.wordWrite execution.trace.schedule
    (execution.trace.stateBase+offset) (by
      intro event member first second same
      cases event with
      | state store => exact MemoryProjection.word_congr store first second _ same
      | output store =>
        exact (MemoryProjection.half_misses store (output_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.output store, member, rfl⟩))
          (MemoryRegions.disjoint_symm execution.separate) offset bound first).trans same)
    execution.trace.stateBefore execution.trace.stateBefore rfl
  exact projected.trans (congrFun (MemoryProjection.words _ _) _)

theorem Execution.output_bytes (execution : Execution state output) (offset : Nat) (bound : offset<12288) :
    execution.memory (execution.trace.outputBase+offset)=execution.trace.outputMemory (execution.trace.outputBase+offset) := by
  have projected := MemoryProjection.project_at write outputProject MemoryProjection.halfWrite execution.trace.schedule
    (execution.trace.outputBase+offset) (by
      intro event member first second same
      cases event with
      | state store =>
        exact (MemoryProjection.word_misses store (state_inside execution.trace store
          (List.mem_filterMap.mpr ⟨.state store, member, rfl⟩)) execution.separate offset bound first).trans same
      | output store => exact MemoryProjection.half_congr store first second _ same)
    execution.trace.stateBefore execution.trace.outputBefore (congrFun execution.shared _).symm
  exact projected.trans (congrFun (MemoryProjection.halves _ _) _)

def Execution.stateRead (execution : Execution state output) (head : Fin 48) (row key : Fin 128) : Float32 :=
  FloatMemory.load execution.memory (execution.trace.stateBase+4*stateIndex head row key)

def Execution.outputRead (execution : Execution state output) (head : Fin 48) (row : Fin 128) : GatedBytes.BF :=
  Model.ofBits (HalfMemory.load execution.memory (execution.trace.outputBase+2*outputIndex head row))

theorem Execution.state_correct (execution : Execution state output) (head : Fin 48) (row key : Fin 128) :
    execution.stateRead head row key=state head row key := by
  unfold Execution.stateRead FloatMemory.load
  rw [ArrayFrame.word_congr execution.trace.stateMemory execution.memory execution.trace.stateBase 3145728
    _ execution.state_bytes (by have := GatedStores.state_bounds head row key; omega)]
  exact execution.trace.state_correct head row key

theorem Execution.output_correct (execution : Execution state output) (head : Fin 48) (row : Fin 128) :
    execution.outputRead head row=output head row := by
  unfold Execution.outputRead
  rw [ArrayFrame.half_congr execution.trace.outputMemory execution.memory execution.trace.outputBase 12288
    _ execution.output_bytes (by have := GatedStores.output_bounds head row; omega)]
  exact execution.trace.output_correct head row

def Execution.stateBuffer (execution : Execution state output) : GatedDevice.Storage state where
  bytes := execution.memory
  base := execution.trace.stateBase
  aligned := execution.trace.stateAligned
  bounded := execution.trace.stateBounded
  attached := execution.state_correct

def Execution.outputBuffer (execution : Execution state output) (head : Fin 48) : ArrayStorage.BFBuffer (output head) where
  bytes := execution.memory
  base := execution.trace.outputBase+2*(head.val*128)
  aligned := by have := execution.trace.outputAligned; omega
  bounded := by have := execution.trace.outputBounded; have := head.isLt; omega
  attached := by
    intro row
    have raw := congrArg (fun value : GatedBytes.BF => value.bits) (execution.output_correct head row)
    change HalfMemory.load execution.memory (execution.trace.outputBase+2*outputIndex head row)=_ at raw
    rw [show execution.trace.outputBase+2*outputIndex head row=
      execution.trace.outputBase+2*(head.val*128)+2*row.val by unfold outputIndex; omega] at raw
    exact raw

theorem Execution.during_other (execution : Execution state output) {base size : Nat}
    (events : List Event) (subset : ∀ event ∈ events, event ∈ execution.trace.schedule)
    (stateSeparate : MemoryRegions.Disjoint execution.trace.stateBase 3145728 base size)
    (outputSeparate : MemoryRegions.Disjoint execution.trace.outputBase 12288 base size)
    (offset : Nat) (bound : offset<size) :
    MemoryProjection.execute write events execution.trace.stateBefore (base+offset)=execution.trace.stateBefore (base+offset) := by
  apply MemoryProjection.frame
  intro event member memory
  cases event with
  | state store =>
      exact MemoryProjection.word_misses store
        (state_inside execution.trace store (List.mem_filterMap.mpr ⟨.state store, subset _ member, rfl⟩)) stateSeparate offset bound memory
  | output store =>
      exact MemoryProjection.half_misses store
        (output_inside execution.trace store (List.mem_filterMap.mpr ⟨.output store, subset _ member, rfl⟩)) outputSeparate offset bound memory

theorem Execution.other_region (execution : Execution state output) {base size : Nat}
    (stateSeparate : MemoryRegions.Disjoint execution.trace.stateBase 3145728 base size)
    (outputSeparate : MemoryRegions.Disjoint execution.trace.outputBase 12288 base size)
    (offset : Nat) (bound : offset<size) : execution.memory (base+offset)=execution.trace.stateBefore (base+offset) :=
  execution.during_other execution.trace.schedule (fun _ member => member) stateSeparate outputSeparate offset bound

end Inference.Kernels.Delta.GatedMemory
