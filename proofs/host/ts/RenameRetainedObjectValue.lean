import host.ts.RenameParametricObjectValue
import host.ts.RenameRetainedObjectNext
import host.ts.RenameRetainedStores
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RetainedNotes.objectStored (notes : RetainedNotes) (owner : Nat) (name : Name) (role : Value)
    (tail : List Tree) (env : Env) (action : ObjectAction) : RetainedNotes :=
  ⟨(RuntimeNotes.mk (returnNote role) tail notes.runtime.cells).objectAction action owner env,
    notes.privates,notes.captures,notes.arrays,notes.publicFields.write owner name role,notes.buffers⟩

/-- Install the current retained initializer role, then schedule the next
original object-literal action. Every existing annotation family is preserved
and only the written public-field note changes. -/
theorem RetainedInventory.object_value_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner : Nat) (name : Name) (value : Val) (o₀ : Obj) (frames : List Frame) (env : Env)
    (action : ObjectAction) (valid : action.valid) (role : Value) (head : Tree) (tail : List Tree)
    (control : s₀.ctl = .ret value)
    (stack : s₀.stack = .l (.objVal owner (.str name) action.properties env)::frames)
    (object : s₀.heap.get owner = some (.obj o₀)) (ordinary : o₀.kind = .ordinary)
    (controlNote : notes.runtime.control = returnNote role) (stackNotes : notes.runtime.stack = head::tail)
    (sourceBound : s₀.next ≤ 2^64) (targetBound : s.next ≤ 2^64) :
    ∃ targetValue targetObject targetFrames,
      interpC (step F s₀).run C₀ = some (objectValueState s₀ owner o₀ name value frames env action,C₀) ∧
      interpC (step F s).run C = some (objectValueState s (R.a owner) targetObject name targetValue targetFrames (R.env env) action,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (objectValueState s₀ owner o₀ name value frames env action)
        (objectValueState s (R.a owner) targetObject name targetValue targetFrames (R.env env) action) ∧
      RetainedInventory (notes.objectStored owner name role tail env action) ν₀ ν C₀ C R live
        (objectValueState s₀ owner o₀ name value frames env action)
        (objectValueState s (R.a owner) targetObject name targetValue targetFrames (R.env env) action) := by
  obtain ⟨targetValue,targetObject,targetFrames,targetRead,left,right,post⟩ := step_object_value_from_source F
    (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old' s₀ s h
    owner name value o₀ frames env action valid control stack object ordinary sourceBound targetBound
  obtain ⟨actualValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,actualFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.objectValue_view] at targetStack
  -- The core theorem selected these actual values from the same control and
  -- stack projections. Recover the unique representatives for annotation use.
  have actualTarget := step_object_value_eq F s (R.a owner) name actualValue targetObject actualFrames (R.env env) action valid
    targetControl targetStack targetRead (by
      have support := h.stackLive
      rw [stack] at support
      obtain ⟨o,read,relation,_⟩ := h.heap.readOrdinary owner o₀ support.1.1.1 object ordinary
      have equal := HObj.obj.inj (Option.some.inj (read.symm.trans targetRead))
      exact equal ▸ relation.ordinary ordinary)
  have sourceControl := inventory.runtime.source.control
  have targetRoleControl := inventory.runtime.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetRoleControl
  have sourceRole := returnNote_view sourceControl
  have targetRole := returnNote_view targetRoleControl
  have sourceStack := inventory.runtime.source.stack
  have targetStackRole := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  have support := h.stackLive
  rw [stack] at support
  have alive : live owner := support.1.1.1
  have sourceWord := Nat.lt_of_lt_of_le (h.heap.sourceBound owner alive) sourceBound
  have targetWord := Nat.lt_of_lt_of_le (h.heap.targetBound owner alive) targetBound
  let new₀ := {o₀ with props := setPropL (.str name) (.data value true true) o₀.props}
  let new := {targetObject with props := setPropL (.str name) (.data actualValue true true) targetObject.props}
  have cells := inventory.runtime.cellInventory.setObject h.heap owner o₀ targetObject new₀ new value actualValue
    alive object targetRead sourceWord targetWord
  have privateFields := inventory.privates.setProps owner o₀ targetObject new₀.props new.props object targetRead sourceWord targetWord
  have captures := inventory.captures.setOrdinary h.heap owner o₀ new₀ new value actualValue alive object ordinary sourceWord targetWord
  have arrayHeld := inventory.arrays.setOrdinary h.heap owner o₀ new₀ new value actualValue alive object ordinary sourceWord targetWord
  have publicFields := inventory.publicFields.store h.heap owner o₀ targetObject name role value actualValue true true
    alive object targetRead sourceRole targetRole sourceWord targetWord
  have buffers := inventory.buffers.setOrdinary h.heap owner o₀ new₀ new value actualValue alive object ordinary sourceWord targetWord
  let baseNotes : RuntimeNotes := ⟨returnNote role,tail,notes.runtime.cells⟩
  have runtimeBase : RuntimeInventory baseNotes ν₀ ν C₀ C R live
      (({s₀ with stack := frames}.setObj owner new₀).ret value)
      (({s with stack := actualFrames}.setObj (R.a owner) new).ret actualValue) :=
    ⟨cells.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,cells.source⟩,
      ⟨returnNote_holds targetRole,targetStackRole.tail,cells.target⟩⟩
  have runtime : RuntimeInventory (baseNotes.objectAction action owner env) ν₀ ν C₀ C R live
      (objectValueState s₀ owner o₀ name value frames env action)
      (objectValueState s (R.a owner) targetObject name actualValue actualFrames (R.env env) action) := by
    refine ⟨cells.keyLive,?_,?_⟩
    · have sourceOwner : identity.a owner = owner := rfl
      simpa only [sourceOwner,identity_environment,objectValueState,ObjectAction.advance,St.ret,St.go,new₀] using
        runtimeBase.source.objectAction action owner env
    · exact runtimeBase.target.objectAction action owner env
  have actualRun : interpC (step F s).run C = some
      (objectValueState s (R.a owner) targetObject name actualValue actualFrames (R.env env) action,C) := by rw [actualTarget]; rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actualRun))
  dsimp only at same
  rw [same] at post
  refine ⟨actualValue,targetObject,actualFrames,left,actualRun,post,runtime,?_,?_,?_,?_,?_⟩
  · exact privateFields.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact captures.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact arrayHeld.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
  · exact publicFields.frame (fun _ h => h) (fun _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
  · exact buffers.frame (fun _ h => h) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
end Host.Ts.Owned.Annotated
