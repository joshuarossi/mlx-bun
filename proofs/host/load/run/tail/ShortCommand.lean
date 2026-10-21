import host.load.Stream
import host.ts.DecodeExpr
import host.load.Native
namespace Host.Load.Run.Tail
open Lean Elab Command Meta Host.Ts Host.Ts.Stream Host.Load

/-! A streamed branch of a decode chain. From boundary `k` of a chain `P`, with
the native token queue replaced, the machine runs natively while a discovery
valuation answers the numeric tests; boundaries are written to the stream
directory like `host_stream`'s. Native data only chooses the boundaries and the
oracle: `host_stream_state Q i` imports them and `host_chunk Q i` checks every
transition in the kernel. -/

private unsafe def restore (state server : Lean.Expr) (pre : Lean.Name) :
    TermElabM (St LSt × SSrv × G) := do
  let (sNative, decoded) ← (ConstructorDecode.decode state).run {}
  let (cNative, decoded) ← (ConstructorDecode.decode server).run decoded
  let mut g : G := { pre }
  let aliasNames : Std.HashSet Lean.Name := decoded.aliases.foldl (fun names alias => names.insert alias.1) {}
  let env ← getEnv
  for (name, type, value) in decoded.aliases do
    let bodyConstants := match env.find? name with
      | some (.defnInfo d) => d.value.getUsedConstants
      | _ => #[]
    let deps := (type.getUsedConstants ++ bodyConstants).filter aliasNames.contains
    g := { g with memo := g.memo.insert (ptrAddrUnsafe value, type) (name, value), deps := g.deps.insert name deps }
  return (unsafeCast sNative, unsafeCast cNative, g)

private def addAbbrev (name : Lean.Name) (type value : Lean.Expr) (compile : Bool) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

private unsafe def branch (pre src : Lean.Name) (k : Nat) (start : Lean.Expr) (tokens : List NumV)
    (ρ : Nat → F64) (width limit : Nat) : TermElabM Unit := do
  let t0 ← IO.monoMsNow
  astTabRef.set (← loadAstTab)
  Memo.reset
  let srcS := mkConst (src ++ Name.mkSimple s!"s{k}")
  let srcC := mkConst (src ++ Name.mkSimple s!"S{k}")
  let (s, c, g) ← restore srcS srcC pre
  let mut s := s.setFfi { s.ffi with mlx := { s.ffi.mlx with tokens } }
  let mut c : SSrv := ⟨c.tab, []⟩
  let mut g := g
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let ansTy := mkConst ``Ans
  let oE := mkConst (pre ++ `O)
  let server (tab : Lean.Expr) (m : Nat) := mkApp2 (mkConst ``SSrv.mk) tab (mkApp3 (mkConst ``List.drop [.zero]) ansTy (mkRawNatLit m) oE)
  let srv0 := server (mkApp (mkConst ``SSrv.tab) srcC) 0
  IO.FS.writeBinFile (Host.Ts.Stream.fileOf dir pre 0) (writeRoots { nonce := nonce, defs := #[], st := start, srv := srv0 })
  let mut o : Array Ans := #[]
  let mut ks : Array Nat := #[]
  let mut steps := 0
  let mut i := 0
  while !isHalt s.ctl do
    if steps ≥ limit then throwError "host_stream_branch: no halt within {limit} steps"
    let mut n := 0
    while n < width && !isHalt s.ctl do
      match interpRec ρ (step Host.Load.ffi s).run c [] with
      | some (s', c', a) => s := s'; c := c'; o := o ++ a.reverse.toArray; n := n + 1
      | none => throwError "host_stream_branch: stuck after {steps + n} steps"
    steps := steps + n
    ks := ks.push n
    i := i + 1
    Memo.beginEpoch
    let (sE, g') ← (stE StreamExpr.ser (mkConst ``LSt) s).run { g with idx := i, count := 0, defs := #[] }
    let srv := server (toExpr c.tab) o.size
    IO.FS.writeBinFile (Host.Ts.Stream.fileOf dir pre i) (writeRoots { nonce, defs := g'.defs, st := sE, srv })
    g := sweep { g' with defs := #[] } #[sE, srv]
  addAbbrev (pre ++ `F) (mkConst ``Ffi) (mkConst ``Host.Load.ffi) false
  addAbbrev (pre ++ `O) (mkApp (mkConst ``List [.zero]) ansTy) (toExpr o.toList) false
  let natL := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  addAbbrev (pre ++ `ks) natL (toExpr ks.toList) true
  addAbbrev (pre ++ `nonce) (mkConst ``String) (toExpr nonce) true
  logInfo m!"host_stream_branch {pre}: from {src} {k}, {steps} steps in {ks.size} chunks {ks.toList}, halted {isHalt s.ctl}; {o.size} answers {toExpr o.toList}; {(← IO.monoMsNow) - t0} ms"

/-- `host_stream_branch Q from P k := start tokens toks valuation ρ width w`:
the chain `Q` from `P`'s boundary `k` with native token queue `toks` (its
boundary 0 is the term `start`), run to halt in chunks of `w` steps with the
tests answered at `ρ`. Defines `Q.F`, `Q.O`, `Q.ks`, `Q.nonce`. -/
elab "host_stream_branch " q:ident " from " p:ident i:num " := " st:term " tokens " ts:term
    " valuation " v:term " width " w:num : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let ns ← getCurrNamespace
    let start ← instantiateMVars (← Term.elabTermAndSynthesize st none)
    let listTy := mkApp (mkConst ``List [.zero]) (mkConst ``NumV)
    let tokens ← unsafe evalExpr (List NumV) listTy (← instantiateMVars (← Term.elabTermAndSynthesize ts (some listTy)))
    let ρTy ← mkArrow (mkConst ``Nat) (mkConst ``F64)
    let ρ ← unsafe evalExpr (Nat → F64) ρTy (← instantiateMVars (← Term.elabTermAndSynthesize v (some ρTy)))
    unsafe branch (ns ++ q.getId) (ns ++ p.getId) i.getNat start tokens ρ w.getNat 10000000

end Host.Load.Run.Tail
