import kernels.delta.GatedStores
import contracts.mlx.ThreadgroupWriteProjection
import contracts.mlx.FloatMemory
import contracts.mlx.HalfMemory

namespace Inference.Kernels.Delta.GatedBytes
open Contracts.Mlx GatedStores
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := Model FloatFormat.bfloat16
def bits (value : BF) : BitVec 16 := value.bits

inductive Event where
  | output : HalfMemory.Store → Event
  | state : ByteMemory.Store → Event

def stateProject : Event → Option ByteMemory.Store
  | .state store => some store
  | _ => none
def outputProject : Event → Option HalfMemory.Store
  | .output store => some store
  | _ => none

private theorem state_states (stores : List ByteMemory.Store) : (stores.map Event.state).filterMap stateProject=stores := by
  induction stores with
  | nil => rfl
  | cons store rest ih => simpa only [List.map_cons, List.filterMap_cons, stateProject] using congrArg (List.cons store) ih
private theorem state_outputs (stores : List HalfMemory.Store) : (stores.map Event.output).filterMap stateProject=[] := by
  induction stores with
  | nil => rfl
  | cons store rest ih => simpa only [List.map_cons, List.filterMap_cons, stateProject] using ih
private theorem output_states (stores : List ByteMemory.Store) : (stores.map Event.state).filterMap outputProject=[] := by
  induction stores with
  | nil => rfl
  | cons store rest ih => simpa only [List.map_cons, List.filterMap_cons, outputProject] using ih
private theorem output_outputs (stores : List HalfMemory.Store) : (stores.map Event.output).filterMap outputProject=stores := by
  induction stores with
  | nil => rfl
  | cons store rest ih => simpa only [List.map_cons, List.filterMap_cons, outputProject] using congrArg (List.cons store) ih

def thread (stateBase outputBase : Nat) (state : Fin 48 → Fin 128 → Fin 128 → Float32)
    (output : Fin 48 → Fin 128 → BF) (label : Label) : List Event :=
  (outputThread (outputBase/2) (fun h v => bits (output h v)) label).map Event.output ++
    (stateThread (stateBase/4) (fun h v k => FloatMemory.bits (state h v k)) label).map Event.state

def programs (stateBase outputBase : Nat) (state : Fin 48 → Fin 128 → Fin 128 → Float32)
    (output : Fin 48 → Fin 128 → BF) : List (List Event) := labels.map (thread stateBase outputBase state output)

theorem state_thread (stateBase outputBase : Nat) (state : Fin 48 → Fin 128 → Fin 128 → Float32)
    (output : Fin 48 → Fin 128 → BF) (label : Label) :
    (thread stateBase outputBase state output label).filterMap stateProject=
      stateThread (stateBase/4) (fun h v k => FloatMemory.bits (state h v k)) label := by
  simp only [thread, List.filterMap_append, state_outputs, state_states, List.nil_append]

theorem output_thread (stateBase outputBase : Nat) (state : Fin 48 → Fin 128 → Fin 128 → Float32)
    (output : Fin 48 → Fin 128 → BF) (label : Label) :
    (thread stateBase outputBase state output label).filterMap outputProject=
      outputThread (outputBase/2) (fun h v => bits (output h v)) label := by
  simp only [thread, List.filterMap_append, output_outputs, output_states, List.append_nil]

theorem state_programs (stateBase outputBase : Nat) (state : Fin 48 → Fin 128 → Fin 128 → Float32)
    (output : Fin 48 → Fin 128 → BF) :
    ThreadgroupWriteProjection.programs stateProject (programs stateBase outputBase state output)=
      statePrograms (stateBase/4) (fun h v k => FloatMemory.bits (state h v k)) := by
  simp only [ThreadgroupWriteProjection.programs, programs, List.map_map, Function.comp_def, state_thread, statePrograms]

theorem output_programs (stateBase outputBase : Nat) (state : Fin 48 → Fin 128 → Fin 128 → Float32)
    (output : Fin 48 → Fin 128 → BF) :
    ThreadgroupWriteProjection.programs outputProject (programs stateBase outputBase state output)=
      outputPrograms (outputBase/2) (fun h v => bits (output h v)) := by
  simp only [ThreadgroupWriteProjection.programs, programs, List.map_map, Function.comp_def, output_thread, outputPrograms]

