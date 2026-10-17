import Mathlib.Data.Finset.Basic

namespace Inference.Contracts.Mlx.EncoderFences

-- The map operations performed under outputs_mtx_ in the pinned
-- CommandEncoder::end_encoding. Resource and fence identities are abstract.
-- The platform must give waitForFence/updateFence/completion their ordering
-- and visibility semantics; this module proves the dependency bookkeeping.
abbrev Registry := Nat → Option Nat

def register (registry : Registry) (outputs : Finset Nat) (fence : Nat) : Registry :=
  fun resource => if resource ∈ outputs then some fence else registry resource

def complete (registry : Registry) (outputs : Finset Nat) (fence : Nat) : Registry :=
  fun resource =>
    if resource ∈ outputs ∧ registry resource = some fence then none else registry resource

theorem register_output (registry : Registry) (outputs : Finset Nat) (fence resource : Nat)
    (present : resource ∈ outputs) : register registry outputs fence resource = some fence := by
  simp [register, present]

theorem register_other (registry : Registry) (outputs : Finset Nat) (fence resource : Nat)
    (absent : resource ∉ outputs) : register registry outputs fence resource = registry resource := by
  simp [register, absent]

theorem complete_owned (registry : Registry) (outputs : Finset Nat) (fence resource : Nat)
    (present : resource ∈ outputs) (owned : registry resource = some fence) :
    complete registry outputs fence resource = none := by
  simp [complete, present, owned]

theorem complete_other (registry : Registry) (outputs : Finset Nat) (fence resource : Nat)
    (other : registry resource ≠ some fence) :
    complete registry outputs fence resource = registry resource := by
  simp [complete, other]

theorem old_completion_preserves_new_writer (registry : Registry) (oldOutputs newOutputs : Finset Nat)
    (oldFence newFence resource : Nat) (different : newFence ≠ oldFence) (present : resource ∈ newOutputs) :
    complete (register registry newOutputs newFence) oldOutputs oldFence resource = some newFence := by
  simp [complete, register, present, different]

-- A set records the deduplicated waitForFence calls made before overwriting
-- the registry with the current encoder's outputs.
def waits (registry : Registry) : List Nat → Finset Nat
  | [] => ∅
  | resource :: rest =>
    match registry resource with
    | none => waits registry rest
    | some fence => insert fence (waits registry rest)

theorem wait_iff (registry : Registry) (inputs : List Nat) (fence : Nat) :
    fence ∈ waits registry inputs ↔ ∃ resource ∈ inputs, registry resource = some fence := by
  induction inputs with
  | nil => simp [waits]
  | cons resource rest ih =>
    cases entry : registry resource with
    | none => simp [waits, entry, ih]
    | some producer => simp [waits, entry, ih, eq_comm]

theorem waits_for_input (registry : Registry) (inputs : List Nat) (resource fence : Nat)
    (input : resource ∈ inputs) (producer : registry resource = some fence) :
    fence ∈ waits registry inputs := (wait_iff registry inputs fence).mpr ⟨resource, input, producer⟩

-- Latest writers and completed fences are ghost state used only in the
-- proof. They are not extra runtime checks or runtime data structures.
structure State where
  registry : Registry
  latest : Registry
  completed : Finset Nat

def empty : State := ⟨fun _ => none, fun _ => none, ∅⟩

def Tracked (state : State) : Prop :=
  ∀ resource fence, state.latest resource = some fence → fence ∉ state.completed →
    state.registry resource = some fence

def submit (state : State) (outputs : Finset Nat) (fence : Nat) : State :=
  ⟨register state.registry outputs fence, register state.latest outputs fence, state.completed⟩

def finish (state : State) (outputs : Finset Nat) (fence : Nat) : State :=
  ⟨complete state.registry outputs fence, state.latest, insert fence state.completed⟩

theorem empty_tracked : Tracked empty := by simp [Tracked, empty]

theorem submit_tracked (state : State) (tracked : Tracked state) (outputs : Finset Nat) (fence : Nat) :
    Tracked (submit state outputs fence) := by
  intro resource producer latest pending
  by_cases output : resource ∈ outputs
  · simpa [submit, register, output] using latest
  · exact (register_other state.registry outputs fence resource output).trans
      (tracked resource producer (by simpa [submit, register, output] using latest) pending)

theorem finish_tracked (state : State) (tracked : Tracked state) (outputs : Finset Nat) (fence : Nat) :
    Tracked (finish state outputs fence) := by
  intro resource producer latest pending
  have absent : producer ∉ state.completed := by
    exact fun present => pending (Finset.mem_insert_of_mem present)
  have different : producer ≠ fence := by
    intro equal
    subst producer
    exact pending (Finset.mem_insert_self _ _)
  have recorded := tracked resource producer latest absent
  change complete state.registry outputs fence resource = some producer
  simp [complete, recorded, different]

theorem input_dependency (state : State) (tracked : Tracked state) (inputs : List Nat)
    (resource fence : Nat) (input : resource ∈ inputs) (latest : state.latest resource = some fence) :
    fence ∈ state.completed ∨ fence ∈ waits state.registry inputs := by
  by_cases done : fence ∈ state.completed
  · exact Or.inl done
  · exact Or.inr (waits_for_input state.registry inputs resource fence input
      (tracked resource fence latest done))

-- Removing encoder-local temporaries is valid for an external input only
-- when that resource is not classified as a temporary. This obligation is
-- explicit; this module does not assume arbitrary temporary classification.
def externalInputs (inputs : List Nat) (temporaries : Finset Nat) : List Nat :=
  inputs.filter fun resource => resource ∉ temporaries

theorem external_input_dependency (state : State) (tracked : Tracked state) (inputs : List Nat)
    (temporaries : Finset Nat) (resource fence : Nat) (input : resource ∈ inputs)
    (external : resource ∉ temporaries) (latest : state.latest resource = some fence) :
    fence ∈ state.completed ∨ fence ∈ waits state.registry (externalInputs inputs temporaries) := by
  apply input_dependency state tracked _ resource fence _ latest
  simp [externalInputs, input, external]

-- Every interleaving of serialized map updates and completion callbacks
-- preserves the pending-writer invariant. Native mutex correctness and fence
-- identity lifetime are separate contracts needed to instantiate this model.
inductive Event where
  | submit (outputs : Finset Nat) (fence : Nat)
  | finish (outputs : Finset Nat) (fence : Nat)

def step (state : State) : Event → State
  | .submit outputs fence => submit state outputs fence
  | .finish outputs fence => finish state outputs fence

def run : State → List Event → State
  | state, [] => state
  | state, event :: rest => run (step state event) rest

theorem step_tracked (state : State) (tracked : Tracked state) (event : Event) : Tracked (step state event) := by
  cases event with
  | submit outputs fence => exact submit_tracked state tracked outputs fence
  | finish outputs fence => exact finish_tracked state tracked outputs fence

theorem run_tracked (state : State) (tracked : Tracked state) (events : List Event) : Tracked (run state events) := by
  induction events generalizing state with
  | nil => exact tracked
  | cons event rest ih => exact ih _ (step_tracked state tracked event)

theorem run_input_dependency (events : List Event) (inputs : List Nat) (resource fence : Nat)
    (input : resource ∈ inputs) (latest : (run empty events).latest resource = some fence) :
    fence ∈ (run empty events).completed ∨ fence ∈ waits (run empty events).registry inputs :=
  input_dependency _ (run_tracked empty empty_tracked events) inputs resource fence input latest

end Inference.Contracts.Mlx.EncoderFences
