import host.ts.Chunk
import host.load.Expr
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

/-! # Lockstep walk of two machine states

Walks a source state `s1` and a target state `s2` from their roots, building
correspondences on heap addresses, mlx handles and graph nodes (BFS), and
recording, for every number position, the source `NumV` and the target `NumV`.
Used for reachability (`s1 = s2`) and for restart maps (`s1 = T0`, `s2 = T1`).

Native nodes: eager nodes are compared by shape and dtype only (their primitives and
inputs are never read by the FFI model; only nodes of compiled-closure traces are
replayed), trace nodes in full.

A template spec's ghosts (`Ctx.ghosts`: addresses whose content depends on the history)
are paired but not compared (`W.ghostSeen`), and its by-key maps (`Ctx.byKey`) are
compared entry by string key, keys on one side only being ghost entries
(`W.ghostEntries`). Both are empty unless a command passes them. -/

namespace Host.Ts.Sim.Template
open Lean Meta Host.Ts Host.Load

/-! ## Native folds and formatting -/

def trieFold {α β : Type} (f : β → Nat → α → β) : Trie α → Nat → Nat → β → β
  | .nil, _, _, b => b
  | .node v c0 c1 c2 c3, base, mul, b =>
    let b := match v with | some x => f b base x | none => b
    let b := trieFold f c0 (base + mul * 0) (mul * 4) b
    let b := trieFold f c1 (base + mul * 1) (mul * 4) b
    let b := trieFold f c2 (base + mul * 2) (mul * 4) b
    trieFold f c3 (base + mul * 3) (mul * 4) b

/-- Fold over the entries of a paged store with their addresses. -/
def ptrieFold {α β : Type} (f : β → Nat → α → β) (t : PTrie α) (b : β) : β :=
  trieFold (fun b gi g => trieFold (fun b pi p => trieFold (fun b ei x => f b (gi * 4096 + pi * 64 + ei) x) p 0 1 b) g 0 1 b) t.root 0 1 b

def fmtF64 : F64 → String
  | .nan => "NaN"
  | .inf n => if n then "-Inf" else "Inf"
  | .zero n => if n then "-0" else "0"
  | .fin n m e =>
    let sg := if n then "-" else ""
    if e ≥ 0 then s!"{sg}{m * 2 ^ e.toNat}" else s!"{sg}{m}*2^{e}"

def opName {α : Type} [Repr α] (x : α) : String :=
  match (toString (repr x)).splitOn "." with
  | [] => ""
  | l => l.getLast!

partial def fmtSym : SymE → String
  | .lit x => fmtF64 x
  | .var i => s!"v{i}"
  | .bin op a b => s!"({fmtSym a} {opName op} {fmtSym b})"
  | .un op a => s!"{opName op}({fmtSym a})"

def fmtNum (tab : Array SymE) : NumV → String
  | .lit x => fmtF64 x
  | .ref i => s!"ref{i}=" ++ (match tab[i]? with | some e => fmtSym e | none => "?")

def strOf (cs : List Char) : String := String.ofList cs

def fmtKey : PKey → String
  | .str s => strOf s
  | .sym i => s!"@@sym{i}"

inductive Loc where
  | root (n : String)
  | heap (a : Nat)
  | hnd (h : Nat)
  | node (n : Nat)
deriving Inhabited

def Loc.str : Loc → String
  | .root n => n
  | .heap a => s!"h{a}"
  | .hnd h => s!"H{h}"
  | .node n => s!"N{n}"

inductive Mode where
  | plain | heap | node | handle | region
deriving BEq, Inhabited

structure Ctx where
  s1 : St LSt
  s2 : St LSt
  t1 : Array SymE
  t2 : Array SymE
  env : Environment
  /-- Source arrays compared on their source-length prefix (the target may append). -/
  framed : List Nat := []
  /-- Source nodes compared in full (nodes of compiled-closure traces). -/
  traceNodes : Std.HashSet Nat := {}
  /-- Compare every node in full, following inputs. -/
  followIns : Bool := false
  /-- Also walk eager nodes' primitives, not their inputs (a compaction: the numbers a kept node's primitive mentions
  are results, as its closedness needs). -/
  primNums : Bool := false
  /-- Ghost addresses: paired, their content not compared. -/
  ghosts : Std.HashSet Nat := {}
  /-- JavaScript maps compared by key. -/
  byKey : List Nat := []
  /-- Heap addresses, handles and nodes below these are paired but not walked (a walk of a footprint). -/
  heapFrom : Nat := 0
  handlesFrom : Nat := 0
  nodesFrom : Nat := 0

