import host.sim.template.ReturnLiteral
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta

private partial def symData (e : Lean.Expr) : MetaM Lean.Expr := do
  let e ← withOptions (smartUnfolding.set · false) <| withTransparency .all <| whnf e
  let args := e.getAppArgs
  if e.isAppOfArity ``Host.Ts.SymE.lit 1 then return e
  if e.isAppOfArity ``Host.Ts.SymE.var 1 then
    return mkApp e.getAppFn (← whnf args[0]!)
  if e.isAppOfArity ``Host.Ts.SymE.bin 3 then
    return mkAppN e.getAppFn #[← whnf args[0]!, ← symData args[1]!, ← symData args[2]!]
  if e.isAppOfArity ``Host.Ts.SymE.un 2 then
    return mkAppN e.getAppFn #[← whnf args[0]!, ← symData args[1]!]
  throwError "server_data: expected symbolic expression constructor"

/-- Reify a computed table for the native chooser. Subsequent run equalities check it. -/
elab "server_data " dest:ident " := " value:term : command => liftTermElabM do
  let value ← Term.elabTermAndSynthesize value (some (mkConst ``Host.Ts.SSrv))
  let value ← whnf value
  unless value.isAppOfArity ``Host.Ts.SSrv.mk 2 do throwError "server_data: expected server"
  let mut tab := value.getAppArgs[0]!
  let mut entries := #[]
  repeat
    tab ← whnf tab
    if tab.isAppOfArity ``List.nil 1 then break
    unless tab.isAppOfArity ``List.cons 3 do throwError "server_data: expected list"
    entries := entries.push (← symData tab.getAppArgs[1]!)
    tab := tab.getAppArgs[2]!
  let table ← mkListLit (mkConst ``Host.Ts.SymE) entries.toList
  let result := mkAppN value.getAppFn #[table, value.getAppArgs[1]!]
  let name := (← getCurrNamespace) ++ dest.getId
  addDecl (.defnDecl (mkDefinitionValEx name [] (mkConst ``Host.Ts.SSrv) result (.regular 0) .safe [name]))
end Host.Ts.Sim.Template
