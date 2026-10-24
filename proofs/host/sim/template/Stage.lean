import host.sim.template.Bridges
import host.sim.StageRel
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # Stage templates cut from the route (`tpl_stage`)

`tpl_stage X from s, S : "f" (world := w, spec := "…", piece := "p", depth := d, cap := n)` runs the
route natively from `s`/`S` (a state of `w`, or of the load world: its lift) to the first call of the
function `f` (a closure name, or `#a`; at stack depth `d` if given) and cuts the stage there, as a
**site template** (one per call site and stage class):

* **isolation**: the call state with no caller frames (`StageTpl`'s call state; the caller's frames
  are the target-only stack base `r` of `StageTpl.holdsU`), every heap and native entry kept: the
  caller's own entries are entries the stage never touches, so the simulation pins them as images and
  `Conv.StageFoot`/`Conv.NFoot` state that they do not change (frozenness without a frame theorem;
  `collect` in the spec drops only garbage). Untouched pages are the caller stream's page constants
  (the boundary is written with the restored names), so the band's equality is by definition. The
  spec's `counters` may raise the native counters; its places symbolize;
* **the stage run**: from the isolated call state natively, boundaries every 10 000 steps, to the last
  local state `s1` (every state up to it satisfies `Disp.localB`) and the return step to `s2` (the
  return to the empty stack), the last chunk being that one step.

It defines `X.F`, `X.O`, `X.ks`, `X.nonce`, `X.srv`, `X.T1` (`s2`'s boundary), `X.steps`, `X.entries`,
`X.orig`, `X.frames` (the framed arrays the template holds) and `X.callSteps` (steps from `s` to the
call), and writes `seg.json` (v2) and `stage.json` (`genStage.ts`): the piece, its variables in the
stage specs' format `[[variable, quantity], …]` (a place's `qty`, the class table's `L`, `o`, `C`, …),
the oracle, the call's steps and depth, and the footprint (`footJson`: `foot`, `hfoot`, `nfoot`, the
written ranges `wrR` and the fresh range of `StageFoot`'s `wr`, `NFoot`'s `wh` and `wi`). Nothing here
is trusted: `genStage.ts` writes the kernel checks (`StageTpl`, the footprint equalities). -/

namespace Host.Ts.Sim.Template
open Lean Elab Command Meta Host.Ts _root_.Host.Load Host.Ts.Stream

/-- The stage templates' acceptance: `ok` at local states only (`StageTpl.holdsU`'s `hloc`). -/
def okLocal {S : Type} (ok : St S → SSrv → Bool) (s : St S) (Sv : SSrv) : Bool := ok s Sv && Disp.localB s

theorem okLocal_localB {S : Type} {ok : St S → SSrv → Bool} : ∀ s Sv, okLocal ok s Sv = true → Disp.localB s = true :=
  fun s Sv h => by simp only [okLocal, Bool.and_eq_true] at h; exact h.2

/-- The return state's top frame is no statement list (`StageTpl.top`). -/
def noBlockTop : List Frame → Bool
  | .s (.block _ _) :: _ => false
  | _ => true

theorem noBlockTop_sound {fs : List Frame} (h : noBlockTop fs = true) : ∀ rs env gs, fs ≠ .s (.block rs env) :: gs := by
  intro rs env gs he
  subst he
  simp [noBlockTop] at h

/-- The spec's static band (`static`): heap addresses, handles and nodes below these bounds are kept
whole, page by page, so the stage template's band pages are the caller stream's constants (equality
by definition). The spec's `counters` (`next`, `nnext`) place the template's native counters above
every caller's (`MIso`: the template's fresh handles land above the caller's). -/
structure Static where
  heap : Nat := 0
  handles : Nat := 0
  nodes : Nat := 0
  next : Nat := 0
  nnext : Nat := 0

/-! ## Collection preserving pages

`ptrieKeep t keep` is `t` without the entries `keep` rejects; every trie node none of whose
entries goes is the same object as in `t`, so the stream serializer (which names pages by pointer
identity) reuses the source's page constants for untouched pages. -/