structure W where
  sig : Std.HashMap Nat Nat := {}
  sigInv : Std.HashMap Nat Nat := {}
  par : Std.HashMap Nat (Loc × String) := {}
  hnd : Std.HashMap Nat Nat := {}
  hndInv : Std.HashMap Nat Nat := {}
  hpar : Std.HashMap Nat (Loc × String) := {}
  nod : Std.HashMap Nat Nat := {}
  nodInv : Std.HashMap Nat Nat := {}
  npar : Std.HashMap Nat (Loc × String) := {}
  hostO : Std.HashMap Nat Nat := {}
  work : Array (Nat × Nat × Nat) := #[]
  head : Nat := 0
  mism : Array (Loc × String × String) := #[]
  /-- Source ref ↦ target number, with the place. -/
  pairs : Array (Nat × NumV × Loc × String) := #[]
  /-- A source literal whose target differs. -/
  litDiff : Array (Loc × String × String × String) := #[]
  bigs : Array (Loc × String × Int × Int) := #[]
  nats : Array (Loc × String × Nat × Nat) := #[]
  suffix : Array (Loc × Nat × Nat × List Val) := #[]
  itemsNew : Array (Loc × NumV) := #[]
  /-- Ghost addresses reached. -/
  ghostSeen : Array Nat := #[]
  /-- By-key map entries on one side only (map, key). -/
  ghostEntries : Array (Nat × String) := #[]

abbrev WM := ReaderT Ctx (StateRefT W IO)

def mism (loc : Loc) (lab msg : String) : WM Unit := modify fun w => { w with mism := w.mism.push (loc, lab, msg) }

/-! ## Correspondences (state updated in place: `modifyGet`) -/

def pairHeap (a b : Nat) (loc : Loc) (lab : String) : WM Unit := do
  let walk := a ≥ (← read).heapFrom
  let r ← modifyGet fun w =>
    match w.sig[a]? with
    | some b' => (if b' == b then none else some s!"sigma inconsistent: h{a} -> h{b'} and h{b}", w)
    | none => match w.sigInv[b]? with
      | some a' => (some s!"sigma not injective: h{a'} and h{a} -> h{b}", w)
      | none => (none, { w with sig := w.sig.insert a b, sigInv := w.sigInv.insert b a, par := w.par.insert a (loc, lab), work := if walk then w.work.push (0, a, b) else w.work })
  if let some m := r then mism loc lab m

def pairHandle (a b : Nat) (loc : Loc) (lab : String) : WM Unit := do
  if a == 0 && b == 0 then return
  if a == 0 || b == 0 then mism loc lab s!"handle null vs nonnull: {a} {b}"; return
  let walk := a ≥ (← read).handlesFrom
  let r ← modifyGet fun w =>
    match w.hnd[a]? with
    | some b' => (if b' == b then none else some s!"handle map inconsistent: H{a} -> H{b'} and H{b}", w)
    | none => match w.hndInv[b]? with
      | some a' => (some s!"handle map not injective: H{a'} and H{a} -> H{b}", w)
      | none => (none, { w with hnd := w.hnd.insert a b, hndInv := w.hndInv.insert b a, hpar := w.hpar.insert a (loc, lab), work := if walk then w.work.push (1, a, b) else w.work })
  if let some m := r then mism loc lab m

def pairNode (a b : Nat) (loc : Loc) (lab : String) : WM Unit := do
  if a == 0 && b == 0 then return
  if a == 0 || b == 0 then mism loc lab s!"node null vs nonnull: {a} {b}"; return
  let walk := a ≥ (← read).nodesFrom
  let r ← modifyGet fun w =>
    match w.nod[a]? with
    | some b' => (if b' == b then none else some s!"node map inconsistent: N{a} -> N{b'} and N{b}", w)
    | none => match w.nodInv[b]? with
      | some a' => (some s!"node map not injective: N{a'} and N{a} -> N{b}", w)
      | none => (none, { w with nod := w.nod.insert a b, nodInv := w.nodInv.insert b a, npar := w.npar.insert a (loc, lab), work := if walk then w.work.push (2, a, b) else w.work })
  if let some m := r then mism loc lab m

def pairRegion (r q : Nat) (loc : Loc) (lab : String) : WM Unit := do
  if r ≥ 2 ^ 48 then
    if q ≥ 2 ^ 48 then pairHeap (r - 2 ^ 48) (q - 2 ^ 48) loc (lab ++ "~cb") else mism loc lab s!"region class {r} {q}"
  else if r % 4 != q % 4 then mism loc lab s!"region class {r} {q}"
  else if r % 4 == 3 then
    let e ← modifyGet fun w => match w.hostO[r / 4]? with
      | some q' => (if q' == q / 4 then none else some s!"host object map inconsistent {r} {q}", w)
      | none => (none, { w with hostO := w.hostO.insert (r / 4) (q / 4) })
    if let some m := e then mism loc lab m
  else pairHandle (r / 4) (q / 4) loc (lab ++ s!"~r{r % 4}")

def isHandle (s : St LSt) (i : Int) : Bool :=
  i > 0 && i < s.aux.ffi.mlx.next && ((s.aux.ffi.mlx.arrs.get i.toNat).isSome || (s.aux.ffi.mlx.objs.get i.toNat).isSome)

