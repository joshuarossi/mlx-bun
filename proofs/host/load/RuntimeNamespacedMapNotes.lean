import host.load.RuntimeNamespacedMap223
set_option maxRecDepth 1000000
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.NamespacedMap
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``NamespacedMap.through223
  forallTelescope info.type fun args tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected retained batch endpoint"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec inventory (p : Lean.Expr) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf ``RetainedInventory then return p
        if p.isAppOfArity ``And 2 then
          try inventory p.getAppArgs[0]! catch _ => inventory p.getAppArgs[1]!
        else throwError "missing retained batch inventory"
      let retained ← inventory body
      for (name,index) in [(`arrayNotes,1),(`arrayLiveSet,7)] do
        let value := retained.getAppArgs[index]!
        let used ← args.filterM fun a => pure (value.find? (· == a)).isSome
        Parametric.Driver.addData ((← getCurrNamespace) ++ name) (← mkLambdaFVars used value)


end Host.Load.Run.Full.Ordinary.NamespacedMap
