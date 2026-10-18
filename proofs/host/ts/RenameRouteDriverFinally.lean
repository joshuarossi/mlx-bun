import host.ts.RenameRouteDriver
import host.ts.RenameParametricFinally
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

/-- Select an actual returning try/finally transition. Hoisting and every
chosen source/endpoint equation are kernel checked. -/
elab "host_transport_return_finally " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    unless ctl.isAppOfArity ``Ctl.abr 1 do throwError "host_transport_return_finally: expected return completion"
    let value ← field (← field ctl ``Ctl.abr 1 0) ``Abrupt.ret 1 0
    let stack ← mkAppM ``St.stack #[s]
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.s 1 0
    unless (← whnf frame).isAppOfArity ``StmtF.try_ 3 do throwError "host_transport_return_finally: expected try frame"
    let fin ← field (← field frame ``StmtF.try_ 3 1) ``Option.some 2 1
    for (tag,v) in [("F",f),("input",s),("output",t),("sourceValue",value),("sourceBody",fin),
      ("sourceHandler",← field frame ``StmtF.try_ 3 0),("sourceEnv",← field frame ``StmtF.try_ 3 2),
      ("sourceTail",← field stack ``List.cons 3 2)] do
      addData (pre ++ Name.mkSimple tag) v (if tag == "input" || tag == "output" then some stateTy else none)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  let fact (tag p : String) := emit (header ++ s!"theorem {n}.{tag} : {p} := by host_kernel_rfl")
  fact "source_control" s!"{n}.input.ctl = .abr (.ret {n}.sourceValue)"
  fact "source_frame" s!"{n}.input.stack = .s (.try_ {n}.sourceHandler (some {n}.sourceBody) {n}.sourceEnv)::{n}.sourceTail"
  fact "source_hoist" s!"noInitFunctions {n}.sourceBody = true"
  fact "source_post" ("enterBlock ({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}.push (.s (.finally_ (.abrupt (.ret " ++ s!"{n}.sourceValue))))) {n}.sourceBody {n}.sourceEnv = {n}.output")
  emit (header ++ s!"theorem {n}.source_bound : {n}.input.next+(blockNames {n}.sourceBody).length ≤ 2^64 := by decide +kernel")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s)
      (bound : s.next+(blockNames {n}.sourceBody).length ≤ 2^64) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R (CellsLive live {n}.input.next (blockNames {n}.sourceBody)) framed before after old old' {n}.output result := by
    obtain ⟨v,fs,_,run,related⟩ := step_return_finally_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h {n}.sourceValue {n}.sourceHandler {n}.sourceBody {n}.sourceEnv {n}.sourceTail
      {n}.source_control {n}.source_frame {n}.source_hoist {n}.source_bound bound
    exact ⟨_,run,{n}.source_post ▸ related⟩")
end Host.Ts.Owned.Parametric.Driver