def natCmp (a b : Nat) (loc : Loc) (lab : String) : WM Unit := do
  unless a == b do modify fun w => { w with nats := w.nats.push (loc, lab, a, b) }

def bigCmp (i j : Int) (loc : Loc) (lab : String) : WM Unit := do
  let c ← read
  if i ≥ 2 ^ 62 then
    if j ≥ 2 ^ 62 then
      let a := (i - 2 ^ 62).toNat; let b := (j - 2 ^ 62).toNat
      natCmp (a % 2 ^ 24) (b % 2 ^ 24) loc (lab ++ "~extoff")
      pairRegion (a / 2 ^ 24) (b / 2 ^ 24) loc (lab ++ "~extptr")
    else mism loc lab s!"bigint class (ext ptr vs other) {i} {j}"
  else if i ≥ 2 ^ 56 then
    if j ≥ 2 ^ 56 && j < 2 ^ 62 then
      let a := (i - 2 ^ 56).toNat; let b := (j - 2 ^ 56).toNat
      natCmp (a % 2 ^ 32) (b % 2 ^ 32) loc (lab ++ "~jsoff")
      pairHeap (a / 2 ^ 32) (b / 2 ^ 32) loc (lab ++ "~jsptr")
    else mism loc lab s!"bigint class (js ptr vs other) {i} {j}"
  else if isHandle c.s1 i then
    if isHandle c.s2 j then pairHandle i.toNat j.toNat loc lab
    else mism loc lab s!"bigint: handle {i} vs non-handle {j}"
  else unless i == j do modify fun w => { w with bigs := w.bigs.push (loc, lab, i, j) }

/-- Source refs are recorded with their target; source literals must stay the same value. -/
def numCmp (x y : NumV) (loc : Loc) (lab : String) : WM Unit := do
  let c ← read
  match x with
  | .ref r => modify fun w => { w with pairs := w.pairs.push (r, y, loc, lab) }
  | .lit a =>
    let same := match y with
      | .lit b => decide (a = b)
      | .ref j => decide (c.t2[j]? = some (SymE.lit a))
    unless same do modify fun w => { w with litDiff := w.litDiff.push (loc, lab, fmtF64 a, fmtNum c.t2 y) }

def dimCmp (d e : Host.Mlx.Ffi.Dim) (loc : Loc) (lab : String) : WM Unit :=
  match d, e with
  | .lit i, .lit j => unless i == j do
      modify fun w => { w with litDiff := w.litDiff.push (loc, lab, toString i, toString j) }
  | _, _ => numCmp d.num e.num loc lab

def symCmp (i j : Nat) (loc : Loc) (lab : String) : WM Unit :=
  if i ≥ 16 && j ≥ 16 then pairHeap (i - 16) (j - 16) loc (lab ++ "~sym") else natCmp i j loc (lab ++ "~sym")

/-! ## Generic walk over `ToExpr` images -/

partial def charsOfE (e : Lean.Expr) : String :=
  let rec go (e : Lean.Expr) (acc : String) : String :=
    if e.isAppOfArity ``List.cons 3 then
      let c := e.getArg! 1
      let ch := if c.isAppOfArity ``Char.ofNat 1 then (match (c.getArg! 0) with | .lit (.natVal n) => Char.ofNat n | _ => '?') else '?'
      go (e.getArg! 2) (acc.push ch)
    else acc
  go e ""

partial def natOfE : Lean.Expr → Option Nat
  | .lit (.natVal n) => some n
  | e => if e.isAppOfArity ``OfNat.ofNat 3 then natOfE (e.getArg! 1) else none

def intOfE (e : Lean.Expr) : Option Int :=
  if e.isAppOfArity ``Int.ofNat 1 then (natOfE (e.getArg! 0)).map Int.ofNat
  else if e.isAppOfArity ``Int.negSucc 1 then (natOfE (e.getArg! 0)).map Int.negSucc
  else (natOfE e).map Int.ofNat

def boolOfE (e : Lean.Expr) : Option Bool :=
  if e.isConstOf ``Bool.true then some true else if e.isConstOf ``Bool.false then some false else none

def f64OfE (e : Lean.Expr) : Option F64 :=
  if e.isConstOf ``F64.nan then some .nan
  else if e.isAppOfArity ``F64.inf 1 then (boolOfE (e.getArg! 0)).map .inf
  else if e.isAppOfArity ``F64.zero 1 then (boolOfE (e.getArg! 0)).map .zero
  else if e.isAppOfArity ``F64.fin 3 then do
    let b ← boolOfE (e.getArg! 0); let m ← natOfE (e.getArg! 1); let x ← intOfE (e.getArg! 2)
    some (.fin b m x)
  else none

def numVOfE (e : Lean.Expr) : Option NumV :=
  if e.isAppOfArity ``NumV.lit 1 then (f64OfE (e.getArg! 0)).map .lit
  else if e.isAppOfArity ``NumV.ref 1 then (natOfE (e.getArg! 0)).map .ref
  else none

