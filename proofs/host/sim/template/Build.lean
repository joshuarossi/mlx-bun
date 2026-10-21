import host.sim.template.Walk
import host.ts.DecodeExpr
import host.load.Decode
import host.load.Stream
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The decode-loop template and its case streams

The template start state `T0` is a data constant chosen natively from the
ordinary readback cut `P.s3272` (iteration 1 of the five-token run):

* garbage collection: only the heap entries reachable from the roots (control,
  stack, jobs, stores, mlx pending/error handler, the intrinsics `1 … 39`, and
  the JS objects native closures name) are kept; of the native graph, only the
  live nodes (held by reachable handles and vectors, and the nodes of
  compiled-closure traces with their inputs), and of the native handles only the live
  ones. Eager nodes keep their `ins`:
  the FFI model reads only shapes and dtypes of eager nodes;
* symbolization: one fresh table entry per loop-carried place — the 64 cache
  offsets (`var 9`), `generated` (`var 10`), the per-iteration `stepIndex`
  cell (`var 11`), `yieldCount` (`var 12`), the yielded record's `index`
  (`var 13`) and `token` (`var 15`, the previous token), the native token
  queue `[var 14]` (the token read at the cut) and axis 2 of the 32 live KV
  buffer nodes (`var 16`, one entry per node).

Nothing here is trusted: `T0` is data. Its relation to `P.s3272` and the case
runs are kernel obligations stated elsewhere. `tpl_template` writes `T0` as a
one-boundary stream; `tpl_case` runs one iteration case from it natively,
answering tests at the case's valuation, and writes its boundaries every
`10 000` steps up to the next readback cut (or halt), like `host_stream`. -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts Host.Load Host.Ts.Stream

/-! ## Places of the ordinary cut `P.s3272` -/

def offsets : List Nat := [2672298, 2672303, 2672308, 2672320, 2672329, 2672334, 2672339, 2672351, 2672360, 2672365,
  2672370, 2672382, 2672391, 2672396, 2672401, 2672413, 2672422, 2672427, 2672432, 2672444, 2672453, 2672458, 2672463,
  2672475, 2672484, 2672489, 2672494, 2672506, 2672515, 2672520, 2672525, 2672537, 2672546, 2672551, 2672556, 2672568,
  2672577, 2672582, 2672587, 2672599, 2672608, 2672613, 2672618, 2672630, 2672639, 2672644, 2672649, 2672661, 2672670,
  2672675, 2672680, 2672692, 2672701, 2672706, 2672711, 2672723, 2672732, 2672737, 2672742, 2672754, 2672763, 2672768,
  2672773, 2672785]

/-- The handles of the live KV buffers (keys and values of the 16 attention layers). -/
def kvHandles : List Nat := [25850, 25851, 26070, 26071, 26302, 26303, 26534, 26535, 26766, 26767, 26998, 26999, 27227,
  27228, 27459, 27460, 27691, 27692, 27923, 27924, 28155, 28156, 28387, 28388, 28619, 28620, 28839, 28840, 29050, 29051, 29261, 29262]

/-- Output arrays the loop only appends to: `forwarded`, `emitted`. -/
def framedArrays : List Nat := [2673447, 12502]

def keyIs (k : PKey) (s : String) : Bool := match k with
  | .str cs => cs == s.toList
  | _ => false

def setNum (x : NumV) : PropV → PropV
  | .data (.num _) w e => .data (.num x) w e
  | v => v

def readNum (s : St LSt) (a : Nat) (prop : Option String) : Option NumV :=
  match prop with
  | none => match s.cell? a with
    | some (some (.num x)) => some x
    | _ => none
  | some k => match s.obj? a with
    | some o => match o.props.find? (fun (q, _) => keyIs q k) with
      | some (_, .data (.num x) _ _) => some x
      | _ => none
    | none => none

