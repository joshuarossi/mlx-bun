import host.sim.template.Stage
import host.sim.conv.MergeSt
import host.sim.native.Image
import host.sim.template.Sigma
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # The route-level driver (`tpl_chain`)

`tpl_chain X from s, S : "<plan>" (world := w, cap := n)` runs the route natively from `s`/`S` (a state
of `w`, or of the load world: its lift) for one representative prompt (the plan's valuation, e.g. a
class table row's `rep`), cut at every call of the plan's stage functions, to the plan's stop.

* **Glue**: the stream `X` (boundaries every 10 000 steps), a stage call's state at a boundary `ia`
  reached by a one-step chunk (`ia - 1`), the merged state after the call at `ia + 1` (a zero-step
  chunk: the conversions and the stage run are not steps of `X`); `seg.json` lists each call as a
  `stage` entry. The glue pieces are `X`'s segments between the entries (`gen.ts`: `X.runSeg<k>`). A chain from
  a call (its start state a stage call) has the site at boundary 0 and an empty glue 0, as does a chain whose first
  step enters a call. Each glue piece's oracle (its run's slice of `X.O`) and variable map (the plan's `vars`, then
  the earlier calls' result variables with the stages' `results` quantities) are in `glue<k>.json`, as a
  stage instance's in its `stage.json`.
* **Stage instances, one per (call site, stage class)**: at the `k`-th call the site template
  `X.st<k>` (`host.sim.template.Stage`: the call state without the caller's frames, every entry kept,
  the boundary written with `X`'s page names, so `X.st<k>.s0 = { X.s<ia> with stack := [] }` is a
  comparison of shared constants), run natively to its return (`runLocal`); `genStage.ts` writes its
  modules from its `stage.json`. The class is the plan's (`class`, or the row's tag for the piece).
* **Isolate**: at the instance's own site the call morphism `σ` is `Map.id` and `θ` the identity
  (`conv`: `"sigma": "id"`); the caller's frames `rs` are `X.s<ia>.stack`.
* **Merge**: the merged state is `Conv.mergeSt Map.id τ rs wr X.s<ia> I.s2 I.s0 I.s2.ffi` with
  `τ = Map.id.res n0 n0` (`n0` the call's table length, the instance's start table), computed by
  evaluating that definition, so its boundary is that definition (`genChain.ts`: `X.merge<k>`, a check
  of shared constants); the stage's table entries past `n0` become fresh variables `ws` (`es = resTab
  ws`), bound to the stage's values (`resVal`), and the run continues at the extended valuation. With
  `compact` (the default) A3's compaction follows: the canonical state at `ia + 2` (below).

It defines `X.F`, `X.O`, `X.ks`, `X.nonce`, `X.srv`, `X.T1`, `X.steps` and, for every instance, the same
for `X.st<k>` and `X.st<k>.callSteps`; it writes `seg.json` (v2, with the `stage` entries) and
`chain.json` (the pieces in order) beside `X`'s boundaries, and `stage.json` beside each instance's.

The plan (JSON, the string itself or a file): `stages` (`fn`, a function's name, `#<address>`, or `@ret`: the
closure the previous stage returned, as a dispatch's forward; `piece`, optional `depth`, `class`, `name`
and `results`, the quantities of the stage's new table entries), `stop` (`Stop`, default `halt`; `readback`: the
start's callee at the start's depth), `cap` (per piece: a glue segment or a stage run), `fresh` (the first fresh variable, default 1000), `baseVals` (the
valuation, pairs), `row` and `classes` (a class table row, `host/sim/lin/classes.json`: the stage classes
from its tags, the row id recorded), `glue` (the glue pieces' names), `vars` (the start template's
variable map, for the instances' `stage.json`), `static` (as `tpl_stage`'s).

Names (`chain.json`, as `proofs/host/sim/compose/gen.ts` names pieces): glue `k` is `glue[k]` (default `g<k>`, and
`start` for an empty glue 0; Lean: `X.runSeg<k>`, `gen.ts`, none for an empty piece); call `k` is
`<stage>__<glue k>__<glue k+1>` (`<stage>` the stage's `name`, default `<piece>_<class>`; Lean: the instance `X.st<k>`, `genStage.ts`, and the site facts `genChain.ts` writes). -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts _root_.Host.Load Host.Ts.Stream

structure ChainStage where
  fn : String
  piece : String
  depth : Option Nat := none
  cls : Option String := none
  /-- The stage's name in the composition (`proofs/host/sim/compose/gen.ts`), default `<piece>_<class>`. -/
  name : Option String := none
  /-- The quantities of the stage's new table entries, in order (the glue pieces' variable maps). -/
  results : List String := []

structure ChainPlan where
  stages : List ChainStage := []
  stop : Stop := .halt
  cap : Nat := 8000000
  fresh : Nat := 1000
  baseVals : List (Nat × Nat) := []
  row : Option String := none
  tags : List (String × String) := []
  static : Static := {}
  /-- The glue pieces' names in order (default `g<k>`). -/
  glue : List String := []
  /-- The start template's variables and their quantities (the stage specs' map, `[[v, q], …]`). -/
  vars : List (Nat × String) := []
  /-- Compact after every merge (default `true`). -/
  compact : Bool := true
  /-- The framed arrays (`K.fr`; default `framedArrays`): a canonical state holds the call's entry there (the template
  prefix the framed clause extends). -/
  frames : List Nat := framedArrays
  /-- The bridge kinds the glue is cut at (`Bridge.routeBridges`, as `tpl_case_split … bridging`; default none). -/
  bridges : List String := []
  /-- Start from the start's call isolated (`isolate`: the caller's frames dropped, the spec's places symbolized):
  a stage's body cut at its own stage calls, to its return (`stop: "ret"`). -/
  isolate : Bool := false
  /-- Fast-forward (natively, no boundaries) to the `n`-th call of a function (`fn`, optional `depth`, `count`) before
  the chain starts: a decode iteration's start at its readback call. -/
  skipTo : Option (String × Option Nat × Nat) := none
  /-- End the chain where the machine is stuck (`stop` "stuck: …"), its pieces so far written, instead of failing. -/
  stuckStop : Bool := false
  /-- The acceptance of the generated checks (`seg.json`/`stage.json` "accept"): `auto` (`okJSK` at a band-free P, else
  `okJS`), `js`, `jsk`, or `jsj` (`Disp.okJSJ` with the counter offset bound `D0`, for kernel-creating chains). -/
  accept : String := "auto"
  D0 : Nat := 4096
  /-- The chain's load parameters (`[lo, E, NE, NL, N0]`), instead of its start's counters' (a decode loop's banded relation). -/
  loadP : Option (List Nat) := none
  /-- The start's mlx token queue replaced by these references (a decode template's readback suffix dropped,
  `Full.RelF.dropTokens`; `chain.json` "startTokens", genChain's `<Name>.s0_tok`). -/
  startTokens : Option (List Nat) := none
  /-- The template spec of the isolated start (a file or the JSON itself). -/
  spec : Option String := none
  /-- The caller's wide frames (`JSP.wide`: address and `WFrame` Lean term): the chain's acceptance, and a site
  instance's at the frames its start holds (`Conv.isolateW`'s preimages under `Map.id`). -/
  wide : List (Nat × String) := []