def dimOfE (e : Lean.Expr) : Option Host.Mlx.Ffi.Dim :=
  if e.isAppOfArity ``Host.Mlx.Ffi.Dim.lit 1 then (intOfE (e.getArg! 0)).map .lit
  else if e.isAppOfArity ``Host.Mlx.Ffi.Dim.sym 1 then (numVOfE (e.getArg! 0)).map .sym
  else none

def fieldMode (n : Lean.Name) (i : Nat) (m : Mode) : Mode :=
  if n == ``List.cons || n == ``Option.some then m
  else if n == ``Val.obj || n == ``Mem.js || n == ``Arg.jsPtr then (if i == 0 then .heap else .plain)
  else if n == ``LitF.object || n == ``LitF.objKey || n == ``LitF.objVal || n == ``LitF.objSpread then (if i == 0 then .heap else .plain)
  else if n == ``FnF.classMembers || n == ``FnF.classKey || n == ``FnF.classStatic || n == ``FnF.superRet then (if i ≤ 1 then .heap else .plain)
  else if n == ``FnF.fields || n == ``FnF.fieldVal || n == ``FnF.promiseThen then (if i == 0 then .heap else .plain)
  -- private brands are the addresses of their brand cells
  else if n == ``FnF.privVal then (if i ≤ 1 then .heap else .plain)
  else if n == ``CallF.priv || n == ``ExprF.priv || n == ``InstMember.privField || n == ``InstMember.privMethod then (if i == 0 then .heap else .plain)
  else if n == ``AsgF.privObj || n == ``Target.priv then (if i == 1 then .heap else .plain)
  else if n == ``AsgF.updPrivObj then (if i == 2 then .heap else .plain)
  else if n == ``Boundary.derived || n == ``Boundary.async || n == ``Boundary.gen then .heap
  else if n == ``Reaction.adopt || n == ``Reaction.forward then .heap
  else if n == ``Reaction.then_ then (if i == 2 then .heap else .plain)
  else if n == ``Mem.ext || n == ``Arg.extPtr then (if i == 0 then .region else .plain)
  else if n == ``Host.Mlx.Ffi.Clo.fn || n == ``Host.Mlx.Ffi.Clo.compiled then (if i == 0 then .region else .plain)
  else if n == ``Host.Mlx.Ffi.Pending.mk then
    (if i == 0 || i == 3 || i == 4 then .handle else if i == 1 then .heap else if i ≥ 5 then .node else .plain)
  else if n == ``Host.Mlx.Ffi.Prim.kernel || n == ``Host.Mlx.Ffi.Prim.replayed then (if i == 0 then .handle else .plain)
  else if n == ``Host.Mlx.Ffi.Node.mk then (if i == 1 then .node else .plain)
  else if n == ``Host.Mlx.Ffi.Obj.vec || n == ``Host.Mlx.Ffi.Trace.mk then .node
  else .plain

def natPair (m : Mode) (a b : Nat) (loc : Loc) (lab : String) : WM Unit :=
  match m with
  | .plain => natCmp a b loc lab
  | .heap => pairHeap a b loc lab
  | .node => pairNode a b loc lab
  | .handle => pairHandle a b loc lab
  | .region => pairRegion a b loc lab

def numParamsOf (env : Environment) (n : Lean.Name) : Nat :=
  match env.find? n with
  | some (.ctorInfo i) => i.numParams
  | _ => 0

