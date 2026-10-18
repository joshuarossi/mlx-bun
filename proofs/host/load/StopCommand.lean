import host.load.Stop
import host.load.GrowthCommand

namespace Host.Load.Stop
open Lean Elab Command Meta Host.Ts Host.Ts.Stream

private def define (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

/-- Restore an actual source cut and choose bounded states under a new
discovery valuation. A positive final argument specializes the generated
cell and stops just after periodic clear_cache; zero runs to normal halt.
Only subsequent ordinary chunk equations establish execution. -/
elab "host_stop_fragment " name:ident " : " state:term ", " server:term ", " rhoInput:term
    ", " limit:num ", " chunkSize:num ", " count:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let chunkSize := chunkSize.getNat
  if chunkSize == 0 then throwError "host_stop_fragment: chunk size must be positive"
  let stType := mkApp (mkConst ``St) (mkConst ``LSt)
  let sE ← instantiateMVars (← Term.elabTermAndSynthesize state (some stType))
  let cE ← instantiateMVars (← Term.elabTermAndSynthesize server (some (mkConst ``SSrv)))
  let rhoType ← mkArrow (mkConst ``Nat) (mkConst ``F64)
  let rhoE ← instantiateMVars (← Term.elabTermAndSynthesize rhoInput (some rhoType))
  let rho ← unsafe evalExpr (Nat → F64) rhoType rhoE
  astTabRef.set (← loadAstTab)
  Memo.reset
  let started ← IO.monoMsNow
  let (initial, initialC, initialG) ← unsafe Growth.restoreChoiceState sE cE pre
  let mut s := initial
  let mut g := initialG
  let mut entry := sE
  let mut generatedCell : Nat := 0
  let mut sourceC := initialC
  let mut seekSteps : Nat := 0
  if count.getNat > 0 then
    while !atClearTest s do
      if seekSteps == limit.getNat then throwError "host_stop_fragment: clear condition not found"
      match interpS (step Host.Load.ffi s).run sourceC with
      | none => throwError "host_stop_fragment: source path stuck before clear condition"
      | some (s',c') => s := s'; sourceC := c'; seekSteps := seekSteps + 1
    let cells := (cellsNamed (toExpr (chars!"generated")) (toExpr s.stack) ++
      cellsNamed (toExpr (chars!"generated")) (toExpr s.ctl)).eraseDups
    let [cell] := cells | throwError "host_stop_fragment: expected one generated cell, got {cells}"
    generatedCell := cell
    let .ex statement localEnv := s.ctl |
      throwError "host_stop_fragment: clear test is not a source statement"
    define (pre ++ `statement) (mkConst ``Stmt) (toExpr statement)
    define (pre ++ `localEnv) (mkConst ``Env) (toExpr localEnv)
    Memo.beginEpoch
    let (originalBody,g') ← (stE StreamExpr.ser (mkConst ``LSt) s).run { g with idx := 0, defs := #[], count := 0 }
    for (name,type,value) in g'.defs do define name type value
    define (pre ++ `original) stType originalBody
    g := sweep { g' with defs := #[] } #[originalBody]
    s := generatedAt s cell count.getNat
    Memo.beginEpoch
    let (body, g') ← (stE StreamExpr.ser (mkConst ``LSt) s).run { g with idx := 1, defs := #[], count := 0 }
    for (name,type,value) in g'.defs do define name type value
    define (pre ++ `entry) stType body
    entry := mkConst (pre ++ `entry)
    g := sweep { g' with defs := #[] } #[body]
  else
    define (pre ++ `entry) stType entry
    define (pre ++ `original) stType sE
  define (pre ++ `generatedCell) (mkConst ``Nat) (toExpr generatedCell)
  define (pre ++ `seekSteps) (mkConst ``Nat) (toExpr seekSteps)
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let tab := sourceC.tab
  let mut c : SSrv := ⟨tab,[]⟩
  let mut oracle : Array Ans := #[]
  let mut ks : Array Nat := #[]
  let mut fuel : Nat := 0
  let mut sinceBoundary : Nat := 0
  let beforeEvents := s.trace.length
  let mut cleared := false
  let server (tab : List SymE) (used : Nat) :=
    mkApp2 (mkConst ``SSrv.mk) (toExpr tab)
      (mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit used) (mkConst (pre ++ `O)))
  IO.FS.writeBinFile (Stream.fileOf dir pre 0)
    (writeRoots { nonce, defs := #[], st := entry, srv := server tab 0 })
  let mut done := false
  while !done do
    if fuel == limit.getNat then throwError "host_stop_fragment: did not reach source exit in {fuel} steps"
    match interpRec rho (step Host.Load.ffi s).run c [] with
    | none => throwError "host_stop_fragment: source path stuck at {fuel}"
    | some (s',c',answers) => s := s'; c := c'; oracle := oracle ++ answers.reverse.toArray
    fuel := fuel + 1
    sinceBoundary := sinceBoundary + 1
    if s.trace.length > beforeEvents then
      if let some event := s.trace.head? then
        if nameEq event.sym chars!"mlx_clear_cache" then cleared := true
    done := if count.getNat == 0 then isHalt s.ctl else cleared && afterClear s
    if done || sinceBoundary == chunkSize then
      ks := ks.push sinceBoundary
      sinceBoundary := 0
      Memo.beginEpoch
      let (body,g') ← (stE StreamExpr.ser (mkConst ``LSt) s).run
        { g with idx := ks.size + 1, defs := #[], count := 0 }
      g := g'
      let srv := server c.tab oracle.size
      IO.FS.writeBinFile (Stream.fileOf dir pre ks.size)
        (writeRoots { nonce, defs := g.defs, st := body, srv })
      g := sweep { g with defs := #[] } #[body,srv]
      resetCache
  define (pre ++ `O) (mkApp (mkConst ``List [.zero]) (mkConst ``Ans)) (toExpr oracle.toList)
  define (pre ++ `F) (mkConst ``Ffi) (mkConst ``Host.Load.ffi)
  define (pre ++ `boot) (mkApp (mkConst ``Option [.zero]) stType)
    (mkApp2 (mkConst ``Option.some [.zero]) stType entry)
  define (pre ++ `srv) (mkConst ``SSrv) (server tab 0)
  for (name,type,value) in
      [(pre ++ `ks,mkApp (mkConst ``List [.zero]) (mkConst ``Nat),toExpr ks.toList),
       (pre ++ `nonce,mkConst ``String,toExpr nonce)] do
    let decl := Declaration.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe }
    addDecl decl
    compileDecl decl
  Memo.reset
  logInfo m!"host_stop_fragment {pre}: {ks.size} fragments/{fuel} steps; generated cell {generatedCell}; {(← IO.monoMsNow)-started} ms. State choice only; entry reachability remains an invariant obligation."

end Host.Load.Stop