def writeNum (s : St LSt) (a : Nat) (prop : Option String) (x : NumV) : St LSt :=
  match prop with
  | none => s.setCell a (.num x)
  | some k => match s.obj? a with
    | some o =>
      let ps := o.props.map (fun (q, v) => if keyIs q k then (q, setNum x v) else (q, v))
      s.setObj a { o with props := ps }
    | none => s

/-- A fresh template entry: its table index, its variable, and the number the cut held there. -/
structure Entry where
  name : String
  ref : Nat
  var : Nat
  orig : NumV

instance : Inhabited Entry := ⟨⟨"", 0, 0, .lit .nan⟩⟩

/-- The scalar places: name, address, property (none: a cell), value at the cut, variable. -/
def scalarPlaces : List (String × Nat × Option String × NumV × Nat) :=
  [("generated", 2673316, none, .lit (F64.ofNat 1), 10), ("stepIndex", 2975684, none, .lit (F64.ofNat 1), 11),
   ("yieldCount", 2591, none, .lit (F64.ofNat 1), 12), ("record.index", 2827771, some "index", .lit (F64.ofNat 0), 13),
   ("record.token", 2827771, some "token", .ref 1, 15)]

/-- Symbolize the (collected) cut. -/
def symbolize (s : St LSt) (c : SSrv) : Except String (St LSt × SSrv × Array Entry) := do
  let mut tab := c.tab.toArray
  let mut s := s
  let mut ents : Array Entry := #[]
  let mut places : List (String × Nat × Option String × NumV × Nat) :=
    offsets.map fun a => (s!"offset h{a}", a, some "offset", .lit (F64.ofNat 3), 9)
  places := places ++ scalarPlaces
  for (nm, a, p, x, v) in places do
    match readNum s a p with
    | some y => unless decide (y = x) do throw s!"{nm} h{a}: unexpected value {repr y}"
    | none => throw s!"{nm} h{a}: not a number place"
    let r := tab.size
    s := writeNum s a p (.ref r)
    tab := tab.push (.var v)
    ents := ents.push ⟨nm, r, v, x⟩
  -- the native token read at the cut
  let rt := tab.size
  tab := tab.push (.var 14)
  let m := s.aux.ffi.mlx
  let some t := m.tokens.head? | throw "no token at the cut"
  ents := ents.push ⟨"mlx.tokens[0]", rt, 14, t⟩
  let mut m := { m with tokens := [.ref rt] }
  -- live KV buffer capacity, one entry per node
  for h in kvHandles do
    let some id := m.arrs.get h | throw s!"kv handle {h}: no node"
    let some nd := m.nodes.get id | throw s!"kv node {id}: missing"
    unless nd.shape.length == 4 && nd.shape[2]? == some (.lit 256) do throw s!"kv node N{id}: unexpected shape"
    let r := tab.size
    tab := tab.push (.var 16)
    ents := ents.push ⟨s!"capacity N{id}", r, 16, .lit (F64.ofNat 256)⟩
    m := { m with nodes := m.nodes.set id { nd with shape := Host.Mlx.Ffi.setAt nd.shape 2 (.sym (.ref r)) } }
  s := s.setFfi { s.aux.ffi with mlx := m }
  return (s, { c with tab := tab.toList }, ents)

/-! ## Cases -/

structure Case where
  name : String
  /-- Valuation overrides (variable, value). -/
  over : List (Nat × Nat)
  /-- Stop at the next readback (else run to halt). -/
  loop : Bool
  /-- The lookahead read of the final iteration needs a second token (`var 17`). -/
  extraToken : Bool

/-- The cut's values of the template variables (ν of iteration 1 of the five-token run). -/
def baseVals : List (Nat × Nat) :=
  [(9, 3), (10, 1), (11, 1), (12, 1), (13, 0), (14, 101), (15, 100), (16, 256), (17, 102)]

