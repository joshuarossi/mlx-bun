import host.sim.Chunk
import host.sim.template.InactiveView
import host.sim.template.BootEq
set_option Elab.async false
namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts

/-- Reify computed constructor fields while retaining existing named data and the
candidate's native-state expression. This chooses data; it proves no equality. -/
private partial def constructorData (native : Lean.Expr) (e : Lean.Expr) :
    StateT (Std.HashMap Lean.Expr Lean.Expr) MetaM Lean.Expr := do
  if e == native || e.isConst || e.isLit || e.isAppOfArity ``OfNat.ofNat 3 ||
      e.isAppOfArity ``Char.ofNat 1 then return e
  if let some result := (← get)[e]? then return result
  let original := e
  let e ← whnf e
  let result ← match e.getAppFn with
  | .const name _ =>
    match ← getConstInfo name with
    | .ctorInfo c =>
      let mut args := e.getAppArgs
      for i in [c.numParams:args.size] do
        let a := args[i]!
        unless ← isProp (← inferType a) do
          args := args.set! i (← constructorData native a)
      pure (mkAppN e.getAppFn args)
    | _ => pure e
  | _ => pure e
  modify fun cache => cache.insert original result
  return result

/-- A bounded full-world candidate with the original native-state expression.
The subsequent exact `runOk` equality checks this choice, including that field. -/
private def microCandidate (p f ok s c : TSyntax `ident) (n : TSyntax `num)
    (ending : Option (TSyntax `ident × TSyntax `ident)) (retainBridge : Bool := false)
    (check : Bool := true) : TermElabM Unit := do
  let pre := (← getCurrNamespace) ++ p.getId
  let F := mkConst (← realizeGlobalConstNoOverloadWithInfo f)
  let ok := mkConst (← realizeGlobalConstNoOverloadWithInfo ok)
  let s := mkConst (← realizeGlobalConstNoOverloadWithInfo s)
  let c := mkConst (← realizeGlobalConstNoOverloadWithInfo c)
  let n := n.getNat
  unless 0 < n && n ≤ 64 do throwError "sim_micro_candidate: expected 1 to 64 steps"
  let sTy ← inferType s
  let tyS := sTy.appArg!
  let path ← IO.getEnv "HOST_MICRO_TRACE"
  let trace (message : String) : IO Unit := match path with
    | none => pure ()
    | some path => IO.FS.withFile path .append fun file => file.putStrLn s!"{pre}: {message}"
  let (state, server) ← match ending with
    | some (t, d) => pure (mkConst (← realizeGlobalConstNoOverloadWithInfo t),
        mkConst (← realizeGlobalConstNoOverloadWithInfo d))
    | none => do
      trace "selecting bounded source run"
      let native := mkApp2 (mkConst ``St.ffi) tyS s
      let run := mkAppN (mkConst ``runS) #[F, mkRawNatLit n, s, c]
      let result ← whnf run
      trace "source run selected"
      unless result.isAppOfArity ``Option.some 2 do throwError "sim_micro_candidate: source run stuck"
      let pair ← whnf result.appArg!
      unless pair.isAppOfArity ``Prod.mk 4 do throwError "sim_micro_candidate: expected result pair"
      let state ← whnf pair.getAppArgs[2]!
      unless state.isAppOfArity ``St.mk 6 do throwError "sim_micro_candidate: expected machine state"
      let mut args := state.getAppArgs
      let aux ← whnf args[5]!
      unless aux.isAppOfArity ``Aux.mk 5 do throwError "sim_micro_candidate: expected auxiliary state"
      let (chosenFfi, frozen) ← if retainBridge then do
        unless ← isDefEq F (mkConst ``Host.Load.Layers.full) do
          throwError "sim_micro_bridge_candidate: expected the actual full FFI"
        let inner ← mkAppM ``Prod.fst #[native]
        let ane ← mkAppM ``Prod.fst #[inner]
        let bridge ← mkAppM ``Host.Load.Ane.ASt.bridge #[ane]
        let actual ← whnf aux.getAppArgs[2]!
        unless actual.isAppOfArity ``Prod.mk 4 do throwError "expected full FFI outer pair"
        let inner ← whnf actual.getAppArgs[2]!
        unless inner.isAppOfArity ``Prod.mk 4 do throwError "expected full FFI inner pair"
        let ane ← whnf inner.getAppArgs[2]!
        unless ane.isAppOfArity ``Host.Load.Ane.ASt.mk 2 do throwError "expected Neural Engine layer state"
        let ane := mkAppN ane.getAppFn (ane.getAppArgs.set! 1 bridge)
        let inner := mkAppN inner.getAppFn (inner.getAppArgs.set! 2 ane)
        pure (mkAppN actual.getAppFn (actual.getAppArgs.set! 2 inner), bridge)
      else pure (native, native)
      args := args.set! 5 (mkAppN aux.getAppFn (aux.getAppArgs.set! 2 chosenFfi))
      let (state, cache) ← (constructorData frozen (mkAppN state.getAppFn args)).run {}
      trace s!"state data normalized, {cache.size} shared expressions"
      let server ← (constructorData frozen pair.getAppArgs[3]!).run' cache
      trace "server data normalized"
      pure (state, server)
  let declare (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
    addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  declare (pre ++ `s1) sTy state
  declare (pre ++ `S1) (mkConst ``SSrv) server
  unless check do return
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) sTy (mkConst ``SSrv)
  let expected := mkApp2 (mkConst ``Option.some [.zero]) pairTy
    (mkApp4 (mkConst ``Prod.mk [.zero, .zero]) sTy (mkConst ``SSrv) (mkConst (pre ++ `s1)) (mkConst (pre ++ `S1)))
  let lhs := mkAppN (mkConst ``runOk) #[F, ok, mkRawNatLit n, s, c]
  trace "checking exact runOk equality"
  addDecl (.thmDecl { name := pre ++ `checked, levelParams := [], type := ← mkEq lhs expected, value := ← mkEqRefl lhs })
  trace "exact runOk equality kernel checked"
  logInfo m!"sim_micro_candidate {pre}: {n} steps kernel checked"

elab "sim_micro_candidate " p:ident f:ident ok:ident " from " s:ident ", " c:ident
    " steps " n:num : command => liftTermElabM <| microCandidate p f ok s c n none

elab "sim_micro_finish " p:ident f:ident ok:ident " from " s:ident ", " c:ident
    " steps " n:num " ending " t:ident ", " d:ident : command =>
  liftTermElabM <| microCandidate p f ok s c n (some (t, d))

elab "sim_micro_bridge_candidate " p:ident f:ident ok:ident " from " s:ident ", " c:ident
    " steps " n:num : command => liftTermElabM <| microCandidate p f ok s c n none true

elab "sim_micro_boot_candidate " p:ident f:ident ok:ident " from " s:ident ", " c:ident
    " steps " n:num : command => do
  let src := mkIdent (p.getId ++ `src)
  let raw := mkIdent (p.getId ++ `raw)
  let rawS := mkIdent (raw.getId ++ `s1)
  let rawT := mkIdent (raw.getId ++ `S1)
  let dst := mkIdent (p.getId ++ `s1)
  let srv := mkIdent (p.getId ++ `S1)
  let checked := mkIdent (p.getId ++ `checked)
  elabCommand (← `(bridge_literal $src from $s using Host.Load.Run.Tpl.PRENative32.s0))
  let mut current := src
  let mut currentSrv := c
  for i in [0:n.getNat] do
    let raw := mkIdent (p.getId ++ Lean.Name.mkSimple s!"raw{i}")
    let rawS := mkIdent (raw.getId ++ `s1)
    let rawT := mkIdent (raw.getId ++ `S1)
    let view := mkIdent (p.getId ++ Lean.Name.mkSimple s!"view{i}")
    liftTermElabM <| microCandidate raw f ok current currentSrv (Syntax.mkNumLit "1") none true false
    elabCommand (← `(bridge_literal $view from $rawS using Host.Load.Run.Tpl.PRENative32.s0))
    current := view
    currentSrv := rawT
  elabCommand (← `(bridge_literal $dst from $current using $s))
  elabCommand (← `(noncomputable def $srv : Host.Ts.SSrv := $currentSrv))
  elabCommand (← `(boot_rfl $checked from $s to $dst :
    Host.Ts.Sim.runOk $f $ok $n $s $c = some ($dst, $srv)))

elab "sim_micro_boot_finish " p:ident f:ident ok:ident " from " s:ident ", " c:ident
    " steps " n:num " ending " t:ident ", " d:ident : command => do
  let dst := mkIdent (p.getId ++ `s1)
  let srv := mkIdent (p.getId ++ `S1)
  let checked := mkIdent (p.getId ++ `checked)
  elabCommand (← `(noncomputable def $dst := $t))
  elabCommand (← `(noncomputable def $srv : Host.Ts.SSrv := $d))
  elabCommand (← `(boot_rfl $checked from $s to $t :
    Host.Ts.Sim.runOk $f $ok $n $s $c = some ($t, $d)))

end Host.Ts.Sim.Template
