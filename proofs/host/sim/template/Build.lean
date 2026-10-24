import host.sim.template.Walk
import host.sim.template.World
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
`10 000` steps up to the next readback cut (or halt), like `host_stream`.

Both commands are generic in the world (`host.sim.template.World`): with `(world := w)` they run
the machine of `w` (`full`: `Host.Load.Layers.full`, `host.sim.template.FullWorld`; a template of
that world cut from a load-world state is its lift `TWorld.lift`), without it the load world's
exactly as before. With `(spec := "<file or JSON>")` (a template spec, `TSpec`) the template's places,
framed arrays, ghosts, by-key maps, frozen entries and cases come from it instead of the literals
below; `(stop := "<pred>", cap := n)` give a case's stop predicate (`Stop`) and step cap. -/

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
  ⟨"FINALC1", [(0, 257), (9, 257), (10, 255), (11, 255), (12, 255), (13, 254), (16, 512)], false, true⟩,
  -- EOS read at a loop cut (`var 14`): the exit runs before the yield, the clear test, the budget
  -- test and the next forward, so it covers every loop iteration
  ⟨"EOSX", [(14, 248044)], false, false⟩,
  -- EOS read in the final iteration (`var 17`), after the cut's token is yielded with no cache
  -- clear (`FINALE`) or with one (`FINALEC0`, `FINALC0`'s phase)
  ⟨"FINALE", [(0, 3), (17, 248044)], false, true⟩,
  ⟨"FINALEC0", [(0, 258), (9, 258), (10, 256), (11, 256), (12, 256), (13, 255), (16, 512), (17, 248044)], false, true⟩]

/-- The cases of a prompt of any length (`host.sim.CasesL`): `cases` and the two loop cases where
the cache clear (`i % 256 = 0`) meets the KV fill (`p % 256 = 255`, `CLEARFILL`) or growth
(`p % 256 = 0`, `CLEARGROWTH`). The case commands look names up here. -/
def casesL : List Case := cases ++ [
  ⟨"CLEARFILL", [(9, 255), (10, 256), (11, 256), (12, 256), (13, 255), (16, 256), (0, 1000)], true, false⟩,
  ⟨"CLEARGROWTH", [(9, 256), (10, 256), (11, 256), (12, 256), (13, 255), (16, 256), (0, 1000)], true, false⟩]

/-- The case metadata the module generators read (`gen.ts`, `genFinal.ts` with `--meta`): the
last boundary, the steps, the stop, the framed arrays at the start, and the bridge points
(`kind`; boundary `ia` of the bridge state; its `next`, the address of a spread's new array;
the steps `nA` to the state before it; the array `arr` it returns, `0` if none). -/
structure SegBridge where
  kind : String
  ia : Nat
  aN : Nat
  nA : Nat
  arr : Nat
  /-- Kind-specific fields (seg.json v2: `len`, `slice`, `typed`, `ptr`, `newdata`, `stage`). -/
  extra : List (String × Lean.Json) := []

def segJson (name stop : String) (t1 steps : Nat) (frames : List Nat) (bridges : List SegBridge)
    (more : List (String × Lean.Json) := []) : Lean.Json :=
  Lean.Json.mkObj ([("case", Lean.toJson name), ("T1", Lean.toJson t1), ("steps", Lean.toJson steps),
    ("stop", Lean.toJson stop),
    ("frames", Lean.toJson frames),
    ("bridges", Lean.Json.arr (bridges.map fun b =>
      Lean.Json.mkObj ([("kind", Lean.toJson b.kind), ("ia", Lean.toJson b.ia), ("aN", Lean.toJson b.aN),
        ("nA", Lean.toJson b.nA), ("arr", Lean.toJson b.arr)] ++ b.extra)).toArray)] ++ more)

/-- Write `seg.json` beside the case's boundaries. -/
def writeSeg (dir : System.FilePath) (pre : Lean.Name) (j : Lean.Json) : IO Unit :=
  IO.FS.writeFile (dir / pre.toString / "seg.json") (j.pretty ++ "\n")

def Case.valuation (c : Case) (i : Nat) : F64 :=
  match c.over.find? (·.1 == i) with
  | some (_, v) => F64.ofNat v
  | none => match baseVals.find? (·.1 == i) with
    | some (_, v) => F64.ofNat v
    | none => Host.Load.Decode.valuation i

/-! ## Template specs

