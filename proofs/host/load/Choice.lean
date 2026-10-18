import host.load.Summary
namespace Host.Load.Extract
open Lean Elab Command Meta Host.Ts

private structure Sharing where
  pre : Lean.Name
  next : Nat := 0
  memo : Std.HashMap Lean.Expr (Lean.Expr × Nat) := {}
private abbrev SharingM := StateT Sharing TermElabM

private partial def share (e : Lean.Expr) : SharingM (Lean.Expr × Nat) := do
  if let some r := (← get).memo[e]? then return r
  let (v, cost) ← match e with
    | .app f a => do
      let (f, fc) ← share f
      let (a, ac) ← share a
      pure (Lean.mkApp f a, fc + ac + 1)
    | _ => pure (e, 1)
  let result ← if cost > 256 then do
      let s ← get
      let name := s.pre ++ Name.mkSimple s!"part{s.next}"
      modify fun s => { s with next := s.next + 1 }
      let ty ← inferType v
      let d := Declaration.defnDecl { name, levelParams := [], type := ty, value := v, hints := .regular 0, safety := .safe }
      addDecl d
      compileDecl d
      pure (mkConst name, 1)
    else pure (v, cost)
  modify fun s => { s with memo := s.memo.insert e result }
  pure result

/-- Native replay only chooses compact metadata. This command makes no source
execution claim: `load_summary_checked` must check the projection against a
separately checked stream boundary. No whole boundary heap is compiled. -/
elab "load_replay_summary " name:ident " : " boot:term ", " tab:term ", " valuation:term ", " steps:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let stTy := mkApp (mkConst ``St) (mkConst ``LSt)
  let optTy := mkApp (mkConst ``Option [.zero]) stTy
  let tabTy := mkApp (mkConst ``List [.zero]) (mkConst ``SymE)
  let rhoTy ← mkArrow (mkConst ``Nat) (mkConst ``F64)
  let bE ← instantiateMVars (← Term.elabTermAndSynthesize boot (some optTy))
  let tE ← instantiateMVars (← Term.elabTermAndSynthesize tab (some tabTy))
  let rE ← instantiateMVars (← Term.elabTermAndSynthesize valuation (some rhoTy))
  let kE ← instantiateMVars (← Term.elabTermAndSynthesize steps (some (mkConst ``Nat)))
  let some initial ← unsafe evalExpr (Option (St LSt)) optTy bE | throwError "load_replay_summary: boot failed"
  let tab ← unsafe evalExpr (List SymE) tabTy tE
  let rho ← unsafe evalExpr (Nat → F64) rhoTy rE
  let k ← unsafe evalExpr Nat (mkConst ``Nat) kE
  let started ← IO.monoMsNow
  let mut s := initial
  let mut srv : SSrv := ⟨tab, []⟩
  for i in [0:k] do
    match interpRec rho (step Host.Load.ffi s).run srv [] with
    | some (s', srv', _) => s := s'; srv := srv'
    | none => throwError "load_replay_summary: native replay stuck at {i}"
  let some metadata := loaded s (entryEnv initial) | throwError "load_replay_summary: extraction failed"
  let action : SharingM Lean.Expr := do return (← share (toExpr metadata)).1
  let (body, sharing) ← action.run { pre }
  let d := Declaration.defnDecl { name := pre, levelParams := [], type := mkConst ``Loaded, value := body, hints := .regular 0, safety := .safe }
  addDecl d
  compileDecl d
  logInfo m!"load_replay_summary {pre}: {k} native steps, {sharing.next} metadata pages, {(← IO.monoMsNow) - started} ms (candidate only)"

/-- Connect chosen metadata to the authoritative source state by a kernel
projection equality. The candidate's method of construction is irrelevant. -/
elab "load_summary_checked " name:ident " : " st:term ", " env:term " using " candidate:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let stTy := mkApp (mkConst ``St) (mkConst ``LSt)
  let s ← instantiateMVars (← Term.elabTermAndSynthesize st (some stTy))
  let e ← instantiateMVars (← Term.elabTermAndSynthesize env (some (mkConst ``Env)))
  let c ← instantiateMVars (← Term.elabTermAndSynthesize candidate (some (mkConst ``Loaded)))
  addDecl (.defnDecl { name := pre, levelParams := [], type := mkConst ``Loaded, value := c, hints := .regular 0, safety := .safe })
  let lhs := mkApp2 (mkConst ``loaded) s e
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) (mkConst ``Loaded) (mkConst pre)
  let ty ← mkEq lhs rhs
  addDecl (.thmDecl { name := pre ++ `matches, levelParams := [], type := ty, value := ← mkEqRefl lhs })

end Host.Load.Extract
