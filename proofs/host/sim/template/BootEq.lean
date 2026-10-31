import host.sim.template.BridgeLiteral
import host.sim.template.a4pre_setup_native32.Origin
import host.sim.full.Raise
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta

private def ctorData (e : Lean.Expr) (ctor : Lean.Name) (arity : Nat) : MetaM Lean.Expr := do
  let mut e := e
  for _ in [0:16] do
    e := e.headBeta
    match e with
    | .mdata _ body => e := body
    | _ =>
      if e.isAppOfArity ctor arity then return e
      let .const n us := e.getAppFn | throwError "boot_rfl: expected {ctor} data"
      let ci ← getConstInfo n
      let some body := ci.value? | throwError "boot_rfl: no data body for {n}"
      e := mkAppN (body.instantiateLevelParams ci.levelParams us) e.getAppArgs
  throwError "boot_rfl: constructor alias bound exceeded"

private def setArg (e : Lean.Expr) (i : Nat) (v : Lean.Expr) : Lean.Expr :=
  mkAppN e.getAppFn (e.getAppArgs.set! i v)

private def parts (s : Lean.Expr) : MetaM (Lean.Expr × Lean.Expr × Lean.Expr × Lean.Expr) := do
  let aux ← ctorData s.getAppArgs[5]! ``Host.Ts.Aux.mk 5
  let outer ← ctorData aux.getAppArgs[2]! ``Prod.mk 4
  let inner ← ctorData outer.getAppArgs[2]! ``Prod.mk 4
  let ane ← ctorData inner.getAppArgs[2]! ``Host.Load.Ane.ASt.mk 2
  return (aux, outer, inner, ane)

/-- Reify both states with the already checked literal boot bridge, check the equation,
then transport it to the original states. No interpreter step is assumed. -/
elab "boot_rfl " p:ident " from " s:ident " to " t:ident " : " type:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let s := mkConst (← realizeGlobalConstNoOverloadWithInfo s)
  let t := mkConst (← realizeGlobalConstNoOverloadWithInfo t)
  let type ← Term.elabTermAndSynthesize type (some (mkSort .zero))
  let chosen ← ctorData (← getConstInfo ``Host.Load.Run.Tpl.PRENative32.s0).value! ``Host.Ts.St.mk 6
  let (_, _, _, chosenAne) ← parts chosen
  let snapshot := chosenAne.getAppArgs[1]!
  let boot := mkApp (mkConst ``Host.Load.Boot.replay) (mkConst ``Host.Load.Run.Prompt.P.oblog2818)
  let mut equations : Array Lean.Name := #[]
  let mut views : Array Lean.Expr := #[]
  for (raw, suffix) in [(s, "src"), (t, "dst")] do
    let source ← ctorData (← getConstInfo raw.constName!).value! ``Host.Ts.St.mk 6
    let (aux, outer, inner, ane) ← parts source
    let ane := setArg ane 1 snapshot
    let inner := setArg inner 2 ane
    let outer := setArg outer 2 inner
    let aux := setArg aux 2 outer
    let value := setArg source 5 aux
    let name := pre ++ Lean.Name.mkSimple suffix
    addDecl (.defnDecl (mkDefinitionValEx name [] (← inferType raw) value (.regular 0) .safe [name]))
    let view := mkConst name
    let withBridge := mkApp (mkConst ``Host.Load.Run.Tpl.PRENative32.withBridge) raw
    let functional := mkApp withBridge snapshot
    let viewEq := pre ++ Lean.Name.mkSimple (suffix ++ "_view")
    addDecl (.thmDecl { name := viewEq, levelParams := [], type := ← mkEq view functional, value := ← mkEqRefl view })
    let rawFfi ← mkAppM ``Host.Ts.St.ffi #[raw]
    let rawBridge ← mkAppM ``Host.Ts.Sim.Full.bridgeOf #[rawFfi]
    let rawEq := pre ++ Lean.Name.mkSimple (suffix ++ "_bridge")
    addDecl (.thmDecl { name := rawEq, levelParams := [], type := ← mkEq rawBridge boot, value := ← mkEqRefl rawBridge })
    let bridgeEq ← mkAppM ``Eq.trans #[← mkAppM ``Eq.symm #[mkConst ``Host.Load.Run.Tpl.PRENative32.bridge_exact],
      ← mkAppM ``Eq.symm #[mkConst rawEq]]
    let restore ← mkAppM ``Eq.trans #[← mkAppM ``congrArg #[withBridge, bridgeEq],
      ← mkAppM ``Host.Load.Run.Tpl.PRENative32.withBridge_self #[raw]]
    let proof ← mkAppM ``Eq.trans #[mkConst viewEq, restore]
    let eqName := pre ++ Lean.Name.mkSimple (suffix ++ "_eq")
    addDecl (.thmDecl { name := eqName, levelParams := [], type := ← mkEq view raw, value := ← instantiateMVars proof })
    equations := equations.push eqName
    views := views.push view
  let viewType ← instantiateMVars <| type.replace fun e =>
    if e == s then some views[0]! else if e == t then some views[1]! else none
  let some (_, lhs, _) := viewType.eq? | throwError "boot_rfl: expected an equality"
  let checked := pre ++ `checked
  addDecl (.thmDecl { name := checked, levelParams := [], type := viewType, value := ← mkEqRefl lhs })
  let srcEq := mkIdent equations[0]!
  let dstEq := mkIdent equations[1]!
  let checkedId := mkIdent checked
  let proof ← Term.elabTermAndSynthesize (← `(by simpa only [$srcEq:term, $dstEq:term] using $checkedId:term)) (some type)
  addDecl (.thmDecl { name := pre, levelParams := [], type, value := proof })

end Host.Ts.Sim.Template
