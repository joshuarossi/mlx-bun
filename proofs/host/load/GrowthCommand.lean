import host.load.Growth
import host.load.Micro
import host.load.Summary

namespace Host.Load.Growth
open Lean Elab Command Meta Host.Ts Host.Ts.Stream

deriving instance Lean.ToExpr for Roots

private def define (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

/-- Restore candidate data for a source fragment and retain its imported
serialization aliases. This constructs no execution theorem. -/
unsafe def restoreChoiceState (state server : Lean.Expr) (pre : Lean.Name) :
    TermElabM (St LSt × SSrv × G) := do
  let (s, decoded) ← (ConstructorDecode.decode state).run {}
  let (c, decoded) ← (ConstructorDecode.decode server).run decoded
  let names : Std.HashSet Lean.Name := decoded.aliases.foldl (fun set a => set.insert a.1) {}
  let env ← getEnv
  let mut g : G := { pre }
  for (name, type, value) in decoded.aliases do
    let constants := match env.find? name with
      | some (.defnInfo d) => d.value.getUsedConstants
      | _ => #[]
    g := { g with
      memo := g.memo.insert (ptrAddrUnsafe value, type) (name, value)
      deps := g.deps.insert name ((type.getUsedConstants ++ constants).filter names.contains) }
  return (unsafeCast s, unsafeCast c, g)

private def stateType : Lean.Expr := mkApp (mkConst ``St) (mkConst ``LSt)
private def listType (type : Lean.Expr) : Lean.Expr := mkApp (mkConst ``List [.zero]) type

-- Construct only introductions and reflexivity. In particular, do not ask the
-- elaborator to accept a computed geometry assertion before the kernel sees
-- it; a wrong selected root or header fails ordinary kernel conversion.
private partial def reflexiveConjunction (type : Lean.Expr) : TermElabM Lean.Expr := do
  let type ← whnf type
  if type.isAppOfArity ``And 2 then
    let args := type.getAppArgs
    return mkApp4 (mkConst ``And.intro) args[0]! args[1]!
      (← reflexiveConjunction args[0]!) (← reflexiveConjunction args[1]!)
  if type.isAppOfArity ``Eq 3 then
    let args := type.getAppArgs
    let levels := type.getAppFn.constLevels!
    return mkApp2 (mkConst ``Eq.refl levels) args[0]! args[1]!
  throwError "host_growth_fragment: unexpected geometry proposition {type}"

elab "host_growth_entry_checked " name:ident " : " state:term " using " chosen:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let s ← instantiateMVars (← Term.elabTermAndSynthesize state (some stateType))
  let roots ← instantiateMVars (← Term.elabTermAndSynthesize chosen (some (mkConst ``Roots)))
  let type := mkApp2 (mkConst ``Entry) s roots
  let value ← reflexiveConjunction type
  addDecl (.thmDecl { name := (← getCurrNamespace) ++ name.getId, levelParams := [], type, value })

elab "host_growth_outcome_checked " name:ident " : " state:term ", " address:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let s ← instantiateMVars (← Term.elabTermAndSynthesize state (some stateType))
  let cache ← instantiateMVars (← Term.elabTermAndSynthesize address (some (mkConst ``Nat)))
  let lhs := mkApp2 (mkConst ``outcome) s cache
  let normalized ← reduce lhs
  unless normalized.isAppOfArity ``Option.some 2 do
    throwError "host_growth_outcome_checked: no returned tensor pair"
  define pre (mkConst ``Outcome) normalized.getAppArgs[1]!
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) (mkConst ``Outcome) (mkConst pre)
  let type ← mkEq lhs rhs
  let value ← mkEqRefl lhs
  addDecl (.thmDecl { name := pre ++ `matches, levelParams := [], type, value })

/-- Choose a positive-capacity growth fragment at the next real repository
`KVCache.updateAndFetch` call. The changed offset is an explicit hypothetical
entry specialization, never a reachability theorem. Ordinary `host_chunk`
obligations subsequently check every interpreter transition. -/
elab "host_growth_fragment " name:ident " from " state:term ", " server:term
    " valuation " valuation:term " seek " limit:num " width " width:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let width := width.getNat
  if width == 0 then throwError "host_growth_fragment: width must be positive"
  let sE ← instantiateMVars (← Term.elabTermAndSynthesize state (some stateType))
  let cE ← instantiateMVars (← Term.elabTermAndSynthesize server (some (mkConst ``SSrv)))
  let rhoTy ← mkArrow (mkConst ``Nat) (mkConst ``F64)
  let rhoE ← instantiateMVars (← Term.elabTermAndSynthesize valuation (some rhoTy))
  let rho ← unsafe evalExpr (Nat → F64) rhoTy rhoE
  astTabRef.set (← loadAstTab)
  Memo.reset
  let started ← IO.monoMsNow
  let (initial, initialC, initialG) ← unsafe restoreChoiceState sE cE pre
  let mut s := initial
  let mut c := initialC
  let mut seekSteps : Nat := 0
  while !isUpdateCall s do
    if seekSteps == limit.getNat then throwError "host_growth_fragment: source call not found"
    match interpS (step Host.Load.ffi s).run c with
    | none => throwError "host_growth_fragment: original source path stuck at {seekSteps}"
    | some (s', c') => s := s'; c := c'; seekSteps := seekSteps + 1
  let some sourceRoots := roots s | throwError "host_growth_fragment: no source roots"
  let mut g := initialG
  let saveDefinition (g : G) (tag : String) (s : St LSt) : TermElabM (Lean.Expr × G) := do
    Memo.beginEpoch
    let (body, g) ← (stE StreamExpr.ser (mkConst ``LSt) s).run { g with defs := #[], count := 0 }
    for (name, type, value) in g.defs do define name type value
    let name := pre ++ Name.mkSimple tag
    define name stateType body
    resetCache
    pure (mkConst name, sweep { g with defs := #[] } #[body])
  let (templateE, g') ← saveDefinition g "template" s
  g := g'
  define (pre ++ `seekSteps) (mkConst ``Nat) (toExpr seekSteps)
  s := atOffset s sourceRoots.cache 256
  let some entryRoots := roots s | throwError "host_growth_fragment: entry roots vanished"
  let (entryE, g') ← saveDefinition { g with idx := 1 } "entry" s
  g := g'
  define (pre ++ `roots) (mkConst ``Roots) (toExpr entryRoots)
  -- Projection and specialization proofs live in a separate module, so a
  -- failed geometry check cannot be confused with successful state choice.
  let _ := templateE
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let originalDepth := s.stack.length
  let tab := c.tab
  c := ⟨tab, []⟩
  let mut oracle : Array Ans := #[]
  let mut ks : Array Nat := #[]
  let mut fuel : Nat := 0
  let mut sinceBoundary : Nat := 0
  let server (tab : List SymE) (used : Nat) :=
    mkApp2 (mkConst ``SSrv.mk) (toExpr tab)
      (mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit used) (mkConst (pre ++ `O)))
  IO.FS.writeBinFile (Stream.fileOf dir pre 0)
    (writeRoots { nonce, defs := #[], st := entryE, srv := server tab 0 })
  let mut done := false
  while !done do
    if fuel == 100000 then throwError "host_growth_fragment: method did not return"
    match interpRec rho (step Host.Load.ffi s).run c [] with
    | none => throwError "host_growth_fragment: growth path stuck at {fuel}"
    | some (s', c', answers) => s := s'; c := c'; oracle := oracle ++ answers.reverse.toArray
    fuel := fuel + 1
    sinceBoundary := sinceBoundary + 1
    done := s.stack.length == originalDepth && match s.ctl with | .ret _ => true | _ => false
    if done || sinceBoundary == width then
      ks := ks.push sinceBoundary
      sinceBoundary := 0
      Memo.beginEpoch
      let (body, g') ← (stE StreamExpr.ser (mkConst ``LSt) s).run
        { g with idx := ks.size + 1, defs := #[], count := 0 }
      g := g'
      let srv := server c.tab oracle.size
      IO.FS.writeBinFile (Stream.fileOf dir pre ks.size)
        (writeRoots { nonce, defs := g.defs, st := body, srv })
      g := sweep { g with defs := #[] } #[body, srv]
      resetCache
  define (pre ++ `O) (listType (mkConst ``Ans)) (toExpr oracle.toList)
  define (pre ++ `F) (mkConst ``Ffi) (mkConst ``Host.Load.ffi)
  define (pre ++ `boot) (mkApp (mkConst ``Option [.zero]) stateType)
    (mkApp2 (mkConst ``Option.some [.zero]) stateType entryE)
  define (pre ++ `srv) (mkConst ``SSrv) (server tab 0)
  for (name, type, value) in
      [(pre ++ `ks, listType (mkConst ``Nat), toExpr ks.toList),
       (pre ++ `nonce, mkConst ``String, toExpr nonce)] do
    let decl := Declaration.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe }
    addDecl decl
    compileDecl decl
  Memo.reset
  logInfo m!"host_growth_fragment {pre}: candidate entry after {seekSteps} original native steps; {ks.size} fragments/{fuel} growth steps; {(← IO.monoMsNow)-started} ms. Entry reachability remains an explicit invariant obligation."

end Host.Load.Growth
