import kernels.delta.SiluHeads128Threads

namespace Inference.Kernels.Delta.SiluHeads128Memory
open Contracts.Mlx Layers SiluHeads128Geometry SiluHeads128Threads SiluHeads128Output GatedInputs
set_option maxRecDepth 2000
attribute [local irreducible] CopyContiguous.programs MultiOutputWrites.programs
  normalizedPrograms valuePrograms

variable {values : Fin 10240 → ArrayStorage.BF} {qScale kScale : Fin 128 → ArrayStorage.BF}

theorem query_values (p : SiluRmsHeads.Platform) (input : DeltaHeadsMemory.Input values qScale kScale) :
    normalizedValues p (fun h => current input (DeltaHeads.qHead h)) input.storage.qScale.read=
      (DeltaHeadsDevice.produced p width epsilon input.storage).q 0 := by
  funext h col
  have same : (fun j : Fin 128 => current input (DeltaHeads.qHead h) j.val)=
      fun j => input.storage.input.read (DeltaHeads.channel (DeltaHeads.qHead h) j) := by
    funext j
    exact current_read input (DeltaHeads.qHead h) j
  unfold normalizedValues
  rw [same]
  unfold DeltaHeadsDevice.produced
  rfl

theorem key_values (p : SiluRmsHeads.Platform) (input : DeltaHeadsMemory.Input values qScale kScale) :
    normalizedValues p (fun h => current input (DeltaHeads.kHead h)) input.storage.kScale.read=
      (DeltaHeadsDevice.produced p width epsilon input.storage).k 0 := by
  funext h col
  have same : (fun j : Fin 128 => current input (DeltaHeads.kHead h) j.val)=
      fun j => input.storage.input.read (DeltaHeads.channel (DeltaHeads.kHead h) j) := by
    funext j
    exact current_read input (DeltaHeads.kHead h) j
  unfold normalizedValues
  rw [same]
  unfold DeltaHeadsDevice.produced
  rfl

theorem value_values (p : SiluRmsHeads.Platform) (input : DeltaHeadsMemory.Input values qScale kScale) :
    valueValues p (fun h => current input (DeltaHeads.vHead h))=
      (DeltaHeadsDevice.produced p width epsilon input.storage).v 0 := by
  funext h col
  unfold valueValues
  change SiluRmsHeads.activate p (current input (DeltaHeads.vHead h) col.val)=_
  rw [current_read]
  unfold DeltaHeadsDevice.produced
  rfl

-- Enumerate all physical groups as Q[0..15], K[16..31], V[32..79].
-- Geometry proves the branch tests and original offsets for these labels.
def programs (p : SiluRmsHeads.Platform) (input : DeltaHeadsMemory.Input values qScale kScale)
    (bases : Fin 3 → Nat) (initial : Initial) : Option (List (List HalfMemory.Store)) := do
  let q ←normalizedPrograms p (fun h => current input (DeltaHeads.qHead h)) input.storage.qScale.read (bases 0) initial
  let k ←normalizedPrograms p (fun h => current input (DeltaHeads.kHead h)) input.storage.kScale.read (bases 1) initial
  let v ←valuePrograms p (fun h => current input (DeltaHeads.vHead h)) (bases 2) initial
  pure (q++k++v)

theorem layout_programs (geometry : DeltaHeadsMemory.Geometry) (data : DeltaHeads.Output 1 ArrayStorage.BF) :
    MultiOutputWrites.programs (geometry.layout data)=
      CopyContiguous.programs (blocks := 512) (geometry.base 0) (fun i => ArrayStorage.bits (flatten (data.q 0) i))++
      CopyContiguous.programs (blocks := 512) (geometry.base 1) (fun i => ArrayStorage.bits (flatten (data.k 0) i))++
      CopyContiguous.programs (blocks := 1536) (geometry.base 2) (fun i => ArrayStorage.bits (flatten (data.v 0) i)) := by
  rw [MultiOutputWrites.programs,show List.finRange 3=[0,1,2] from by decide +kernel]
  simp only [List.flatMap_cons,List.flatMap_nil,List.append_nil,DeltaHeadsMemory.Geometry.layout,DeltaHeadsMemory.vector]
  exact List.append_assoc _ _ _ |>.symm

theorem source_programs (p : SiluRmsHeads.Platform) (input : DeltaHeadsMemory.Input values qScale kScale)
    (geometry : DeltaHeadsMemory.Geometry) (initial : Initial) :
    programs p input geometry.base initial=some
      (MultiOutputWrites.programs (geometry.layout (DeltaHeadsDevice.produced p width epsilon input.storage))) := by
  unfold programs
  rw [normalized_programs,normalized_programs,value_programs,query_values,key_values,value_values,layout_programs]
  rfl

variable {input : DeltaHeadsMemory.Input values qScale kScale} {p : SiluRmsHeads.Platform}

theorem source_execution (execution : DeltaHeadsMemory.Execution input p width epsilon) (initial : Initial)
    (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores,store ∈ execution.trace.schedule) :
    ∃ writes,programs p (execution.during stores subset) execution.geometry.base initial=some writes ∧
      ThreadgroupWrites.Executes writes execution.trace.schedule execution.trace.remaining ∧
      ThreadgroupWrites.AtBarrier execution.trace.remaining := by
  refine ⟨_,?_,execution.trace.execution,execution.trace.completed⟩
  rw [source_programs,execution.partial_produced stores subset]

theorem all_reads_current (execution : DeltaHeadsMemory.Execution input p width epsilon)
    (stores : List HalfMemory.Store) (subset : ∀ store ∈ stores,store ∈ execution.trace.schedule) :
    (execution.during stores subset).storage.input.bytes=HalfMemory.execute stores execution.trace.before ∧
    (execution.during stores subset).storage.qScale.bytes=HalfMemory.execute stores execution.trace.before ∧
    (execution.during stores subset).storage.kScale.bytes=HalfMemory.execute stores execution.trace.before := ⟨rfl,rfl,rfl⟩

theorem readback (execution : DeltaHeadsMemory.Execution input p width epsilon) :
    execution.output=DeltaHeads.forward p (fun _ => values) qScale kScale width epsilon := execution.output_eq

theorem output_heap (execution : DeltaHeadsMemory.Execution input p width epsilon) :
    execution.queryBuffer.bytes=execution.trace.memory ∧
    execution.keyBuffer.bytes=execution.trace.memory ∧
    execution.valueBuffer.bytes=execution.trace.memory := ⟨rfl,rfl,rfl⟩

end Inference.Kernels.Delta.SiluHeads128Memory
