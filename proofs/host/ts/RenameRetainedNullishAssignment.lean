import host.ts.RenameParametricPrivateAssign
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameRuntimeDispatch
set_option Elab.async false
namespace Host.Ts.Owned.Parametric

theorem FrameR.logical_old_view {NR : NumV → NumV → Prop} {R : Ren}
    {op : LogOp} {target : Target} {rhs : Expr} {env : Env} {frame : Frame}
    (h : FrameR NR R (.a (.old (.log op) target rhs env)) frame) :
    ∃ target' rhs' env', frame = .a (.old (.log op) target' rhs' env') := by
  obtain ⟨af,rfl,relation⟩ := h.a_view
  have tag := relation.tag_eq
  cases af <;> simp only [Encode.asgF,treeTag] at tag
  all_goals try contradiction
  case old op' target' rhs' env' =>
    cases relation with | node _ fields =>
      cases fields with | cons hop fields =>
        cases hop
        exact ⟨target',rhs',env',rfl⟩

theorem step_nullish_object_eq (F : Ffi) (s : St F.S) (owner : Nat)
    (target : Target) (rhs : Expr) (env : Env) (frames : List Frame)
    (control : s.ctl = .ret (.obj owner))
    (stack : s.stack = .a (.old (.log .nullish) target rhs env)::frames) :
    step F s = M.pure {s with ctl := .ret (.obj owner),stack := frames} := by
  simp only [step,control,stepRet,stack,retStep,retA,isNullish,Bool.cond_false,retS,St.ret,St.go]
end Host.Ts.Owned.Parametric
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The existing object is returned by `??=`. Its constructor and resource
meaning come from the current state relation; the right-hand side is skipped. -/
theorem RetainedInventory.nullish_object_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (owner : Nat) (target : Target) (rhs : Expr) (env : Env) (frames : List Frame)
    (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret (.obj owner))
    (stack : s₀.stack = .a (.old (.log .nullish) target rhs env)::frames)
    (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with ctl := .ret (.obj owner),stack := frames}
      let t := {s with ctl := .ret (.obj (R.a owner)),stack := targetFrames}
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.obj owner),tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨value,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,tailRelation⟩ := h.stack_view stack
  obtain ⟨target',rhs',env',rfl⟩ := frameRelation.logical_old_view
  have sourceLive := h.stackLive
  rw [stack] at sourceLive
  have objectLive := h.controlLive
  rw [control] at objectLive
  have post : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      {s₀ with ctl := .ret (.obj owner),stack := frames}
      {s with ctl := .ret (.obj (R.a owner)),stack := targetFrames} :=
    (h.restack tailRelation sourceLive.2).go
      (.node _ (.cons (.value (.obj owner)) .nil)) objectLive
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  have runtime : RuntimeInventory ⟨returnNote (.obj owner),tail,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      {s₀ with ctl := .ret (.obj owner),stack := frames}
      {s with ctl := .ret (.obj (R.a owner)),stack := targetFrames} :=
    ⟨inventory.runtime.keyLive,
      ⟨returnNote_holds (.obj owner),sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨returnNote_holds (.obj owner),targetNotes.tail,inventory.runtime.target.cells⟩⟩
  refine ⟨targetFrames,?_,?_,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
  · rw [step_nullish_object_eq F s₀ owner target rhs env frames control stack]; rfl
  · rw [step_nullish_object_eq F s (R.a owner) target' rhs' env' targetFrames targetControl targetStack]; rfl
end Host.Ts.Owned.Annotated
