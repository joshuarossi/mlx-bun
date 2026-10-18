import host.ts.RenameRetainedGetterEntry
import host.ts.RenameRetainedGetter
import host.ts.RenameMapIndexEffects

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Ts.Owned.Annotated
open Parametric

theorem getter_environment_nonempty {S : Type} (s : St S) (name : Option Name) (env : Env)
    (home : Val) (owner : Nat) (disposedName handleName : Name) (yes : Stmt) (nonempty : home ≠ .undef) :
    closureEnvironment s (getterFunction name disposedName handleName yes) env false home (.obj owner) =
      (nHome,s.next+1)::(nThis,s.next)::env := by
  unfold closureEnvironment
  rw [closureStart_home s env home (.obj owner) nonempty]
  rfl

theorem getter_environment_this {S : Type} (s : St S) (name : Option Name) (env : Env)
    (home : Val) (owner : Nat) (disposedName handleName : Name) (yes : Stmt) :
    lookupEnv nThis (closureEnvironment s (getterFunction name disposedName handleName yes) env false home (.obj owner)) =
      some s.next := by
  classical
  by_cases empty : home = .undef
  · subst home
    change lookupEnv nThis ((nThis,s.next)::env) = _
    exact lookupEnv_head nThis s.next env
  · rw [getter_environment_nonempty s name env home owner disposedName handleName yes empty,
      lookupEnv_skip nThis nHome (s.next+1) ((nThis,s.next)::env) (by decide +kernel)]
    exact lookupEnv_head nThis s.next env

theorem getter_environment_private {S : Type} (s : St S) (name : Option Name) (env : Env)
    (home : Val) (owner : Nat) (disposedName handleName field : Name) (yes : Stmt) (brand : Nat)
    (names : nameEq (privName field) nThis = false ∧ nameEq (privName field) nHome = false)
    (lookup : lookupEnv (privName field) env = some brand) :
    lookupEnv (privName field) (closureEnvironment s (getterFunction name disposedName handleName yes) env false home (.obj owner)) =
      some brand := by
  classical
  by_cases empty : home = .undef
  · subst home
    change lookupEnv (privName field) ((nThis,s.next)::env) = _
    rw [lookupEnv_skip (privName field) nThis s.next env names.1]
    exact lookup
  · rw [getter_environment_nonempty s name env home owner disposedName handleName yes empty,
      lookupEnv_skip (privName field) nHome (s.next+1) ((nThis,s.next)::env) names.2,
      lookupEnv_skip (privName field) nThis s.next env names.1]
    exact lookup

def getterCallResult {S : Type} (s : St S) (name : Option Name) (env : Env) (home : Val) (owner : Nat)
    (disposedName handleName : Name) (yes : Stmt) (value : Val) : St S :=
  {getterEntryState s name env home owner disposedName handleName yes with ctl := .ret value,stack := s.stack}

def getterCallNotes (notes : RetainedNotes) (receiver owner : Nat) (role : Value) : RetainedNotes :=
  notes.withRuntime ⟨returnNote role,notes.runtime.stack,notes.runtime.cells.write receiver (.obj owner)⟩