A spec (JSON; `(spec := "<file>")`, or the JSON itself) lists, in table order, the template's places: numbers of the cut, each replaced
by a fresh table entry `.var v` (the place's `var`), the number the cut held checked against
`value` (a number, `{"ref": i}`, or absent). Place kinds:

* `cell` (`addr`), `prop` (`addr`, the property `key`), `priv` (`addr`, the private name
  `key`), `elem` (`addr`, `index`), `mapVal` (`addr`, the string key `key`): numbers of the
  JavaScript heap (the loop variables, id counters, `#traceId` fields);
* `token` (`index`): the native token queue's entry;
* `dim` (`addr` a native handle, or a node id for a family given by `nodes`; `index` the axis;
  optional `rank`): a node's shape dimension (the KV capacity, shapeless-trace dims);
* `payload` (`addr` a native handle): a compiled closure's payload number (the trace id).

A place with `addrs` (or `handles`, `nodes`) stands for one place per address, named
`<name> h<a>` (dims: `<name> N<node>`). An address may be `"$field"`, a field of the Addr JSON
the spec's `addr` names (relative to the spec; `genAddr.ts`). The other fields: `frames` (the
framed arrays, default `framedArrays`), `prompt` (`{"addr": a}`: the prompt array, framed with
template prefix `[]`, added to the frames), `ghosts` (heap addresses whose content depends on
the history: the walks pair them but do not compare them), `maps` (JavaScript maps the walks
compare by key, extra keys being ghost entries), `frozen` (caller entries: a stage template
leaves them out, `tpl_stage`), `collect` (collect the cut, default `true`), `cases` (as `cases`
below: `name`, `over` pairs, `loop`, `extraToken`, `grow`) and `baseVals` (pairs). -/

inductive NumExp where
  | any
  | nat (n : Nat)
  | ref (i : Nat)

def NumExp.ok : NumExp → NumV → Bool
  | .any, _ => true
  | .nat n, y => decide (y = .lit (F64.ofNat n))
  | .ref i, y => decide (y = .ref i)

structure Place where
  name : String
  kind : String
  addr : Nat := 0
  key : String := ""
  index : Nat := 0
  value : NumExp := .any
  var : Nat
  rank : Option Nat := none

structure TSpec where
  places : Array Place := #[]
  frames : Option (List Nat) := none
  ghosts : List Nat := []
  maps : List Nat := []
  frozen : List Nat := []
  collect : Bool := true
  cases : List Case := []
  grow : List String := []
  baseVals : List (Nat × Nat) := []

instance : Inhabited TSpec := ⟨{}⟩

