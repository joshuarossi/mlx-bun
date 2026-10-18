import host.ts.RenameRetainedFinally
import host.ts.RenameRuntimeDriverValues
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

/-- Source-selected cleanup for the array-returning decode route: save the
original returned object, or resume it when the real finalizer completes. -/
elab "host_retained_finally " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let entering ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value (if tag == "F" then none else some stateTy)
    let add (tag : String) (value : Lean.Expr) := Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
    let control ← whnf (← mkAppM ``St.ctl #[s])
    let stack ← mkAppM ``St.stack #[s]
    let frame ← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.s 1 0
    add "sourceTail" (← Parametric.Driver.field stack ``List.cons 3 2)
    if control.isAppOfArity ``Ctl.abr 1 then
      add "sourcePending" (← Parametric.Driver.field (← Parametric.Driver.field control.getAppArgs[0]! ``Abrupt.ret 1 0) ``Val.obj 1 0)
      add "sourceHandler" (← Parametric.Driver.field frame ``StmtF.try_ 3 0)
      add "sourceBody" (← Parametric.Driver.field (← Parametric.Driver.field frame ``StmtF.try_ 3 1) ``Option.some 2 1)
      add "sourceEnv" (← Parametric.Driver.field frame ``StmtF.try_ 3 2)
      pure true
    else
      add "sourceInitial" (← Parametric.Driver.field control ``Ctl.ret 1 0)
      let completion ← Parametric.Driver.field frame ``StmtF.finally_ 1 0
      let abrupt ← Parametric.Driver.field completion ``Comp.abrupt 1 0
      add "sourcePending" (← Parametric.Driver.field (← Parametric.Driver.field abrupt ``Abrupt.ret 1 0) ``Val.obj 1 0)
      pure false
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  let (extra,postLive,postNotes,call) ← if entering then do
      fact "source_control" s!"{n}.input.ctl = .abr (.ret (.obj {n}.sourcePending))"
      fact "source_frame" s!"{n}.input.stack = .s (.try_ {n}.sourceHandler (some {n}.sourceBody) {n}.sourceEnv)::{n}.sourceTail"
      fact "source_hoist" s!"noInitFunctions {n}.sourceBody = true"
      fact "source_names" s!"blockNames {n}.sourceBody = []"
      Parametric.Driver.emit (header ++ s!"theorem {n}.source_bound : {n}.input.next ≤ 2^64 := by decide +kernel")
      pure ("(bound : s.next ≤ 2^64)",s!"CellsLive live {n}.input.next (blockNames {n}.sourceBody)",
        s!"notes.withRuntime (notes.runtime.bodyEntered {n}.sourceBody {n}.sourceEnv (finallyObjectNote {n}.sourcePending::tail))",
        s!"inventory.return_finally_object_step h {n}.sourcePending {n}.sourceHandler {n}.sourceBody {n}.sourceEnv
          {n}.sourceTail head tail {n}.source_control {n}.source_frame stackNotes {n}.source_hoist {n}.source_names {n}.source_bound bound")
    else do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceInitial"
      fact "source_frame" s!"{n}.input.stack = .s (.finally_ (.abrupt (.ret (.obj {n}.sourcePending))))::{n}.sourceTail"
      pure ("","live",s!"notes.withRuntime ⟨abruptReturnNote (.obj {n}.sourcePending),tail,notes.runtime.cells⟩",
        s!"inventory.finally_object_resume_step h {n}.sourceInitial {n}.sourcePending {n}.sourceTail head tail
          {n}.source_control {n}.source_frame stackNotes")
  Parametric.Driver.emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  Parametric.Driver.emit (header ++ s!"theorem {n}.retained_transport
      (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop)
      (before after : List Val) (old old' : List Event) (s : St {n}.F.S)
      (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RetainedInventory notes ν₀ ν C₀ C R live {n}.input s)
      (head : Annotated.Tree) (tail : List Annotated.Tree) (stackNotes : notes.runtime.stack = head::tail) {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
        interpC (step {n}.F s).run C = some (result,C) ∧
        Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R ({postLive}) framed before after old old' {n}.output result ∧
        RetainedInventory ({postNotes}) ν₀ ν C₀ C R ({postLive}) {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by
      obtain ⟨frames,left,right,post,retained⟩ := {call}
      have source := {n}.source_run C₀
      have same := congrArg Prod.fst (Option.some.inj (left.symm.trans source))
      dsimp only at same
      rw [same] at post retained
      exact ⟨_,source,right,post,retained,pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀
        {n}.input {n}.output inst {n}.source_step source⟩")
end Host.Ts.Owned.Annotated.Driver
