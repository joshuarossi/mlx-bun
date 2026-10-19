import host.load.RuntimeCompiledArgumentEntryThrough279Joined
import host.load.RuntimeNamespacedDecodeFree2056Native

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_assert_retained_schema retained_through279, 279

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_through279, 278

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_through279, 280

theorem actual_entry279 : Region.s0 = NamespacedDecode.Free2056.output := by host_kernel_rfl

theorem actual_exit279 : Region.s279 = P.RestStream.micro0.micro23.s36 := by host_kernel_rfl

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  forallTelescopeReducing (← getConstInfo ``retained_through279).type fun args conclusion => do
    let conclusion ← whnf conclusion
    unless conclusion.isAppOfArity ``Exists 2 do throwError "compiled argument join: missing reached state"
    let native ← args.findM? fun arg => return (← arg.fvarId!.getDecl).userName == `FR
    let some native := native | throwError "compiled argument join: missing arbitrary native relation"
    withLocalDeclD `result conclusion.getAppArgs[0]! fun result => do
      let rec findState (type : Lean.Expr) : MetaM Lean.Expr := do
        let type ← whnf type
        if type.getAppFn.isConstOf ``Parametric.StateR then return type
        if type.isAppOfArity ``And 2 then
          let saved ← saveState
          try findState type.getAppArgs[0]! catch _ => saved.restore; findState type.getAppArgs[1]!
        else throwError "compiled argument join: missing full state relation"
      let post ← findState (mkApp conclusion.getAppArgs[1]! result)
      unless ← isDefEq post.getAppArgs[2]! native do
        throwError "compiled argument join: changed the native relation"
      unless ← isDefEq post.getAppArgs[post.getAppArgs.size-2]! (mkConst ``Region.s279) do
        throwError "compiled argument join: wrong reached source"

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
