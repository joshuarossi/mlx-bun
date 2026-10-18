import host.ts.RenameRetainedUndefined

set_option Elab.async false
namespace Host.Ts

/-- Strict number/null equality never resolves or converts the number. -/
theorem step_number_null_seq_eq (F : Ffi) (s : St F.S) (value : NumV) (frames : List Frame)
    (control : s.ctl = .ret .null) (stack : s.stack = .e (.binR .seq (.num value))::frames) :
    step F s = M.pure ({s with stack := frames}.ret (.bool false)) := by
  funext β k
  simp only [step,control,stepRet,stack,retStep,retE,binOp,strictEq,M.bind,M.pure,retS]

end Host.Ts
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The non-null `optInt` guard follows from the current number/null
constructors. It preserves all inventories without a numeric-server query,
target value, branch answer or literal-only restriction. -/
theorem RetainedInventory.number_null_seq_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (value : NumV) (frames : List Frame) (control : s₀.ctl = .ret .null)
    (stack : s₀.stack = .e (.binR .seq (.num value))::frames) :
    ∃ targetFrames,
      interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.ret (.bool false),C₀) ∧
      interpC (step F s).run C = some ({s with stack := targetFrames}.ret (.bool false),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.ret (.bool false)) ({s with stack := targetFrames}.ret (.bool false)) ∧
      RetainedInventory (notes.withRuntime (notes.runtime.binaryResult (.bool false) notes.runtime.stack.tail))
        ν₀ ν C₀ C R live ({s₀ with stack := frames}.ret (.bool false)) ({s with stack := targetFrames}.ret (.bool false)) := by
  obtain ⟨_,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨left,frameEq,leftRelation⟩ := frameRelation.binR_view
  obtain ⟨targetValue,rfl,_⟩ := leftRelation.num_view
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
    by rw [step_number_null_seq_eq F s₀ value frames control stack]; rfl,
    by rw [step_number_null_seq_eq F s targetValue targetFrames targetControl targetStack]; rfl,
    post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩

end Host.Ts.Owned.Annotated
