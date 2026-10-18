import host.ts.RenameRetainedHeapFrame
import host.ts.RenameParametricMapControl
import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

theorem ForestHolds.tails {ν : Nat → F64} {C : CSrv} {R : Ren}
    {roles : List Tree} {values : List Owned.Tree} (h : ForestHolds ν C R roles values) :
    ForestHolds ν C R roles.tail values.tail := by
  cases h with
  | nil => exact .nil
  | cons _ tail => exact tail

/-- The absent-thisArg guard follows from the undefined constructors in the
initial StateR. It needs no numeric guard or new operand-role interpretation. -/
theorem RetainedInventory.undefined_sne_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (frames : List Frame) (control : s₀.ctl = .ret .undef)
    (stack : s₀.stack = .e (.binR .sne .undef)::frames) :
    ∃ targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret (.bool false),C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret (.bool false),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret (.bool false)) ({s with stack := targetFrames}.ret (.bool false)) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail))
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (.bool false)) ({s with stack := targetFrames}.ret (.bool false)) := by
  obtain ⟨v,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨left,frameEq,leftRelation⟩ := frameRelation.binR_view
  cases leftRelation
  rw [frameEq] at targetStack
  have sourceStack := inventory.runtime.source.stack
  have targetStackRoles := inventory.runtime.target.stack
  rw [stack,List.map_cons] at sourceStack
  rw [targetStack,List.map_cons] at targetStackRoles
  have runtime : RuntimeInventory (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail)
      ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (.bool false)) ({s with stack := targetFrames}.ret (.bool false)) :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.bool false),sourceStack.tails,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.bool false),targetStackRoles.tails,inventory.runtime.target.cells⟩⟩
  have support := h.stackLive
  rw [stack] at support
  have post := (h.restack tailRelation support.2).go
    (c:=.ret (.bool false)) (c':=.ret (.bool false))
    (.node _ (.cons (.value (.bool false)) .nil)) ⟨True.intro,True.intro⟩
  exact ⟨targetFrames,
    by rw [step_undefined_sne_eq F s₀ frames control stack]; rfl,
    by rw [step_undefined_sne_eq F s targetFrames targetControl targetStack]; rfl,
    post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
