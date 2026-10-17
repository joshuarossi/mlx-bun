import Mathlib.Data.Finset.Basic

namespace Inference.Contracts.Mlx.DispatchBarriers

-- Serial CommandEncoder registration and maybeInsertBarrier in pinned
-- device.cpp. Resource IDs are MTL buffer identities, not tensor handles.
-- Metal's barrier ordering/visibility is a platform contract. Concurrent
-- contexts and cross-encoder fences have separate obligations.
structure State where
  previousInputs : Finset Nat
  previousOutputs : Finset Nat
  nextInputs : Finset Nat
  nextOutputs : Finset Nat
  needsBarrier : Bool

def empty : State := ⟨∅, ∅, ∅, ∅, false⟩

def input (state : State) (resource : Nat) : State :=
  { state with
    nextInputs := insert resource state.nextInputs
    needsBarrier := state.needsBarrier || decide (resource ∈ state.previousOutputs) }

def registerOutput (state : State) (resource : Nat) : State :=
  { state with
    nextOutputs := insert resource state.nextOutputs
    needsBarrier := state.needsBarrier || decide (resource ∈ state.previousInputs) }

def output (state : State) (resource : Nat) : State := registerOutput (input state resource) resource

structure Ready (state : State) : Prop where
  readAfterWrite : ∀ resource ∈ state.previousOutputs, resource ∈ state.nextInputs → state.needsBarrier=true
  writeAfterRead : ∀ resource ∈ state.previousInputs, resource ∈ state.nextOutputs → state.needsBarrier=true

theorem empty_ready : Ready empty where
  readAfterWrite := by simp [empty]
  writeAfterRead := by simp [empty]

theorem input_ready (state : State) (ready : Ready state) (resource : Nat) : Ready (input state resource) where
  readAfterWrite := by
    intro other previous pending
    rcases Finset.mem_insert.mp pending with equal|old
    · subst other
      change resource ∈ state.previousOutputs at previous
      simp [input, previous]
    · simp only [input, ready.readAfterWrite other previous old, Bool.true_or]
  writeAfterRead := by
    intro other previous pending
    simp only [input, ready.writeAfterRead other previous pending, Bool.true_or]

theorem register_ready (state : State) (ready : Ready state) (resource : Nat) : Ready (registerOutput state resource) where
  readAfterWrite := by
    intro other previous pending
    simp only [registerOutput, ready.readAfterWrite other previous pending, Bool.true_or]
  writeAfterRead := by
    intro other previous pending
    rcases Finset.mem_insert.mp pending with equal|old
    · subst other
      change resource ∈ state.previousInputs at previous
      simp [registerOutput, previous]
    · simp only [registerOutput, ready.writeAfterRead other previous old, Bool.true_or]

theorem output_ready (state : State) (ready : Ready state) (resource : Nat) : Ready (output state resource) :=
  register_ready _ (input_ready state ready resource) resource

-- set_output_array calls set_input_array before register_output_array.
-- Consequently a repeated write is included in the read-after-write check.
theorem output_read (state : State) (resource : Nat) : resource ∈ (output state resource).nextInputs := by
  simp [output, registerOutput, input]

theorem write_after_write (state : State) (resource : Nat) (previous : resource ∈ state.previousOutputs) :
    (output state resource).needsBarrier=true := by
  simp [output, registerOutput, input, previous]

def dispatch (state : State) : State :=
  if state.needsBarrier then
    ⟨state.nextInputs, state.nextOutputs, ∅, ∅, false⟩
  else
    ⟨state.previousInputs ∪ state.nextInputs, state.previousOutputs ∪ state.nextOutputs, ∅, ∅, false⟩

theorem dispatch_ready (state : State) : Ready (dispatch state) := by
  unfold dispatch
  split <;> constructor <;> simp

theorem no_barrier_reads (state : State) (ready : Ready state) (none : state.needsBarrier=false) :
    Disjoint state.previousOutputs state.nextInputs := by
  apply Finset.disjoint_left.mpr
  intro resource previous pending
  have required := ready.readAfterWrite resource previous pending
  rw [none] at required
  contradiction

theorem no_barrier_writes (state : State) (ready : Ready state) (none : state.needsBarrier=false) :
    Disjoint state.previousInputs state.nextOutputs := by
  apply Finset.disjoint_left.mpr
  intro resource previous pending
  have required := ready.writeAfterRead resource previous pending
  rw [none] at required
  contradiction

theorem dispatch_inputs (state : State) : state.nextInputs ⊆ (dispatch state).previousInputs := by
  unfold dispatch
  split
  · exact Finset.Subset.refl _
  · exact Finset.subset_union_right

theorem dispatch_outputs (state : State) : state.nextOutputs ⊆ (dispatch state).previousOutputs := by
  unfold dispatch
  split
  · exact Finset.Subset.refl _
  · exact Finset.subset_union_right

def inputs : State → List Nat → State
  | state, [] => state
  | state, resource::rest => inputs (input state resource) rest
def outputs : State → List Nat → State
  | state, [] => state
  | state, resource::rest => outputs (output state resource) rest

theorem inputs_ready (state : State) (ready : Ready state) (resources : List Nat) : Ready (inputs state resources) := by
  induction resources generalizing state with
  | nil => exact ready
  | cons resource rest ih => exact ih _ (input_ready state ready resource)

theorem outputs_ready (state : State) (ready : Ready state) (resources : List Nat) : Ready (outputs state resources) := by
  induction resources generalizing state with
  | nil => exact ready
  | cons resource rest ih => exact ih _ (output_ready state ready resource)

def launch (state : State) (reads writes : List Nat) : State := outputs (inputs state reads) writes

theorem launch_ready (state : State) (ready : Ready state) (reads writes : List Nat) : Ready (launch state reads writes) :=
  outputs_ready _ (inputs_ready state ready reads) writes

-- ConcurrentContext defers output registration until scope exit. This
-- proves the following consumer observes the whole group's outputs; it
-- does not assert independence of the copies inside that group.
structure Concurrent where
  current : State
  produced : Finset Nat

def beginConcurrent (state : State) : Concurrent := ⟨state, ∅⟩
def concurrentOutput (context : Concurrent) (resource : Nat) : Concurrent :=
  ⟨input context.current resource, insert resource context.produced⟩
def concurrentDispatch (context : Concurrent) : Concurrent := ⟨dispatch context.current, context.produced⟩
def finishConcurrent (context : Concurrent) : State :=
  { context.current with previousOutputs := context.current.previousOutputs ∪ context.produced }

theorem concurrent_recorded (context : Concurrent) (resource : Nat) :
    resource ∈ (concurrentOutput context resource).produced := by simp [concurrentOutput]

theorem concurrent_retained (context : Concurrent) (resource : Nat) (present : resource ∈ context.produced) :
    resource ∈ (concurrentDispatch context).produced := present

theorem concurrent_exit (context : Concurrent) (resource : Nat) (present : resource ∈ context.produced) :
    resource ∈ (finishConcurrent context).previousOutputs := Finset.mem_union_right _ present

theorem concurrent_consumer (context : Concurrent) (resource : Nat) (present : resource ∈ context.produced) :
    (input (finishConcurrent context) resource).needsBarrier=true := by
  have recorded := concurrent_exit context resource present
  simp only [input, recorded, decide_true, Bool.or_true]

theorem concurrent_finished_ready (context : Concurrent) : Ready (finishConcurrent (concurrentDispatch context)) := by
  cases context with
  | mk current produced =>
    unfold concurrentDispatch finishConcurrent dispatch
    split <;> constructor <;> simp

end Inference.Contracts.Mlx.DispatchBarriers
