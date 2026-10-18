import host.ts.RenameRuntimeDriverExpression
import host.ts.RenameRuntimeDriverBinding
import host.ts.RenameRuntimeDriverStatements
import host.ts.RenameRuntimeDriverReturns
import host.ts.RenameRuntimeDriverDescent
import host.ts.RenameRuntimeDriverCallStart
import host.ts.RenameRuntimeDriverCallEntry
import host.ts.RenameRuntimeDriverParameters
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_runtime_step: source syntax cannot be printed"

/-- Source-only selection among the checked runtime rule families. Unsupported
constructors are rejected before any target execution or meaning is chosen. -/
elab "host_runtime_step " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let selected ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.ev 2 then
      let expression ← whnf control.getAppArgs[0]!
      if expression.isAppOfArity ``Expr.lit 1 || expression.isAppOfArity ``Expr.id 1 then
        pure "host_runtime_value"
      else if expression.isAppOfArity ``Expr.bin 3 then pure "host_runtime_structural"
      else if expression.isAppOfArity ``Expr.call 3 then pure "host_runtime_call_entry"
      else if #[``Expr.member,``Expr.index,``Expr.new,``Expr.chain,``Expr.await,``Expr.yield,
        ``Expr.log,``Expr.cond,``Expr.seq].contains expression.getAppFn.constName! then pure "host_runtime_descent"
      else throwError "host_runtime_step: unsupported source expression"
    else if control.isAppOfArity ``Ctl.ex 2 then pure "host_runtime_statement"
    else if control.isAppOfArity ``Ctl.abr 1 then pure "host_runtime_return"
    else if control.isAppOfArity ``Ctl.bind 5 then pure "host_runtime_binding"
    else if control.isAppOfArity ``Ctl.ret 1 then
      let frame ← whnf (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1)
      if frame.isAppOfArity ``Frame.e 1 then
        let expression ← whnf frame.getAppArgs[0]!
        if expression.isAppOfArity ``ExprF.binL 3 then pure "host_runtime_structural"
        else if expression.isAppOfArity ``ExprF.binR 2 then pure "host_runtime_arithmetic"
        else throwError "host_runtime_step: unsupported source expression continuation"
      else if frame.isAppOfArity ``Frame.c 1 then
        let call ← whnf frame.getAppArgs[0]!
        if call.isAppOfArity ``CallF.args 6 then pure "host_runtime_structural"
        else if #[``CallF.callee,``CallF.method,``CallF.newCallee].contains call.getAppFn.constName! then
          pure "host_runtime_call_start"
        else throwError "host_runtime_step: unsupported source call continuation"
      else if frame.isAppOfArity ``Frame.s 1 then
        let statement ← whnf frame.getAppArgs[0]!
        if statement.isAppOfArity ``StmtF.decl 4 then pure "host_runtime_binding"
        else if statement.isAppOfArity ``StmtF.block 2 then
          if (← whnf statement.getAppArgs[0]!).isAppOfArity ``List.nil 1 then pure "host_runtime_return"
          else pure "host_runtime_statement"
        else if statement.isConstOf ``StmtF.ret || statement.isAppOfArity ``StmtF.scope 1 then pure "host_runtime_return"
        else throwError "host_runtime_step: unsupported source statement continuation"
      else if frame.isAppOfArity ``Frame.k 1 then
        let fn ← whnf frame.getAppArgs[0]!
        if fn.isAppOfArity ``FnF.params 4 || fn.isAppOfArity ``FnF.paramDflt 5 then pure "host_runtime_parameter"
        else pure "host_runtime_return"
      else throwError "host_runtime_step: unsupported source continuation"
    else throwError "host_runtime_step: unsupported source control"
  Parametric.Driver.emit s!"{selected} {← printed f.raw}, {← printed s.raw} using {← printed initial.raw} to {← printed t.raw} using {← printed next.raw} as {name.getId}"

end Host.Ts.Owned.Annotated.Driver