def planOf (j : Lean.Json) (tags : List (String × String)) : Except String ChainPlan := do
  let stages ← (← (SpecJ.optD j "stages" (.arr #[])).getArr?).toList.mapM fun s => do
    let fn ← (← SpecJ.req s "fn").getStr?
    let piece ← (SpecJ.optD s "piece" (.str fn)).getStr?
    let depth := ((s.getObjVal? "depth").bind (·.getNat?)).toOption
    let cls := ((s.getObjVal? "class").bind (·.getStr?)).toOption
    let name := ((s.getObjVal? "name").bind (·.getStr?)).toOption
    let results ← (← (SpecJ.optD s "results" (.arr #[])).getArr?).toList.mapM (·.getStr?)
    pure ({ fn, piece, depth, cls, name, results } : ChainStage)
  let glue ← (← (SpecJ.optD j "glue" (.arr #[])).getArr?).toList.mapM (·.getStr?)
  let vars ← (← (SpecJ.optD j "vars" (.arr #[])).getArr?).toList.mapM fun v => do
    match (← v.getArr?).toList with
    | [a, q] => pure (← a.getNat?, ← q.getStr?)
    | _ => throw "vars: pairs [variable, quantity]"
  let stop ← Stop.parse (← (SpecJ.optD j "stop" (.str "halt")).getStr?)
  return { stages, stop, cap := ((j.getObjVal? "cap").bind (·.getNat?)).toOption.getD 8000000,
           fresh := ((j.getObjVal? "fresh").bind (·.getNat?)).toOption.getD 1000,
           baseVals := ← SpecJ.pairsOf (SpecJ.optD j "baseVals" (.arr #[])),
           row := ((j.getObjVal? "row").bind (·.getStr?)).toOption, tags, static := staticOf j, glue, vars,
           compact := ((j.getObjVal? "compact").bind (·.getBool?)).toOption.getD true,
           frames := ((j.getObjVal? "frames").bind fun v => (Lean.fromJson? v : Except String (List Nat))).toOption.getD framedArrays,
           bridges := ((j.getObjVal? "bridges").bind fun v => (Lean.fromJson? v : Except String (List String))).toOption.getD [],
           isolate := ((j.getObjVal? "isolate").bind (·.getBool?)).toOption.getD false,
           stuckStop := ((j.getObjVal? "stuckStop").bind (·.getBool?)).toOption.getD false,
           accept := ((j.getObjVal? "accept").bind (·.getStr?)).toOption.getD "auto",
           D0 := ((j.getObjVal? "D0").bind (·.getNat?)).toOption.getD 4096,
           loadP := ((j.getObjVal? "loadP").bind fun v => (Lean.fromJson? v : Except String (List Nat))).toOption,
           startTokens := ((j.getObjVal? "startTokens").bind fun v => (Lean.fromJson? v : Except String (List Nat))).toOption,
           skipTo := match j.getObjVal? "skipTo" with
             | .ok o => match (o.getObjVal? "fn").bind (·.getStr?) with
               | .ok fn => some (fn, ((o.getObjVal? "depth").bind (·.getNat?)).toOption,
                   ((o.getObjVal? "count").bind (·.getNat?)).toOption.getD 1)
               | .error _ => none
             | .error _ => none,
           wide := ((j.getObjVal? "wide").bind fun v => (Lean.fromJson? v : Except String (List (Nat × String)))).toOption.getD [],
           spec := match j.getObjVal? "spec" with
             | .ok (.str p) => some p
             | .ok (.obj o) => some (Lean.Json.obj o).compress
             | _ => none }

/-- A class table row's tags (`classes.json`, A4b's `host/sim/lin`). -/
def rowTags (classes : Lean.Json) (row : String) : Except String (List (String × String)) := do
  for c in (← (← SpecJ.req classes "classes").getArr?) do
    for r in (← (SpecJ.optD c "rows" (.arr #[])).getArr?) do
      if (r.getObjVal? "id").bind (·.getStr?) == .ok row then
        match r.getObjVal? "tags" with
        | .ok (.obj kvs) => return kvs.foldl (fun acc k v => match v with | .str t => acc ++ [(k, t)] | _ => acc) []
        | _ => return []
  throw s!"no class table row {row}"

unsafe def loadPlan (arg : String) : IO ChainPlan := do
  let text ← if arg.startsWith "{" then pure arg else IO.FS.readFile arg
  let j ← IO.ofExcept (Lean.Json.parse text)
  let tags ← match j.getObjVal? "row", j.getObjVal? "classes" with
    | .ok (.str row), .ok (.str f) => IO.ofExcept (rowTags (← IO.ofExcept (Lean.Json.parse (← IO.FS.readFile f))) row)
    | _, _ => pure []
  IO.ofExcept (planOf j tags)

/-! ## Compaction after a merge

A3's compaction (`Conv.compact`, `Conv.full_compact`) relates the merged state `s1` to a canonical state `c`
under `κ = Map.compact n0 n1 nS pl nr big region node`: the call's addresses (`< n0`) and table entries
(`< nS`) fixed, the canonical result places `n0 + j` sent to the stage's result addresses `pl` (the
stage-created addresses the merged state still reaches, in the order a walk from its roots meets them, so
the canonical state does not depend on the stage's allocation order), the canonical fresh addresses after
them to `s1.next + k`, the canonical result numbers `nS + j` to `nr` (the stage-made references the merged
state reaches); the native part likewise (result handles and nodes at canonical places from the call's
counters, `big`, `region`, `node` of `Compaction.fwd`). `c` is `s1` pushed back by the inverse: the
call's entries the stage did not write are `s1`'s (the caller's; the same page constants), the written
ones and the results renamed; its trace is the call's; its table the call's with one fresh result variable
per result number (`ws`, `θ = compactθ ws rs`, `rs` the merged entries). -/

/-- The data of a compaction. -/
structure Compaction where
  n0 : Nat
  n1 : Nat
  nS : Nat
  pl : List Nat
  nr : List Nat
  plh : List Nat
  pln : List Nat
  xn0 : Nat
  xn1 : Nat
  nn0 : Nat
  nn1 : Nat
  ws : List Nat
  rs : List SymE
  wrB : List Nat
  /-- The canonical native state's arrays, objects and nodes (the shift checks' chunks). -/
  counts : List Nat := []
  whB : List Nat
  wiB : List Nat
  fwd : RData

def ptrieOf {α : Type} (l : List (Nat × α)) : PTrie α := l.foldl (fun t (k, v) => t.set k v) PTrie.nil

def indexIn (l : List Nat) (x : Nat) : Option Nat := (l.zipIdx.find? (·.1 == x)).map (·.2)

unsafe def Compaction.json (k : Compaction) : Lean.Json :=
  let pairs (l : List (Nat × Nat)) := Lean.Json.arr (l.toArray.map fun (a, b) => Lean.Json.arr #[Lean.toJson a, Lean.toJson b])
  Lean.Json.mkObj [("n0", Lean.toJson k.n0), ("n1", Lean.toJson k.n1), ("nS", Lean.toJson k.nS), ("pl", Lean.toJson k.pl),
    ("nr", Lean.toJson k.nr), ("plh", Lean.toJson k.plh), ("pln", Lean.toJson k.pln), ("xn0", Lean.toJson k.xn0),
    ("xn1", Lean.toJson k.xn1), ("nn0", Lean.toJson k.nn0), ("nn1", Lean.toJson k.nn1), ("ws", Lean.toJson k.ws),
    ("rs", Lean.toJson (k.rs.map fmtSym)), ("wrB", Lean.toJson k.wrB), ("whB", Lean.toJson k.whB), ("wiB", Lean.toJson k.wiB),
    ("counts", Lean.toJson k.counts),
    ("fwd", Lean.Json.mkObj [("n0", Lean.toJson k.fwd.n0), ("n1", Lean.toJson k.fwd.n1), ("nh0", Lean.toJson k.fwd.nh0),
      ("nh1", Lean.toJson k.fwd.nh1), ("nn0", Lean.toJson k.fwd.nn0), ("nn1", Lean.toJson k.fwd.nn1),
      ("heap", pairs (k.pl.zipIdx.map fun (b, j) => (k.n0 + j, b))), ("hnd", pairs (k.plh.zipIdx.map fun (h, j) => (k.xn0 + j, h))),
      ("node", pairs (k.pln.zipIdx.map fun (n, j) => (k.nn0 + j, n)))])]

/-- A number as a Lean term. -/
def leanF64 : F64 → String
  | .nan => "F64.nan"
  | .inf n => s!"(F64.inf {n})"
  | .zero n => s!"(F64.zero {n})"
  | .fin n m e => s!"(F64.fin {n} {m} ({e}))"

/-- A symbolic expression as a Lean term (a generated module's statement). -/
def leanSym : SymE → String
  | .lit x => s!"(SymE.lit {leanF64 x})"
  | .var i => s!"(SymE.var {i})"
  | .bin op a b => s!"(SymE.bin .{opName op} {leanSym a} {leanSym b})"
  | .un op a => s!"(SymE.un .{opName op} {leanSym a})"

def leanNum : NumV → String
  | .lit x => s!"(NumV.lit {leanF64 x})"
  | .ref i => s!"(NumV.ref {i})"

/-- A JavaScript value as a Lean term (none for a pointer). -/
def leanVal : Val → Option String
  | .undef => some "Val.undef"
  | .null => some "Val.null"
  | .bool b => some s!"(Val.bool {b})"
  | .num x => some s!"(Val.num {leanNum x})"
  | .big i => some s!"(Val.big ({i}))"
  | .str s => some s!"(Val.str {repr (String.ofList s)}.toList)"
  | .sym i => some s!"(Val.sym {i})"
  | .obj a => some s!"(Val.obj {a})"
  | .ptr _ _ => none

/-- The elements of the array at `a` (`Template.arrOf`). -/
def arrAt {S : Type} (s : St S) (a : Nat) : List Val :=
  match s.heap.get a with
  | some (.obj o) => match o.kind with
    | .array es => es
    | _ => []
  | _ => []

/-- The framed arrays at `s` past the start `s0`'s (`CallGen.arrExt_of`): per address, whether the start's
elements are a prefix, and the further elements as Lean terms. -/
def arrsJson {S : Type} (s0 s : St S) (frames : List Nat) : Lean.Json :=
  Lean.Json.arr (frames.toArray.map fun a =>
    let e0 := arrAt s0 a; let e := arrAt s a
    Lean.Json.mkObj [("a", Lean.toJson a), ("prefix", Lean.toJson ((e.take e0.length).map leanVal == e0.map leanVal)),
      ("els", Lean.toJson ((e.drop e0.length).map fun v => (leanVal v).getD "none"))])

/-- Keys present in `t0` and absent from `t2` (entries a piece removed). -/
unsafe def removedKeys {α : Type} (t0 t2 : PTrie α) : List Nat :=
  (changedKeys t2 t0 (2 ^ 62)).filter fun k => (t2.get k).isNone

/-- The native counters at a state with table length `n` (`Conv.Cnt`: handles, nodes, JS addresses, table refs). -/
def nclCnt {F : Ffi} (w : TWorld F) (s : St F.S) (n : Nat) : Lean.Json :=
  let l := w.proj s; Lean.toJson [l.aux.ffi.mlx.next, l.aux.ffi.mlx.nnext, l.next, n]

/-- The native bookkeeping of a piece from boundary `a` (state `sa`, table length `na`) to `b` (`Conv.NClean`,
`Conv.NClean.stepKeep`): the handles (arrays and objects), nodes and readback items it changes or creates, the
entries it removes (none, for the keep form), and the counters at both ends. -/
unsafe def nclJson {F : Ffi} (w : TWorld F) (sa sb : St F.S) (na nb a b : Nat) : Lean.Json :=
  let ma := (w.proj sa).aux.ffi.mlx; let mb := (w.proj sb).aux.ffi.mlx
  let lh := ((changedKeys ma.arrs mb.arrs (2 ^ 62)) ++ (changedKeys ma.objs mb.objs (2 ^ 62))).mergeSort (· ≤ ·) |>.eraseDups
  Lean.Json.mkObj [("from", Lean.toJson a), ("to", Lean.toJson b), ("lh", Lean.toJson lh),
    ("ln", Lean.toJson (changedKeys ma.nodes mb.nodes (2 ^ 62))), ("li", Lean.toJson (changedKeys ma.items mb.items (2 ^ 62))),
    ("removed", Lean.Json.mkObj [("arrs", Lean.toJson (removedKeys ma.arrs mb.arrs)), ("objs", Lean.toJson (removedKeys ma.objs mb.objs)),
      ("nodes", Lean.toJson (removedKeys ma.nodes mb.nodes)), ("items", Lean.toJson (removedKeys ma.items mb.items))]),
    ("ca", nclCnt w sa na), ("cb", nclCnt w sb nb),
    ("jh", Lean.toJson ((changedKeys (w.proj sa).heap (w.proj sb).heap (2 ^ 62)) ++ removedKeys (w.proj sa).heap (w.proj sb).heap |>.mergeSort (· ≤ ·)))]

/-- The canonical state of the merged state `sr` (after the call `sC` with table `callTab`; the merged
table `mTab`), its table, the compaction's data, and the valuation of the canonical result variables
(`cbase` on). -/
unsafe def compactNative {F : Ffi} (w : TWorld F) (sC sr : St F.S) (callTab mTab : List SymE) (cbase : Nat)
    (ρ : Nat → F64) (frames : List Nat := framedArrays) (start : Option (St F.S) := none) :
    TermElabM (St F.S × List SymE × Compaction × (Nat → F64)) := do
  let env ← getEnv
  let lC := w.proj sC; let l1 := w.proj sr
  let mC := lC.aux.ffi.mlx; let m1 := l1.aux.ffi.mlx
  let n0 := lC.next; let n1 := l1.next; let nS := callTab.length
  let xn0 := mC.next; let xn1 := m1.next; let nn0 := mC.nnext; let nn1 := m1.nnext
  -- the stage's results are what the merged state reaches through the stage's writes: a walk of the footprint from
  -- the roots and the written caller entries, not entering the caller's other entries (they cannot reach a result)
  let wrB := changedKeys lC.heap l1.heap n0
  let whB := ((changedKeys mC.arrs m1.arrs xn0) ++ (changedKeys mC.objs m1.objs xn0)).eraseDups
  let ctx : Ctx := { s1 := l1, s2 := l1, t1 := mTab.toArray, t2 := mTab.toArray, env, traceNodes := traceNodesOf m1,
                     heapFrom := n0, handlesFrom := xn0, nodesFrom := nn0, primNums := true }
  let ((), wk) ← ((show Host.Ts.Sim.Template.WM Unit from do
      for n in w.extraNodes sr.aux.ffi do pairNode n n (.root "extra") ""
      for b in wrB do modify fun x => { x with sig := x.sig.insert b b, sigInv := x.sigInv.insert b b, work := x.work.push (0, b, b) }
      for h in whB do modify fun x => { x with hnd := x.hnd.insert h h, hndInv := x.hndInv.insert h h, work := x.work.push (1, h, h) }
      walkRoots ((nativeHeapRefs m1).map fun a => (a, a))).run ctx).run ({} : Host.Ts.Sim.Template.W)
  unless wk.mism.isEmpty do throwError "compaction: the walk found {wk.mism.size} mismatches"
  let order (kind lo : Nat) : List Nat :=
    (wk.work.toList.filterMap fun (k, a, _) => if k == kind && a ≥ lo then some a else none).eraseDups
  -- result nodes in the merged state's order: the full nodes' images keep their order (`MShift.norder`)
  let pl := order 0 n0; let plh := order 1 xn0; let pln := (order 2 nn0).mergeSort (· ≤ ·)
  let nr := (wk.pairs.toList.filterMap fun (r, _, _, _) => if r ≥ nS then some r else none).eraseDups
  let ws := (List.range nr.length).map (cbase + ·)
  let rs := nr.map fun r => mTab[r]?.getD (.var 0)
  -- merged → canonical, and canonical → merged (κ's native part)
  let inv : RData := ⟨n1, n0 + pl.length, ptrieOf (pl.zipIdx.map fun (b, j) => (b, n0 + j)),
    ptrieOf (plh.zipIdx.map fun (h, j) => (h, xn0 + j)), xn1, xn0 + plh.length, nn1, nn0 + pln.length,
    ptrieOf (pln.zipIdx.map fun (n, j) => (n, nn0 + j)), ptrieOf (nr.zipIdx.map fun (r, j) => (r, NumV.ref (nS + j)))⟩
  let fwd : RData := ⟨n0 + pl.length, n1, ptrieOf (pl.zipIdx.map fun (b, j) => (n0 + j, b)),
    ptrieOf (plh.zipIdx.map fun (h, j) => (xn0 + j, h)), xn0 + plh.length, xn1, nn0 + pln.length, nn1,
    ptrieOf (pln.zipIdx.map fun (n, j) => (nn0 + j, n)), ptrieOf (nr.zipIdx.map fun (r, j) => (nS + j, NumV.ref r))⟩
  let D := inv.map
  -- the JavaScript heap: the call's entries kept, the written ones and the results renamed
  let heap := ptrieKeep l1.heap (· < n0)
  -- a written framed array: the call's entry (the template prefix the framed clause extends)
  let heap := wrB.foldl (fun t b => if frames.contains b then (match lC.heap.get b with | some o => t.set b o | none => t)
    else match l1.heap.get b with | some o => t.set b (D.hobj o) | none => t) heap
  let heap := pl.zipIdx.foldl (fun t (b, j) => match l1.heap.get b with | some o => t.set (n0 + j) (D.hobj o) | none => t) heap
  -- the framed arrays the chain start holds: its elements (the template prefix the frames extend, the elements past it
  -- absorbed into the frames' target prefixes; `Prefill.IterGhostCW.compact`), on the changed list
  let frR : List Nat := match start with
    | none => []
    | some s0 => frames.filter fun a => match (w.proj s0).heap.get a, l1.heap.get a with
      | some (.obj o0), some (.obj o) => (match o0.kind, o.kind with | .array _, .array _ => true | _, _ => false)
      | _, _ => false
  let heap := match start with
    | none => heap
    | some s0 => frR.foldl (fun t a => match (w.proj s0).heap.get a, D.hobj <$> l1.heap.get a with
      | some (.obj o0), some (.obj o) => t.set a (.obj { o with kind := o0.kind })
      | _, _ => t) heap
  let wrB := (wrB ++ frR).mergeSort (· ≤ ·) |>.eraseDups
  -- the native state likewise
  let mvA (t : PTrie Nat) (h : Nat) (h' : Nat) : PTrie Nat := match m1.arrs.get h with | some n => t.set h' (D.node n) | none => t
  let mvO (t : PTrie Host.Mlx.Ffi.Obj) (h : Nat) (h' : Nat) : PTrie Host.Mlx.Ffi.Obj := match m1.objs.get h with | some o => t.set h' (D.nobj o) | none => t
  let arrs := plh.zipIdx.foldl (fun t (h, j) => mvA t h (xn0 + j)) (whB.foldl (fun t h => mvA t h h) (ptrieKeep m1.arrs (· < xn0)))
  let objs := plh.zipIdx.foldl (fun t (h, j) => mvO t h (xn0 + j)) (whB.foldl (fun t h => mvO t h h) (ptrieKeep m1.objs (· < xn0)))
  let nodes := pln.zipIdx.foldl (fun t (n, j) => match m1.nodes.get n with | some nd => t.set (nn0 + j) (D.nnode nd) | none => t)
    (ptrieKeep m1.nodes (· < nn0))
  let wiB := changedKeys mC.items m1.items nn0
  let items := pln.zipIdx.foldl (fun t (n, j) => match m1.items.get n with | some x => t.set (nn0 + j) (D.nv x) | none => t)
    (wiB.foldl (fun t i => match m1.items.get i with | some x => t.set i (D.nv x) | none => t) (ptrieKeep m1.items (· < nn0)))
  let mc := { m1 with arrs := arrs, objs := objs, nodes := nodes, items := items }
  let mc := { mc with next := xn0 + plh.length, nnext := nn0 + pln.length, tokens := m1.tokens.map D.nv }
  let mc := { mc with pending := m1.pending.map D.pend, errh := m1.errh.map D.arg }
  let hmap (h : Nat) : Option Nat := if h < xn0 then some h else (indexIn plh h).map (xn0 + ·)
  let nmap (n : Nat) : Option Nat := if n < nn0 then some n else (indexIn pln n).map (nn0 + ·)
  let ffi := w.renameExtra (w.setLoad sr.aux.ffi { l1.aux.ffi with mlx := mc }) hmap nmap
  let c : St F.S := ⟨heap, n0 + pl.length, D.ctl l1.ctl, l1.stack.map D.frame,
    ⟨l1.aux.jobs.map D.job, ffi, lC.aux.trace, D.stores l1.aux.stores⟩⟩
  let vals := rs.map fun e => e.eval ρ
  let ρ' : Nat → F64 := fun v => match (ws.zip vals).find? (·.1 == v) with
    | some (_, x) => x
    | none => ρ v
  let cnt {α : Type} (t : PTrie α) : Nat := ptrieFold (fun (n : Nat) _ _ => n + 1) t 0
  let k : Compaction := { n0, n1, nS, pl, nr, plh, pln, xn0, xn1, nn0, nn1, ws, rs, wrB, whB, wiB, fwd,
                          counts := [cnt mc.arrs, cnt mc.objs, cnt mc.nodes] }
  return (c, callTab ++ ws.map SymE.var, k, ρ')

/-- The written and fresh heap addresses of a stage run (`Conv.StageFoot`'s `wr`). -/
unsafe def wrOf (l0 l2 : St LSt) : List Nat :=
  changedKeys l0.heap l2.heap l0.next ++ ((List.range' l0.next (l2.next - l0.next)).filter fun a => (l2.heap.get a).isSome)

/-- `e` is the variable `v` up to integer casts and `+ 0`, `- 0`, `· 1`. -/
def isVarUpTo (v : Nat) : SymE → Bool
  | .var w => w == v
  | .un op a => (op == .int32 || op == .uint32 || op == .trunc || op == .floor || op == .ceil) && isVarUpTo v a
  | .bin .add a (.lit z) => decide (z = F64.ofNat 0) && isVarUpTo v a
  | .bin .sub a (.lit z) => decide (z = F64.ofNat 0) && isVarUpTo v a
  | .bin .mul a (.lit z) => decide (z = F64.ofNat 1) && isVarUpTo v a
  | _ => false

/-- A stage result's quantity: the quantity of the one mapped variable its value mentions, exact (the variable up to
casts) or derived (another expression of it, for the reader to scale). -/
def resQty (vars : List (Nat × String)) (e : SymE) : Option (String × Bool) :=
  match vars.filter fun (v, _) => !(e.noVar v) with
  | [(v, q)] => some (q, isVarUpTo v e)
  | _ => none

/-- Why `interpRec` fails on a run: the machine's message, or the symbolic operation it cannot answer. -/
def whyStuck {α : Type} (ρ : Nat → F64) : Free α → SSrv → String
  | .pure _, _ => "no failure"
  | .fail m, _ => m
  | .bin op a b k, c => match c.val a, c.val b with
    | some x, some y => whyStuck ρ (k c.tab.length) { c with tab := c.tab ++ [.bin op x y] }
    | _, _ => "an unknown number reference"
  | .un op a k, c => match c.val a with
    | some x => whyStuck ρ (k c.tab.length) { c with tab := c.tab ++ [.un op x] }
    | none => "an unknown number reference"
  | .test op a b k, c => match c.val a, c.val b with
    | some x, some y => whyStuck ρ (k (F64.test op (x.eval ρ) (y.eval ρ))) c
    | _, _ => "an unknown number reference"
  | .conc a k, c => match c.val a with
    | some (.lit x) => whyStuck ρ (k x) c
    | some e => s!"a concrete value of the symbolic number {fmtSym e}"
    | none => "an unknown number reference"

/-- A state's control, for messages: the callee's name at a call. -/
def ctlNote {S : Type} (s : St S) : String :=
  match s.ctl with
  | .call (.obj a) _ args =>
    let nm := (fnNameOf s a).getD s!"#{a}"
    let sym := match Bridge.symCallName s with | some n => s!" (native {String.ofList n})" | none => ""
    s!"a call of {nm}{sym} with {args.length} arguments, depth {s.stack.length}"
  | .ret _ => s!"a return at depth {s.stack.length}"
  | _ => s!"depth {s.stack.length}"

/-- `tpl_chain`'s work: see the module doc. -/
unsafe def chainCmdW {F : Ffi} (w : TWorld F) (pre srcName srvName : Lean.Name) (planArg : String) (capO : Option Nat)
    (argE : Option Lean.Expr := none) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let plan ← loadPlan planArg
  let cap := capO.getD plan.cap
  let t0 ← IO.monoMsNow
  -- an abstracted boundary (`host_stream … abs`, e.g. the prompt boot's `P.a2818 fw`) at the argument `arg`
  let srcE ← match argE with
    | some a => pure ((← getConstInfo srcName).value!.beta #[← Meta.reduce a (skipTypes := true)])
    | none => pure (mkConst srcName)
  let fromLoad ← isDefEq (← inferType (match argE with | some a => mkApp (mkConst srcName) a | none => mkConst srcName))
    (mkApp (mkConst ``St) (mkConst ``LSt))
  let (s, c0, g0) ← if fromLoad then do
      let (l, c, g) ← restoreAny (S := LSt) srcE (mkConst srvName) pre
      pure (w.lift l, c, g)
    else restoreAny (S := F.S) srcE (mkConst srvName) pre
  -- a fast-forward to the start (no boundaries): the `count`-th call of `fn`
  let (s, c0) ← match plan.skipTo with
    | none => pure (s, c0)
    | some (fn, d, n) => do
      let ρs : Nat → F64 := fun i => match plan.baseVals.find? (·.1 == i) with
        | some (_, v) => F64.ofNat v
        | none => Host.Load.Decode.valuation i
      let mut st := s
      let mut c : SSrv := ⟨c0.tab, []⟩
      let mut k : Nat := 0
      let mut n0 : Nat := 0
      while k < n do
        match interpRec ρs (step F st).run c [] with
        | some (s', c', _) =>
          st := s'; c := c'; n0 := n0 + 1
          if isCallOf st fn d then k := k + 1
        | none => throwError "tpl_chain {pre}: stuck after {n0} steps of the fast-forward at {ctlNote st}: {whyStuck ρs (step F st).run c}"
      logInfo m!"tpl_chain {pre}: fast-forward {n0} steps to call {n} of {fn}"
      pure (st, ({ c with oracle := [] } : SSrv))
  -- an isolated start: the call without the caller's frames, the spec's places symbolized
  let spec := (← specOfPath plan.spec).getD {}
  let (s, c0, isoEnts) ← if plan.isolate then do
      let (s0, cI, ents, _, stats) ← isolate w s c0 spec plan.static "none"
      logInfo m!"tpl_chain {pre}: isolated start: {stats}, {ents.size} symbolized places"
      pure (s0, cI, ents)
    else pure (s, c0, #[])
  -- the start's token queue replaced
  let s := match plan.startTokens with
    | none => s
    | some ts => let l := (w.proj s).aux.ffi
      s.setFfi (w.setLoad s.aux.ffi { l with mlx := { l.mlx with tokens := ts.map NumV.ref } })
  let t1 ← IO.monoMsNow
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let oE := mkConst (pre ++ `O)
  let drop (m : Nat) := mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit m) oE
  let mut ρ : Nat → F64 := fun i => match plan.baseVals.find? (·.1 == i) with
    | some (_, v) => F64.ofNat v
    | none => match isoEnts.find? (·.var == i) with
      | some e => match e.orig with
        | .lit x => x
        | .ref _ => Host.Load.Decode.valuation i
      | none => Host.Load.Decode.valuation i
  let (g, b0) ← writeBoundaryW w pre nonce dir { g0 with pre } 0 s c0.tab (drop 0)
    (if fromLoad || argE.isSome || plan.isolate || plan.startTokens.isSome then none else some (mkConst srcName))
  let mut g := g
  let mut bytes := b0
  let mut st := s
  let mut c : SSrv := ⟨c0.tab, []⟩
  -- the glue piece's start (its native bookkeeping's `a`)
  let mut segSt := s
  -- the canonical result variables' defining terms (the stage's results over the call's variables), earlier ones
  -- substituted: the chain end's table de-canonicalized (`chain.json` "dtheta", the end facts' `<Name>.dθ`)
  let mut dws : Array Nat := #[]
  let mut drs : Array SymE := #[]
  let mut segTab := c0.tab.length
  let mut o : Array Ans := #[]
  let mut steps : Nat := 0
  let mut ks : Array Nat := #[]
  let mut bs : Array SegBridge := #[]
  let mut pieces : Array Lean.Json := #[]
  let mut segStart : Nat := 0
  let mut segSteps : Nat := 0
  let mut fresh := plan.fresh
  let mut stop := ""
  let mut site : Nat := 0
  let mut segO : Nat := 0
  let mut frames : List Nat := plan.frames
  -- the chain's load parameters, from its start's counters (`LoadP`: lo, E, NE, NL, N0): its acceptance's and its
  -- compactions' (`fullJSPP`, `Conv.FullShiftQ`)
  let loadPJ : Lean.Json := match plan.loadP with
    | some p => Lean.toJson p
    | none => let m := (w.proj s).aux.ffi.mlx; Lean.toJson [m.next, 131072, 2 ^ 40, m.nnext, m.nnext]
  let mut nBridges : Nat := 0
  let mut seg0 : Nat := 0
  let mut gvars : List (Nat × String) := plan.vars
  -- result variables derived from a mapped variable by another expression (variable, quantity, the expression)
  let mut gderived : List (Nat × String × String) := []
  let mut first := true
  let mut startEmpty := false
  -- the closure the last stage returned (a stage `fn` "@ret": its call, as a dispatch's forward)
  let mut lastRet : Option Nat := none
  let isStage (r : Option Nat) (x : St F.S) : Option ChainStage := plan.stages.find? fun cs =>
    if cs.fn == "@ret" then r.any fun a => isCallOf x s!"#{a}" cs.depth else isCallOf x cs.fn cs.depth
  -- glue `k`'s name: the plan's, else `start` for an empty glue 0 (a chain from a call), else `g<k>`
  let glueName (empty0 : Bool) (k : Nat) : String :=
    plan.glue[k]?.getD (if k == 0 && empty0 then "start" else s!"g{k}")
  -- glue `k`'s oracle (the answers of its run, `X.O`'s slice) and variable map, beside `X`'s boundaries
  -- `k` the glue's index, its run the segments `runSeg<seg0>` … `runSeg<seg1>` between the bridges inside it
  let writeGlue (k : Nat) (nm : String) (a b o0 o1 steps seg0 seg1 : Nat) (vars : List (Nat × String))
      (derived : List (Nat × String × String) := []) (ncl : Lean.Json := .null) : IO Lean.Json := do
    let lean := if a ≥ b then Lean.Json.null else if seg0 == seg1 then Lean.toJson s!"{pre}.runSeg{seg0}"
      else Lean.toJson ((List.range' seg0 (seg1 + 1 - seg0)).map fun j => s!"{pre}.runSeg{j}")
    let j := Lean.Json.mkObj [("glue", Lean.toJson nm), ("chain", Lean.toJson pre.toString), ("index", Lean.toJson k),
      ("lean", lean), ("world", Lean.toJson w.name), ("from", Lean.toJson a), ("to", Lean.toJson b), ("steps", Lean.toJson steps),
      ("vars", Lean.Json.arr (vars.toArray.map fun (v, q) => Lean.Json.arr #[Lean.toJson v, Lean.toJson q])),
      ("oracle", Lean.toJson s!"List.take {o1 - o0} (List.drop {o0} {pre}.O)"), ("answers", Lean.toJson (o1 - o0)),
      ("derived", Lean.Json.arr (derived.toArray.map fun (v, q, e) => Lean.Json.arr #[Lean.toJson v, Lean.toJson q, Lean.toJson e])),
      ("bridges", Lean.toJson (seg1 - seg0)), ("ncl", ncl)]
    IO.FS.writeFile (dir / pre.toString / s!"glue{k}.json") (j.pretty ++ "\n")
    pure (Lean.Json.mkObj [("glue", Lean.toJson nm), ("lean", lean), ("from", Lean.toJson a), ("to", Lean.toJson b),
      ("steps", Lean.toJson steps), ("meta", Lean.toJson s!"glue{k}.json")])
  -- the readback stop: the start's callee called again at the start's depth
  let (fa0, depth0) := match s.ctl with
    | .call (.obj a) _ _ => (a, s.stack.length)
    | _ => (0, 0)
  while stop.isEmpty do
    -- glue, to the next stage call or the stop
    let mut n : Nat := 0
    let mut call : Option (ChainStage × St F.S × SSrv × List Ans) := none
    let mut bridge : Option (BridgeHit × St F.S × SSrv × List Ans) := none
    -- a chain from a call: the start state is the site (no step into it, an empty glue 0)
    let mut stepped := true
    if first then
      first := false
      if let some cs := isStage lastRet st then
        call := some (cs, st, c, [])
        stepped := false
    while call.isNone && bridge.isNone && n < 10000 do
      match plan.stop with
      | .readback => match st.ctl with
        | .call (.obj a) _ _ => if steps > 0 && a == fa0 && st.stack.length == depth0 then stop := "readback"; break
        | _ => pure ()
      | .call f d => if steps > 0 && isCallOf st f d then stop := plan.stop.name; break
      | .below d => if st.stack.length < d then stop := plan.stop.name; break
      | .steps k => if steps ≥ k then stop := plan.stop.name; break
      | .ret => if steps > 0 && isRetAt st s.stack.length then stop := "ret"; break
      | _ => pure ()
      if isHalt st.ctl then stop := "halt"; break
      match interpRec ρ (step F st).run c [] with
      | some (s', c', a) =>
        -- the stop's call ends the chain before a stage of the same function (a decode iteration's next readback)
        let stopHere := match plan.stop, s'.ctl with
          | .readback, .call (.obj f) _ _ => f == fa0 && s'.stack.length == depth0
          | .call fn d, _ => isCallOf s' fn d
          | _, _ => false
        if stopHere then
          st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1; segSteps := segSteps + 1
          stop := plan.stop.name
          break
        if let some cs := isStage lastRet s' then call := some (cs, s', c', a); break
        if !plan.bridges.isEmpty then
          if let some hit := Bridge.routeBridges { kinds := plan.bridges } frames (w.proj s') c' then
            bridge := some (hit, s', c', a); break
        st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1; segSteps := segSteps + 1
      | none =>
        let why := s!"stuck after {steps} steps at {ctlNote st}: {whyStuck ρ (step F st).run c}"
        if plan.stuckStop then
          stop := s!"stuck: {why}"
          logInfo m!"tpl_chain {pre}: {why}"
          break
        throwError "tpl_chain {pre}: {why}"
      if segSteps > cap then throwError "tpl_chain {pre}: a glue piece exceeds {cap} steps"
    if n > 0 then
      ks := ks.push n
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
    -- a bridge point inside the glue: the step into the bridge state (boundary `ia`), then its transition (`ia + 1`):
    -- a patch, B-newdata's or B-size's patched step, or the state's own step (as `tpl_case_split`)
    if let some (hit, sA, cA, aA) := bridge then
      let nA := steps
      st := sA; c := cA; o := o ++ aA.reverse.toArray; steps := steps + 1; segSteps := segSteps + 1
      ks := ks.push 1
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
      let ia := ks.size
      let arr := match st.ctl with
        | .ret (.obj a) => a
        | _ => 0
      let aN := st.next
      let mut nT := 1
      if hit.size then
        match interpRec ρ (Disp.sizeS F st).run c [] with
        | some (s', c', a') => st := s'; c := c'; o := o ++ a'.reverse.toArray; nT := 3
        | none => throwError "tpl_chain {pre}: the patched B-size transition is stuck"
      else match hit.patch, hit.ndBytes.bind fun bsT => (Bridge.ndParts st).map (·, bsT) with
        | some (lB, es), _ => st := w.unproj st lB; c := { c with tab := c.tab ++ es }
        | none, some ((name, rt, tys, rest, bb), bsT) =>
          match interpRec ρ (Disp.newDataS F st name rt tys rest bb bsT).run c [] with
          | some (s', c', a') => st := s'; c := c'; o := o ++ a'.reverse.toArray
          | none => throwError "tpl_chain {pre}: the patched B-newdata step is stuck"
        | none, none =>
          match interpRec ρ (step F st).run c [] with
          | some (s', c', a') => st := s'; c := c'; o := o ++ a'.reverse.toArray
          | none => throwError "tpl_chain {pre}: stuck at the bridge"
      steps := steps + nT; segSteps := segSteps + nT
      ks := ks.push nT
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
      let patched := hit.patch.isSome || hit.ndBytes.isSome || hit.size
      bs := bs.push { kind := hit.kind, ia, aN, nA, arr, extra := hit.extra ++ (if patched then [("patched", Lean.toJson true)] else []) }
      if hit.kind == "spread" then frames := frames ++ [aN]
      frames := frames ++ hit.frames
      nBridges := nBridges + 1
      continue
    let some (cs, sC, cC, a) := call | continue
    if site == 0 then startEmpty := segSteps == 0
    let oEnd := o.size
    -- the step into the call state, a chunk of its own (boundary `ia`)
    if stepped then
      st := sC; c := cC; o := o ++ a.reverse.toArray; steps := steps + 1
      ks := ks.push 1
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
    let ia := ks.size
    pieces := pieces.push (← writeGlue site (glueName startEmpty site) segStart (if stepped then ia - 1 else ia) segO oEnd
      segSteps seg0 bs.size gvars gderived (nclJson w segSt st segTab c.tab.length segStart ia))
    -- the site template and its run, in the instance's own stream with `X`'s page names
    let ipre := pre ++ Lean.Name.mkSimple s!"st{site}"
    let inonce := s!"{ipre}:{← IO.monoNanosNow}"
    IO.FS.createDirAll (dir / ipre.toString)
    let (s0, cI, _, ifr, stats) ← isolate w st c { frames := some frames } plan.static "none"
    let iwide := plan.wide.filter fun (a, _) => ((w.proj s0).heap.get a).isSome
    let iO := mkConst (ipre ++ `O)
    let (gI, bI0) ← writeBoundaryW w ipre inonce dir { g with pre := ipre } 0 s0 cI.tab
      (mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit 0) iO) none
    let (s2, c2, out) ← runLocal w ipre inonce dir ρ s0 cI.tab { g := gI, bytes := bI0 } cap
    defineStream ipre w.ffiC out.o cI.tab out.ks inonce out.steps
    defineEntries ipre #[] ifr
    let cls := cs.cls.getD ((plan.tags.find? (·.1 == cs.piece)).map (·.2) |>.getD "")
    -- the called function as recorded: `@ret` with the closure's address
    let fnR := match cs.fn, st.ctl with
      | "@ret", .call (.obj a) _ _ => s!"@ret #{a}"
      | f, _ => f
    let sname := cs.name.getD (if cls.isEmpty then cs.piece else s!"{cs.piece}_{cls}")
    let callName := s!"{sname}__{glueName startEmpty site}__{glueName startEmpty (site + 1)}"
    let n0 := c.tab.length
    -- the stage's new table entries become fresh variables, bound to the stage's values
    let ws := (List.range (c2.tab.length - n0)).map (fresh + ·)
    let vals := (c2.tab.drop n0).map fun e => e.eval ρ
    let ρ0 := ρ
    ρ := fun v => match (ws.zip vals).find? (·.1 == v) with
      | some (_, x) => x
      | none => ρ0 v
    fresh := fresh + ws.length
    -- the merge: `Conv.mergeSt` at the instance's own site (σ = Map.id)
    let rs := st.stack
    let wr := wrOf (w.proj s0) (w.proj s2)
    let τ := Map.res Map.id n0 n0
    let sr := Conv.mergeSt Map.id τ rs wr st s2 s0 s2.aux.ffi
    let stage := Lean.Json.mkObj [("name", Lean.toJson callName), ("stage", Lean.toJson sname),
      ("fn", Lean.toJson fnR), ("piece", Lean.toJson cs.piece), ("class", Lean.toJson cls),
      ("site", Lean.toJson site), ("instance", Lean.toJson ipre.toString), ("T1", Lean.toJson out.ks.size),
      ("steps", Lean.toJson out.steps), ("callSteps", Lean.toJson steps), ("rs", Lean.toJson rs.length),
      ("n0", Lean.toJson n0), ("ws", Lean.toJson ws), ("wr", Lean.toJson wr.length), ("stepped", Lean.toJson stepped),
      ("stepAnswers", Lean.toJson (o.size - oEnd)),
      ("conv", Lean.Json.mkObj [("sigma", Lean.toJson "id"), ("theta", Lean.toJson "id"), ("compaction", Lean.toJson plan.compact)])]
    IO.FS.writeFile (dir / ipre.toString / "stage.json")
      ((stageJson ipre fnR cs.piece w.name out.ks.size out.steps plan.vars ifr #[] cI.tab.toArray
        ([("site", Lean.toJson site), ("class", Lean.toJson cls), ("name", Lean.toJson callName), ("chain", Lean.toJson pre.toString),
          ("callBoundary", Lean.toJson ia), ("callSteps", Lean.toJson steps), ("callDepth", Lean.toJson rs.length),
          ("wide", Lean.toJson iwide), ("loadP", loadPJ), ("accept", Lean.toJson plan.accept), ("D0", Lean.toJson plan.D0),
          ("traceNew", Lean.toJson ((w.proj s2).aux.trace.length - (w.proj s0).aux.trace.length)),
          ("tab0", Lean.toJson cI.tab.length)] ++ footJson (w.proj s0) (w.proj s2) plan.static)).pretty ++ "\n")
    writeSeg dir ipre (segJson cs.piece "return" out.ks.size out.steps ifr [] (segMore w (w.proj s0) (w.proj s2) false))
    -- the merged state at boundary `ia + 1` (zero steps), the table with the fresh variables
    let callSt := st
    let callTab := c.tab
    st := sr
    c := { c with tab := c.tab ++ resTab' ws }
    ks := ks.push 0
    let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
    g := g'; bytes := bytes + b
    -- the compaction: the canonical state at the next boundary (another zero-step chunk)
    let mut compJ := Lean.Json.null
    let mut kdWs : List Nat := []
    let mut kdNr : List Nat := []
    if plan.compact then
      let (cs', ctab, kd, ρ') ← compactNative w callSt sr callTab c.tab fresh ρ frames (some s)
      fresh := fresh + kd.ws.length
      ρ := ρ'
      st := cs'
      c := { c with tab := ctab }
      ks := ks.push 0
      let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
      g := g'; bytes := bytes + b
      compJ := (kd.json.setObjVal! "cCall" (nclCnt w callSt callTab.length)).setObjVal! "cCan" (nclCnt w cs' ctab.length)
        |>.setObjVal! "removed" (let mc := (w.proj callSt).aux.ffi.mlx; let mk := (w.proj cs').aux.ffi.mlx
          Lean.toJson (removedKeys mc.arrs mk.arrs ++ removedKeys mc.objs mk.objs ++ removedKeys mc.nodes mk.nodes ++ removedKeys mc.items mk.items))
        -- the canonical results' values: the instance's end table at the result references (Lean terms)
        |>.setObjVal! "rsLean" (Lean.toJson (kd.nr.map fun r => (c2.tab[r]?.map leanSym).getD "none"))
      kdWs := kd.ws
      let dsub : Nat → SymE := fun v => match dws.toList.idxOf? v with
        | some j => drs[j]?.getD (.var v)
        | none => .var v
      for (wv, r) in kd.ws.zip kd.nr do
        dws := dws.push wv
        drs := drs.push (((c2.tab[r]?).getD (.var wv)).subst dsub)
      kdNr := kd.nr
    -- the result variables' quantities for the glue after the call: the plan's `results`, else the one mapped variable
    -- the value mentions (exact up to casts; otherwise listed as derived, with its expression)
    let stageE := c2.tab.drop n0
    let resEnts : List (Nat × Nat × SymE) := match plan.compact, compJ with
      | true, .null => []
      | true, _ => (kdWs.zip kdNr).filterMap fun (v, r) => (stageE[r - n0]?).map fun e => (v, r - n0, e)
      | false, _ => (ws.zipIdx.filterMap fun (v, j) => (stageE[j]?).map fun e => (v, j, e))
    for (w, j, e) in resEnts do
      match cs.results[j]? with
      | some q => gvars := gvars ++ [(w, q)]
      | none => match resQty gvars e with
        | some (q, true) => gvars := gvars ++ [(w, q)]
        | some (q, false) => gderived := gderived ++ [(w, q, fmtSym e)]
        | none => pure ()
    bs := bs.push { kind := "stage", ia, aN := st.next, nA := steps, arr := 0, extra := [("fn", Lean.toJson fnR),
      ("piece", Lean.toJson cs.piece), ("class", Lean.toJson cls), ("site", Lean.toJson site), ("name", Lean.toJson callName),
      ("instance", Lean.toJson ipre.toString), ("T1", Lean.toJson out.ks.size), ("n0", Lean.toJson n0), ("ws", Lean.toJson ws),
      ("compaction", compJ), ("arrs", arrsJson s sr frames)] }
    pieces := pieces.push (Lean.Json.mkObj [("stage", stage)])
    lastRet := match st.ctl with | .ret (.obj f) => some f | _ => none
    logInfo m!"tpl_chain {pre}: site {site} {callName} ({fnR}) at boundary {ia}: {stats}; stage {out.steps} steps, {out.ks.size} chunks, {ws.length} fresh variables, {wr.length} written entries"
    site := site + 1
    segStart := if plan.compact then ia + 2 else ia + 1
    segSt := st
    segTab := c.tab.length
    segSteps := 0
    segO := o.size
    seg0 := bs.size
  pieces := pieces.push (← writeGlue site (glueName startEmpty site) segStart ks.size segO o.size segSteps seg0 bs.size gvars gderived
    (nclJson w segSt st segTab c.tab.length segStart ks.size))
  writeSeg dir pre (segJson "chain" stop ks.size steps plan.frames bs.toList
    (segMore w (w.proj s) (w.proj st) false ++ [("row", Lean.toJson plan.row), ("wide", Lean.toJson plan.wide),
      ("accept", Lean.toJson plan.accept), ("D0", Lean.toJson plan.D0),
      ("loadP", loadPJ)]))
  IO.FS.writeFile (dir / pre.toString / "chain.json") ((Lean.Json.mkObj [("chain", Lean.toJson pre.toString),
    ("world", Lean.toJson w.name), ("row", Lean.toJson plan.row), ("stop", Lean.toJson stop), ("T1", Lean.toJson ks.size),
    ("start", let l := w.proj s; Lean.Json.mkObj [("next", Lean.toJson l.next), ("mnext", Lean.toJson l.aux.ffi.mlx.next),
      ("nnext", Lean.toJson l.aux.ffi.mlx.nnext)]),
    -- the native bookkeeping's full check at the start (`Conv.ncleanB`): its counters and the key counts
    ("ncl0", let m := (w.proj s).aux.ffi.mlx; Lean.Json.mkObj [("c", nclCnt w s c0.tab.length),
      ("counts", Lean.toJson [(changedKeys PTrie.nil m.arrs (2 ^ 62)).length, (changedKeys PTrie.nil m.objs (2 ^ 62)).length,
        (changedKeys PTrie.nil m.nodes (2 ^ 62)).length, (changedKeys PTrie.nil m.items (2 ^ 62)).length])]),
    ("endArrs", arrsJson s st frames),
    ("source", Lean.toJson srcName.toString), ("startTokens", Lean.toJson plan.startTokens),
    ("dtheta", let keep := (dws.toList.zip drs.toList).filter fun (v, _) => c.tab.any fun e => !e.noVar v
      Lean.Json.mkObj [("ws", Lean.toJson (keep.map (·.1))), ("rs", Lean.toJson (keep.map (leanSym ·.2))),
      ("endTab", Lean.toJson (c.tab.map fun e => leanSym (e.subst fun v => match dws.toList.idxOf? v with
        | some j => drs[j]?.getD (.var v)
        | none => .var v)))]),
    ("steps", Lean.toJson steps), ("pieces", Lean.Json.arr pieces)]).pretty ++ "\n")
  defineStream pre w.ffiC o c0.tab ks nonce steps
  let t2 ← IO.monoMsNow
  logInfo m!"tpl_chain {pre}: restore {t1 - t0} ms, run {t2 - t1} ms; {steps} glue steps to {stop}, {site} stage calls, {nBridges} bridges, {ks.size} chunks (T1 = {pre}.s{ks.size}), {bytes} bytes"
where
  resTab' (ws : List Nat) : List SymE := ws.map SymE.var

/-- `tpl_chain X from s, S : "<plan>" [(world := w, cap := n, arg := t)]` (`arg`: `s` is an abstracted boundary,
`host_stream … abs`, applied to `t`, e.g. the prompt boot's `P.a2818 (π.map natV)`). -/
elab "tpl_chain " p:ident " from " src:ident ", " srv:ident " : " plan:str os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `cap, `arg]
    let pre := (← getCurrNamespace) ++ p.getId
    let srcN ← resolveGlobalConstNoOverload src
    let srvN ← resolveGlobalConstNoOverload srv
    let argE ← match os.find? (·.1 == `arg) with
      | some (_, t) => some <$> (instantiateMVars (← Term.elabTermAndSynthesize t none))
      | none => pure none
    match os.ident `world with
    | none | some `lf => unsafe chainCmdW lfWorld pre srcN srvN plan.getString (os.num `cap) argE
    | some n =>
      let args := #[toExpr pre, toExpr srcN, toExpr srvN, toExpr plan.getString, toExpr (os.num `cap), toExpr argE]
      unsafe inWorld ``chainCmdW (← worldConst n) args

end Host.Ts.Sim.Template
