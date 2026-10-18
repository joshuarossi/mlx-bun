import host.ts.RenameRouteDriver
import host.ts.RenameParametricStatements
import host.ts.RenameParametricUndefinedBranch
namespace Host.Ts.Owned.Parametric.Driver
open Lean Elab Command Meta

elab "host_transport_statement " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let ctl ← mkAppM ``St.ctl #[s]
    let st ← whnf (← field ctl ``Ctl.ex 2 0)
    let action ← match st.getAppFn.constName! with
      | ``Stmt.expr => pure (mkAppN (mkConst ``StatementAction.expression) st.getAppArgs)
      | ``Stmt.func => pure (mkAppN (mkConst ``StatementAction.function) st.getAppArgs)
      | ``Stmt.if_ => pure (mkAppN (mkConst ``StatementAction.ifTest) st.getAppArgs)
      | ``Stmt.throw => pure (mkAppN (mkConst ``StatementAction.throwExpression) st.getAppArgs)
      | ``Stmt.break => pure (mkAppN (mkConst ``StatementAction.breakLabel) st.getAppArgs)
      | ``Stmt.continue => pure (mkAppN (mkConst ``StatementAction.continueLabel) st.getAppArgs)
      | ``Stmt.empty => pure (mkConst ``StatementAction.empty)
      | ``Stmt.while_ => pure (mkAppN (mkConst ``StatementAction.whileTest) st.getAppArgs)
      | ``Stmt.doWhile => pure (mkAppN (mkConst ``StatementAction.doBody) st.getAppArgs)
      | ``Stmt.forOf => pure (mkAppN (mkConst ``StatementAction.forOfSource) st.getAppArgs)
      | ``Stmt.ret =>
        let value ← whnf st.getAppArgs[0]!
        if value.isAppOfArity ``Option.none 1 then pure (mkConst ``StatementAction.returnVoid)
        else pure (mkApp (mkConst ``StatementAction.returnExpression) (← field value ``Option.some 2 1))
      | _ => throwError "host_transport_statement: unsupported source statement {st.getAppFn}"
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceAction",action),("sourceEnv",← field ctl ``Ctl.ex 2 1)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ex {n}.sourceAction.statement {n}.sourceEnv := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_post : {n}.sourceAction.advance {n}.input {n}.sourceEnv = {n}.output := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result := by
    obtain ⟨_,hr,hs⟩ := step_statement_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h {n}.sourceAction {n}.sourceEnv {n}.source_control
    exact ⟨_,hr,{n}.source_post ▸ hs⟩")

elab "host_transport_undefined_branch " f:term ", " s:term " to " t:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    let stack ← mkAppM ``St.stack #[s]
    let iff ← field (← field (← field stack ``List.cons 3 1) ``Frame.s 1 0) ``StmtF.if_ 3 0
    let frame ← field (← field stack ``List.cons 3 1) ``Frame.s 1 0
    for (tag,value) in [("F",f),("input",s),("output",t),("sourceYes",iff),
      ("sourceNo",← field frame ``StmtF.if_ 3 1),("sourceEnv",← field frame ``StmtF.if_ 3 2),
      ("sourceTail",← field stack ``List.cons 3 2)] do
      addData (pre ++ Name.mkSimple tag) value (if tag == "input" || tag == "output" then some stateTy else none)
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric in\n"
  emit (header ++ s!"theorem {n}.source_control : {n}.input.ctl = .ret .undef := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_frame : {n}.input.stack = .s (.if_ {n}.sourceYes {n}.sourceNo {n}.sourceEnv)::{n}.sourceTail := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.source_run (C : CSrv) : interpC (step {n}.F {n}.input).run C = some ({n}.output,C) := by host_kernel_rfl")
  emit (header ++ s!"theorem {n}.transport (NR : NumV → NumV → Prop) (FR : Ren → {n}.F.S → {n}.F.S → Prop)
      (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (h : StateR NR FR R live framed before after old old' {n}.input s) :
      ∃ result, interpC (step {n}.F s).run C = some (result,C) ∧
        StateR NR FR R live framed before after old old' {n}.output result ∧ result.heap = s.heap := by
    obtain ⟨result,hr₀,hr,hs,heap⟩ := step_if_undefined_from_source {n}.F NR FR R C₀ C live framed before after old old'
      {n}.input s h {n}.sourceYes {n}.sourceNo {n}.sourceEnv {n}.sourceTail {n}.source_control {n}.source_frame
    rw [{n}.source_run] at hr₀
    have he := congrArg Prod.fst (Option.some.inj hr₀)
    dsimp only at he
    rw [← he] at hs
    exact ⟨result,hr,hs,heap⟩")
end Host.Ts.Owned.Parametric.Driver