partial def trieKeep {β : Type} (leaf : Nat → β → Option β × Bool) : Trie β → Nat → Nat → Trie β × Bool
  | .nil, _, _ => (.nil, false)
  | t@(.node v c0 c1 c2 c3), base, mul =>
    let (v', cv) := match v with
      | some x => leaf base x
      | none => (none, false)
    let (d0, e0) := trieKeep leaf c0 base (mul * 4)
    let (d1, e1) := trieKeep leaf c1 (base + mul) (mul * 4)
    let (d2, e2) := trieKeep leaf c2 (base + mul * 2) (mul * 4)
    let (d3, e3) := trieKeep leaf c3 (base + mul * 3) (mul * 4)
    if !(cv || e0 || e1 || e2 || e3) then (t, false)
    else match v', d0, d1, d2, d3 with
      | none, .nil, .nil, .nil, .nil => (.nil, true)
      | _, _, _, _, _ => (.node v' d0 d1 d2 d3, true)

def ptrieKeep {α : Type} (t : PTrie α) (keep : Nat → Bool) : PTrie α :=
  let entry (gi pi : Nat) (ei : Nat) (x : α) : Option α × Bool :=
    if keep (gi * 4096 + pi * 64 + ei) then (some x, false) else (none, true)
  let page (gi : Nat) (pi : Nat) (p : Trie α) : Option (Trie α) × Bool :=
    match trieKeep (entry gi pi) p 0 1 with
    | (.nil, ch) => (none, ch)
    | (p', ch) => (some p', ch)
  let group (gi : Nat) (g : Trie (Trie α)) : Option (Trie (Trie α)) × Bool :=
    match trieKeep (page gi) g 0 1 with
    | (.nil, ch) => (none, ch)
    | (g', ch) => (some g', ch)
  ⟨(trieKeep group t.root 0 1).1⟩

/-- Sorted addresses as ranges `[lo, hi)`. -/
def toRanges (xs : List Nat) : List (Nat × Nat) :=
  (xs.foldl (fun (acc : List (Nat × Nat)) x => match acc with
    | (lo, hi) :: r => if x == hi then (lo, hi + 1) :: r else (x, x + 1) :: (lo, hi) :: r
    | [] => [(x, x + 1)]) []).reverse

def staticOf (j : Lean.Json) : Static :=
  let num (o : Lean.Json) (k : String) : Nat := ((o.getObjVal? k).bind (·.getNat?)).toOption.getD 0
  let st : Static := match j.getObjVal? "static" with
    | .ok s => { heap := num s "heap", handles := num s "handles", nodes := num s "nodes" }
    | .error _ => {}
  match j.getObjVal? "counters" with
  | .ok c => { st with next := num c "next", nnext := num c "nnext" }
  | .error _ => st

/-- The places' quantities (`qty`, default the place's name), in table order: the stage specs'
variable map. -/
def qtysOf (j : Lean.Json) : List (Nat × String) :=
  match j.getObjVal? "places" with
  | .ok (.arr ps) => ps.toList.filterMap fun p =>
      match (p.getObjVal? "var").bind (·.getNat?) with
      | .ok v => some (v, ((p.getObjVal? "qty").bind (·.getStr?)).toOption.getD
          (((p.getObjVal? "name").bind (·.getStr?)).toOption.getD s!"v{v}"))
      | .error _ => none
  | _ => []

def specJson (arg : Option String) : IO Lean.Json := do
  match arg with
  | none => pure (Lean.Json.mkObj [])
  | some a =>
    let text ← if a.startsWith "{" then pure a else IO.FS.readFile a
    IO.ofExcept (Lean.Json.parse text)

/-- The identity walk of `l` from `roots` (and `nodes`): the reached heap addresses, handles and nodes. -/
unsafe def reach (l : St LSt) (c : SSrv) (roots : List Nat) (nodes : List Nat) (env : Environment)
    (traceSet : Std.HashSet Nat) : IO W := do
  let ctx : Ctx := { s1 := l, s2 := l, t1 := c.tab.toArray, t2 := c.tab.toArray, env, traceNodes := traceSet }
  let ((), wk) ← ((do
      for n in nodes do pairNode n n (.root "extra") ""
      walkRoots (roots.map fun a => (a, a))).run ctx).run {}
  unless wk.mism.isEmpty do throw (IO.userError s!"identity walk: {wk.mism.size} mismatches")
  pure wk

/-- The site template's call state of `s`: the caller's frames dropped (they are the target-only stack
base of `StageTpl.holdsU`), every heap and native entry kept: the caller's own entries are entries the
stage never touches, so the run pins them as images and `Conv.StageFoot`/`NFoot` say they do not change
(with `collect` in the spec: `true`, only what the whole call state reaches; `"callee"`, only what the callee
reaches and the static band: a **class template**, the start of `Conv.site_class`'s link into a site; untouched
pages kept as they are in both);
the native counters raised to the spec's `counters`; symbolized at the spec's places. Also the framed
arrays it holds and a summary. -/
unsafe def isolate {F : Ffi} (w : TWorld F) (s : St F.S) (c : SSrv) (sp : TSpec) (st : Static) (collect : String) :
    TermElabM (St F.S × SSrv × Array Entry × List Nat × String) := do
  let env ← getEnv
  let l := w.proj s
  let m := l.aux.ffi.mlx
  let traceSet := traceNodesOf m
  let natRefs := nativeHeapRefs m
  let intr := (List.range 40).filter fun a => (l.heap.get a).isSome
  -- what the callee reaches from the isolated roots (the stage's footprint at the call; a summary only)
  let wkI ← reach { l with stack := [] } c (intr ++ natRefs) (w.extraNodes s.aux.ffi) env traceSet
  let (sg, s') ← if collect == "all" || collect == "callee" then do
      -- `all`: what the whole call state reaches; `callee`: what the callee reaches (a class template)
      let wkA ← if collect == "callee" then pure wkI else reach l c (intr ++ natRefs) (w.extraNodes s.aux.ffi) env traceSet
      let keepA (a : Nat) := wkA.sig.contains a || a < st.heap
      let keepH (h : Nat) := wkA.hnd.contains h || h < st.handles
      let keepN (n : Nat) := wkA.nod.contains n || n < st.nodes
      let sg : St LSt := { l with heap := ptrieKeep l.heap keepA }
      let mx := { m with nodes := ptrieKeep m.nodes keepN, items := ptrieKeep m.items keepN,
                         arrs := ptrieKeep m.arrs keepH, objs := ptrieKeep m.objs keepH }
      pure (sg.setFfi { sg.aux.ffi with mlx := mx }, s.setFfi (w.restrict s.aux.ffi keepH keepN))
    else pure (l, s)
  let mg := sg.aux.ffi.mlx
  let sg : St LSt := { sg with stack := [] }
  let sg := sg.setFfi { sg.aux.ffi with mlx := { mg with next := max mg.next st.next, nnext := max mg.nnext st.nnext } }
  let (T0, c0, ents) ← match symbolizeSpec sp.places sg c with
    | .ok r => pure r
    | .error e => throwError "tpl_stage: {e}"
  let frames := sp.framesD.filter fun a => (T0.heap.get a).isSome
  let heapN := ptrieFold (fun (k : Nat) _ _ => k + 1) T0.heap 0
  let stats := s!"{if collect == "callee" then "class" else "site"} template heap {heapN} (callee reaches {wkI.sig.size}), handles {wkI.hnd.size}, nodes {wkI.nod.size}{if collect == "all" then "; collected" else ""}"
  return (w.unproj s' T0, c0, ents, frames, stats)

/-- The boundaries' writer state of a stream. -/
structure Out where
  g : G
  bytes : Nat := 0
  o : Array Ans := #[]
  ks : Array Nat := #[]
  steps : Nat := 0

/-- Run the isolated stage from `s0` natively to its return (the last local state, then the return
step), writing boundaries every 10 000 steps (the return step a chunk of its own). -/
unsafe def runLocal {F : Ffi} (w : TWorld F) (pre : Lean.Name) (nonce : String) (dir : System.FilePath)
    (ρ : Nat → F64) (s0 : St F.S) (tab : List SymE) (out : Out) (cap : Nat) : TermElabM (St F.S × SSrv × Out) := do
  let oE := mkConst (pre ++ `O)
  let drop (m : Nat) := mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit m) oE
  let mut out := out
  let mut st := s0
  let mut c : SSrv := ⟨tab, []⟩
  let mut done := false
  while !done do
    let mut n : Nat := 0
    let mut last : Option (St F.S × SSrv × List Ans) := none
    while n < 10000 do
      if isHalt st.ctl then throwError "tpl_stage {pre}: halted inside the stage"
      match interpRec ρ (step F st).run c [] with
      | some (s', c', a) =>
        if !Disp.localB s' then last := some (s', c', a); break
        st := s'; c := c'; out := { out with o := out.o ++ a.reverse.toArray, steps := out.steps + 1 }; n := n + 1
      | none => throwError "tpl_stage {pre}: stuck after {out.steps} steps"
    if n > 0 then
      out := { out with ks := out.ks.push n }
      let (g', b) ← writeBoundaryW w pre nonce dir out.g out.ks.size st c.tab (drop out.o.size) none
      out := { out with g := g', bytes := out.bytes + b }
    if let some (s', c', a) := last then
      st := s'; c := c'
      out := { out with o := out.o ++ a.reverse.toArray, steps := out.steps + 1, ks := out.ks.push 1 }
      let (g', b) ← writeBoundaryW w pre nonce dir out.g out.ks.size st c.tab (drop out.o.size) none
      out := { out with g := g', bytes := out.bytes + b }
      done := true
    if out.steps > cap then throwError "tpl_stage {pre}: no return within {cap} steps"
  return (st, c, out)

private def addDefT (name : Lean.Name) (type value : Lean.Expr) (compile : Bool := false) : TermElabM Unit := do
  let d := Declaration.defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }
  addDecl d
  if compile then compileDecl d

/-- The stream constants every template stream defines. -/
def defineStream (pre : Lean.Name) (ffiC : Lean.Name) (o : Array Ans) (tab : List SymE) (ks : Array Nat) (nonce : String)
    (steps : Nat) : TermElabM Unit := do
  let oE := mkConst (pre ++ `O)
  addDefT (pre ++ `O) (mkApp (mkConst ``List [.zero]) (mkConst ``Ans)) (toExpr o.toList)
  addDefT (pre ++ `F) (mkConst ``Ffi) (mkConst ffiC)
  addDefT (pre ++ `ks) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (toExpr ks.toList) (compile := true)
  addDefT (pre ++ `nonce) (mkConst ``String) (toExpr nonce) (compile := true)
  addDefT (pre ++ `srv) (mkConst ``SSrv) (mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oE)
  addDefT (pre ++ `T1) (mkConst ``Nat) (mkRawNatLit ks.size) (compile := true)
  addDefT (pre ++ `steps) (mkConst ``Nat) (mkRawNatLit steps)

def defineEntries (pre : Lean.Name) (ents : Array Entry) (frames : List Nat) : TermElabM Unit := do
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
  addDefT (pre ++ `entries) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr (ents.toList.map fun e => (e.ref, e.var)))
  let origTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``NumV)
  addDefT (pre ++ `orig) (mkApp (mkConst ``List [.zero]) origTy) (toExpr (ents.toList.map fun e => (e.ref, e.orig)))
  let natsTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  addDefT (pre ++ `frames) natsTy (toExpr frames) (compile := true)

/-- `stage.json`: the piece instance for the module generators and the class table's checks. -/
def stageJson (pre : Lean.Name) (fn piece : String) (w : String) (t1 steps : Nat) (vars : List (Nat × String))
    (frames : List Nat) (ents : Array Entry) (tab : Array SymE) (more : List (String × Lean.Json) := []) : Lean.Json :=
  Lean.Json.mkObj ([("instance", Lean.toJson pre.toString), ("piece", Lean.toJson piece), ("fn", Lean.toJson fn),
    ("world", Lean.toJson w), ("T1", Lean.toJson t1), ("steps", Lean.toJson steps),
    ("vars", Lean.Json.arr (vars.toArray.map fun (v, q) => Lean.Json.arr #[Lean.toJson v, Lean.toJson q])),
    ("oracle", Lean.toJson s!"{pre}.O"), ("frames", Lean.toJson frames),
    ("entries", Lean.Json.arr (ents.map fun e => Lean.Json.mkObj [("name", Lean.toJson e.name), ("ref", Lean.toJson e.ref),
      ("var", Lean.toJson e.var), ("orig", Lean.toJson (fmtNum tab e.orig))]))] ++ more)

/-- The keys of a paged store. -/
def keysOf {α : Type} (t : PTrie α) : List Nat := (ptrieFold (fun (acc : Array Nat) k _ => acc.push k) t #[]).toList.mergeSort (· ≤ ·)

/-- Every key of a trie (`base`, `mul` as in `trieFold`), through `f`. -/
partial def trieEach {β : Type} (f : Nat → β → Array Nat → Array Nat) : Trie β → Nat → Nat → Array Nat → Array Nat
  | .nil, _, _, acc => acc
  | .node v c0 c1 c2 c3, base, mul, acc =>
    let acc := match v with | some x => f base x acc | none => acc
    let acc := trieEach f c0 base (mul * 4) acc
    let acc := trieEach f c1 (base + mul) (mul * 4) acc
    let acc := trieEach f c2 (base + mul * 2) (mul * 4) acc
    trieEach f c3 (base + mul * 3) (mul * 4) acc

/-- The keys where two tries differ, skipping the subtries they share (the same object): `both` at a key
present on both sides, `one` at a key present on one side. -/
unsafe def trieDiff {β : Type} (both : Nat → β → β → Array Nat → Array Nat) (one : Nat → β → Array Nat → Array Nat) :
    Trie β → Trie β → Nat → Nat → Array Nat → Array Nat
  | a, b, base, mul, acc =>
    if ptrEq a b then acc else
    match a, b with
    | .node va a0 a1 a2 a3, .node vb b0 b1 b2 b3 =>
      let acc := match va, vb with
        | some x, some y => both base x y acc
        | none, some y => one base y acc
        | some x, none => one base x acc
        | none, none => acc
      let acc := trieDiff both one a0 b0 base (mul * 4) acc
      let acc := trieDiff both one a1 b1 (base + mul) (mul * 4) acc
      let acc := trieDiff both one a2 b2 (base + mul * 2) (mul * 4) acc
      trieDiff both one a3 b3 (base + mul * 3) (mul * 4) acc
    | .nil, t => trieEach one t base mul acc
    | t, .nil => trieEach one t base mul acc

/-- The keys of `t2` whose entry is not the same object as `t0`'s (below `lim`), in order; shared pages and
groups are skipped, so the cost is the changed pages'. -/
unsafe def changedKeys {α : Type} (t0 t2 : PTrie α) (lim : Nat) : List Nat :=
  let entry (off : Nat) : Trie α → Trie α → Nat → Nat → Array Nat → Array Nat :=
    fun p q b m acc => trieDiff (fun k x y acc => if ptrEq x y then acc else acc.push (off + k)) (fun k _ acc => acc.push (off + k)) p q b m acc
  let pageAll (off : Nat) : Trie α → Array Nat → Array Nat := fun p acc => trieEach (fun k _ acc => acc.push (off + k)) p 0 1 acc
  let page (gi : Nat) : Nat → Trie α → Trie α → Array Nat → Array Nat :=
    fun pi p q acc => entry (gi * 4096 + pi * 64) p q 0 1 acc
  let group : Nat → Trie (Trie α) → Trie (Trie α) → Array Nat → Array Nat := fun gi g h acc =>
    trieDiff (page gi) (fun pi p acc => pageAll (gi * 4096 + pi * 64) p acc) g h 0 1 acc
  let groupAll : Nat → Trie (Trie α) → Array Nat → Array Nat := fun gi g acc =>
    trieEach (fun pi p acc => pageAll (gi * 4096 + pi * 64) p acc) g 0 1 acc
  let ks := trieDiff group groupAll t0.root t2.root 0 1 #[]
  -- only keys present in t2 (a key present only in t0 is a removal, not a write)
  (ks.toList.filter fun k => decide (k < lim) && (t2.get k).isSome).mergeSort (· ≤ ·) |>.eraseDups

/-- A stage template's footprint (`host.sim.conv`): the start's present non-band heap addresses
(`foot`), handles (`hfoot`) and nodes (`nfoot`); the run's written heap ranges below the start's
counter (`wrR`; with the fresh range `[s0.next, s2.next)` the `wr` of `Conv.StageFoot`), written and
fresh handles (`wh`) and written readback items of old nodes (`wi`) (`Conv.NFoot`). -/
unsafe def footJson (l0 l2 : St LSt) (st : Static) : List (String × Lean.Json) :=
  let x0 := l0.aux.ffi.mlx; let x2 := l2.aux.ffi.mlx
  let heapN := ptrieFold (fun (n : Nat) _ _ => n + 1) l0.heap 0
  let footJ := if heapN ≤ 100000 then Lean.toJson ((keysOf l0.heap).filter (· ≥ st.heap)) else Lean.Json.mkObj [("count", Lean.toJson heapN)]
  let wr := changedKeys l0.heap l2.heap l0.next
  let hs0 := ((keysOf x0.arrs) ++ (keysOf x0.objs)).eraseDups.mergeSort (· ≤ ·)
  let wh := ((changedKeys x0.arrs x2.arrs (2 ^ 64)) ++ (changedKeys x0.objs x2.objs (2 ^ 64))).eraseDups.mergeSort (· ≤ ·)
  let wi := changedKeys x0.items x2.items x0.nnext
  let rj (rs : List (Nat × Nat)) := Lean.Json.arr (rs.toArray.map fun (a, b) => Lean.Json.arr #[Lean.toJson a, Lean.toJson b])
  let big (l : List Nat) : Lean.Json := if l.length ≤ 100000 then Lean.toJson l else Lean.Json.mkObj [("count", Lean.toJson l.length)]
  [("static", Lean.Json.mkObj [("heap", Lean.toJson st.heap), ("handles", Lean.toJson st.handles), ("nodes", Lean.toJson st.nodes)]),
   ("counters", Lean.Json.mkObj [("next", Lean.toJson x0.next), ("nnext", Lean.toJson x0.nnext)]),
   -- the start's footprint lists (a class template's; a site template's are its whole state: their sizes only)
   ("foot", footJ), ("wrR", rj (toRanges wr)), ("fresh", Lean.toJson [l0.next, l2.next]),
   ("hfoot", big (hs0.filter (· ≥ st.handles))), ("nfoot", big ((keysOf x0.nodes).filter (· ≥ st.nodes))),
   ("wh", Lean.toJson wh), ("wi", Lean.toJson wi), ("nodesFresh", Lean.toJson [x0.nnext, x2.nnext])]

/-- Run from `s` to the first call of `fn` (at depth `d`), natively. -/
unsafe def toCall {F : Ffi} (s : St F.S) (c : SSrv) (ρ : Nat → F64) (fn : String) (d : Option Nat) (cap : Nat) :
    TermElabM (St F.S × SSrv × Nat) := do
  let mut st := s
  let mut c := c
  let mut n := 0
  while !isCallOf st fn d do
    if isHalt st.ctl then throwError "tpl_stage: halted before a call of {fn}"
    if n > cap then throwError "tpl_stage: no call of {fn} within {cap} steps"
    match interpRec ρ (step F st).run c [] with
    | some (s', c', _) => st := s'; c := c'; n := n + 1
    | none => throwError "tpl_stage: stuck after {n} steps before a call of {fn}"
  return (st, c, n)

/-- `tpl_stage`'s work: see the module doc. -/
unsafe def stageCmdW {F : Ffi} (w : TWorld F) (pre srcName srvName : Lean.Name) (fn piece : String)
    (specPath : Option String) (depth : Option Nat) (capO : Option Nat) : TermElabM Unit := do
  astTabRef.set (← loadAstTab)
  Memo.reset
  let cap := capO.getD 8000000
  let spec := (← specOfPath specPath).getD {}
  let sj ← specJson specPath
  let t0 ← IO.monoMsNow
  let fromLoad ← isDefEq (← inferType (mkConst srcName)) (mkApp (mkConst ``St) (mkConst ``LSt))
  let (s, c, gS) ← if fromLoad then do
      let (l, c, g) ← restoreAny (S := LSt) (mkConst srcName) (mkConst srvName) pre
      pure (w.lift l, c, g)
    else restoreAny (S := F.S) (mkConst srcName) (mkConst srvName) pre
  let ρ := spec.valuation ⟨"", [], false, false⟩
  let (sC, cC, n0) ← toCall s ⟨c.tab, []⟩ ρ fn depth cap
  let t1 ← IO.monoMsNow
  let stat := staticOf sj
  -- `collect`: none (a site template, default), `true`/`"all"` (garbage dropped), `"callee"` (a class template)
  let collect := match sj.getObjVal? "collect" with
    | .ok (.bool true) => "all"
    | .ok (.str c) => c
    | _ => "none"
  let (s0, c0, ents, frames, stats) ← isolate w sC cC spec stat collect
  let t2 ← IO.monoMsNow
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let oE := mkConst (pre ++ `O)
  -- the caller's page names (`g` from the restore) for the template's untouched pages: the band
  let (g, b0) ← writeBoundaryW w pre nonce dir { gS with pre } 0 s0 c0.tab (mkApp3 (mkConst ``List.drop [.zero]) (mkConst ``Ans) (mkRawNatLit 0) oE) none
  let (s2, _, out) ← runLocal w pre nonce dir ρ s0 c0.tab { g, bytes := b0 } cap
  let t3 ← IO.monoMsNow
  defineStream pre w.ffiC out.o c0.tab out.ks nonce out.steps
  defineEntries pre ents frames
  addDefT (pre ++ `callSteps) (mkConst ``Nat) (mkRawNatLit n0)
  writeSeg dir pre (segJson piece "return" out.ks.size out.steps frames [] (segMore w (w.proj s0) (w.proj s2) false))
  IO.FS.writeFile (dir / pre.toString / "stage.json")
    ((stageJson pre fn piece w.name out.ks.size out.steps (qtysOf sj) frames ents c0.tab.toArray
      ([("callSteps", Lean.toJson n0), ("callDepth", Lean.toJson sC.stack.length), ("tab0", Lean.toJson c0.tab.length)] ++
        footJson (w.proj s0) (w.proj s2) stat)).pretty ++ "\n")
  logInfo m!"tpl_stage {pre} ({fn}): restore {t1 - t0 - 0} ms incl. {n0} steps to the call (depth {sC.stack.length}), isolate {t2 - t1} ms ({stats}); stage {out.steps} steps in {t3 - t2} ms, {out.ks.size} chunks (T1 = {pre}.s{out.ks.size}), oracle {out.o.size} answers, {out.bytes} bytes"

/-- `tpl_stage X from s, S : "f" [(piece := "…", world := w, spec := "…", depth := d, cap := n)]`. -/
elab "tpl_stage " p:ident " from " src:ident ", " srv:ident " : " fn:str os:(tplOpts)? : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let os : TplOpts := tplOptsOf (os.map (·.raw))
    os.check [`world, `spec, `depth, `cap, `piece]
    let pre := (← getCurrNamespace) ++ p.getId
    let srcN ← resolveGlobalConstNoOverload src
    let srvN ← resolveGlobalConstNoOverload srv
    let piece := (os.str `piece).getD fn.getString
    match os.ident `world with
    | none | some `lf => unsafe stageCmdW lfWorld pre srcN srvN fn.getString piece (os.str `spec) (os.num `depth) (os.num `cap)
    | some n =>
      let args := #[toExpr pre, toExpr srcN, toExpr srvN, toExpr fn.getString, toExpr piece, toExpr (os.str `spec),
        toExpr (os.num `depth), toExpr (os.num `cap)]
      unsafe inWorld ``stageCmdW (← worldConst n) args

end Host.Ts.Sim.Template
