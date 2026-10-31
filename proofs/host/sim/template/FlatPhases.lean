import host.sim.template.FlatMicro
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts

private partial def phaseData (frozen e : Lean.Expr) :
    StateT (Std.HashMap Lean.Expr Lean.Expr) MetaM Lean.Expr := do
  if e == frozen || e.isConst || e.isLit || e.isAppOfArity ``OfNat.ofNat 3 ||
      e.isAppOfArity ``Char.ofNat 1 then return e
  if let some v := (← get)[e]? then return v
  let original := e
  let e ← whnf e
  let result ← match e.getAppFn with
  | .const name _ =>
    match ← getConstInfo name with
    | .ctorInfo c =>
      let mut args := e.getAppArgs
      for i in [c.numParams:args.size] do
        unless ← isProp (← inferType args[i]!) do
          args := args.set! i (← phaseData frozen args[i]!)
      pure (mkAppN e.getAppFn args)
    | _ => pure e
  | _ => pure e
  modify fun cache => (cache.insert original result).insert result result
  return result

elab "sim_flat_boot_choose " p:ident f:ident " from " s:ident ", " c:ident
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
    for _ in [0:n.getNat] do
      let run := mkAppN (mkConst ``runS) #[F, mkRawNatLit 1, state, server]
      let result ← whnf run
      unless result.isAppOfArity ``Option.some 2 do throwError "flat candidate: run stuck"
      let pair ← whnf result.appArg!
      unless pair.isAppOfArity ``Prod.mk 4 do throwError "flat candidate: expected pair"
      let (next, cache1) ← (phaseData frozen pair.getAppArgs[2]!).run cache
      let (nextServer, cache2) ← (phaseData frozen pair.getAppArgs[3]!).run cache1
      state := next
      server := nextServer
      cache := cache2
    let declare (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
      addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
    declare ((← getCurrNamespace) ++ view.getId) stateTy state
    declare ((← getCurrNamespace) ++ srv.getId) (mkConst ``SSrv) server
  elabCommand (← `(bridge_literal $dst from $view using $s))
  logInfo m!"flat candidate {p.getId}: {n.getNat} steps selected"

elab "sim_flat_boot_check " p:ident f:ident ok:ident " from " s:ident ", " c:ident
    " steps " n:num : command => do
  let dst := mkIdent (p.getId ++ `s1)
  let srv := mkIdent (p.getId ++ `S1)
  let checked := mkIdent (p.getId ++ `checked)
  elabCommand (← `(boot_rfl $checked from $s to $dst :
    Host.Ts.Sim.runOk $f $ok $n $s $c = some ($dst, $srv)))
  logInfo m!"flat candidate {p.getId}: exact run kernel checked"

end Host.Ts.Sim.Template