def cases : List Case := [
  ⟨"ORDINARY", [], true, false⟩,
  ⟨"CLEAR", [(10, 256), (11, 256), (12, 256), (13, 255), (0, 1000)], true, false⟩,
  ⟨"GROWTH", [(9, 256), (10, 254), (11, 254), (12, 254), (13, 253), (0, 1000)], true, false⟩,
  ⟨"FILL", [(9, 255), (10, 253), (11, 253), (12, 253), (13, 252), (0, 1000)], true, false⟩,
  ⟨"FINAL", [(0, 3)], false, true⟩,
  -- final iterations at the two cache-clear phases (`i % 256 = 0`, `(i + 1) % 256 = 0`)
  ⟨"FINALC0", [(0, 258), (9, 258), (10, 256), (11, 256), (12, 256), (13, 255), (16, 512)], false, true⟩,
  ⟨"FINALC1", [(0, 257), (9, 257), (10, 255), (11, 255), (12, 255), (13, 254), (16, 512)], false, true⟩]

def Case.valuation (c : Case) (i : Nat) : F64 :=
  match c.over.find? (·.1 == i) with
  | some (_, v) => F64.ofNat v
  | none => match baseVals.find? (·.1 == i) with
    | some (_, v) => F64.ofNat v
    | none => Host.Load.Decode.valuation i

/-! ## Native restoration and boundary files -/

/-- Decode a state and server constant; the decoded named constants seed the
generator's aliases, so unchanged pages keep their names. -/
unsafe def restore (state server : Lean.Expr) (pre : Lean.Name) : MetaM (St LSt × SSrv × G) := do
  let (sN, d) ← (ConstructorDecode.decode state).run {}
  let (cN, d) ← (ConstructorDecode.decode server).run d
  let mut g : G := { pre }
  let aliasNames : Std.HashSet Lean.Name := d.aliases.foldl (fun ns a => ns.insert a.1) {}
  let env ← getEnv
  for (name, type, value) in d.aliases do
    let bodyConstants := match env.find? name with
      | some (.defnInfo dd) => dd.value.getUsedConstants
      | _ => #[]
    let deps := (type.getUsedConstants ++ bodyConstants).filter aliasNames.contains
    g := { g with memo := g.memo.insert (ptrAddrUnsafe value, type) (name, value), deps := g.deps.insert name deps }
  return (unsafeCast sN, unsafeCast cN, g)

