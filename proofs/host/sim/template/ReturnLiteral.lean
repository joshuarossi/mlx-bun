import host.sim.template.BridgeLiteral
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta

/-- Choose a return-reference boundary; its relation is supplied by `ReturnNum`. -/
elab "return_literal " dest:ident " from " src:ident " at " n:num : command => liftTermElabM do
  let src ← realizeGlobalConstNoOverloadWithInfo src
  let ci ← getConstInfo src
  let source ← whnf (mkConst src)
  unless source.isAppOfArity ``Host.Ts.St.mk 6 do throwError "return_literal: expected state data"
  let value := mkApp (mkConst ``Host.Ts.NumV.ref) (mkRawNatLit n.getNat)
  let ctl := mkApp (mkConst ``Host.Ts.Ctl.ret) (mkApp (mkConst ``Host.Ts.Val.num) value)
  let value := mkAppN source.getAppFn (source.getAppArgs.set! 3 ctl)
  let name := (← getCurrNamespace) ++ dest.getId
  addDecl (.defnDecl (mkDefinitionValEx name [] ci.type value (.regular 0) .safe [name]))

private partial def listData (e : Lean.Expr) : MetaM Lean.Expr := do
  let e ← whnf e
  if e.isAppOfArity ``List.nil 1 then return e
  unless e.isAppOfArity ``List.cons 3 do throwError "server_literal: expected list data"
  return mkAppN e.getAppFn (e.getAppArgs.set! 2 (← listData e.getAppArgs[2]!))

/-- Write constructor lists for the chooser, retaining a kernel-checkable source expression. -/
elab "server_literal " dest:ident " := " value:term : command => liftTermElabM do
  let value ← Term.elabTermAndSynthesize value (some (mkConst ``Host.Ts.SSrv))
  let value ← whnf value
  unless value.isAppOfArity ``Host.Ts.SSrv.mk 2 do throwError "server_literal: expected server data"
  let args := value.getAppArgs
  let value := mkAppN value.getAppFn #[← listData args[0]!, ← listData args[1]!]
  let name := (← getCurrNamespace) ++ dest.getId
  addDecl (.defnDecl (mkDefinitionValEx name [] (mkConst ``Host.Ts.SSrv) value (.regular 0) .safe [name]))

end Host.Ts.Sim.Template