/-- The cases whose iteration grows the KV capacity (`genRestart.ts`'s `grow`). -/
def growCases : List String := ["GROWTH", "CLEARGROWTH"]

namespace SpecJ
open Lean (Json)

def req (j : Json) (k : String) : Except String Json :=
  match j.getObjVal? k with
  | .ok v => .ok v
  | .error _ => .error s!"missing field {k}"

def optD (j : Json) (k : String) (d : Json) : Json :=
  match j.getObjVal? k with
  | .ok v => v
  | .error _ => d

def natOf (addr : Json) : Json → Except String Nat
  | .str s => match s.toList with
    | '$' :: rest => match addr.getObjVal? (String.ofList rest) with
      | .ok v => v.getNat?
      | .error _ => .error s!"unknown address {s}"
    | _ => .error s!"expected a number: {s}"
  | j => j.getNat?

def natsOf (addr : Json) (j : Json) : Except String (List Nat) := do
  (← j.getArr?).toList.mapM (natOf addr)

def pairsOf (j : Json) : Except String (List (Nat × Nat)) := do
  (← j.getArr?).toList.mapM fun p => do
    match (← p.getArr?).toList with
    | [x, y] => pure (← x.getNat?, ← y.getNat?)
    | _ => throw "expected a pair [variable, value]"

def numExpOf : Json → Except String NumExp
  | .null => pure .any
  | j@(.num _) => return .nat (← j.getNat?)
  | j => match j.getObjVal? "ref" with
    | .ok r => return .ref (← r.getNat?)
    | .error _ => throw "a place's value: a number, {\"ref\": i} or null"

def placesOf (addr : Json) (j : Json) : Except String (Array Place) := do
  let name ← (optD j "name" (.str "")).getStr?
  let kind ← (← req j "kind").getStr?
  let key ← (optD j "key" (.str "")).getStr?
  let index ← (optD j "index" (Lean.toJson (0 : Nat))).getNat?
  let value ← numExpOf (optD j "value" .null)
  let var ← (← req j "var").getNat?
  let rank ← match j.getObjVal? "rank" with
    | .ok r => some <$> r.getNat?
    | .error _ => pure none
  let one (n : String) (a : Nat) (k : String) : Place := { name := n, kind, addr := a, key := k, index, value, var, rank }
  match j.getObjVal? "addrs", j.getObjVal? "handles", j.getObjVal? "nodes" with
  | .ok as, _, _ => return (← natsOf addr as).toArray.map fun a => one (if kind == "dim" then name else s!"{name} h{a}") a key
  | _, .ok hs, _ => return (← natsOf addr hs).toArray.map fun h => one name h key
  | _, _, .ok ns => return (← natsOf addr ns).toArray.map fun n => one name n "node"
  | _, _, _ => return #[one name (← natOf addr (optD j "addr" (Lean.toJson (0 : Nat)))) key]

def caseOf (j : Json) : Except String (Case × Bool) := do
  let name ← (← req j "name").getStr?
  let over ← pairsOf (optD j "over" (.arr #[]))
  let loop ← (optD j "loop" (.bool false)).getBool?
  let extraToken ← (optD j "extraToken" (.bool false)).getBool?
  let grow ← (optD j "grow" (.bool false)).getBool?
  return (⟨name, over, loop, extraToken⟩, grow)

def specOf (addr : Json) (j : Json) : Except String TSpec := do
  let mut places : Array Place := #[]
  for p in (← (optD j "places" (.arr #[])).getArr?) do places := places ++ (← placesOf addr p)
  let frames ← match j.getObjVal? "frames" with
    | .ok f => some <$> natsOf addr f
    | .error _ => pure none
  let frames ← match j.getObjVal? "prompt" with
    | .ok p => do
      let a ← natOf addr (← req p "addr")
      pure (some ((frames.getD framedArrays) ++ [a]))
    | .error _ => pure frames
  let cs ← (← (optD j "cases" (.arr #[])).getArr?).toList.mapM caseOf
  return { places, frames
           ghosts := ← natsOf addr (optD j "ghosts" (.arr #[]))
           maps := ← natsOf addr (optD j "maps" (.arr #[]))
           frozen := ← natsOf addr (optD j "frozen" (.arr #[]))
           collect := match optD j "collect" (.bool true) with
             | .bool b => b
             | .str c => c != "none"
             | _ => true
           cases := cs.map (·.1)
           grow := (cs.filter (·.2)).map (·.1.name)
           baseVals := ← pairsOf (optD j "baseVals" (.arr #[])) }

end SpecJ

/-- Read a template spec: the JSON itself (a string starting with `{`, as generated modules give
it), or a file (relative to the working directory). Its `addr` is an object or a file (relative
to the spec's file). -/
def loadSpec (arg : String) : IO TSpec := do
  let (text, dir) ← if arg.startsWith "{" then pure (arg, ("." : System.FilePath))
    else pure (← IO.FS.readFile arg, ((arg : System.FilePath).parent.getD "."))
  let j ← IO.ofExcept (Lean.Json.parse text)
  let addr ← match j.getObjVal? "addr" with
    | .ok (.str f) => IO.ofExcept (Lean.Json.parse (← IO.FS.readFile (dir / f)))
    | .ok o => pure o
    | .error _ => pure Lean.Json.null
  match SpecJ.specOf addr j with
  | .ok s => pure s
  | .error e => throw (IO.userError s!"template spec {if arg.startsWith "{" then "(inline)" else arg}: {e}")

def TSpec.framesD (sp : TSpec) : List Nat := sp.frames.getD framedArrays

/-- The case `nm`: the spec's, else `casesL`'s. -/
def TSpec.case? (sp : TSpec) (nm : String) : Option Case :=
  (sp.cases.find? (·.name == nm)).orElse fun _ => casesL.find? (·.name == nm)

def TSpec.valuation (sp : TSpec) (c : Case) (i : Nat) : F64 :=
  match c.over.find? (·.1 == i) with
  | some (_, v) => F64.ofNat v
  | none => match sp.baseVals.find? (·.1 == i) with
    | some (_, v) => F64.ofNat v
    | none => c.valuation i

def TSpec.grows (sp : TSpec) (nm : String) : Bool := sp.grow.contains nm || growCases.contains nm

/-! ### Symbolization by a spec -/

def dimNum : Host.Mlx.Ffi.Dim → NumV
  | .lit i => .lit (F64.ofNat i.toNat)
  | .sym x => x

/-- Symbolize the (collected) cut at the spec's places, in order. -/
def symbolizeSpec (ps : Array Place) (s : St LSt) (c : SSrv) : Except String (St LSt × SSrv × Array Entry) := do
  let mut tab := c.tab.toArray
  let mut s := s
  let mut ents : Array Entry := #[]
  for p in ps do
    let r := tab.size
    let check (y : NumV) (at_ : String) : Except String Unit :=
      unless p.value.ok y do throw s!"{p.name} {at_}: unexpected value {repr y}"
    match p.kind with
    | "cell" | "prop" =>
      let prop := if p.kind == "cell" then none else some p.key
      let some y := readNum s p.addr prop | throw s!"{p.name} h{p.addr}: not a number place"
      check y s!"h{p.addr}"
      s := writeNum s p.addr prop (.ref r)
      ents := ents.push ⟨p.name, r, p.var, y⟩
    | "priv" | "elem" | "mapVal" =>
      let some o := s.obj? p.addr | throw s!"{p.name} h{p.addr}: not an object"
      let (y, o') ← match p.kind, o.kind with
        | "priv", _ => match o.priv.find? (fun ((_, n), _) => n == p.key.toList) with
          | some (_, .data (.num y) _ _) =>
            pure (y, { o with priv := o.priv.map fun (k, v) => if k.2 == p.key.toList then (k, setNum (.ref r) v) else (k, v) })
          | _ => throw s!"{p.name} h{p.addr}: no number field #{p.key}"
        | "elem", .array xs => match xs[p.index]? with
          | some (.num y) => pure (y, { o with kind := .array (xs.set p.index (.num (.ref r))) })
          | _ => throw s!"{p.name} h{p.addr}[{p.index}]: not a number"
        | "mapVal", .map es => match es.find? (fun (k, _) => match k with | .str cs => cs == p.key.toList | _ => false) with
          | some (_, .num y) =>
            pure (y, { o with kind := .map (es.map fun (k, v) => match k with
              | .str cs => if cs == p.key.toList then (k, .num (.ref r)) else (k, v)
              | _ => (k, v)) })
          | _ => throw s!"{p.name} h{p.addr}: no number entry {p.key}"
        | _, _ => throw s!"{p.name} h{p.addr}: not a {p.kind} place"
      check y s!"h{p.addr}"
      s := s.setObj p.addr o'
      ents := ents.push ⟨p.name, r, p.var, y⟩
    | "token" =>
      let m := s.aux.ffi.mlx
      let some y := m.tokens[p.index]? | throw s!"{p.name}: no token {p.index} at the cut"
      check y s!"token {p.index}"
      s := s.setFfi { s.aux.ffi with mlx := { m with tokens := m.tokens.set p.index (.ref r) } }
      ents := ents.push ⟨p.name, r, p.var, y⟩
    | "dim" =>
      let m := s.aux.ffi.mlx
      let id ← if p.key == "node" then pure p.addr else match m.arrs.get p.addr with
        | some id => pure id
        | none => throw s!"{p.name} H{p.addr}: no node"
      let some nd := m.nodes.get id | throw s!"{p.name} N{id}: missing"
      if let some k := p.rank then unless nd.shape.length == k do throw s!"{p.name} N{id}: rank {nd.shape.length}"
      let some d := nd.shape[p.index]? | throw s!"{p.name} N{id}: no axis {p.index}"
      check (dimNum d) s!"N{id}"
      s := s.setFfi { s.aux.ffi with mlx := { m with nodes := m.nodes.set id { nd with
        shape := Host.Mlx.Ffi.setAt nd.shape p.index (.sym (.ref r)) } } }
      ents := ents.push ⟨s!"{p.name} N{id}", r, p.var, dimNum d⟩
    | "payload" =>
      let m := s.aux.ffi.mlx
      let some (.clo (.compiled cb (.num y) sh ts)) := m.objs.get p.addr
        | throw s!"{p.name} H{p.addr}: not a compiled closure with a number payload"
      check y s!"H{p.addr}"
      s := s.setFfi { s.aux.ffi with mlx := { m with objs := m.objs.set p.addr (.clo (.compiled cb (.num (.ref r)) sh ts)) } }
      ents := ents.push ⟨p.name, r, p.var, y⟩
    | k => throw s!"{p.name}: unknown place kind {k}"
    tab := tab.push (.var p.var)
  return (s, { c with tab := tab.toList }, ents)

/-! ## Stop predicates

`Stop` ends a case's run (`tpl_case … (stop := "<pred>")`): `readback` (the template control's
callee is called again at the template's depth, after a first step), `halt`, `call:<f>` and
`call:<f>@<d>` (a call of the closure named `f`, or of the function object at address `#a`,
at stack depth `d`), `below:<d>` (the stack shorter than `d`: a return out of the start's
frames) and `steps:<n>`. Every run also stops at a halt. -/

inductive Stop where
  | readback
  | halt
  | call (fn : String) (depth : Option Nat)
  | below (d : Nat)
  | steps (n : Nat)
  /-- The start's call returns (a return at the start's depth or below). -/
  | ret

def Stop.parse (s : String) : Except String Stop :=
  let natS (cs : List Char) : Except String Nat := match (String.ofList cs).toNat? with
    | some n => .ok n
    | none => .error s!"stop {s}: not a number"
  match s.toList with
  | ['r', 'e', 'a', 'd', 'b', 'a', 'c', 'k'] => .ok .readback
  | ['h', 'a', 'l', 't'] => .ok .halt
  | 'c' :: 'a' :: 'l' :: 'l' :: ':' :: rest =>
    match rest.span (· != '@') with
    | (f, []) => .ok (.call (String.ofList f) none)
    | (f, _ :: d) => return .call (String.ofList f) (some (← natS d))
  | 'b' :: 'e' :: 'l' :: 'o' :: 'w' :: ':' :: rest => return .below (← natS rest)
  | 's' :: 't' :: 'e' :: 'p' :: 's' :: ':' :: rest => return .steps (← natS rest)
  | ['r', 'e', 't'] => .ok .ret
  | _ => .error s!"unknown stop predicate {s} (readback, halt, call:<f>[@<d>], below:<d>, steps:<n>, ret)"

def Stop.name : Stop → String
  | .readback => "readback"
  | .halt => "halt"
  | .call f none => s!"call:{f}"
  | .call f (some d) => s!"call:{f}@{d}"
  | .below d => s!"below:{d}"
  | .steps n => s!"steps:{n}"
  | .ret => "ret"

/-- A return state at depth at most `d`. -/
def isRetAt {S : Type} (s : St S) (d : Nat) : Bool :=
  match s.ctl with
  | .ret _ => s.stack.length ≤ d
  | _ => false

/-- The name of the closure a function object runs (`#a`: the object itself). -/
def fnNameOf {S : Type} (s : St S) (a : Nat) : Option String :=
  match s.obj? a with
  | some o => match o.kind with
    | .fn (.closure (.mk (some n) ..) ..) => some (String.ofList n)
    -- a method (no name of its own): the key its home object holds it under
    | .fn (.closure (.mk none ..) _ _ (.obj h)) => match s.obj? h with
      | some ho => ho.props.findSome? fun (k, p) => match k, p with
        | .str n, .data (.obj b) _ _ => if b == a then some (String.ofList n) else none
        | _, _ => none
      | none => none
    | _ => none
  | none => none

/-- `s` is a call of the function `fn` (a closure name, or `#a`) at depth `d`. -/
def isCallOf {S : Type} (s : St S) (fn : String) (d : Option Nat) : Bool :=
  match s.ctl with
  | .call (.obj a) _ _ =>
    (d.all (· == s.stack.length)) &&
      (match fn.toList with
        | '#' :: rest => (String.ofList rest).toNat? == some a
        | _ => fnNameOf s a == some fn)
  | _ => false

/-! ## Native restoration and boundary files -/

/-- Decode a state and server constant; the decoded named constants seed the
generator's aliases, so unchanged pages keep their names. -/
unsafe def restoreAny {S : Type} (state server : Lean.Expr) (pre : Lean.Name) : MetaM (St S × SSrv × G) := do
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

/-- `restoreAny` at the load world. -/
unsafe def restore (state server : Lean.Expr) (pre : Lean.Name) : MetaM (St LSt × SSrv × G) :=
  restoreAny state server pre

/-- Write boundary `i`: the state (serialized, or an existing constant) and the server
`⟨tab, oracle⟩`. -/
def writeBoundaryW {F : Ffi} (w : TWorld F) (pre : Lean.Name) (nonce : String) (dir : System.FilePath) (g : G)
    (i : Nat) (s : St F.S) (tab : List SymE) (oracle : Lean.Expr) (stConst : Option Lean.Expr) : IO (G × Nat) := do
  Memo.beginEpoch
  let (sE, g) ← match stConst with
    | some e => pure (e, g)
    | none => (stE w.ser w.tyS s).run { g with idx := i, count := 0, defs := #[] }
  let srv := mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oracle
  let bytes := writeRoots { nonce, defs := (if stConst.isSome then #[] else g.defs), st := sE, srv }
  IO.FS.writeBinFile (Stream.fileOf dir pre i) bytes
  let g := sweep { g with defs := #[] } #[sE, srv]
  pure (g, bytes.size)

/-- `writeBoundaryW` at the load world. -/
def writeBoundary (pre : Lean.Name) (nonce : String) (dir : System.FilePath) (g : G) (i : Nat) (s : St LSt)
    (tab : List SymE) (oracle : Lean.Expr) (stConst : Option Lean.Expr) : IO (G × Nat) :=
  writeBoundaryW lfWorld pre nonce dir g i s tab oracle stConst

private def addDef (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

private def natList (xs : List Nat) : Lean.Expr := toExpr xs

/-- The spec of a command's `spec` clause. -/
def specOfPath (path : Option String) : IO (Option TSpec) :=
  match path with
  | some p => some <$> loadSpec p
  | none => pure none

/-! ## The template -/

/-- The template `pre.s0`/`pre.S0` (one boundary) of the world `w` from the cut `src`/`srv` (a
state of `w`, or of the load world: then its lift): the cut collected (unless the spec says
not to) and symbolized (at the spec's places, else at the decode cut's literals). Defines
`pre.F`, `pre.nonce`, `pre.ks`, `pre.entries` (index, variable), `pre.orig` (index, the cut's
number) and, with a spec, `pre.frames`, `pre.ghosts`, `pre.maps`, `pre.frozen`; with a spec
it writes `template.json` (the world, the start's counters, the entries, frames, ghosts, maps, frozen entries)
beside the boundary. -/
unsafe def templateCmdW {F : Ffi} (w : TWorld F) (pre srcName srvName : Lean.Name) (specPath : Option String) :
    TermElabM Unit := do
    astTabRef.set (← loadAstTab)
    Memo.reset
    let spec? ← specOfPath specPath
    let spec := spec?.getD {}
    let t0 ← IO.monoMsNow
    let fromLoad ← isDefEq (← inferType (mkConst srcName)) (mkApp (mkConst ``St) (mkConst ``LSt))
    let (s, c, _) ← if fromLoad then do
        let (l, c, g) ← restoreAny (S := LSt) (mkConst srcName) (mkConst srvName) pre
        pure (w.lift l, c, g)
      else restoreAny (S := F.S) (mkConst srcName) (mkConst srvName) pre
    let t1 ← IO.monoMsNow
    let l := w.proj s
    -- reachability (identity walk) and collection
    let m := l.aux.ffi.mlx
    let traceSet := traceNodesOf m
    let natRefs := nativeHeapRefs m
    let roots := ((List.range 40).filter fun a => (l.heap.get a).isSome) ++ natRefs
    let ctx : Ctx := { s1 := l, s2 := l, t1 := c.tab.toArray, t2 := c.tab.toArray, env := ← getEnv, traceNodes := traceSet }
    let extra := w.extraNodes s.aux.ffi
    let ((), wk) ← ((do
        for n in extra do pairNode n n (.root "extra") ""
        walkRoots (roots.map fun a => (a, a))).run ctx).run {}
    unless wk.mism.isEmpty do throwError "tpl_template: the identity walk found {wk.mism.size} mismatches"
    let (sg, s) :=
      if spec.collect then
        let heap := ptrieFold (fun (acc : PTrie Host.Ts.HObj) a o => if wk.sig.contains a then acc.set a o else acc) l.heap PTrie.nil
        let nodes := ptrieFold (fun (acc : PTrie Host.Mlx.Ffi.Node) n nd => if wk.nod.contains n then acc.set n nd else acc) m.nodes PTrie.nil
        let items := ptrieFold (fun (acc : PTrie NumV) n x => if wk.nod.contains n then acc.set n x else acc) m.items PTrie.nil
        let sg : St LSt := { l with heap }
        -- native handles: only the live ones (garbage vectors and configs of earlier iterations go)
        let arrs := ptrieFold (fun (acc : PTrie Nat) h n => if wk.hnd.contains h then acc.set h n else acc) m.arrs PTrie.nil
        let objs := ptrieFold (fun (acc : PTrie Host.Mlx.Ffi.Obj) h o => if wk.hnd.contains h then acc.set h o else acc) m.objs PTrie.nil
        (sg.setFfi { sg.aux.ffi with mlx := { m with nodes, items, arrs, objs } },
          s.setFfi (w.restrict s.aux.ffi wk.hnd.contains wk.nod.contains))
      else (l, s)
    let symb := match spec? with
      | some sp => symbolizeSpec sp.places sg c
      | none => symbolize sg c
    let (T0, c0, ents) ← match symb with
      | .ok r => pure r
      | .error e => throwError "tpl_template: {e}"
    let T0 := w.unproj s T0
    let t2 ← IO.monoMsNow
    let nonce := s!"{pre}:{← IO.monoNanosNow}"
    let dir ← streamDir
    IO.FS.createDirAll (dir / pre.toString)
    let nilAns := mkApp (mkConst ``List.nil [.zero]) (mkConst ``Ans)
    let (_, bytes) ← writeBoundaryW w pre nonce dir { pre } 0 T0 c0.tab nilAns none
    addDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
    addDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
    addDef (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (natList []) (compile := true)
    let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
    addDef (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr (ents.toList.map fun e => (e.ref, e.var)))
    let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
    addDef (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy) (toExpr (ents.toList.map fun e => (e.ref, e.orig)))
    if let some sp := spec? then
      let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
      addDef (pre ++ `frames) natsTy (natList sp.framesD) (compile := true)
      addDef (pre ++ `ghosts) natsTy (natList sp.ghosts) (compile := true)
      addDef (pre ++ `maps) natsTy (natList sp.maps) (compile := true)
      addDef (pre ++ `frozen) natsTy (natList sp.frozen) (compile := true)
      let lT := w.proj T0
      let j := Lean.Json.mkObj [("world", Lean.toJson w.name), ("frames", Lean.toJson sp.framesD),
        ("start", Lean.Json.mkObj [("n", Lean.toJson c0.tab.length), ("next", Lean.toJson lT.next),
          ("mnext", Lean.toJson lT.aux.ffi.mlx.next), ("nnext", Lean.toJson lT.aux.ffi.mlx.nnext)]),
        ("ghosts", Lean.toJson sp.ghosts), ("maps", Lean.toJson sp.maps), ("frozen", Lean.toJson sp.frozen),
        ("entries", Lean.Json.arr (ents.map fun e => Lean.Json.mkObj [("name", Lean.toJson e.name),
          ("ref", Lean.toJson e.ref), ("var", Lean.toJson e.var), ("orig", Lean.toJson (fmtNum c.tab.toArray e.orig))]))]
      IO.FS.writeFile (dir / pre.toString / "template.json") (j.pretty ++ "\n")
    let heapN : Nat := ptrieFold (fun (k : Nat) _ _ => k + 1) l.heap 0
    let desc := w.describe T0.aux.ffi
    logInfo m!"tpl_template {pre}: restore {t1 - t0} ms, collect+symbolize {t2 - t1} ms; heap {wk.sig.size}/{heapN} kept, live handles {wk.hnd.size}, live nodes {wk.nod.size} (trace {traceSet.size}); table {c.tab.length} -> {c0.tab.length}; boundary {bytes} bytes{if w.name == "lf" then "" else s!"; world {w.name}{if fromLoad then " (lifted)" else ""}: {desc}"}"

/-- `templateCmdW` at the load world, without a spec. -/
unsafe def templateCmd (pre srcName srvName : Lean.Name) : TermElabM Unit := templateCmdW lfWorld pre srcName srvName none

/-! ## Cases -/

/-- The counters of a run (`seg.json` v2): heap, native handle and node counter deltas. -/
def countersJson (l0 l1 : St LSt) : List (String × Lean.Json) :=
  [("dJ", Lean.toJson (l1.next - l0.next)), ("dH", Lean.toJson (l1.aux.ffi.mlx.next - l0.aux.ffi.mlx.next)),
   ("dN", Lean.toJson (l1.aux.ffi.mlx.nnext - l0.aux.ffi.mlx.nnext))]

/-- `seg.json` v2's fields beyond v1: version, world, counters and growth. -/
def segMore {F : Ffi} (w : TWorld F) (l0 l1 : St LSt) (grow : Bool) : List (String × Lean.Json) :=
  [("version", Lean.toJson (2 : Nat)), ("world", Lean.toJson w.name), ("counters", Lean.Json.mkObj (countersJson l0 l1)),
   ("grow", Lean.toJson grow)]

/-- Case `nm` run in the world `w` from the template `base.s0`/`base.S0` natively (tests
answered at the case's valuation), writing boundaries every 10 000 steps up to the stop
(`stop`, default the next readback cut for a loop case, else halt) within `cap` steps; defines
`pre.F`, `pre.O`, `pre.ks`, `pre.nonce`, `pre.srv`, `pre.T1` (the last boundary) and `pre.steps`,
and writes `seg.json` (v2). -/
unsafe def caseCmdW {F : Ffi} (w : TWorld F) (pre base : Lean.Name) (nm : String) (specPath : Option String)
    (stopS : Option String) (cap : Option Nat) : TermElabM Unit := do
    let spec? ← specOfPath specPath
    let spec := spec?.getD {}
    let some cs := spec.case? nm | throwError "tpl_case: unknown case {nm}"
    let stopP ← match stopS with
      | some p => match Stop.parse p with
        | .ok q => pure q
        | .error e => throwError "tpl_case: {e}"
      | none => pure (if cs.loop then Stop.readback else Stop.halt)
    let cap := cap.getD 8000000
    astTabRef.set (← loadAstTab)
    Memo.reset
    let t0 ← IO.monoMsNow
    let (s0, c0, g0) ← restoreAny (S := F.S) (mkConst (base ++ `s0)) (mkConst (base ++ `S0)) pre
    let t1 ← IO.monoMsNow
    let (s, tab, stConst) :=
      if cs.extraToken then
        let r := c0.tab.length
        let l := w.proj s0
        let m := l.aux.ffi.mlx
        (w.unproj s0 (l.setFfi { l.aux.ffi with mlx := { m with tokens := m.tokens ++ [.ref r] } }), c0.tab ++ [.var 17], none)
      else (s0, c0.tab, some (mkConst (base ++ `s0)))
    let fa ← match stopP, s.ctl with
      | .readback, .call (.obj fa) _ _ => pure fa
      | .readback, _ => throwError "tpl_case: the template control is not a call"
      | _, _ => pure 0
    let depth := s.stack.length
    let nonce := s!"{pre}:{← IO.monoNanosNow}"
    let dir ← streamDir
    IO.FS.createDirAll (dir / pre.toString)
    let oE := mkConst (pre ++ `O)
    let drop (m : Nat) := mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit m) oE
    let ρ := if spec?.isSome then spec.valuation cs else cs.valuation
    let (g, b0) ← writeBoundaryW w pre nonce dir g0 0 s tab (drop 0) stConst
    let mut g := g
    let mut bytes := b0
    let mut st := s
    let mut c : SSrv := ⟨tab, []⟩
    let mut o : Array Ans := #[]
    let mut steps : Nat := 0
    let mut ks : Array Nat := #[]
    let mut stop := ""
    let mut wms : Nat := 0
    while stop.isEmpty do
      let mut n : Nat := 0
      while n < 10000 do
        match stopP with
        | .readback =>
          if steps > 0 then
            match st.ctl with
            | .call (.obj a) _ _ => if a == fa && st.stack.length == depth then stop := "readback"; break
            | _ => pure ()
        | .halt => pure ()
        | .call f d => if steps > 0 && isCallOf st f d then stop := stopP.name; break
        | .below d => if st.stack.length < d then stop := stopP.name; break
        | .steps k => if steps ≥ k then stop := stopP.name; break
        | .ret => if steps > 0 && isRetAt st depth then stop := "ret"; break
        if isHalt st.ctl then stop := "halt"; break
        match interpRec ρ (step F st).run c [] with
        | some (s', c', a) => st := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1; n := n + 1
        | none => throwError "tpl_case {pre}: stuck after {steps} steps"
      if n > 0 then
        ks := ks.push n
        let tw ← IO.monoMsNow
        let (g', b) ← writeBoundaryW w pre nonce dir g ks.size st c.tab (drop o.size) none
        wms := wms + ((← IO.monoMsNow) - tw)
        g := g'
        bytes := bytes + b
      if steps > cap then throwError "tpl_case {pre}: no stop within {cap} steps"
    writeSeg dir pre (segJson cs.name stop ks.size steps spec.framesD [] (segMore w (w.proj s) (w.proj st) (spec.grows cs.name)))
    let t2 ← IO.monoMsNow
    let ansL := mkApp (mkConst ``List [.zero]) (mkConst ``Ans)
    addDef (pre ++ `O) ansL (toExpr o.toList)
    addDef (pre ++ `F) (mkConst ``Ffi) (mkConst w.ffiC)
    addDef (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (natList ks.toList) (compile := true)
    addDef (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
    addDef (pre ++ `srv) (mkConst ``SSrv) (mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oE)
    addDef (pre ++ `T1) (mkConst ``Nat) (mkRawNatLit ks.size) (compile := true)
    addDef (pre ++ `steps) (mkConst ``Nat) (mkRawNatLit steps)
    let rate := if t2 - t1 - wms == 0 then 0 else steps * 1000 / (t2 - t1 - wms)
    logInfo m!"tpl_case {pre} ({cs.name}): restore {t1 - t0} ms, run+write {t2 - t1} ms (write {wms} ms, {rate} steps/s run); {steps} steps to {stop}, {ks.size} chunks (T1 = {pre}.s{ks.size}), oracle {o.size} answers, {bytes} bytes{if w.name == "lf" then "" else s!"; world {w.name}: {w.describe st.aux.ffi}"}"

/-- `caseCmdW` at the load world, without a spec. -/
unsafe def caseCmd (pre base : Lean.Name) (nm : String) : TermElabM Unit := caseCmdW lfWorld pre base nm none none none

/-! ## Worlds by name -/

/-- The world constant of a `world` clause: `n`, `Host.Ts.Sim.Template.n` or
`Host.Ts.Sim.Template.<n>World` (`full`: `fullWorld`, `host.sim.template.FullWorld`). -/
def worldConst (n : Lean.Name) : MetaM Lean.Name := do
  let env ← getEnv
  let cands := [n, `Host.Ts.Sim.Template ++ n, `Host.Ts.Sim.Template ++ Lean.Name.mkSimple (n.toString ++ "World")]
  match cands.find? env.contains with
  | some c => pure c
  | none => throwError "unknown template world {n} (import host.sim.template.FullWorld for `full`)"

/-- Run the generic command `cmd` (a constant `{F} → TWorld F → …`) at the world constant `wc`
with the arguments `args`. -/
unsafe def inWorld (cmd wc : Lean.Name) (args : Array Lean.Expr) : TermElabM Unit := do
  let ty ← inferType (mkConst wc)
  unless ty.isAppOfArity ``TWorld 1 do throwError "{wc} is not a template world"
  let e := mkAppN (mkConst cmd) (#[ty.appArg!, mkConst wc] ++ args)
  -- every argument given (a default argument left off would evaluate a function as the action)
  let ety ← inferType e
  unless ← isDefEq ety (mkApp (mkConst ``TermElabM) (mkConst ``Unit)) do throwError "inWorld {cmd}: the arguments leave the type {ety}"
  let act ← evalExpr (TermElabM Unit) ety e (safety := .unsafe)
  act

/-! A command's options: `(world := w, spec := "<file or JSON>", stop := "<pred>", cap := n)`, any
subset in any order (no new keywords: option names are identifiers). -/

syntax tplOpt := ident " := " term
syntax tplOpts := " (" tplOpt,* ")"

/-- The options of an optional `tplOpts` clause. -/
def tplOptsOf (stx : Option Syntax) : List (Lean.Name × Syntax) :=
  match stx with
  | some o => o[1]!.getSepArgs.toList.map fun a => (a[0]!.getId, a[2]!)
  | none => []

abbrev TplOpts := List (Lean.Name × Syntax)

def TplOpts.check (os : TplOpts) (known : List Lean.Name) : MetaM Unit :=
  for (n, _) in os do
    unless known.contains n do throwError "unknown option {n} (options: {known})"

def TplOpts.ident (os : TplOpts) (n : Lean.Name) : Option Lean.Name :=
  (os.find? (·.1 == n)).bind fun (_, v) => if v.isIdent then some v.getId else none
def TplOpts.str (os : TplOpts) (n : Lean.Name) : Option String :=
  (os.find? (·.1 == n)).bind fun (_, v) => v.isStrLit?
def TplOpts.num (os : TplOpts) (n : Lean.Name) : Option Nat :=
  (os.find? (·.1 == n)).bind fun (_, v) => v.isNatLit?

/-- `tpl_template T from s, S [(world := w, spec := "<file or JSON>")]`: the template `T.s0`/`T.S0` (one
boundary) from the cut `s`/`S`, with `T.F`, `T.nonce`, `T.entries` (index, variable) and `T.orig` (index,
the cut's number). -/
elab "tpl_template " p:ident " from " src:ident ", " srv:ident os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `spec]
    let pre := (← getCurrNamespace) ++ p.getId
    let srcN ← resolveGlobalConstNoOverload src
    let srvN ← resolveGlobalConstNoOverload srv
    match os.ident `world with
    | none | some `lf => unsafe templateCmdW lfWorld pre srcN srvN (os.str `spec)
    | some n => unsafe inWorld ``templateCmdW (← worldConst n) #[toExpr pre, toExpr srcN, toExpr srvN, toExpr (os.str `spec)]

/-- `tpl_case X from T : "NAME" [(world := w, spec := "…", stop := "<pred>", cap := n)]`: run case `NAME`
from the template `T.s0`/`T.S0` natively (tests answered at the case's valuation), writing boundaries
every 10 000 steps up to the stop; defines `X.F`, `X.O`, `X.ks`, `X.nonce`, `X.srv`, `X.T1` (the last
boundary index) and `X.steps`. -/
elab "tpl_case " p:ident " from " b:ident " : " nm:str os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `spec, `stop, `cap]
    let ns ← getCurrNamespace
    let pre := ns ++ p.getId
    let base := ns ++ b.getId
    match os.ident `world with
    | none | some `lf => unsafe caseCmdW lfWorld pre base nm.getString (os.str `spec) (os.str `stop) (os.num `cap)
    | some n =>
      let args := #[toExpr pre, toExpr base, toExpr nm.getString, toExpr (os.str `spec), toExpr (os.str `stop), toExpr (os.num `cap)]
      unsafe inWorld ``caseCmdW (← worldConst n) args

end Host.Ts.Sim.Template