/-- Write boundary `i`: the state (serialized, or an existing constant) and the server
`⟨tab, oracle⟩`. -/
def writeBoundary (pre : Lean.Name) (nonce : String) (dir : System.FilePath) (g : G) (i : Nat) (s : St LSt)
    (tab : List SymE) (oracle : Lean.Expr) (stConst : Option Lean.Expr) : IO (G × Nat) := do
  Memo.beginEpoch
  let (sE, g) ← match stConst with
    | some e => pure (e, g)
    | none => (stE StreamExpr.ser (mkConst ``LSt) s).run { g with idx := i, count := 0, defs := #[] }
  let srv := mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oracle
  let bytes := writeRoots { nonce, defs := (if stConst.isSome then #[] else g.defs), st := sE, srv }
  IO.FS.writeBinFile (Stream.fileOf dir pre i) bytes
  let g := sweep { g with defs := #[] } #[sE, srv]
  pure (g, bytes.size)

private def addDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

private def natList (xs : List Nat) : Lean.Expr := toExpr xs

/-- `tpl_template T from s, S`: the template `T.s0`/`T.S0` (one boundary) from the cut `s`/`S`,
with `T.F`, `T.nonce`, `T.entries` (index, variable) and `T.orig` (index, the cut's number). -/
unsafe def templateCmd (pre srcName srvName : Lean.Name) : TermElabM Unit := do
    astTabRef.set (← loadAstTab)
    Memo.reset
    let t0 ← IO.monoMsNow
    let (s, c, _) ← restore (mkConst srcName) (mkConst srvName) pre
    let t1 ← IO.monoMsNow
    -- reachability (identity walk) and collection
    let m := s.aux.ffi.mlx
    let traceSet := traceNodesOf m
    let natRefs := nativeHeapRefs m
    let roots := ((List.range 40).filter fun a => (s.heap.get a).isSome) ++ natRefs
    let ctx : Ctx := { s1 := s, s2 := s, t1 := c.tab.toArray, t2 := c.tab.toArray, env := ← getEnv, traceNodes := traceSet }
    let ((), w) ← ((walkRoots (roots.map fun a => (a, a))).run ctx).run {}
    unless w.mism.isEmpty do throwError "tpl_template: the identity walk found {w.mism.size} mismatches"
    let heap := ptrieFold (fun (acc : PTrie Host.Ts.HObj) a o => if w.sig.contains a then acc.set a o else acc) s.heap PTrie.nil
    let nodes := ptrieFold (fun (acc : PTrie Host.Mlx.Ffi.Node) n nd => if w.nod.contains n then acc.set n nd else acc) m.nodes PTrie.nil
    let items := ptrieFold (fun (acc : PTrie NumV) n x => if w.nod.contains n then acc.set n x else acc) m.items PTrie.nil
    let sg : St LSt := { s with heap }
    -- native handles: only the live ones (garbage vectors and configs of earlier iterations go)
    let arrs := ptrieFold (fun (acc : PTrie Nat) h n => if w.hnd.contains h then acc.set h n else acc) m.arrs PTrie.nil
    let objs := ptrieFold (fun (acc : PTrie Host.Mlx.Ffi.Obj) h o => if w.hnd.contains h then acc.set h o else acc) m.objs PTrie.nil
    let sg := sg.setFfi { sg.aux.ffi with mlx := { m with nodes, items, arrs, objs } }
    let (T0, c0, ents) ← match symbolize sg c with
      | .ok r => pure r
      | .error e => throwError "tpl_template: {e}"
    let t2 ← IO.monoMsNow
    let nonce := s!"{pre}:{← IO.monoNanosNow}"
    let dir ← streamDir
    IO.FS.createDirAll (dir / pre.toString)
    let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
    let (_, bytes) ← writeBoundary pre nonce dir { pre } 0 T0 c0.tab nilAns none
    addDef (pre ++ `F) (mkConst ``Ffi) (mkConst ``Host.Load.ffi)
    addDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
    addDef (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (natList []) (compile := true)
    let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
    addDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr (ents.toList.map fun e => (e.ref, e.var)))
    let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
    addDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy) (toExpr (ents.toList.map fun e => (e.ref, e.orig)))
    let heapN : Nat := ptrieFold (fun (k : Nat) _ _ => k + 1) s.heap 0
    logInfo m!"tpl_template {pre}: restore {t1 - t0} ms, collect+symbolize {t2 - t1} ms; heap {w.sig.size}/{heapN} kept, live handles {w.hnd.size}, live nodes {w.nod.size} (trace {traceSet.size}); table {c.tab.length} -> {c0.tab.length}; boundary {bytes} bytes"

/-- `tpl_case X from T : "NAME"`: run case `NAME` from the template `T.s0`/`T.S0`
natively (tests answered at the case's valuation), writing boundaries every
10 000 steps up to the next readback cut or halt; defines `X.F`, `X.O`, `X.ks`,
`X.nonce`, `X.srv`, `X.T1` (the last boundary) and `X.steps`. -/
unsafe def caseCmd (pre base : Lean.Name) (nm : String) : TermElabM Unit := do
    let some cs := cases.find? (·.name == nm) | throwError "tpl_case: unknown case {nm}"
    astTabRef.set (← loadAstTab)
    Memo.reset
    let t0 ← IO.monoMsNow
    let (s0, c0, g0) ← restore (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
    let t1 ← IO.monoMsNow
    let (s, tab, stConst) :=
      if cs.extraToken then
        let r := c0.tab.length
        let m := s0.aux.ffi.mlx
        (s0.setFfi { s0.aux.ffi with mlx := { m with tokens := m.tokens ++ [.ref r] } }, c0.tab ++ [.var 17], none)
      else (s0, c0.tab, some (mkConst (base ++ `s0)))
    let .call (.obj fa) _ _ := s.ctl | throwError "tpl_case: the template control is not a call"
    let depth := s.stack.length
    let nonce := s!"{pre}:{← IO.monoNanosNow}"
    let dir ← streamDir
    IO.FS.createDirAll (dir / pre.toString)
    let oE := mkConst (pre ++ `O)
    let drop (m : Nat) := mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit m) oE
    let ρ := cs.valuation
    let (g, b0) ← writeBoundary pre nonce dir g0 0 s tab (drop 0) stConst
    let mut g := g
    let mut bytes := b0
    let mut st := s
    let mut c : SSrv := ⟨tab, []⟩
    let mut o : Array Ans := #[]
    let mut steps : Nat := 0
    let mut ks : Array Nat := #[]
    let mut stop := ""
    while stop.isEmpty do
      let mut n : Nat := 0
      while n < 10000 do
        if cs.loop && steps > 0 then
          match st.ctl with
          | .call (.obj a) _ _ => if a == fa && st.stack.length == depth then stop := "readback"; break
          | _ => pure ()
        if isHalt st.ctl then stop := "halt"; break
        match interpRec ρ (step Host.Load.ffi st).run c [] with
        | some (s', c', a) => st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1
        | none => throwError "tpl_case {pre}: stuck after {steps} steps"
      if n > 0 then
        ks := ks.push n
        let (g', b) ← writeBoundary pre nonce dir g ks.size st c.tab (drop o.size) none
        g := g'
        bytes := bytes + b
      if steps > 8000000 then throwError "tpl_case {pre}: no stop within 8000000 steps"
    let t2 ← IO.monoMsNow
    let ansL := mkApp (mkConst ``List [.zero]) (mkConst ``Ans)
    addDef (pre ++ `O) ansL (toExpr o.toList)
    addDef (pre ++ `F) (mkConst ``Ffi) (mkConst ``Host.Load.ffi)
    addDef (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (natList ks.toList) (compile := true)
    addDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
    addDef (pre ++ `srv) (mkConst ``SSrv) (mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oE)
    addDef (pre ++ `T1) (mkConst ``Nat) (mkRawNatLit ks.size) (compile := true)
    addDef (pre ++ `steps) (mkConst ``Nat) (mkRawNatLit steps)
    logInfo m!"tpl_case {pre} ({cs.name}): restore {t1 - t0} ms, run+write {t2 - t1} ms; {steps} steps to {stop}, {ks.size} chunks (T1 = {pre}.s{ks.size}), oracle {o.size} answers, {bytes} bytes"

/-- `tpl_template T from s, S`: the template `T.s0`/`T.S0` (one boundary) from the cut `s`/`S`,
with `T.F`, `T.nonce`, `T.entries` (index, variable) and `T.orig` (index, the cut's number). -/
elab "tpl_template " p:ident " from " src:ident ", " srv:ident : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    unsafe templateCmd ((← getCurrNamespace) ++ p.getId) src.getId srv.getId

/-- `tpl_case X from T : "NAME"`: run case `NAME` from the template `T.s0`/`T.S0`
natively (tests answered at the case's valuation), writing boundaries every
10 000 steps up to the next readback cut or halt; defines `X.F`, `X.O`, `X.ks`,
`X.nonce`, `X.srv`, `X.T1` (the last boundary index) and `X.steps`. -/
elab "tpl_case " p:ident " from " b:ident " : " nm:str : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    unsafe caseCmd ((← getCurrNamespace) ++ p.getId) ((← getCurrNamespace) ++ b.getId) nm.getString

end Host.Ts.Sim.Template
