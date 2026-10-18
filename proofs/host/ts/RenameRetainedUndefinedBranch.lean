import host.ts.RenameRetainedBranch
import host.ts.RenameRetainedHeapFrame
import host.ts.RenameParametricUndefinedBranch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

/-- The actual undefined guard is false by JavaScript truthiness. Its target
constructor is fixed by StateR, and all existing occurrence notes survive. -/
theorem RetainedInventory.if_undefined_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (yes : Stmt) (no : Option Stmt) (env : Env) (frames : List Frame)
    (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret .undef)
    (stack : s₀.stack = .s (.if_ yes no env)::frames) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with ctl := branchCtl false yes no env,stack := frames}
      let t := {s with ctl := branchCtl false yes no (R.env env),stack := targetFrames}
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime ⟨branchControlNote false yes no env,tail,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨value,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.if_view] at targetStack
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  obtain ⟨result,left,right,post,_⟩ := step_if_undefined_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h yes no env frames control stack
  have actual : interpC (step F s).run C =
      some ({s with ctl := branchCtl false yes no (R.env env),stack := targetFrames},C) := by
    rw [step_if_undefined_eq F s yes no (R.env env) targetFrames targetControl targetStack]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (right.symm.trans actual))
  dsimp only at same
  rw [same] at post
  have runtime : RuntimeInventory ⟨branchControlNote false yes no env,tail,notes.runtime.cells⟩ ν₀ ν C₀ C R live
      {s₀ with ctl := branchCtl false yes no env,stack := frames}
      {s with ctl := branchCtl false yes no (R.env env),stack := targetFrames} :=
    ⟨inventory.runtime.keyLive,
      ⟨by simpa only [identity_environment] using branchControlNote_holds ν₀ C₀ identity false yes no env,
        sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨branchControlNote_holds ν C R false yes no env,targetNotes.tail,inventory.runtime.target.cells⟩⟩
  exact ⟨targetFrames,left,actual,post,inventory.heap_step runtime rfl rfl (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
