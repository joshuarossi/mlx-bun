import host.ts.RenameRuntimeForNotes

set_option Elab.async false

namespace Host.Ts.Owned.Annotated
open Parametric

inductive ForSchedulePhase where
  | testPhase
  | bodyPhase (guard : Bool)
def ForSchedulePhase.frame : ForSchedulePhase → Option Expr → Option Expr → Stmt → Env → List Name → List Name → LoopF
  | .testPhase,test,update,body,env,names,labels => .forTest false test update body env names labels
  | .bodyPhase _,test,update,body,env,names,labels => .forBody test update body env names labels
def ForSchedulePhase.value : ForSchedulePhase → Val → Val
  | .testPhase,value => value
  | .bodyPhase guard,_ => .bool guard
def ForSchedulePhase.schedule {S : Type} (phase : ForSchedulePhase) (s : St S)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) : St S :=
  match phase with
  | .testPhase => forTestState s test update body env names labels
  | .bodyPhase guard => forBodyState s guard test update body env names labels
def ForSchedulePhase.notes (phase : ForSchedulePhase) (notes : RuntimeNotes) (test update : Option Expr)
    (body : Stmt) (env : Env) (names labels : List Name) (tail : List Tree) : RuntimeNotes :=
  match phase with
  | .testPhase => notes.forTest test update body env names labels tail
  | .bodyPhase guard => notes.forBody guard test update body env names labels tail

theorem ForSchedulePhase.heap {S : Type} (phase : ForSchedulePhase) (s : St S)
    (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name) :
    (phase.schedule s test update body env names labels).heap = s.heap := by
  cases phase with
  | testPhase => cases test <;> rfl
  | bodyPhase guard => cases guard <;> rfl
theorem ForSchedulePhase.notes_holds {S : Type} (phase : ForSchedulePhase) (notes : RuntimeNotes)
    (ν : Nat → F64) (C : CSrv) (R : Ren) (test update : Option Expr) (body : Stmt)
    (env : Env) (names labels : List Name) (tail : List Tree) (s : St S)
    (frames : ForestHolds ν C R tail (s.stack.map Encode.frame)) (cells : notes.cells.Holds ν C R s) :
    (phase.notes notes test update body env names labels tail).Holds ν C R
      (phase.schedule s test update body (R.env env) names labels) := by
  cases phase with
  | testPhase => exact notes.forTest_holds ν C R test update body env names labels tail s frames cells
  | bodyPhase guard => exact notes.forBody_holds ν C R guard test update body env names labels tail s frames cells

/-- Testing or entering a for body only schedules existing syntax and frames.
The actual Boolean control relation determines the body/exit branch on both
sides, so no target guard or future heap fact is an input. -/
theorem RetainedInventory.for_schedule_step (F : Ffi) (phase : ForSchedulePhase) (FR : Ren → F.S → F.S → Prop)
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (test update : Option Expr) (body : Stmt) (env : Env) (names labels : List Name)
    (frames : List Frame) (headNote : Tree) (tailNotes : List Tree)
    (control : s₀.ctl = .ret (phase.value value))
    (stack : s₀.stack = .lp (phase.frame test update body env names labels)::frames)
    (stackNotes : notes.runtime.stack = headNote::tailNotes) :
    ∃ sourcePost targetPost, interpC (step F s₀).run C₀ = some (sourcePost,C₀) ∧
      interpC (step F s).run C = some (targetPost,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' sourcePost targetPost ∧
      RetainedInventory (notes.withRuntime (phase.notes notes.runtime test update body env names labels tailNotes))
        ν₀ ν C₀ C R live sourcePost targetPost := by
  obtain ⟨targetValue,targetControl,valueRelation⟩ := (h.control_view control).ret_view
  obtain ⟨targetFrame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  have targetFrameEq : targetFrame = .lp (phase.frame test update body (R.env env) names labels) := by
    cases phase with
    | testPhase => exact frameRelation.forTest_view
    | bodyPhase guard => exact frameRelation.forBody_view
  rw [targetFrameEq] at targetStack
  have actualTarget : s.ctl = .ret (phase.value targetValue) := by
    cases phase with
    | testPhase => exact targetControl
    | bodyPhase guard => cases valueRelation; exact targetControl
  have left : step F s₀ = M.pure (phase.schedule {s₀ with stack := frames} test update body env names labels) := by
    cases phase with
    | testPhase => exact step_for_test_eq F s₀ value test update body env names labels frames control stack
    | bodyPhase guard => exact step_for_body_eq F s₀ guard test update body env names labels frames control stack
  have right : step F s = M.pure (phase.schedule {s with stack := targetFrames} test update body (R.env env) names labels) := by
    cases phase with
    | testPhase => exact step_for_test_eq F s targetValue test update body (R.env env) names labels targetFrames actualTarget targetStack
    | bodyPhase guard => exact step_for_body_eq F s guard test update body (R.env env) names labels targetFrames actualTarget targetStack
  have paired : ∃ result, interpC (step F s₀).run C₀ = some
        (phase.schedule {s₀ with stack := frames} test update body env names labels,C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (phase.schedule {s₀ with stack := frames} test update body env names labels) result := by
    cases phase with
    | testPhase =>
      exact step_for_test_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
        s₀ s h value test update body env names labels frames control stack
    | bodyPhase guard =>
      exact step_for_body_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed before after old old'
        s₀ s h guard test update body env names labels frames control stack
  obtain ⟨result,sourceRun,targetRun,post⟩ := paired
  have targetRun' : interpC (step F s).run C =
      some (phase.schedule {s with stack := targetFrames} test update body (R.env env) names labels,C) := by rw [right]; rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans targetRun'))
  dsimp only at same
  rw [same] at post
  have sourceFrames := inventory.runtime.source.stack
  have targetFramesRole := inventory.runtime.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceFrames
  rw [stackNotes,targetStack,List.map_cons] at targetFramesRole
  have runtime : RuntimeInventory (phase.notes notes.runtime test update body env names labels tailNotes) ν₀ ν C₀ C R live
      (phase.schedule {s₀ with stack := frames} test update body env names labels)
      (phase.schedule {s with stack := targetFrames} test update body (R.env env) names labels) :=
    ⟨by cases phase with
        | testPhase => cases test <;> exact inventory.runtime.keyLive
        | bodyPhase guard => cases guard <;> exact inventory.runtime.keyLive,
      by simpa only [identity_environment] using phase.notes_holds notes.runtime ν₀ C₀ identity test update body env names labels tailNotes {s₀ with stack := frames} sourceFrames.tail inventory.runtime.source.cells,
      phase.notes_holds notes.runtime ν C R test update body env names labels tailNotes {s with stack := targetFrames} targetFramesRole.tail inventory.runtime.target.cells⟩
  refine ⟨_,_,sourceRun,targetRun',post,inventory.grow_heap_step runtime (fun _ alive => alive) ?_ ?_⟩
  · intro a _; rw [phase.heap]
  · intro a _; rw [phase.heap]

end Host.Ts.Owned.Annotated
