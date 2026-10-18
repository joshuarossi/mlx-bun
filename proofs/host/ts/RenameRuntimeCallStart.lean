import host.ts.RenameRuntimeArguments
import host.ts.RenameParametricCallStart
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def callStartFrameNote (mode : CallStart) (this : Value) (args : List Elem) (env : Env) : Tree :=
  .node "Frame.c" [match mode with
    | .callee optional => .node "CallF.callee" [.atom (List Elem) args,environmentNote env,.atom Bool optional]
    | .method optional => .node "CallF.method" [.value this,.atom (List Elem) args,environmentNote env,.atom Bool optional]
    | .construct => .node "CallF.newCallee" [.atom (List Elem) args,environmentNote env]]
def callReceiverNote (mode : CallStart) (this : Value) : Value :=
  match mode with | .method _ => this | _ => .undef

theorem callStartFrameNote_holds {ν : Nat → F64} {C : CSrv} {R : Ren}
    (mode : CallStart) (thisRole : Value) (args : List Elem) (env : Env) (this : Val)
    (role : (callReceiverNote mode thisRole).Holds ν C R (mode.receiver this)) :
    (callStartFrameNote mode thisRole args env).Holds ν C R (Encode.frame (mode.frame this args (R.env env))) := by
  cases mode with
  | callee optional => exact .node _ (.cons (.node _ (.cons (.atom (List Elem) args)
      (.cons (environmentNote_holds ν C R env) (.cons (.atom Bool optional) .nil)))) .nil)
  | method optional => exact .node _ (.cons (.node _ (.cons (.value role) (.cons (.atom (List Elem) args)
      (.cons (environmentNote_holds ν C R env) (.cons (.atom Bool optional) .nil))))) .nil)
  | construct => exact .node _ (.cons (.node _ (.cons (.atom (List Elem) args)
      (.cons (environmentNote_holds ν C R env) .nil))) .nil)

theorem callStartFrameNote_view {ν : Nat → F64} {C : CSrv} {R : Ren}
    (mode : CallStart) (thisRole : Value) (args : List Elem) (env : Env) (this : Val)
    (h : (callStartFrameNote mode thisRole args env).Holds ν C R (Encode.frame (mode.frame this args (R.env env)))) :
    (callReceiverNote mode thisRole).Holds ν C R (mode.receiver this) := by
  cases mode with
  | callee _ => exact .undef
  | construct => exact .undef
  | method _ =>
    cases h with | node _ outer =>
      cases outer with | cons inner _ =>
        cases inner with | node _ fields =>
          cases fields with | cons value _ =>
            cases value with | value value => exact value

/-- An actual object callee starts argument collection with its owned address
and exact saved receiver role. Optional-call tests follow from the object
control; no target guard or argument operand is supplied. -/
theorem RuntimeInventory.call_start_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (mode : CallStart) (a : Nat) (this : Val) (thisRole : Value) (args : List Elem) (env : Env) (frames : List Frame)
    (tailNotes : List Tree) (control : s₀.ctl = .ret (.obj a))
    (stack : s₀.stack = mode.frame this args env::frames)
    (stackNotes : notes.stack = callStartFrameNote mode thisRole args env::tailNotes) :
    ∃ targetThis targetFrames,
      interpC (step F s₀).run C₀ = some
        (argumentState {s₀ with stack := frames} mode.kind (.obj a) (mode.receiver this) [] args env,C₀) ∧
      interpC (step F s).run C = some
        (argumentState {s with stack := targetFrames} mode.kind (.obj (R.a a)) (mode.receiver targetThis) [] args (R.env env),C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        (argumentState {s₀ with stack := frames} mode.kind (.obj a) (mode.receiver this) [] args env)
        (argumentState {s with stack := targetFrames} mode.kind (.obj (R.a a)) (mode.receiver targetThis) [] args (R.env env)) ∧
      RuntimeInventory ({notes with stack := tailNotes}.arguments mode.kind (.obj a) (callReceiverNote mode thisRole) [] args env)
        ν₀ ν C₀ C R live
        (argumentState {s₀ with stack := frames} mode.kind (.obj a) (mode.receiver this) [] args env)
        (argumentState {s with stack := targetFrames} mode.kind (.obj (R.a a)) (mode.receiver targetThis) [] args (R.env env)) := by
  obtain ⟨targetValue,targetControl,receiver⟩ := (h.control_view control).ret_view
  cases receiver
  obtain ⟨frame,targetFrames,targetStack,frameRelation,_⟩ := h.stack_view stack
  obtain ⟨targetThis,frameEq,_⟩ := frameRelation.callStart_view mode
  rw [frameEq] at targetStack
  have sourceNotes := inventory.source.stack
  have targetNotes := inventory.target.stack
  rw [stackNotes,stack,List.map_cons] at sourceNotes
  rw [stackNotes,targetStack,List.map_cons] at targetNotes
  obtain ⟨sourceHead,sourceTail⟩ :
      (callStartFrameNote mode thisRole args env).Holds ν₀ C₀ identity (Encode.frame (mode.frame this args env)) ∧
      ForestHolds ν₀ C₀ identity tailNotes (frames.map Encode.frame) := by
    cases sourceNotes with | cons head tail => exact ⟨head,tail⟩
  obtain ⟨targetHead,targetTail⟩ :
      (callStartFrameNote mode thisRole args env).Holds ν C R (Encode.frame (mode.frame targetThis args (R.env env))) ∧
      ForestHolds ν C R tailNotes (targetFrames.map Encode.frame) := by
    cases targetNotes with | cons head tail => exact ⟨head,tail⟩
  have sourceThis := callStartFrameNote_view (ν:=ν₀) (C:=C₀) (R:=identity) mode thisRole args env this
    (by simpa only [identity_environment] using sourceHead)
  have targetThisRole := callStartFrameNote_view mode thisRole args env targetThis targetHead
  obtain ⟨result,sourceRun,targetRun,post⟩ := step_callStart_from_source F (NumberRoles ν₀ ν C₀ C) FR R C₀ C live framed
    before after old old' s₀ s h mode a this args env frames control stack
  have actual : interpC (step F s).run C = some
      (argumentState {s with stack := targetFrames} mode.kind (.obj (R.a a)) (mode.receiver targetThis) [] args (R.env env),C) := by
    rw [step_callStart_eq F s mode (R.a a) targetThis args (R.env env) targetFrames targetControl targetStack]
    rfl
  have same := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actual))
  dsimp only at same
  rw [same] at post
  refine ⟨targetThis,targetFrames,sourceRun,actual,post,?_,?_,?_⟩
  · rw [RuntimeNotes.arguments_cells]
    exact inventory.keyLive
  · have popped : ({notes with stack := tailNotes}).Holds ν₀ C₀ identity {s₀ with stack := frames} :=
      ⟨inventory.source.control,sourceTail,inventory.source.cells⟩
    simpa only [identity_environment] using popped.arguments mode.kind (.obj a) (callReceiverNote mode thisRole) []
      (.obj a) (mode.receiver this) [] args env (.obj a) sourceThis .nil
  · have popped : ({notes with stack := tailNotes}).Holds ν C R {s with stack := targetFrames} :=
      ⟨inventory.target.control,targetTail,inventory.target.cells⟩
    exact popped.arguments mode.kind (.obj a) (callReceiverNote mode thisRole) [] (.obj (R.a a)) (mode.receiver targetThis) []
      args env (.obj a) targetThisRole .nil
end Host.Ts.Owned.Annotated
