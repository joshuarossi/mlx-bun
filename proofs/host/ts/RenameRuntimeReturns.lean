import host.ts.RenameRuntimeDispatch
import host.ts.RenameParametricReturnStep
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def abruptReturnNote (role : Value) : Tree := .node "Ctl.abr" [.node "Abrupt.ret" [.value role]]
def exitControlNote (exit : ReturnExit) (role : Value) : Tree := match exit with
  | .explicitReturn => abruptReturnNote role
  | .emptyScope => returnNote role
  | .emptyBlock | .implicitCall => returnNote .undef
def unwindControlNote (unwind : ReturnUnwind) (role : Value) : Tree := match unwind with
  | .call => returnNote role
  | .block _ | .scope => abruptReturnNote role
def RuntimeNotes.exitReturn (notes : RuntimeNotes) (exit : ReturnExit) (role : Value) (tail : List Tree) : RuntimeNotes :=
  {notes with control := exitControlNote exit role,stack := tail}
def RuntimeNotes.unwindReturn (notes : RuntimeNotes) (unwind : ReturnUnwind) (role : Value) (tail : List Tree) : RuntimeNotes :=
  {notes with control := unwindControlNote unwind role,stack := tail}

theorem abruptReturnNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (h : role.Holds ν C R value) : (abruptReturnNote role).Holds ν C R (Encode.ctl (.abr (.ret value))) :=
  .node _ (.cons (.node _ (.cons (.value h) .nil)) .nil)
theorem abruptReturnNote_view {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (h : (abruptReturnNote role).Holds ν C R (Encode.ctl (.abr (.ret value)))) : role.Holds ν C R value := by
  cases h with | node _ outer => cases outer with | cons inner _ =>
    cases inner with | node _ fields => cases fields with | cons value _ =>
      cases value with | value hv => exact hv
theorem exitControlNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (exit : ReturnExit) (h : role.Holds ν C R value) :
    (exitControlNote exit role).Holds ν C R (Encode.ctl (exit.control value)) := by
  cases exit with
  | explicitReturn => exact abruptReturnNote_holds h
  | emptyScope => exact returnNote_holds h
  | emptyBlock => exact returnNote_holds .undef
  | implicitCall => exact returnNote_holds .undef
theorem unwindControlNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren} {role : Value} {value : Val}
    (unwind : ReturnUnwind) (h : role.Holds ν C R value) :
    (unwindControlNote unwind role).Holds ν C R (Encode.ctl (unwind.control value)) := by
  cases unwind with
  | block _ => exact abruptReturnNote_holds h
  | scope => exact abruptReturnNote_holds h
  | call => exact returnNote_holds h

/-- Return/empty-scope/implicit exits preserve the selected occurrence's
meaning or produce the interpreter's fixed undefined result. -/
theorem RuntimeInventory.return_exit_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (exit : ReturnExit) (env : Env) (frames : List Frame)
    (headNote : Tree) (tailNotes : List Tree) (control : s₀.ctl = .ret value)
    (stack : s₀.stack = exit.frame env::frames) (controlNote : notes.control = returnNote role)
    (stackNotes : notes.stack = headNote::tailNotes) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.go (exit.control value),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.go (exit.control value)) result ∧
      RuntimeInventory (notes.exitReturn exit role tailNotes) ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.go (exit.control value)) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).ret_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.returnExit_view] at targetStack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  obtain ⟨left,right,related⟩ := step_return_exit_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h value targetValue exit env frames targetFrames control targetControl stack targetStack
  exact ⟨_,left,right,related,inventory.keyLive,
    ⟨exitControlNote_holds exit (returnNote_view sourceControl),sourceStack.tail,inventory.source.cells⟩,
    ⟨exitControlNote_holds exit (returnNote_view targetControlRole),targetStackRole.tail,inventory.target.cells⟩⟩

/-- Abrupt return traverses only the original lexical/call boundary, retaining
the same fixed value role until the real function boundary returns it. -/
theorem RuntimeInventory.return_unwind_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (value : Val) (role : Value) (unwind : ReturnUnwind) (env : Env) (frames : List Frame)
    (headNote : Tree) (tailNotes : List Tree) (control : s₀.ctl = .abr (.ret value))
    (stack : s₀.stack = unwind.frame env::frames) (controlNote : notes.control = abruptReturnNote role)
    (stackNotes : notes.stack = headNote::tailNotes) :
    ∃ result, interpC (step F s₀).run C₀ = some ({s₀ with stack := frames}.go (unwind.control value),C₀) ∧
      interpC (step F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        ({s₀ with stack := frames}.go (unwind.control value)) result ∧
      RuntimeInventory (notes.unwindReturn unwind role tailNotes) ν₀ ν C₀ C R live
        ({s₀ with stack := frames}.go (unwind.control value)) result := by
  obtain ⟨targetValue,targetControl,_⟩ := (h.control_view control).returnAbrupt_view
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  rw [frameRelation.returnUnwind_view] at targetStack
  have sourceControl := inventory.source.control
  have targetControlRole := inventory.target.control
  rw [controlNote,control] at sourceControl
  rw [controlNote,targetControl] at targetControlRole
  have sourceStack := inventory.source.stack
  have targetStackRole := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceStack
  rw [stackNotes,targetStack,List.map_cons] at targetStackRole
  obtain ⟨left,right,related⟩ := step_return_unwind_roles F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h value targetValue unwind env frames targetFrames control targetControl stack targetStack
  exact ⟨_,left,right,related,inventory.keyLive,
    ⟨unwindControlNote_holds unwind (abruptReturnNote_view sourceControl),sourceStack.tail,inventory.source.cells⟩,
    ⟨unwindControlNote_holds unwind (abruptReturnNote_view targetControlRole),targetStackRole.tail,inventory.target.cells⟩⟩

end Host.Ts.Owned.Annotated