partial def gw (m : Mode) (e1 e2 : Lean.Expr) (loc : Loc) (lab : String) : WM Unit := do
  let c ← read
  match e1, e2 with
  | .lit (.natVal a), .lit (.natVal b) => natPair m a b loc lab
  | .lit (.strVal a), .lit (.strVal b) => unless a == b do mism loc lab s!"string literal {a} {b}"
  | .const n1 _, .const n2 _ => unless n1 == n2 do mism loc lab s!"const {n1} vs {n2}"
  | _, _ =>
    match e1.getAppFn, e2.getAppFn with
    | .const n1 _, .const n2 _ =>
      if n1 == ``NumV.lit || n1 == ``NumV.ref || n2 == ``NumV.lit || n2 == ``NumV.ref then
        match numVOfE e1, numVOfE e2 with
        | some x, some y => numCmp x y loc lab
        | _, _ => mism loc lab s!"NumV shape {n1} {n2}"
        return
      if n1 == ``Host.Mlx.Ffi.Dim.lit || n1 == ``Host.Mlx.Ffi.Dim.sym then
        match dimOfE e1, dimOfE e2 with
        | some d, some e => dimCmp d e loc lab
        | _, _ => mism loc lab "Dim shape"
        return
      if n1 != n2 then mism loc lab s!"ctor {n1} vs {n2}"; return
      let a1 := e1.getAppArgs
      let a2 := e2.getAppArgs
      if a1.size != a2.size then mism loc lab s!"arity {n1}"; return
      if n1 == ``Val.sym || n1 == ``PKey.sym then
        match natOfE a1[0]!, natOfE a2[0]! with
        | some i, some j => symCmp i j loc lab
        | _, _ => mism loc lab "symbol expr"
        return
      if n1 == ``Val.big || n1 == ``Cell.big || n1 == ``Arg.big then
        match intOfE a1[0]!, intOfE a2[0]! with
        | some i, some j => bigCmp i j loc lab
        | _, _ => mism loc lab "bigint expr"
        return
      let np := numParamsOf c.env n1
      if n1 == ``Prod.mk && a1.size == 4 then
        let α := a1[0]!; let β := a1[1]!
        let envPair := α.isAppOfArity ``List 1 && (α.getArg! 0).isConstOf ``Char && β.isConstOf ``Nat
        let addrFirst := α.isConstOf ``Nat && (β.isConstOf ``Val || β.isConstOf ``Comp)
        if envPair then
          gw .plain a1[2]! a2[2]! loc lab
          gw .heap a1[3]! a2[3]! loc (lab ++ "/env:" ++ charsOfE a1[2]!)
          return
        if addrFirst then
          gw .heap a1[2]! a2[2]! loc lab
          gw .plain a1[3]! a2[3]! loc lab
          return
        gw m a1[2]! a2[2]! loc lab
        gw m a1[3]! a2[3]! loc lab
        return
      let short := n1.getString!
      for i in [np:a1.size] do
        let fm := fieldMode n1 (i - np) m
        let lab' := if n1 == ``List.cons || n1 == ``Option.some then lab else lab ++ "/" ++ short
        gw fm a1[i]! a2[i]! loc lab'
    | _, _ => unless e1 == e2 do mism loc lab "non-constructor expression differs"

/-! ## Native comparison of heap data -/

def keyEqN : PKey → PKey → Bool
  | .str a, .str b => a == b
  | .sym i, .sym j => i == j
  | _, _ => false

def valCtor : Val → String
  | .undef => "undef" | .null => "null" | .bool _ => "bool" | .num _ => "num" | .big _ => "big"
  | .str _ => "str" | .sym _ => "sym" | .obj _ => "obj" | .ptr _ _ => "ptr"

def memCmp (m1 m2 : Mem) (loc : Loc) (lab : String) : WM Unit :=
  match m1, m2 with
  | .js a, .js b => pairHeap a b loc (lab ++ "~js")
  | .ext r, .ext q => pairRegion r q loc (lab ++ "~ext")
  | _, _ => mism loc lab "Mem class"

def valCmp (v1 v2 : Val) (loc : Loc) (lab : String) : WM Unit :=
  match v1, v2 with
  | .undef, .undef => pure ()
  | .null, .null => pure ()
  | .bool a, .bool b => unless a == b do mism loc lab s!"bool {a} {b}"
  | .num x, .num y => numCmp x y loc lab
  | .big i, .big j => bigCmp i j loc lab
  | .str a, .str b => unless a == b do mism loc lab s!"string {repr (strOf a)} vs {repr (strOf b)}"
  | .sym i, .sym j => symCmp i j loc lab
  | .obj a, .obj b => pairHeap a b loc lab
  | .ptr m o, .ptr m' o' => do memCmp m m' loc lab; natCmp o o' loc (lab ++ "~ptroff")
  | _, _ => mism loc lab s!"value kind {valCtor v1} vs {valCtor v2}"

def valsCmp (xs ys : List Val) (loc : Loc) (lab : String) : WM Unit := do
  if xs.length != ys.length then mism loc lab s!"list length {xs.length} {ys.length}"
  let mut i := 0
  for (x, y) in xs.zip ys do
    valCmp x y loc s!"{lab}[{i}]"
    i := i + 1

def propCmp (p q : PropV) (loc : Loc) (lab : String) : WM Unit :=
  match p, q with
  | .data v w e, .data v' w' e' => do
    valCmp v v' loc lab
    unless w == w' && e == e' do mism loc lab "prop attributes"
  | .acc g s e, .acc g' s' e' => do
    valCmp g g' loc (lab ++ "~get"); valCmp s s' loc (lab ++ "~set")
    unless e == e' do mism loc lab "prop attributes"
  | _, _ => mism loc lab "prop data vs accessor"

def propsCmp (ps qs : Props) (loc : Loc) : WM Unit := do
  if ps.length != qs.length then mism loc "props" s!"props length {ps.length} {qs.length}"
  for ((k, v), (k', v')) in ps.zip qs do
    if keyEqN k k' then propCmp v v' loc ("." ++ fmtKey k)
    else mism loc "props" s!"key {fmtKey k} vs {fmtKey k'}"

