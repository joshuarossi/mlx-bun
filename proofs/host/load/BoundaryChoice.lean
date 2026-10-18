import host.load.Choice
import host.load.CarrierChoice

namespace Host.Load.CacheBoundary
open Lean Elab Command Meta Host.Ts Host.Load.Extract Host.Mlx Host.Mlx.FfiEval

private structure Sharing where
  pre : Lean.Name
  next : Nat := 0
  memo : Std.HashMap Lean.Expr (Lean.Expr × Nat) := {}
private abbrev SharingM := StateT Sharing TermElabM

private partial def share (e : Lean.Expr) : SharingM (Lean.Expr × Nat) := do
  if let some result := (← get).memo[e]? then return result
  let (value, cost) ← match e with
    | .app f a => do
      let (f, fc) ← share f
      let (a, ac) ← share a
      pure (mkApp f a, fc+ac+1)
    | _ => pure (e, 1)
  let result ← if cost > 256 then do
      let s ← get
      let name := s.pre ++ Name.mkSimple s!"part{s.next}"
      modify fun s => { s with next := s.next+1 }
      let type ← inferType value
      let decl := Declaration.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe }
      addDecl decl
      compileDecl decl
      pure (mkConst name, 1)
    else pure (value, cost)
  modify fun s => { s with memo := s.memo.insert e result }
  pure result

/-- Choose only compact model/cache metadata. The separately required
`load_summary_checked` theorem ties this data to the original source state. -/
elab "load_boundary_summary " name:ident " : " state:term ", " entry:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let stTy := mkApp (mkConst ``St) (mkConst ``LSt)
  let sE ← instantiateMVars (← Term.elabTermAndSynthesize state (some stTy))
  let eE ← instantiateMVars (← Term.elabTermAndSynthesize entry (some (mkConst ``Host.Ts.Env)))
  let eE ← reduce eE
  let result ← reduce (mkApp2 (mkConst ``loaded) sE eE)
  unless result.isAppOfArity ``Option.some 2 do
    throwError "load_boundary_summary: extraction did not produce metadata"
  let ((body,_), sharing) ← (share result.getAppArgs[1]!).run { pre }
  let decl := Declaration.defnDecl { name := pre, levelParams := [], type := mkConst ``Loaded, value := body, hints := .regular 0, safety := .safe }
  addDecl decl
  compileDecl decl
  logInfo m!"load_boundary_summary {pre}: {sharing.next} metadata pages (candidate only)"

private unsafe def carriers (sE eE bE tE : Lean.Expr) : TermElabM (List Nat) := do
  let (nativeValue, cache) ← (ConstructorDecode.decode sE).run {}
  let (beforeValue, cache) ← (ConstructorDecode.decode bE).run cache
  let (tokenValue, _) ← (ConstructorDecode.decode tE).run cache
  let native : St LSt := unsafeCast nativeValue
  let before : Loaded := unsafeCast beforeValue
  let token : Tensor := unsafeCast tokenValue
  let nodeTy := mkApp2 (mkConst ``RNode) (mkConst ``Int) (mkConst ``InKey)
  let expected ← evalExpr (List (RNode Int InKey)) (mkApp (mkConst ``List [.zero]) nodeTy) eE
  match CarrierChoice.choose native.ffi.mlx SourceKernels.sources expected (inputNode before token) token.node with
  | .ok result => pure result
  | .error message => throwError "load_boundary_carriers: {message}"

/-- Constructor decoding and native search choose carrier data only. The
ordinary FFI family checker must check both Matches and input provenance. -/
elab "load_boundary_carriers " name:ident " : " state:term ", " expected:term
    ", " before:term ", " token:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let sE ← instantiateMVars (← Term.elabTermAndSynthesize state (some (mkApp (mkConst ``St) (mkConst ``LSt))))
  let eE ← instantiateMVars (← Term.elabTermAndSynthesize expected none)
  let bE ← instantiateMVars (← Term.elabTermAndSynthesize before (some (mkConst ``Loaded)))
  let tE ← instantiateMVars (← Term.elabTermAndSynthesize token (some (mkConst ``Tensor)))
  let result ← unsafe carriers sE eE bE tE
  let decl := Declaration.defnDecl { name := pre, levelParams := [], type := mkApp (mkConst ``List [.zero]) (mkConst ``Nat), value := toExpr result, hints := .regular 0, safety := .safe }
  addDecl decl
  compileDecl decl
  logInfo m!"load_boundary_carriers {pre}: {result.length} carriers (candidate only)"

end Host.Load.CacheBoundary
