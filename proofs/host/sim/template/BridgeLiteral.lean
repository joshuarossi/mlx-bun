import host.sim.template.FullWorld
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta

private def literalCtor (e : Lean.Expr) (ctor : Lean.Name) (arity : Nat) : MetaM Lean.Expr := do
  let mut e := e
  for _ in [0:16] do
    e := e.headBeta
    match e with
    | .mdata _ body => e := body
    | _ =>
      if e.isAppOfArity ctor arity then return e
      let .const n us := e.getAppFn | throwError "bridge_literal: expected {ctor} data"
      let ci ← getConstInfo n
      let some body := ci.value? | throwError "bridge_literal: no data body for {n}"
      e := mkAppN (body.instantiateLevelParams ci.levelParams us) e.getAppArgs
  throwError "bridge_literal: {ctor} data exceeds the alias bound"

private def setArg (e : Lean.Expr) (i : Nat) (v : Lean.Expr) : Lean.Expr :=
  mkAppN e.getAppFn (e.getAppArgs.set! i v)

private def bridgeParts (s : Lean.Expr) : MetaM (Lean.Expr × Lean.Expr × Lean.Expr × Lean.Expr) := do
  let aux ← literalCtor s.getAppArgs[5]! ``Host.Ts.Aux.mk 5
  let outer ← literalCtor aux.getAppArgs[2]! ``Prod.mk 4
  let inner ← literalCtor outer.getAppArgs[2]! ``Prod.mk 4
  let ane ← literalCtor inner.getAppArgs[2]! ``Host.Load.Ane.ASt.mk 2
  return (aux, outer, inner, ane)

/-- Copy literal state data, changing only its bridge term. Uses must prove the
whole-state equality before counting any checked run from the chosen data. -/
elab "bridge_literal " dest:ident " from " src:ident " using " chosen:ident : command => liftTermElabM do
  let src ← realizeGlobalConstNoOverloadWithInfo src
  let chosen ← realizeGlobalConstNoOverloadWithInfo chosen
  let ci ← getConstInfo src
  let some body := ci.value? | throwError "bridge_literal: source has no data body"
  unless ci.levelParams.isEmpty do throwError "bridge_literal: expected a closed state type"
  let source ← literalCtor body ``Host.Ts.St.mk 6
  let chosenInfo ← getConstInfo chosen
  let some chosenBody := chosenInfo.value? | throwError "bridge_literal: chosen state has no data body"
  let chosenState ← literalCtor chosenBody ``Host.Ts.St.mk 6
  let (_, _, _, chosenAne) ← bridgeParts chosenState
  let (aux, outer, inner, ane) ← bridgeParts source
  let ane := setArg ane 1 chosenAne.getAppArgs[1]!
  let inner := setArg inner 2 ane
  let outer := setArg outer 2 inner
  let aux := setArg aux 2 outer
  let value := setArg source 5 aux
  let name := (← getCurrNamespace) ++ dest.getId
  addDecl (.defnDecl (mkDefinitionValEx name [] ci.type value (.regular 0) .safe [name]))

/-- A chooser view for an inactive bridge. The serializer must restore the real bridge,
and the generated start equality must check the complete original state. -/
elab "bridge_empty " dest:ident " from " src:ident : command => liftTermElabM do
  let src ← realizeGlobalConstNoOverloadWithInfo src
  let ci ← getConstInfo src
  let some body := ci.value? | throwError "bridge_empty: source has no data body"
  unless ci.levelParams.isEmpty do throwError "bridge_empty: expected a closed state type"
  let source ← literalCtor body ``Host.Ts.St.mk 6
  let (aux, outer, inner, ane) ← bridgeParts source
  let ane := setArg ane 1 (mkConst ``Host.Mlx.FfiAne.St.empty)
  let inner := setArg inner 2 ane
  let outer := setArg outer 2 inner
  let aux := setArg aux 2 outer
  let value := setArg source 5 aux
  let name := (← getCurrNamespace) ++ dest.getId
  addDecl (.defnDecl (mkDefinitionValEx name [] ci.type value (.regular 0) .safe [name]))

end Host.Ts.Sim.Template
