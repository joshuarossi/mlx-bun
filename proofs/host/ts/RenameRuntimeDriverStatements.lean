import host.ts.RenameRuntimeDriverValues
import host.ts.RenameRuntimeStatements
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta
open Parametric

/-- Emit checked original statement entries and nonempty block sequencing,
retaining the old stack notes below newly scheduled syntax. -/
elab "host_runtime_statement " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let pre := (← getCurrNamespace) ++ name.getId
  let entry ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let t ← Term.elabTermEnsuringType t stateTy
    for (tag,value) in [("F",f),("input",s),("output",t)] do
      let type? := if tag == "F" then none else
        some (mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F))))
      Parametric.Driver.addData (pre ++ Name.mkSimple tag) value type?
    let add (tag : String) (value : Lean.Expr) := Parametric.Driver.addData (pre ++ Name.mkSimple tag) value
    let ctl ← whnf (← mkAppM ``St.ctl #[s])
    if ctl.isAppOfArity ``Ctl.ex 2 then
      let stmt ← whnf ctl.getAppArgs[0]!
      let action ← match stmt.getAppFn.constName! with
        | ``Stmt.expr => pure (mkAppN (mkConst ``StatementAction.expression) stmt.getAppArgs)
        | ``Stmt.func => pure (mkAppN (mkConst ``StatementAction.function) stmt.getAppArgs)
        | ``Stmt.if_ => pure (mkAppN (mkConst ``StatementAction.ifTest) stmt.getAppArgs)
        | ``Stmt.throw => pure (mkAppN (mkConst ``StatementAction.throwExpression) stmt.getAppArgs)
        | ``Stmt.break => pure (mkAppN (mkConst ``StatementAction.breakLabel) stmt.getAppArgs)
        | ``Stmt.continue => pure (mkAppN (mkConst ``StatementAction.continueLabel) stmt.getAppArgs)
        | ``Stmt.empty => pure (mkConst ``StatementAction.empty)
        | ``Stmt.while_ => pure (mkAppN (mkConst ``StatementAction.whileTest) stmt.getAppArgs)
        | ``Stmt.doWhile => pure (mkAppN (mkConst ``StatementAction.doBody) stmt.getAppArgs)
        | ``Stmt.forOf => pure (mkAppN (mkConst ``StatementAction.forOfSource) stmt.getAppArgs)
        | ``Stmt.ret =>
          let value ← whnf stmt.getAppArgs[0]!
          if value.isAppOfArity ``Option.none 1 then pure (mkConst ``StatementAction.returnVoid)
          else pure (mkApp (mkConst ``StatementAction.returnExpression) (← Parametric.Driver.field value ``Option.some 2 1))
        | ``Stmt.decl =>
          let kind := stmt.getAppArgs[0]!
          let declarations ← whnf stmt.getAppArgs[1]!
          if declarations.isAppOfArity ``List.nil 1 then pure (mkApp (mkConst ``StatementAction.declarationEmpty) kind)
          else
            let declaration ← whnf (← Parametric.Driver.field declarations ``List.cons 3 1)
            let rest ← Parametric.Driver.field declarations ``List.cons 3 2
            let pattern ← Parametric.Driver.field declaration ``Prod.mk 4 2
            let value ← whnf (← Parametric.Driver.field declaration ``Prod.mk 4 3)
            if value.isAppOfArity ``Option.none 1 then
              pure (mkAppN (mkConst ``StatementAction.declarationUndef) #[kind,pattern,rest])
            else pure (mkAppN (mkConst ``StatementAction.declarationInit)
              #[kind,pattern,← Parametric.Driver.field value ``Option.some 2 1,rest])
        | _ => throwError "host_runtime_statement: unsupported source statement"
      add "sourceAction" action
      add "sourceEnv" ctl.getAppArgs[1]!
      pure true
    else
      let value ← Parametric.Driver.field ctl ``Ctl.ret 1 0
      let stack ← mkAppM ``St.stack #[s]
      let frame ← Parametric.Driver.field (← Parametric.Driver.field stack ``List.cons 3 1) ``Frame.s 1 0
      let statements ← whnf (← Parametric.Driver.field frame ``StmtF.block 2 0)
      unless statements.isAppOfArity ``List.cons 3 do throwError "host_runtime_statement: empty block requires exit rule"
      for (tag,value) in [("sourceValue",value),("sourceStatement",← Parametric.Driver.field statements ``List.cons 3 1),
        ("sourceRest",← Parametric.Driver.field statements ``List.cons 3 2),("sourceEnv",← Parametric.Driver.field frame ``StmtF.block 2 1),
        ("sourceTail",← Parametric.Driver.field stack ``List.cons 3 2)] do add tag value
      pure false
  liftTermElabM do
    let initial ← Term.elabTermEnsuringType initial (mkConst ``SSrv)
    let next ← Term.elabTermEnsuringType next (mkConst ``SSrv)
    Parametric.Driver.addData (pre ++ `initialServer) (← mkAppM ``numberServer #[initial])
    Parametric.Driver.addData (pre ++ `nextServer) (← mkAppM ``numberServer #[next])
  let n := "_root_." ++ pre.toString
  let header := "open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated in\n"
  let fact (tag proposition : String) := Parametric.Driver.emit (header ++ s!"theorem {n}.{tag} : {proposition} := by host_kernel_rfl")
  fact "source_step" s!"interpS (step {n}.F {n}.input).run {n}.initialServer = some ({n}.output,{n}.nextServer)"
  let parameters := s!"(notes : RuntimeNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
      (FR : Ren → {n}.F.S → {n}.F.S → Prop) (live framed : Nat → Prop) (before after : List Val) (old old' : List Event)
      (s : St {n}.F.S) (inst : Inst ν₀ {n}.initialServer C₀)
      (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.input s)
      (inventory : RuntimeInventory notes ν₀ ν C₀ C R live {n}.input s)"
  let (extra,postNotes,body) ← if entry then do
      fact "source_control" s!"{n}.input.ctl = .ex {n}.sourceAction.statement {n}.sourceEnv"
      fact "source_post" s!"{n}.sourceAction.advance {n}.input {n}.sourceEnv = {n}.output"
      pure ("",s!"notes.statement {n}.sourceAction {n}.sourceEnv",s!"
      obtain ⟨left,right,related,annotated⟩ := inventory.statement_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceAction {n}.sourceEnv {n}.source_control
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")
    else do
      fact "source_control" s!"{n}.input.ctl = .ret {n}.sourceValue"
      fact "source_frame" s!"{n}.input.stack = .s (.block ({n}.sourceStatement::{n}.sourceRest) {n}.sourceEnv)::{n}.sourceTail"
      fact "source_post" ("(({" ++ s!"{n}.input with stack := {n}.sourceTail" ++ "}.push (.s (.block " ++ s!"{n}.sourceRest {n}.sourceEnv))).go (.ex {n}.sourceStatement {n}.sourceEnv)) = {n}.output")
      pure ("(headNote : Annotated.Tree) (tailNotes : List Annotated.Tree) (stackNotes : notes.stack = headNote::tailNotes)",
        s!"notes.blockNext {n}.sourceStatement {n}.sourceRest {n}.sourceEnv tailNotes",s!"
      obtain ⟨result,left,right,related,annotated⟩ := inventory.block_next_step {n}.F FR notes ν₀ ν C₀ C R live framed before after old old'
        {n}.input s h {n}.sourceValue {n}.sourceStatement {n}.sourceRest {n}.sourceEnv {n}.sourceTail headNote tailNotes
        {n}.source_control {n}.source_frame stackNotes
      have source : interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) := by simpa only [{n}.source_post] using left
      exact ⟨_,source,right,{n}.source_post ▸ related,{n}.source_post ▸ annotated,
        pure_step_inst {n}.F ν₀ {n}.initialServer {n}.nextServer C₀ {n}.input {n}.output inst {n}.source_step source⟩")
  Parametric.Driver.emit (header ++ s!"theorem {n}.runtime_transport {parameters} {extra} :
      ∃ result, interpC (step {n}.F {n}.input).run C₀ = some ({n}.output,C₀) ∧
      interpC (step {n}.F s).run C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' {n}.output result ∧
      RuntimeInventory ({postNotes}) ν₀ ν C₀ C R live {n}.output result ∧ Inst ν₀ {n}.nextServer C₀ := by {body}")

end Host.Ts.Owned.Annotated.Driver
