import host.ts.RuntimeInventoryArrayLength
import host.ts.RenameParametricShapeSpread

set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem step_typed_length_eq (F : Ffi) (s : St F.S) (a buffer off count : Nat) (o : Obj)
    (kind : EltK) (opt : Bool) (frames : List Frame) (control : s.ctl = .ret (.obj a))
    (stack : s.stack = .e (.member kLength opt)::frames)
    (read : s.heap.get a = some (.obj o)) (typed : o.kind = .typed kind buffer off count) :
    step F s = M.pure ({s with stack := frames}.ret (natV count)) := by
  funext β k
  simp only [step,control,stepRet,stack,retStep,retE,isNullish,Bool.and_false,Bool.cond_false,
    getV,lookup,getChain,St.obj?,read,ownGet,typed,
    show keyIndex kLength = none from rfl,
    show keyEq kLength kLength = true from rfl,M.bind,M.pure,readProp]
  rfl

end Host.Ts.Owned.Parametric

namespace Host.Ts.Owned.Annotated
open Parametric

/-- A typed view's length is fixed structural metadata in the heap relation.
The original getter yields that literal on both sides; no selected future
value, element interpretation or target property lookup is assumed. -/
theorem RetainedInventory.typed_length_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a buffer off count : Nat) (o : Obj) (kind : EltK) (opt : Bool) (frames : List Frame)
    (head : Tree) (tail : List Tree)
    (read : s₀.heap.get a = some (.obj o)) (typed : o.kind = .typed kind buffer off count)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .e (.member kLength opt)::frames)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with stack := frames}.ret (natV count)
      let t := {s with stack := targetFrames}.ret (natV count)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime
        {notes.runtime with control := returnNote (.literal (.lit (F64.ofNat count))),stack := tail})
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨value,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  have alive : live a := by
    have support := h.controlLive
    rw [control] at support
    exact support.1
  obtain ⟨targetObject,targetRead,targetTyped,_⟩ :=
    h.heap.read_typedBuffer a buffer off count o kind alive read typed
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.arrayLengthMember_view] at targetStack
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  have support := h.stackLive
  rw [stack] at support
  have sourceRole : (Value.literal (.lit (F64.ofNat count))).Holds ν₀ C₀ identity (natV count) :=
    .literal _ _ rfl
  have targetRole : (Value.literal (.lit (F64.ofNat count))).Holds ν C R (natV count) :=
    .literal _ _ rfl
  have sourceRun : interpC (step F s₀).run C₀ =
      some ({s₀ with stack := frames}.ret (natV count),C₀) := by
    rw [step_typed_length_eq F s₀ a buffer off count o kind opt frames control stack read typed]
    rfl
  have targetRun : interpC (step F s).run C =
      some ({s with stack := targetFrames}.ret (natV count),C) := by
    rw [step_typed_length_eq F s (R.a a) (R.a buffer) off count targetObject kind opt targetFrames
      targetControl targetStack targetRead targetTyped]
    rfl
  have post := (h.restack tailRelation support.2).go
    (c := .ret (natV count)) (c' := .ret (natV count))
    (.node _ (.cons (.value (Value.paired sourceRole targetRole)) .nil)) ⟨True.intro,True.intro⟩
  have runtime : RuntimeInventory
      {notes.runtime with control := returnNote (.literal (.lit (F64.ofNat count))),stack := tail}
      ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (natV count))
      ({s with stack := targetFrames}.ret (natV count)) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds targetRole,targetStackNotes.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetFrames,sourceRun,targetRun,post,
    inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
