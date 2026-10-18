import host.ts.RenameRuntimeParameterNotes
import host.ts.RenameClosureEntryFields
import host.ts.RenameParametricMapControl
set_option Elab.async false
namespace Host.Ts.Owned.Annotated
open Parametric

def RuntimeNotes.closure (notes : RuntimeNotes) (fn : Func) (args : List Value) (env : Env)
    (arrow : Bool) (receiver : Nat) (thisRole : Value) : RuntimeNotes :=
  {control := returnNote .undef,
   stack := parameterFrameNote fn (fnParams fn) args env::callBoundaryNote::notes.stack,
   cells := if arrow then notes.cells else notes.cells.write receiver thisRole}

/-- Original closure entry seeds the real parameter scheduler from the current
call's fixed argument roles. A non-arrow entry also records its newly allocated
receiver cell using that call's retained receiver meaning. -/
theorem RuntimeInventory.closure_step (F : Ffi) (FR : Ren → F.S → F.S → Prop)
    (notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s₀ s : St F.S)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' s₀ s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live s₀ s)
    (a : Nat) (o₀ : Obj) (fn : Func) (env : Env) (arrow : Bool) (home this₀ : Val) (args₀ : List Val)
    (fnRole thisRole : Value) (argRoles : List Value)
    (control : s₀.ctl = .call (.obj a) this₀ args₀) (object : s₀.heap.get a = some (.obj o₀))
    (closure : o₀.kind = .fn (.closure fn env arrow home))
    (controlNote : notes.control = callNote fnRole thisRole argRoles)
    (sourceBound : s₀.next+2+(paramNames fn).length ≤ 2^64)
    (targetBound : s.next+2+(paramNames fn).length ≤ 2^64) :
    ∃ targetHome targetThis targetArgs,
      interpC (step F s₀).run C₀ = some (closureState s₀ fn env arrow home this₀ args₀ .call,C₀) ∧
      interpC (step F s).run C = some
        (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (ClosureLive live s₀.next arrow home fn)
        framed before after old old'
        (closureState s₀ fn env arrow home this₀ args₀ .call)
        (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call) ∧
      RuntimeInventory
        (notes.closure fn argRoles (closureEnvironment s₀ fn env arrow home this₀) arrow s₀.next thisRole)
        ν₀ ν C₀ C R (ClosureLive live s₀.next arrow home fn)
        (closureState s₀ fn env arrow home this₀ args₀ .call)
        (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call) := by
  obtain ⟨callee,targetThis,targetArgs,targetControl,calleeRelation,_,_⟩ := (h.control_view control).call_view
  cases calleeRelation
  have alive : live a := by have support := h.controlLive; rw [control] at support; exact support.1
  obtain ⟨o,targetObject,objectRelation,_⟩ := h.heap.readObject a o₀ alive
    (h.heap.function_notFramed a o₀ _ alive object closure) object
  have kindRelation := objectRelation.kind
  rw [closure] at kindRelation
  obtain ⟨targetHome,targetClosure,_⟩ := kind_closure kindRelation
  obtain ⟨left,right,sourceRun,targetRun,post⟩ := step_closure_from_state F (NumberRoles ν₀ ν C₀ C) FR R C₀ C
    live framed before after old old' s₀ s h a o₀ fn env arrow home this₀ targetThis args₀ targetArgs
    control targetControl object closure sourceBound targetBound
  have actualSource : interpC (step F s₀).run C₀ = some (closureState s₀ fn env arrow home this₀ args₀ .call,C₀) := by
    rw [step_closure_eq F s₀ a o₀ fn env arrow home this₀ args₀ control object closure,enterClosure_state]
    rfl
  have actualTarget : interpC (step F s).run C = some
      (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call,C) := by
    rw [step_closure_eq F s (R.a a) o fn (R.env env) arrow targetHome targetThis targetArgs
      targetControl targetObject targetClosure,enterClosure_state]
    rfl
  have sourceEq := congrArg Prod.fst (Option.some.inj (sourceRun.symm.trans actualSource))
  have targetEq := congrArg Prod.fst (Option.some.inj (targetRun.symm.trans actualTarget))
  dsimp only at sourceEq targetEq
  rw [sourceEq,targetEq] at post
  have sourceCall := inventory.source.control
  have targetCall := inventory.target.control
  rw [controlNote,control] at sourceCall
  rw [controlNote,targetControl] at targetCall
  obtain ⟨_,sourceThis,sourceArguments⟩ := callNote_view sourceCall
  obtain ⟨_,targetThisRole,targetArguments⟩ := callNote_view targetCall
  have grow := ClosureLive.grow live s₀.next arrow home fn
  have framedCells : CellInventory notes.cells ν₀ ν C₀ C R (ClosureLive live s₀.next arrow home fn)
      (closureState s₀ fn env arrow home this₀ args₀ .call)
      (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call) :=
    inventory.cellInventory.frame grow
      (fun b role entry => closureState_heap_below F s₀ fn env arrow home this₀ args₀ .call sourceBound b
        (h.heap.sourceBound b (inventory.keyLive b role entry)))
      (fun b role entry => closureState_heap_below F s fn (R.env env) arrow targetHome targetThis targetArgs .call targetBound
        (R.a b) (h.heap.targetBound b (inventory.keyLive b role entry)))
  have cells : CellInventory (if arrow then notes.cells else notes.cells.write s₀.next thisRole)
      ν₀ ν C₀ C R (ClosureLive live s₀.next arrow home fn)
      (closureState s₀ fn env arrow home this₀ args₀ .call)
      (closureState s fn (R.env env) arrow targetHome targetThis targetArgs .call) := by
    cases arrow with
    | true => exact framedCells
    | false =>
      apply framedCells.annotate s₀.next thisRole (ClosureLive.receiver live s₀.next home fn)
      · simpa only [cellValueAt,identity,id_eq,closureState_receiver F s₀ fn env home this₀ args₀ .call sourceBound] using sourceThis
      · have fresh : R.a s₀.next = s.next := by simpa only [Nat.add_zero] using h.heap.fresh 0
        rw [fresh]
        simpa only [cellValueAt,closureState_receiver F s fn (R.env env) targetHome targetThis targetArgs .call targetBound] using targetThisRole
  have targetEnvironment := closureEnvironment_from_state fn env (R.env env) arrow home targetHome this₀ targetThis
    args₀ targetArgs post
  refine ⟨targetHome,targetThis,targetArgs,actualSource,actualTarget,post,cells.keyLive,?_,?_⟩
  · refine ⟨returnNote_holds .undef,?_,cells.source⟩
    rw [RuntimeNotes.closure,closureState_stack,List.map_cons,List.map_cons]
    exact .cons (by simpa only [identity_environment] using
      parameterFrameNote_holds (R:=identity) fn (fnParams fn) argRoles (closureEnvironment s₀ fn env arrow home this₀) args₀ sourceArguments)
      (.cons (callBoundaryNote_holds ν₀ C₀ identity) inventory.source.stack)
  · refine ⟨returnNote_holds .undef,?_,cells.target⟩
    rw [RuntimeNotes.closure,closureState_stack,List.map_cons,List.map_cons,targetEnvironment]
    exact .cons (parameterFrameNote_holds fn (fnParams fn) argRoles (closureEnvironment s₀ fn env arrow home this₀) targetArgs targetArguments)
      (.cons (callBoundaryNote_holds ν C R) inventory.target.stack)
end Host.Ts.Owned.Annotated
