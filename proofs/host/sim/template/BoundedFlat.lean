import host.sim.template.FlatPhases
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts

private def currentData (frozen state server : Lean.Expr) : Std.HashMap Lean.Expr Lean.Expr := Id.run do
  let mut pending := #[state, server]
  let mut result : Std.HashMap Lean.Expr Lean.Expr := {}
  while !pending.isEmpty do
    let e := pending.back!
    pending := pending.pop
    unless e == frozen || e.isConst || e.isLit || e.isAppOfArity ``OfNat.ofNat 3 ||
        e.isAppOfArity ``Char.ofNat 1 || result.contains e do
      result := result.insert e e
      match e with
      | .app f a => pending := pending.push f |>.push a
      | .lam _ d b _ | .forallE _ d b _ => pending := pending.push d |>.push b
      | .letE _ t v b _ => pending := pending.push t |>.push v |>.push b
      | .mdata _ b => pending := pending.push b
      | _ => pure ()
  return result

private partial def boundedData (frozen e : Lean.Expr) :
    StateT (Std.HashMap Lean.Expr Lean.Expr) MetaM Lean.Expr := do
  if e == frozen || e.isConst || e.isLit || e.isAppOfArity ``OfNat.ofNat 3 ||
      e.isAppOfArity ``Char.ofNat 1 then return e
  if let some v := (← get)[e]? then return v
  let original := e
  let e ← whnf e
  if e == frozen then return e
  let result ← match e.getAppFn with
  | .const name _ =>
    match ← getConstInfo name with
    | .ctorInfo c =>
      let mut args := e.getAppArgs
      for i in [c.numParams:args.size] do
        unless ← isProp (← inferType args[i]!) do
          args := args.set! i (← boundedData frozen args[i]!)
      pure (mkAppN e.getAppFn args)
    | _ => pure e
  | _ => pure e
  modify fun cache => (cache.insert original result).insert result result
  return result

elab "sim_bounded_boot_choose " p:ident f:ident " from " s:ident ", " c:ident
    " steps " n:num : command => do
  let src := mkIdent (p.getId ++ `src)
  elabCommand (← `(bridge_literal $src from $s using Host.Load.Run.Tpl.PRENative32.s0))
  let view := mkIdent (p.getId ++ `view)
  let dst := mkIdent (p.getId ++ `s1)
  let srv := mkIdent (p.getId ++ `S1)
  liftTermElabM do
    let F := mkConst (← realizeGlobalConstNoOverloadWithInfo f)
    let mut state := mkConst (← realizeGlobalConstNoOverloadWithInfo src)
    let stateTy ← inferType state
    let mut server := mkConst (← realizeGlobalConstNoOverloadWithInfo c)
    let ffi ← mkAppM ``St.ffi #[state]
    let bridge ← mkAppM ``Host.Ts.Sim.Full.bridgeOf #[ffi]
    let frozen ← whnf bridge
    unless 0 < n.getNat && n.getNat ≤ 512 do throwError "expected 1 to 512 steps"
    let mut cache : Std.HashMap Lean.Expr Lean.Expr := {}
    Lean.Meta.resetCache
    for i in [0:n.getNat] do
      let run := mkAppN (mkConst ``runS) #[F, mkRawNatLit 1, state, server]
      let result ← withOptions (smartUnfolding.set · false) <|
        withTransparency .all <| whnf run
      unless result.isAppOfArity ``Option.some 2 do throwError "flat candidate: run stuck"
      let pair ← whnf result.appArg!
      unless pair.isAppOfArity ``Prod.mk 4 do throwError "flat candidate: expected pair"
      let nextState ← whnf pair.getAppArgs[2]!
      unless nextState.isAppOfArity ``St.mk 6 do throwError "flat candidate: expected state"
      let nextAux ← whnf nextState.getAppArgs[5]!
      unless nextAux.isAppOfArity ``Aux.mk 5 do throwError "flat candidate: expected auxiliary state"
      let oldFfi ← whnf (← mkAppM ``St.ffi #[state])
      let newFfi ← whnf nextAux.getAppArgs[2]!
      let retained := if oldFfi == newFfi then oldFfi else frozen
      let (next, cache1) ← (boundedData retained nextState).run cache
      let (nextServer, cache2) ← (boundedData frozen pair.getAppArgs[3]!).run cache1
      state := next
      server := nextServer
      cache := cache2
      if i % 8 == 7 then
        let currentFfi ← whnf (← mkAppM ``St.ffi #[state])
        cache := currentData currentFfi state server
        Lean.Meta.resetCache
    Lean.Meta.resetCache
    let declare (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
      addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
    declare ((← getCurrNamespace) ++ view.getId) stateTy state
    declare ((← getCurrNamespace) ++ srv.getId) (mkConst ``SSrv) server
  elabCommand (← `(bridge_literal $dst from $view using $s))
  logInfo m!"bounded candidate {p.getId}: {n.getNat} steps selected"

end Host.Ts.Sim.Template