def privCmp (ps qs : List ((Nat × Host.Ts.Name) × PropV)) (loc : Loc) : WM Unit := do
  if ps.length != qs.length then mism loc "priv" s!"priv length {ps.length} {qs.length}"
  for (((b, n), v), ((b', n'), v')) in ps.zip qs do
    if n == n' then do pairHeap b b' loc ("#brand:" ++ strOf n); propCmp v v' loc ("#" ++ strOf n)
    else mism loc "priv" s!"priv key {b}#{strOf n} vs {b'}#{strOf n'}"

def envCmp (e1 e2 : Env) (loc : Loc) (lab : String) : WM Unit := do
  if e1.length != e2.length then mism loc lab s!"env length {e1.length} {e2.length}"
  for ((n, a), (n', b)) in e1.zip e2 do
    if n == n' then pairHeap a b loc (lab ++ "/env:" ++ strOf n) else mism loc lab s!"env name {strOf n} vs {strOf n'}"

def cellCmp (c1 c2 : Cell) (loc : Loc) (lab : String) : WM Unit :=
  match c1, c2 with
  | .num x, .num y => numCmp x y loc lab
  | .big i, .big j => bigCmp i j loc lab
  | _, _ => mism loc lab "cell kind"

def bytesCmp (bs cs : List Byte) (loc : Loc) (lab : String) : WM Unit := do
  if bs.length != cs.length then mism loc lab s!"bytes length {bs.length} {cs.length}"
  let mut i := 0
  for (b, c) in bs.zip cs do
    match b, c with
    | .lit x, .lit y => unless x == y do natCmp x y loc s!"{lab}[{i}]"
    | .part k x j, .part k' y j' =>
      if k.code == k'.code && j == j' then
        if j == 0 then cellCmp x y loc s!"{lab}[{i}]:{k.code}"
      else mism loc s!"{lab}[{i}]" "byte part layout"
    | .lit _, .part .. => mism loc s!"{lab}[{i}]" "byte lit vs part"
    | .part .., .lit _ => mism loc s!"{lab}[{i}]" "byte part vs lit"
    i := i + 1

unsafe def ptrEq {α : Type} (a b : α) : Bool := ptrAddrUnsafe a == ptrAddrUnsafe b

unsafe def funcEq (f g : Func) : Bool := ptrEq f g || f == g

unsafe def codeCmp (k1 k2 : Code) (loc : Loc) : WM Unit :=
  match k1, k2 with
  | .closure f env ar home, .closure f' env' ar' home' => do
    unless funcEq f f' do mism loc "code" "closure function differs"
    envCmp env env' loc "closure"
    unless ar == ar' do mism loc "code" "arrow"
    valCmp home home' loc "home"
  | .klass ct env par inst, .klass ct' env' par' inst' => do
    let same := match ct, ct' with
      | some f, some g => funcEq f g
      | none, none => true
      | _, _ => false
    unless same do mism loc "code" "class ctor differs"
    envCmp env env' loc "class"
    valCmp par par' loc "parent"
    gw .plain (toExpr inst) (toExpr inst') loc "inst"
  | .native n d, .native n' d' => do
    unless (toExpr n) == (toExpr n') do mism loc "code" "native differs"
    valsCmp d d' loc "nativeData"
  | .bound t th as, .bound t' th' as' => do
    valCmp t t' loc "boundTarget"; valCmp th th' loc "boundThis"; valsCmp as as' loc "boundArgs"
  | _, _ => mism loc "code" "code kind"

def kindCtor : Kind → String
  | .ordinary => "ordinary" | .array _ => "array" | .fn _ => "fn" | .buf _ => "buf" | .extBuf .. => "extBuf"
  | .typed .. => "typed" | .view .. => "view" | .map _ => "map" | .set _ => "set" | .promise _ => "promise"
  | .gen .. => "gen" | .ns _ => "ns" | .box _ => "box" | .iter .. => "iter"

unsafe def kindCmp (k1 k2 : Kind) (loc : Loc) : WM Unit := do
  let c ← read
  match k1, k2 with
  | .ordinary, .ordinary => pure ()
  | .array xs, .array ys =>
    let framed := match loc with | .heap a => c.framed.contains a | _ => false
    if framed then
      if ys.length < xs.length then mism loc "framed" s!"framed array shrank {xs.length} -> {ys.length}"
      modify fun w => { w with suffix := w.suffix.push (loc, xs.length, ys.length, ys.drop xs.length) }
    else if xs.length != ys.length then mism loc "array" s!"array length {xs.length} -> {ys.length}"
    let mut i := 0
    for (x, y) in xs.zip ys do
      valCmp x y loc s!"[{i}]"
      i := i + 1
  | .fn c, .fn c' => codeCmp c c' loc
  | .buf bs, .buf cs => bytesCmp bs cs loc "bytes"
  | .extBuf r o l, .extBuf r' o' l' => do pairRegion r r' loc "extBuf"; natCmp o o' loc "extBuf.off"; natCmp l l' loc "extBuf.len"
  | .typed k b o l, .typed k' b' o' l' => do
    unless k.code == k'.code do mism loc "typed" "element kind"
    pairHeap b b' loc "typed.buf"; natCmp o o' loc "typed.off"; natCmp l l' loc "typed.len"
  | .view b o l, .view b' o' l' => do pairHeap b b' loc "view.buf"; natCmp o o' loc "view.off"; natCmp l l' loc "view.len"
  | .map es, .map es' =>
    match loc with
    | .heap a => if c.byKey.contains a then mapByKey a es es' loc else mapPos es es' loc
    | _ => mapPos es es' loc
  | .set es, .set es' => valsCmp es es' loc "set"
  | .promise p, .promise p' => gw .plain (toExpr p) (toExpr p') loc "promise"
  | .gen g a q, .gen g' a' q' => do
    gw .plain (toExpr g) (toExpr g') loc "gen"
    unless a == a' do mism loc "gen" "async"
    gw .plain (toExpr q) (toExpr q') loc "genQueue"
  | .ns ex, .ns ex' => envCmp ex ex' loc "ns"
  | .box v, .box v' => valCmp v v' loc "box"
  | .iter s i md, .iter s' i' md' => do valCmp s s' loc "iter.src"; natCmp i i' loc "iter.i"; natCmp md md' loc "iter.mode"
  | _, _ => mism loc "kind" s!"kind {kindCtor k1} vs {kindCtor k2}"
where
  mapPos (es es' : List (Val × Val)) (loc : Loc) : WM Unit := do
    if es.length != es'.length then mism loc "map" s!"map size {es.length} {es'.length}"
    let mut i := 0
    for ((k, v), (k', v')) in es.zip es' do
      valCmp k k' loc s!"map[{i}].key"; valCmp v v' loc s!"map[{i}].val"
      i := i + 1
  mapByKey (a : Nat) (es es' : List (Val × Val)) (loc : Loc) : WM Unit := do
    let keyOf : Val → Option String := fun | .str cs => some (strOf cs) | _ => none
    for (k, v) in es do
      match keyOf k with
      | some ks => match es'.find? (fun (k', _) => keyOf k' == some ks) with
        | some (_, v') => valCmp v v' loc s!"map[{ks}]"
        | none => modify fun w => { w with ghostEntries := w.ghostEntries.push (a, ks) }
      | none => mism loc "map" "a by-key map with a key that is no string"
    for (k', _) in es' do
      match keyOf k' with
      | some ks => if (es.find? (fun (k, _) => keyOf k == some ks)).isNone then
          modify fun w => { w with ghostEntries := w.ghostEntries.push (a, ks) }
      | none => mism loc "map" "a by-key map with a key that is no string"

unsafe def heapStep (a b : Nat) : WM Unit := do
  let c ← read
  let loc := Loc.heap a
  if c.ghosts.contains a then
    modify fun w => { w with ghostSeen := w.ghostSeen.push a }
    return
  match c.s1.heap.get a, c.s2.heap.get b with
  | some (.cell v), some (.cell v') =>
    match v, v' with
    | some x, some y => valCmp x y loc "cell"
    | none, none => pure ()
    | _, _ => mism loc "cell" "TDZ vs initialized"
  | some (.obj o), some (.obj p) => do
    kindCmp o.kind p.kind loc
    valCmp o.proto p.proto loc "proto"
    propsCmp o.props p.props loc
    privCmp o.priv p.priv loc
    unless o.extensible == p.extensible do mism loc "ext" "extensible"
  | none, none => mism loc "" "missing on both sides"
  | some _, none => mism loc "" s!"target h{b} missing"
  | none, some _ => mism loc "" s!"source h{a} missing (not kept)"
  | _, _ => mism loc "" s!"heap entry kind differs (h{a} vs h{b})"

def handleStep (a b : Nat) : WM Unit := do
  let c ← read
  let m1 := c.s1.aux.ffi.mlx; let m2 := c.s2.aux.ffi.mlx
  let loc := Loc.hnd a
  match m1.arrs.get a, m2.arrs.get b with
  | some n, some n' => pairNode n n' loc "arr"
  | none, none => pure ()
  | _, _ => mism loc "arr" "array handle vs other"
  match m1.objs.get a, m2.objs.get b with
  | some o, some o' => gw .plain (toExpr o) (toExpr o') loc "obj"
  | none, none => pure ()
  | _, _ => mism loc "obj" "native object vs other"

def nodeStep (a b : Nat) : WM Unit := do
  let c ← read
  let m1 := c.s1.aux.ffi.mlx; let m2 := c.s2.aux.ffi.mlx
  let loc := Loc.node a
  match m1.nodes.get a, m2.nodes.get b with
  | some x, some y =>
    if c.followIns || c.traceNodes.contains a then
      let ex := toExpr x.prim; let ey := toExpr y.prim
      if ex.getAppFn == ey.getAppFn then gw .plain (toExpr x) (toExpr y) loc "node"
      else mism loc "node" s!"prim {ex.getAppFn} vs {ey.getAppFn}"
    else
      if x.shape.length != y.shape.length then mism loc "shape" s!"rank {x.shape.length} vs {y.shape.length}"
      let mut i := 0
      for (d, e) in x.shape.zip y.shape do
        dimCmp d e loc s!"shape[{i}]"
        i := i + 1
      unless x.dtype == y.dtype do mism loc "dtype" s!"dtype {x.dtype} vs {y.dtype}"
      if c.primNums then gw .plain (toExpr x.prim) (toExpr y.prim) loc "prim"
  | none, none => mism loc "node" "both missing"
  | _, _ => mism loc "node" "missing on one side"
  match m1.items.get a, m2.items.get b with
  | some x, some y => numCmp x y loc "item"
  | none, none => pure ()
  | some _, none => mism loc "item" "item memo lost"
  | none, some y => modify fun w => { w with itemsNew := w.itemsNew.push (loc, y) }

unsafe def drain : WM Unit := do
  repeat
    let next ← modifyGet fun w =>
      if w.head ≥ w.work.size then (none, w) else (some w.work[w.head]!, { w with head := w.head + 1 })
    match next with
    | none => break
    | some (k, a, b) =>
      if k == 0 then heapStep a b
      else if k == 1 then handleStep a b
      else nodeStep a b

/-- Walk from the roots: control, stack, jobs, stores, mlx pending and error handler,
plus explicit heap address pairs. -/
unsafe def walkRoots (extra : List (Nat × Nat)) : WM Unit := do
  let c ← read
  let s1 := c.s1; let s2 := c.s2
  for (a, b) in extra do pairHeap a b (.root "extra") ""
  gw .plain (toExpr s1.ctl) (toExpr s2.ctl) (.root "ctl") ""
  if s1.stack.length != s2.stack.length then mism (.root "stack") "" "stack length"
  let mut i := 0
  for (f, g) in s1.stack.zip s2.stack do
    gw .plain (toExpr f) (toExpr g) (.root s!"stack[{i}]") ""
    i := i + 1
  gw .plain (toExpr s1.aux.jobs) (toExpr s2.aux.jobs) (.root "jobs") ""
  gw .plain (toExpr s1.aux.stores) (toExpr s2.aux.stores) (.root "stores") ""
  gw .plain (toExpr s1.aux.ffi.mlx.pending) (toExpr s2.aux.ffi.mlx.pending) (.root "mlx.pending") ""
  gw .plain (toExpr s1.aux.ffi.mlx.errh) (toExpr s2.aux.ffi.mlx.errh) (.root "mlx.errh") ""
  drain

/-! ## Reporting -/

partial def pathOf (w : W) (loc : Loc) (fuel : Nat) : String :=
  if fuel == 0 then "…" else
  match loc with
  | .root n => n
  | .heap a => match w.par[a]? with
    | some (p, l) => pathOf w p (fuel - 1) ++ s!"{l} > h{a}"
    | none => s!"h{a}"
  | .hnd h => match w.hpar[h]? with
    | some (p, l) => pathOf w p (fuel - 1) ++ s!"{l} > H{h}"
    | none => s!"H{h}"
  | .node n => match w.npar[n]? with
    | some (p, l) => pathOf w p (fuel - 1) ++ s!"{l} > N{n}"
    | none => s!"N{n}"

def tgtOf (w : W) : Loc → String
  | .root _ => ""
  | .heap a => s!"(->h{w.sig[a]?.getD 0})"
  | .hnd h => s!"(->H{w.hnd[h]?.getD 0})"
  | .node n => s!"(->N{w.nod[n]?.getD 0})"

/-- Nodes of compiled-closure traces (inputs, outputs, order) of every native closure object. -/
def traceNodesOf (m : Host.Mlx.Ffi.St) : Std.HashSet Nat :=
  ptrieFold (fun (acc : Std.HashSet Nat) _ (o : Host.Mlx.Ffi.Obj) => match o with
    | .clo (.compiled _ _ _ ts) => ts.foldl (fun acc t => (t.ins ++ t.outs ++ t.order).foldl (·.insert ·) acc) acc
    | _ => acc) m.objs {}

/-- JS heap addresses the native state names (JSCallback regions, JS pointers, pending output buffers). -/
def nativeHeapRefs (m : Host.Mlx.Ffi.St) : List Nat :=
  let argRef : Arg → List Nat
    | .jsPtr b _ _ => [b]
    | .extPtr r _ => if r ≥ 2 ^ 48 then [r - 2 ^ 48] else []
    | _ => []
  let fromObjs := ptrieFold (fun (acc : List Nat) _ (o : Host.Mlx.Ffi.Obj) => match o with
    | .clo (.fn cb p) => (if cb ≥ 2 ^ 48 then [cb - 2 ^ 48] else []) ++ argRef p ++ acc
    | .clo (.compiled cb p _ _) => (if cb ≥ 2 ^ 48 then [cb - 2 ^ 48] else []) ++ argRef p ++ acc
    | _ => acc) m.objs []
  (fromObjs ++ m.pending.map (·.outBuf) ++ (m.errh.map argRef).getD []).eraseDups

end Host.Ts.Sim.Template
