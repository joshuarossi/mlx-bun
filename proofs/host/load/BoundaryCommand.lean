import host.load.Boundary
import host.load.GrowthCommand

namespace Host.Load.CacheBoundary
open Lean Elab Command Meta Host.Ts Host.Ts.Stream

deriving instance Lean.ToExpr for Roots

private def define (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private def stateType : Lean.Expr := mkApp (mkConst ``St) (mkConst ``LSt)
private def listType (type : Lean.Expr) : Lean.Expr := mkApp (mkConst ``List [.zero]) type

private def number (name : Lean.Name) (value : Nat) : TermElabM Unit := do
  let decl := Declaration.defnDecl { name, levelParams := [], type := mkConst ``Nat, value := toExpr value, hints := .regular 0, safety := .safe }
  addDecl decl
  compileDecl decl

/-- Choose a complete 64-layer repository call at an explicitly specialized
entry. This command proves neither entry reachability nor execution. The
stream imports and ordinary `host_chunk` obligations check the chosen states. -/
elab "host_cache_boundary " name:ident " : " state:term ", " server:term ", " rhoInput:term
    ", " positionInput:num ", " limit:num ", " chunkSize:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let chunkSize := chunkSize.getNat
  if chunkSize == 0 then throwError "host_cache_boundary: width must be positive"
  let sE ← instantiateMVars (← Term.elabTermAndSynthesize state (some stateType))
  let cE ← instantiateMVars (← Term.elabTermAndSynthesize server (some (mkConst ``SSrv)))
  let rhoTy ← mkArrow (mkConst ``Nat) (mkConst ``F64)
  let rhoE ← instantiateMVars (← Term.elabTermAndSynthesize rhoInput (some rhoTy))
  let rho ← unsafe evalExpr (Nat → F64) rhoTy rhoE
  let expectedMethod ← unsafe evalExpr (Option Func) (mkApp (mkConst ``Option [.zero]) (mkConst ``Func))
    (mkConst ``runMethod)
  if expectedMethod.isNone then throwError "host_cache_boundary: pinned 64-layer method missing"
  astTabRef.set (← loadAstTab)
  Memo.reset
  let started ← IO.monoMsNow
  let (initial, initialC, initialG) ← unsafe Growth.restoreChoiceState sE cE pre
  let mut s := initial
  let mut c := initialC
  let mut seekSteps : Nat := 0
  while !(match roots s with | some r => expectedMethod == some r.body | none => false) do
    if seekSteps == limit.getNat then throwError "host_cache_boundary: source call not found"
    match interpS (step Host.Load.ffi s).run c with
    | none => throwError "host_cache_boundary: original source path stuck at {seekSteps}"
    | some (s', c') => s := s'; c := c'; seekSteps := seekSteps + 1
  let some sourceRoots := roots s | throwError "host_cache_boundary: missing roots"
  unless sourceRoots.caches.length == 64 && sourceRoots.layers.length == 64 do
    throwError "host_cache_boundary: expected all 64 source layers and caches"
  let saveDefinition (g : G) (tag : String) (s : St LSt) : TermElabM (Lean.Expr × G) := do
    Memo.beginEpoch
    let (body, g) ← (stE StreamExpr.ser (mkConst ``LSt) s).run { g with defs := #[], count := 0 }
    for (name, type, value) in g.defs do define name type value
    let name := pre ++ Name.mkSimple tag
    define name stateType body
    resetCache
    pure (mkConst name, sweep { g with defs := #[] } #[body])
  let (templateE, g) ← saveDefinition initialG "template" s
  let position := positionInput.getNat
  s := atOffsets s sourceRoots.caches position
  let some entryRoots := roots s | throwError "host_cache_boundary: entry roots vanished"
  let (entryE, g) ← saveDefinition { g with idx := 1 } "entry" s
  let mut g := g
  define (pre ++ `roots) (mkConst ``Roots) (toExpr entryRoots)
  number (pre ++ `seekSteps) seekSteps
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
  let mut methodCut : Nat := 0
  let mut methodSteps : Nat := 0
  let server (tab : List SymE) (used : Nat) :=
    mkApp2 (mkConst ``SSrv.mk) (toExpr tab)
      (mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit used) (mkConst (pre ++ `O)))
  IO.FS.writeBinFile (Stream.fileOf dir pre 0)
    (writeRoots { nonce, defs := #[], st := entryE, srv := server tab 0 })
  let mut done := false
  while !done do
    if fuel == 2000000 then throwError "host_cache_boundary: method did not return"
    match interpRec rho (step Host.Load.ffi s).run c [] with
    | none => throwError "host_cache_boundary: source path stuck at {fuel}"
    | some (s', c', answers) => s := s'; c := c'; oracle := oracle ++ answers.reverse.toArray
    fuel := fuel + 1
    sinceBoundary := sinceBoundary + 1
    let returned := methodCut == 0 && s.stack.length == originalDepth &&
      match s.ctl with | .ret _ => true | _ => false
    done := (methodCut > 0 || returned) && isItemCall s
    if done || returned || sinceBoundary == chunkSize then
      ks := ks.push sinceBoundary
      sinceBoundary := 0
      if returned then
        methodCut := ks.size
        methodSteps := fuel
      Memo.beginEpoch
      let (body, g') ← (stE StreamExpr.ser (mkConst ``LSt) s).run
        { g with idx := ks.size + 1, defs := #[], count := 0 }
      g := g'
      let srv := server c.tab oracle.size
      IO.FS.writeBinFile (Stream.fileOf dir pre ks.size)
        (writeRoots { nonce, defs := g.defs, st := body, srv })
      g := sweep { g with defs := #[] } #[body, srv]
      resetCache
      if ks.size % 100 == 0 then
        logInfo m!"host_cache_boundary {pre}: {fuel} steps, {ks.size} snapshots, {g.memo.size} live aliases"
  define (pre ++ `O) (listType (mkConst ``Ans)) (toExpr oracle.toList)
  define (pre ++ `F) (mkConst ``Ffi) (mkConst ``Host.Load.ffi)
  define (pre ++ `boot) (mkApp (mkConst ``Option [.zero]) stateType)
    (mkApp2 (mkConst ``Option.some [.zero]) stateType entryE)
  define (pre ++ `srv) (mkConst ``SSrv) (server tab 0)
  number (pre ++ `steps) fuel
  number (pre ++ `methodCut) methodCut
  number (pre ++ `methodSteps) methodSteps
  for (name, type, value) in
      [(pre ++ `ks, listType (mkConst ``Nat), toExpr ks.toList),
       (pre ++ `nonce, mkConst ``String, toExpr nonce)] do
    let decl := Declaration.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe }
    addDecl decl
    compileDecl decl
  Memo.reset
  logInfo m!"host_cache_boundary {pre}: candidate entry after {seekSteps} original steps; {ks.size} fragments/{fuel} source steps; {(← IO.monoMsNow)-started} ms. Entry reachability remains explicit."

end Host.Load.CacheBoundary