/-- A whole guarded getter call uses current closure/field ownership and the
incoming receiver meaning. Its receiver cell and every intermediate operand
are produced by the original seventeen-step execution, for arbitrary heaps,
callers and fresh counters. -/
theorem RetainedInventory.getter_call_block
    {F : Ffi} {FR : Ren → F.S → F.S → Prop} {notes : RetainedNotes}
    {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (getter owner brand : Nat) (function object : Obj) (name : Option Name) (env : Env) (home : Val)
    (disposedName handleName : Name) (yes : Stmt) (value : Val) (role : Value) (dw de hw he : Bool)
    (control : s₀.ctl = .call (.obj getter) (.obj owner) [])
    (functionRead : s₀.heap.get getter = some (.obj function))
    (closure : function.kind = .fn (.closure (getterFunction name disposedName handleName yes) env false home))
    (objectRead : s₀.heap.get owner = some (.obj object)) (ordinary : object.kind = .ordinary)
    (disposed : findPriv brand disposedName object.priv = some (.data (.bool false) dw de))
    (handle : findPriv brand handleName object.priv = some (.data value hw he))
    (disposedLookup : lookupEnv (privName disposedName) env = some brand)
    (handleLookup : lookupEnv (privName handleName) env = some brand)
    (disposedNames : nameEq (privName disposedName) nThis = false ∧ nameEq (privName disposedName) nHome = false)
    (handleNames : nameEq (privName handleName) nThis = false ∧ nameEq (privName handleName) nHome = false)
    (fieldNote : notes.privates.owners owner = some ⟨brand,handleName,role⟩)
    (controlNote : notes.runtime.control = callNote (.obj getter) (.obj owner) [])
    (sourceBound : s₀.next+2 ≤ 2^64) (targetBound : s.next+2 ≤ 2^64) :
    let fn := getterFunction name disposedName handleName yes
    let live' := CellsLive (ClosureLive live s₀.next false home fn)
      (closureState s₀ fn env false home (.obj owner) [] .call).next []
    ∃ result,
      runC F 17 s₀ C₀ = some (getterCallResult s₀ name env home owner disposedName handleName yes value,C₀) ∧
      runC F 17 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live' framed before after old old'
        (getterCallResult s₀ name env home owner disposedName handleName yes value) result ∧
      RetainedInventory (getterCallNotes notes s₀.next owner role) ν₀ ν C₀ C R live'
        (getterCallResult s₀ name env home owner disposedName handleName yes value) result ∧
      result.ffi = s.ffi ∧ result.next ≤ s.next+2 ∧
      (∀ a, a < s.next → result.heap.get a = s.heap.get a) := by
  let fn := getterFunction name disposedName handleName yes
  let e := closureEnvironment s₀ fn env false home (.obj owner)
  obtain ⟨s4,left4,right4,h4,inv4,ffi4,next4,heap4⟩ := inventory.getter_entry_block h
    getter owner function name env home disposedName handleName yes control functionRead closure controlNote sourceBound targetBound
  have ownerLive := (inventory.privates.keyLive owner ⟨brand,handleName,role⟩ fieldNote).1
  have ownerRead : (getterEntryState s₀ name env home owner disposedName handleName yes).heap.get owner = some (.obj object) :=
    (closureState_heap_below F s₀ fn env false home (.obj owner) [] .call sourceBound owner (h.heap.sourceBound owner ownerLive)).trans objectRead
  have thisRead : (getterEntryState s₀ name env home owner disposedName handleName yes).heap.get s₀.next = some (.cell (some (.obj owner))) :=
    closureState_receiver F s₀ fn env home (.obj owner) [] .call sourceBound
  have thisNote : (getterEntryRuntime notes.runtime fn e s₀.next owner disposedName handleName yes).cells.cells s₀.next = some (.obj owner) := by
    change (notes.runtime.cells.write s₀.next (.obj owner)).cells s₀.next = _
    simp only [Notes.write,ite_true]
  obtain ⟨result,left17,right17,h17,inv17,heap17,ffi17,next17⟩ := inv4.getter_body_return_block h4
    e s₀.next owner brand disposedName handleName object value role dw de hw he yes s₀.stack
    ((statementFrameNotes e (.ifTest (.priv .this disposedName false) yes none)).headD (.node "" []))
    (blockFrameNote [.ret (some (.priv .this handleName false))] e) emptyScopeNote callBoundaryNote notes.runtime.stack
    rfl rfl (getter_environment_this s₀ name env home owner disposedName handleName yes)
    (getter_environment_private s₀ name env home owner disposedName handleName disposedName yes brand disposedNames disposedLookup)
    (getter_environment_private s₀ name env home owner disposedName handleName handleName yes brand handleNames handleLookup)
    thisRead ownerRead ordinary disposed handle thisNote fieldNote rfl
  refine ⟨result,runC_join F left4 left17,runC_join F right4 right17,h17,?_,ffi17.trans ffi4,?_,?_⟩
  · simpa only [getterCallResult,getterCallNotes,getterEntryRuntime,RetainedNotes.withRuntime,RuntimeNotes.closure,
      RuntimeNotes.bodyEntered,RuntimeNotes.blockNext,RuntimeNotes.statement,Bool.false_eq_true,ite_false] using inv17
  · rw [next17]
    exact next4
  · intro a below
    exact (congrArg (fun heap : PTrie HObj => heap.get a) heap17).trans (heap4 a below)

end Host.Ts.Owned.Annotated
