import host.ts.RenameRetainedInventory
import host.ts.RenameRuntimeStatements
import host.ts.RenameParametricMapControl
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def branchControlNote (answer : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) : Tree :=
  if answer then statementNote yes env else
    match no with | some stmt => statementNote stmt env | none => returnNote .undef
theorem branchControlNote_holds (ν : Nat → F64) (C : CSrv) (R : Ren) (answer : Bool)
    (yes : Stmt) (no : Option Stmt) (env : Env) :
    (branchControlNote answer yes no env).Holds ν C R (Encode.ctl (branchCtl answer yes no (R.env env))) := by
  cases answer <;> cases no
  all_goals first
    | exact returnNote_holds .undef
    | exact statementNote_holds ν C R _ env

/-- Once the original comparison/guard step has returned a boolean, its
relation fixes the same boolean in the target. No target branch premise is
needed for the actual `if` dispatch. -/
theorem RetainedInventory.if_bool_step {F : Ffi} {FR : Ren → F.S → F.S → Prop}
    {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv} {R : Ren} {live framed : Nat → Prop}
    {before after : List Val} {old old' : List Event} {s₀ s : St F.S}
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (answer : Bool) (yes : Stmt) (no : Option Stmt) (env : Env) (frames : List Frame)
    (head : Tree) (tail : List Tree) (control : s₀.ctl = .ret (.bool answer))
    (stack : s₀.stack = .s (.if_ yes no env)::frames) (stackNotes : notes.runtime.stack = head::tail) :
    ∃ targetFrames,
      let t₀ := {s₀ with ctl := branchCtl answer yes no env,stack := frames}
      let t := {s with ctl := branchCtl answer yes no (R.env env),stack := targetFrames}
      interpC (step F s₀).run C₀ = some (t₀,C₀) ∧ interpC (step F s).run C = some (t,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' t₀ t ∧
      RetainedInventory (notes.withRuntime
        {notes.runtime with control := branchControlNote answer yes no env,stack := tail}) ν₀ ν C₀ C R live t₀ t := by
  obtain ⟨value,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  cases valueRelation
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.if_view] at targetStack
  have sourceNotes := inventory.runtime.source.stack
  have targetNotes := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  obtain ⟨sourceRun,targetRun,post⟩ := step_if_bool_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h answer yes no env frames targetFrames control targetControl stack targetStack
  have runtime : RuntimeInventory {notes.runtime with control := branchControlNote answer yes no env,stack := tail}
      ν₀ ν C₀ C R live {s₀ with ctl := branchCtl answer yes no env,stack := frames}
      {s with ctl := branchCtl answer yes no (R.env env),stack := targetFrames} :=
    ⟨inventory.runtime.keyLive,
      ⟨by simpa only [identity_environment] using branchControlNote_holds ν₀ C₀ identity answer yes no env,
        sourceNotes.tail,inventory.runtime.source.cells⟩,
      ⟨branchControlNote_holds ν C R answer yes no env,targetNotes.tail,inventory.runtime.target.cells⟩⟩
  have effects : PureRuntimeCase F s₀ s :=
    ⟨.of_pure F s₀ _ (step_if_bool_eq F s₀ answer yes no env frames control stack) ⟨rfl,rfl,rfl⟩,
      .of_pure F s _ (step_if_bool_eq F s answer yes no (R.env env) targetFrames targetControl targetStack) ⟨rfl,rfl,rfl⟩⟩
  exact ⟨targetFrames,sourceRun,targetRun,post,inventory.pure_step runtime effects sourceRun targetRun (.refl C₀) (.refl C)⟩
end Host.Ts.Owned.Annotated
