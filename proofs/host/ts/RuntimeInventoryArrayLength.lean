import host.ts.RenameParametricArrayLength
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The current array inventory fixes its length in both executions. The
getter produces that literal meaning, including when the array's elements
carry symbolic dimensions or native handles. -/
theorem RetainedInventory.array_length_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (a : Nat) (roles : List Value) (opt : Bool) (frames : List Frame)
    (head : Tree) (tail : List Tree) (entry : notes.arrays.owners a = some roles)
    (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = .e (.member kLength opt)::frames)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with stack := frames}.ret (natV roles.length)
      let t := {s with stack := targetFrames}.ret (natV roles.length)
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime
        {notes.runtime with control := returnNote (.literal (.lit (F64.ofNat roles.length))),stack := tail})
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨o₀,o,values,targetValues,sourceObject,sourceKind,targetObject,targetKind,
      sourceElements,targetElements,_,_⟩ := inventory.arrays.selected a roles entry
  have sourceLength : len values = roles.length := by
    simpa only [len_list_length] using (listR_length_eq sourceElements).symm
  have targetLength : len targetValues = roles.length := by
    simpa only [len_list_length] using (listR_length_eq targetElements).symm
  obtain ⟨value,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  rw [frameRelation.arrayLengthMember_view] at targetStack
  have sourceStack := inventory.runtime.source.stack
  have targetStackNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackNotes
  have support := h.stackLive
  rw [stack] at support
  have sourceRole : (Value.literal (.lit (F64.ofNat roles.length))).Holds ν₀ C₀ identity (natV roles.length) :=
    .literal _ _ rfl
  have targetRole : (Value.literal (.lit (F64.ofNat roles.length))).Holds ν C R (natV roles.length) :=
    .literal _ _ rfl
  have sourceRun : interpC (step F s₀).run C₀ =
      some ({s₀ with stack := frames}.ret (natV roles.length),C₀) := by
    rw [step_array_length_eq F s₀ a o₀ values opt frames control stack sourceObject sourceKind,sourceLength]
    rfl
  have targetRun : interpC (step F s).run C =
      some ({s with stack := targetFrames}.ret (natV roles.length),C) := by
    rw [step_array_length_eq F s (R.a a) o targetValues opt targetFrames targetControl targetStack targetObject targetKind,targetLength]
    rfl
  have post := (h.restack tailRelation support.2).go
    (c := .ret (natV roles.length)) (c' := .ret (natV roles.length))
    (.node _ (.cons (.value (Value.paired sourceRole targetRole)) .nil)) ⟨True.intro,True.intro⟩
  have runtime : RuntimeInventory
      {notes.runtime with control := returnNote (.literal (.lit (F64.ofNat roles.length))),stack := tail}
      ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (natV roles.length))
      ({s with stack := targetFrames}.ret (natV roles.length)) :=
    ⟨inventory.runtime.keyLive,⟨returnNote_holds sourceRole,sourceStack.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds targetRole,targetStackNotes.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetFrames,sourceRun,targetRun,post,
    inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
