import host.ts.RenameRuntimeDriverRetained
import host.ts.RenameRuntimeDriverClosure
import host.ts.RenameRuntimeDriverHeapReads
import host.ts.RenameRuntimeDriverPatterns
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Driver
open Lean Elab Command Meta

private def printed (stx : Syntax) : CommandElabM String :=
  match stx.reprint with
  | some text => pure text
  | none => throwError "host_retained_step: source syntax cannot be printed"

/-- Source-selected retained host rules. Native dispatch is registered by its
owning frontend. An unsupported source case is rejected before a target result
or a new operand meaning is selected. -/
elab "host_retained_step " f:term ", " s:term " using " initial:term " to " t:term " using " next:term " as " name:ident : command => do
  let selected ← liftTermElabM do
    let f ← Term.elabTermEnsuringType f (mkConst ``Ffi)
    let stateTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) f)
    let s ← Term.elabTermEnsuringType s stateTy
    let control ← whnf (← mkAppM ``St.ctl #[s])
    if control.isAppOfArity ``Ctl.ev 2 &&
        ((← whnf control.getAppArgs[0]!).isConstOf ``Expr.this ||
        (← whnf control.getAppArgs[0]!).isAppOfArity ``Expr.priv 3) then
      pure "host_retained_heap_read"
    else if control.isAppOfArity ``Ctl.bind 5 then pure "host_retained_pattern"
    else if control.isAppOfArity ``Ctl.call 3 then
      let a ← Parametric.Driver.field control.getAppArgs[0]! ``Val.obj 1 0
      let object ← Parametric.Driver.field (← mkAppM ``St.obj? #[s,a]) ``Option.some 2 1
      let code ← whnf (← Parametric.Driver.field (← mkAppM ``Obj.kind #[object]) ``Kind.fn 1 0)
      unless code.isAppOfArity ``Code.closure 4 do
        throwError "host_retained_step: native source call requires native retained frontend"
      pure "host_retained_closure"
    else if control.isAppOfArity ``Ctl.ret 1 then
      let frame ← whnf (← Parametric.Driver.field (← mkAppM ``St.stack #[s]) ``List.cons 3 1)
      if frame.isAppOfArity ``Frame.b 1 then pure "host_retained_pattern"
      else if frame.isAppOfArity ``Frame.s 1 && (← whnf frame.getAppArgs[0]!).isAppOfArity ``StmtF.declNext 3 then
        pure "host_retained_pattern"
      else if frame.isAppOfArity ``Frame.e 1 && (← whnf frame.getAppArgs[0]!).isAppOfArity ``ExprF.priv 3 then
        pure "host_retained_heap_read"
      else if frame.isAppOfArity ``Frame.k 1 then
        let fn ← whnf frame.getAppArgs[0]!
        if fn.isAppOfArity ``FnF.params 4 && (← whnf fn.getAppArgs[1]!).isAppOfArity ``List.nil 1 then
          pure "host_retained_parameter_body"
        else pure "host_retained_pure_step"
      else pure "host_retained_pure_step"
    else pure "host_retained_pure_step"
  Parametric.Driver.emit s!"{selected} {← printed f.raw}, {← printed s.raw} using {← printed initial.raw} to {← printed t.raw} using {← printed next.raw} as {name.getId}"

end Host.Ts.Owned.Annotated.Driver