-- One schedule preserves each thread's output-then-state order for T=1.
-- Completion precedes the next kernel/cache read; native dispatch visibility
-- and the identity of the separate output allocations remain obligations.
structure Trace (state : Fin 48 → Fin 128 → Fin 128 → Float32) (output : Fin 48 → Fin 128 → BF) where
  stateBefore : ByteMemory.Bytes
  outputBefore : HalfMemory.Bytes
  stateBase : Nat
  outputBase : Nat
  stateAligned : stateBase%4=0
  outputAligned : outputBase%2=0
  stateBounded : stateBase+4*786432 ≤ 2^64
  outputBounded : outputBase+2*6144 ≤ 2^64
  schedule : List Event
  remaining : List (List Event)
  execution : ThreadgroupWrites.Executes (programs stateBase outputBase state output) schedule remaining
  completed : ThreadgroupWrites.AtBarrier remaining

def Trace.canonical (state : Fin 48 → Fin 128 → Fin 128 → Float32) (output : Fin 48 → Fin 128 → BF) : Trace state output :=
  let stores := programs 0 0 state output
  ⟨(fun _ => 0), (fun _ => 0), 0, 0, by decide, by decide, by decide, by decide,
    stores.flatten, List.replicate stores.length [], ThreadgroupWrites.canonical stores, ThreadgroupWrites.canonical_barrier stores⟩

variable {state : Fin 48 → Fin 128 → Fin 128 → Float32} {output : Fin 48 → Fin 128 → BF}

def Trace.stateMemory (trace : Trace state output) : ByteMemory.Bytes :=
  ByteMemory.execute (trace.schedule.filterMap stateProject) trace.stateBefore
def Trace.outputMemory (trace : Trace state output) : HalfMemory.Bytes :=
  HalfMemory.execute (trace.schedule.filterMap outputProject) trace.outputBefore
def Trace.stateRead (trace : Trace state output) (head : Fin 48) (row key : Fin 128) : Float32 :=
  FloatMemory.load trace.stateMemory (trace.stateBase+4*stateIndex head row key)
def Trace.outputRead (trace : Trace state output) (head : Fin 48) (row : Fin 128) : BF :=
  Model.ofBits (HalfMemory.load trace.outputMemory (trace.outputBase+2*outputIndex head row))

theorem Trace.state_correct (trace : Trace state output) (head : Fin 48) (row key : Fin 128) :
    trace.stateRead head row key=state head row key := by
  have run := ThreadgroupWriteProjection.execution stateProject trace.execution
  rw [state_programs] at run
  unfold Trace.stateRead FloatMemory.load Trace.stateMemory
  rw [ByteMemory.execute_bytes_load32 _ _ _ (by have := trace.stateAligned; omega),
    show (trace.stateBase+4*stateIndex head row key)/4=trace.stateBase/4+stateIndex head row key by omega,
    state_stored _ _ _ _ _ run (ThreadgroupWriteProjection.completed stateProject _ trace.completed), FloatMemory.decode_bits]

theorem Trace.output_correct (trace : Trace state output) (head : Fin 48) (row : Fin 128) :
    trace.outputRead head row=output head row := by
  have run := ThreadgroupWriteProjection.execution outputProject trace.execution
  rw [output_programs] at run
  have raw : HalfMemory.load trace.outputMemory (trace.outputBase+2*outputIndex head row)=bits (output head row) := by
    unfold Trace.outputMemory
    rw [HalfMemory.execute_load _ _ _ (by have := trace.outputAligned; omega),
      show (trace.outputBase+2*outputIndex head row)/2=trace.outputBase/2+outputIndex head row by omega]
    exact output_stored _ _ _ _ _ run (ThreadgroupWriteProjection.completed outputProject _ trace.completed) head row
  exact congrArg (fun word : BitVec 16 => (Model.ofBits word : BF)) raw

theorem Trace.state_bounds (trace : Trace state output) (head : Fin 48) (row key : Fin 128) :
    (trace.stateBase+4*stateIndex head row key)%4=0 ∧ trace.stateBase+4*stateIndex head row key+4 ≤ 2^64 := by
  have := trace.stateAligned
  have := trace.stateBounded
  have := GatedStores.state_bounds head row key
  omega

theorem Trace.output_bounds (trace : Trace state output) (head : Fin 48) (row : Fin 128) :
    (trace.outputBase+2*outputIndex head row)%2=0 ∧ trace.outputBase+2*outputIndex head row+2 ≤ 2^64 := by
  have := trace.outputAligned
  have := trace.outputBounded
  have := GatedStores.output_bounds head row
  omega

end Inference.Kernels.Delta.GatedBytes
