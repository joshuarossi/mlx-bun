import host.ts.RenameMlxConstructorHeap
import host.ts.RenameRetainedNormalize

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000000
namespace Host.Ts.Owned.Annotated.MlxConstruction
open Parametric

def assignmentSource {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) : St S :=
  parameterOutput (parametersOutput source env proto brand argument) (parameterEnvironment source env proto brand argument)
    (.k (.fn (.ctor (.obj source.next)))::source.stack) (source.next+4) argument
def assignmentNotes {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (proto brand : Nat)
    (argument : Val) (role : Value) : RetainedNotes :=
  parameterNotes (parametersNotes notes source env proto brand argument role)
    (parameterEnvironment source env proto brand argument) (source.next+4) role
    (constructorBoundaryNote (.obj source.next)::notes.runtime.stack)
def handleOutput {S : Type} (source : St S) (env : Env) (proto brand : Nat) (argument : Val) : St S :=
  privateAssignmentOutput (assignmentSource source env proto brand argument) source.next brand chars!"handle" argument false
    (initializedInstance proto brand (source.next+2))
def handleNotes {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (proto brand : Nat)
    (argument : Val) (role : Value) : RetainedNotes :=
  (assignmentNotes notes source env proto brand argument role).thisPrivateAssigned source.next brand chars!"handle" role

/-- Nineteen original source transitions allocate and initialize the wrapper,
bind its existing argument meaning, and write that same meaning into #handle.
Both heaps/callers and allocation counters are arbitrary. No owning-private
note or future operand role is assumed at an intermediate entry. -/
theorem class_handle {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {source target : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live source target)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' source target)
    (address proto brand : Nat) (object : Obj) (env : Env) (argument : Val)
    (fnRole argRole : Value) (w e : Bool)
    (control : source.ctl = .construct (.obj address) [argument] (.obj address))
    (read : source.heap.get address = some (.obj object))
    (kind : object.kind = .fn (.klass (some constructorFunction) env .null (members brand)))
    (prototype : findProp kPrototype object.props = some (.data (.obj proto) w e))
    (brandLookup : lookupEnv (privName chars!"handle") env = some brand)
    (controlNote : notes.runtime.control = constructNote fnRole [argRole])
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (sourceBound : source.next+6 ≤ 2^64) (targetBound : target.next+6 ≤ 2^64) :
    ∃ result,
      runC F 19 source C₀ = some (handleOutput source env proto brand argument,C₀) ∧
      runC F 19 target C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ParametersLive live source.next) framed before after old old'
        (handleOutput source env proto brand argument) result ∧
      RetainedInventory (handleNotes notes source env proto brand argument argRole) ν₀ ν C₀ C R (ParametersLive live source.next)
        (handleOutput source env proto brand argument) result := by
  obtain ⟨s9,left9,right9,h9,inv9⟩ := class_parameters inventory h address proto brand object env argument fnRole argRole w e
    control read kind prototype controlNote objectLive objectFixed sourceBound targetBound
  host_normalize_retained h9, inv9
  have counter9 : s9.next = target.next+5 := h.heap.target_next_add h9.heap 5 rfl
  obtain ⟨s14,left14,right14,h14,inv14⟩ := prepare_parameter inv9 h9
    (parameterEnvironment source env proto brand argument) (.k (.fn (.ctor (.obj source.next)))::source.stack)
    (source.next+4) argument argRole (constructorBoundaryNote (.obj source.next)::notes.runtime.stack)
    rfl rfl (parameter_lookup_handle source env proto brand argument) (parameters_parameter source env proto brand argument sourceBound) rfl
    (by change source.next+5 ≤ 2^64; omega) (by rw [counter9]; omega)
  host_normalize_retained h14, inv14
  have sourceWord : source.next+4 < 2^64 := by omega
  have thisRead : (assignmentSource source env proto brand argument).heap.get (source.next+3) = some (.cell (some (.obj source.next))) := by
    change ((parametersOutput source env proto brand argument).heap.set (source.next+4) (.cell (some argument))).get (source.next+3) = _
    rw [PTrie.get_set_u64 _ _ _ sourceWord,ite_eq_right (show source.next+3 ≠ source.next+4 by omega)]
    exact parameters_this F source env proto brand argument sourceBound
  have parameterRead : (assignmentSource source env proto brand argument).heap.get (source.next+4) = some (.cell (some argument)) := by
    change ((parametersOutput source env proto brand argument).heap.set (source.next+4) (.cell (some argument))).get (source.next+4) = _
    rw [PTrie.get_set_u64 _ _ _ sourceWord,ite_eq_left rfl]
  have objectRead : (assignmentSource source env proto brand argument).heap.get source.next =
      some (.obj (initializedInstance proto brand (source.next+2))) := by
    change ((parametersOutput source env proto brand argument).heap.set (source.next+4) (.cell (some argument))).get source.next = _
    rw [PTrie.get_set_u64 _ _ _ sourceWord,ite_eq_right (show source.next ≠ source.next+4 by omega)]
    exact parameters_instance F source env proto brand argument sourceBound
  have thisNote : (assignmentNotes notes source env proto brand argument argRole).runtime.cells.cells (source.next+3) = some (.obj source.next) := by
    change (if source.next+3 = source.next+4 then some argRole
      else (parametersNotes notes source env proto brand argument argRole).runtime.cells.cells (source.next+3)) = _
    rw [ite_eq_right (show source.next+3 ≠ source.next+4 by omega)]
    exact parameters_this_note notes source env proto brand argument argRole
  have parameterNote : (assignmentNotes notes source env proto brand argument argRole).runtime.cells.cells (source.next+4) = some argRole := by
    change (if source.next+4 = source.next+4 then some argRole else _) = _
    rw [ite_eq_left rfl]
  have counter14 : s14.next = target.next+5 := h.heap.target_next_add h14.heap 5 rfl
  obtain ⟨result,left5,right5,h19,inv19,_,_⟩ := inv14.this_private_assign_block h14
    (parameterEnvironment source env proto brand argument) chars!"handle" chars!"handle" brand (source.next+3) (source.next+4)
    source.next (initializedInstance proto brand (source.next+2)) argument .undef false argRole rfl
    (by rw [parameter_lookup_other source env proto brand argument (privName chars!"handle") (by decide +kernel) (by decide +kernel)]; exact brandLookup)
    (parameter_lookup_this source env proto brand argument) (parameter_lookup_handle source env proto brand argument)
    thisRead parameterRead objectRead rfl (initialized_handle proto brand (source.next+2))
    thisNote parameterNote (by change source.next+5 ≤ 2^64; omega) (by rw [counter14]; omega)
  exact ⟨result,runC_join F (m:=14) (n:=5) (runC_join F (m:=9) (n:=5) left9 left14) left5,
    runC_join F (m:=14) (n:=5) (runC_join F (m:=9) (n:=5) right9 right14) right5,h19,inv19⟩

theorem stored_handle_note {S : Type} (notes : RetainedNotes) (source : St S) (env : Env) (proto brand : Nat)
    (argument : Val) (role : Value) :
    (handleNotes notes source env proto brand argument role).privates.owners source.next =
      some ⟨brand,chars!"handle",role⟩ := by
  simp only [handleNotes,RetainedNotes.thisPrivateAssigned,RetainedNotes.privateStored,PrivateNotes.write,ite_true]

end Host.Ts.Owned.Annotated.MlxConstruction
