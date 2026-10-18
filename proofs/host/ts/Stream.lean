import host.ts.Chunk
import host.ts.Memo
namespace Host.Ts
open Lean Elab Command Meta

/-! # Streamed chunked runs

`host_chain` holds every state of a chain in one module, so its memory is
the sum of the states. A streamed chain keeps one state at a time:

* `host_stream P : F, boot, tab, ρ, k, N` (`States`) runs the machine
  natively for `N` chunks of `k` steps, answering the symbolic tests at `ρ`
  (the oracle `P.O`, as `discover`), and writes each chunk boundary to a file;
  `chunks [k₀, …]` overrides the uniform sizes to place boundaries at exact cuts;
* `host_stream_state P i` (`G<i>`, importing `G<i-1>`) reads boundary `i`
  and adds `P.s<i>` and `P.S<i>`;
* `host_chunk P i` (`C<i>`, importing `G<i+1>`) checks chunk `i` as for
  `host_chain`, and `host_chain_run`, `host_chain_boot`, `host_chain_result`
  compose the chunks.

States share structure by name. A boundary's file defines constants only
for what changed since the previous boundaries: heap and FFI pages (`PTrie`,
pages and groups keyed by pointer identity of the native value), and the
newest events of the trace (its tail is the previous boundary's trace
constant). Everything else is inline. The kernel unfolds a named page when
a step reads it, and a page a chunk does not touch stays the same constant in
the state it computes, so the expected end state compares by name.

The files only choose the states: every state is a definition the kernel
type-checks, and every chunk is a kernel reduction. A stale or corrupted file
makes a check fail, never succeed wrongly. Files go to `$HOST_STREAM_DIR`
(default `.host-stream` in the working directory), one directory per chain. -/

namespace Stream

/-! ## Expression DAG files

Records in order, each defining the next index of its kind (names, levels,
expressions) from earlier ones, and roots. Identical nodes are written once
(hash-consing on child indices), so a file is the shared DAG of its roots. -/

inductive K where
  | bvar (i : Nat)
  | sort (l : Nat)
  | const (n : Nat) (ls : List Nat)
  | app (f a : Nat)
  | lam (n t b bi : Nat)
  | pi (n t b bi : Nat)
  | lit (l : Literal)
  | proj (s i e : Nat)
deriving BEq, Hashable

structure W where
  buf : ByteArray := .empty
  names : Std.HashMap Lean.Name Nat := {}
  nNames : Nat := 1
  levels : Std.HashMap Level Nat := {}
  nLevels : Nat := 0
  exprs : Std.HashMap K Nat := {}
  nExprs : Nat := 0
  ptr : Std.HashMap USize Nat := {}
  /-- Roots written so far, kept alive while `ptr` refers to their nodes. -/
  keep : Array Lean.Expr := #[]

abbrev WM := StateM W

def putByte (b : UInt8) : WM Unit := modify fun w => { w with buf := w.buf.push b }

partial def putNat (n : Nat) : WM Unit :=
  if n < 128 then putByte n.toUInt8 else do putByte (n % 128 + 128).toUInt8; putNat (n / 128)

def putBytes (b : ByteArray) : WM Unit := do putNat b.size; modify fun w => { w with buf := w.buf ++ b }

partial def natBytes (n : Nat) (acc : ByteArray := .empty) : ByteArray :=
  if n == 0 then acc else natBytes (n / 256) (acc.push (n % 256).toUInt8)

partial def serName : Lean.Name → WM Nat
  | .anonymous => pure 0
  | n@(.str p s) => do
    if let some i := (← get).names[n]? then return i
    let pi ← serName p
    putByte 1; putNat pi; putBytes s.toUTF8
    modifyGet fun w => (w.nNames, { w with names := w.names.insert n w.nNames, nNames := w.nNames + 1 })
  | n@(.num p k) => do
    if let some i := (← get).names[n]? then return i
    let pi ← serName p
    putByte 2; putNat pi; putNat k
    modifyGet fun w => (w.nNames, { w with names := w.names.insert n w.nNames, nNames := w.nNames + 1 })

partial def serLevel (l : Level) : WM Nat := do
  if let some i := (← get).levels[l]? then return i
  match l with
  | .zero => putByte 3
  | .succ a => let a ← serLevel a; putByte 4; putNat a
  | .max a b => let a ← serLevel a; let b ← serLevel b; putByte 5; putNat a; putNat b
  | .imax a b => let a ← serLevel a; let b ← serLevel b; putByte 6; putNat a; putNat b
  | .param n => let n ← serName n; putByte 7; putNat n
  | .mvar _ => panic! "level metavariable in a streamed expression"
  modifyGet fun w => (w.nLevels, { w with levels := w.levels.insert l w.nLevels, nLevels := w.nLevels + 1 })

def emit (k : K) : WM Nat := do
  if let some i := (← get).exprs[k]? then return i
  match k with
  | .bvar i => putByte 10; putNat i
  | .sort l => putByte 11; putNat l
  | .const n ls => putByte 12; putNat n; putNat ls.length; ls.forM putNat
  | .app f a => putByte 13; putNat f; putNat a
  | .lam n t b bi => putByte 14; putNat n; putNat t; putNat b; putNat bi
  | .pi n t b bi => putByte 15; putNat n; putNat t; putNat b; putNat bi
  | .lit (.natVal v) => putByte 16; putBytes (natBytes v)
  | .lit (.strVal s) => putByte 17; putBytes s.toUTF8
  | .proj s i e => putByte 18; putNat s; putNat i; putNat e
  modifyGet fun w => (w.nExprs, { w with exprs := w.exprs.insert k w.nExprs, nExprs := w.nExprs + 1 })

def biCode : BinderInfo → Nat
  | .default => 0 | .implicit => 1 | .strictImplicit => 2 | .instImplicit => 3

def biOf : Nat → BinderInfo
  | 1 => .implicit | 2 => .strictImplicit | 3 => .instImplicit | _ => .default

unsafe def serExprImpl (root : Lean.Expr) : WM Nat := do
  modify fun w => { w with keep := w.keep.push root }
  let mut todo : Array (Lean.Expr × Bool) := #[(root, false)]
  let mut out : Array Nat := #[]
  while h : todo.size > 0 do
    let (e, ready) := todo[todo.size - 1]
    todo := todo.pop
    if !ready then
      if let some i := (← get).ptr[ptrAddrUnsafe e]? then
        out := out.push i
        continue
      match e with
      | .app f a => todo := (((todo.push (e, true)).push (a, false)).push (f, false))
      | .lam _ t b _ | .forallE _ t b _ => todo := (((todo.push (e, true)).push (b, false)).push (t, false))
      | .proj _ _ x => todo := ((todo.push (e, true)).push (x, false))
      | .mdata _ x => todo := todo.push (x, false)
      | _ =>
        let i ← match e with
          | .bvar i => emit (.bvar i)
          | .sort l => do emit (.sort (← serLevel l))
          | .const n ls => do emit (.const (← serName n) (← ls.mapM serLevel))
          | .lit l => emit (.lit l)
          | _ => panic! "free variable, metavariable or let in a streamed expression"
        modify fun w => { w with ptr := w.ptr.insert (ptrAddrUnsafe e) i }
        out := out.push i
    else
      let i ← match e with
        | .app .. => do
          let a := out.back!; out := out.pop; let f := out.back!; out := out.pop; emit (.app f a)
        | .lam n _ _ bi => do
          let b := out.back!; out := out.pop; let t := out.back!; out := out.pop; emit (.lam (← serName n) t b (biCode bi))
        | .forallE n _ _ bi => do
          let b := out.back!; out := out.pop; let t := out.back!; out := out.pop; emit (.pi (← serName n) t b (biCode bi))
        | .proj s k _ => do
          let x := out.back!; out := out.pop; emit (.proj (← serName s) k x)
        | _ => panic! "unexpected node"
      modify fun w => { w with ptr := w.ptr.insert (ptrAddrUnsafe e) i }
      out := out.push i
  return out.back!

@[implemented_by serExprImpl] opaque serExpr (root : Lean.Expr) : WM Nat

/-- A file's roots: definitions (name, type, value) and the boundary's state and server. -/
structure Roots where
  nonce : String
  defs : Array (Lean.Name × Lean.Expr × Lean.Expr)
  st : Lean.Expr
  srv : Lean.Expr

def writeRoots (r : Roots) : ByteArray := Id.run do
  let go : WM Unit := do
    putBytes r.nonce.toUTF8
    for (n, t, v) in r.defs do
      let n ← serName n; let t ← serExpr t; let v ← serExpr v
      putByte 30; putNat n; putNat t; putNat v
    let s ← serExpr r.st; let c ← serExpr r.srv
    putByte 31; putNat s; putNat c
  (go.run {}).2.buf

structure R where
  buf : ByteArray
  pos : Nat := 0

abbrev RM := StateT R (Except String)

def getByte : RM UInt8 := do
  let r ← get
  if h : r.pos < r.buf.size then set { r with pos := r.pos + 1 }; return r.buf[r.pos]
  else throw "truncated stream file"

partial def getNat : RM Nat := do
  let b ← getByte
  if b < 128 then return b.toNat else return (b.toNat - 128) + 128 * (← getNat)

def getBytes : RM ByteArray := do
  let n ← getNat
  let r ← get
  unless r.pos + n ≤ r.buf.size do throw "truncated stream file"
  set { r with pos := r.pos + n }
  return r.buf.extract r.pos (r.pos + n)

def bytesNat (b : ByteArray) : Nat := Id.run do
  let mut n := 0
  for i in [0:b.size] do n := n * 256 + b[b.size - 1 - i]!.toNat
  return n

def getStr : RM String := do
  match String.fromUTF8? (← getBytes) with
  | some s => return s
  | none => throw "bad UTF-8 in stream file"

def readRoots (buf : ByteArray) : Except String Roots := do
  let go : RM Roots := do
    let nonce ← getStr
    let mut names : Array Lean.Name := #[.anonymous]
    let mut levels : Array Level := #[]
    let mut exprs : Array Lean.Expr := #[]
    let mut defs : Array (Lean.Name × Lean.Expr × Lean.Expr) := #[]
    let at_ {α : Type} [Inhabited α] (a : Array α) (i : Nat) : RM α :=
      if h : i < a.size then pure a[i] else throw "stream file refers forward"
    repeat
      match (← getByte).toNat with
      | 1 => let p ← at_ names (← getNat); names := names.push (.str p (← getStr))
      | 2 => let p ← at_ names (← getNat); names := names.push (.num p (← getNat))
      | 3 => levels := levels.push .zero
      | 4 => levels := levels.push (.succ (← at_ levels (← getNat)))
      | 5 => let a ← at_ levels (← getNat); levels := levels.push (.max a (← at_ levels (← getNat)))
      | 6 => let a ← at_ levels (← getNat); levels := levels.push (.imax a (← at_ levels (← getNat)))
      | 7 => levels := levels.push (.param (← at_ names (← getNat)))
      | 10 => exprs := exprs.push (.bvar (← getNat))
      | 11 => exprs := exprs.push (.sort (← at_ levels (← getNat)))
      | 12 =>
        let n ← at_ names (← getNat)
        let k ← getNat
        let mut ls := #[]
        for _ in [0:k] do ls := ls.push (← at_ levels (← getNat))
        exprs := exprs.push (.const n ls.toList)
      | 13 => let f ← at_ exprs (← getNat); exprs := exprs.push (.app f (← at_ exprs (← getNat)))
      | 14 =>
        let n ← at_ names (← getNat); let t ← at_ exprs (← getNat); let b ← at_ exprs (← getNat)
        exprs := exprs.push (.lam n t b (biOf (← getNat)))
      | 15 =>
        let n ← at_ names (← getNat); let t ← at_ exprs (← getNat); let b ← at_ exprs (← getNat)
        exprs := exprs.push (.forallE n t b (biOf (← getNat)))
      | 16 => exprs := exprs.push (.lit (.natVal (bytesNat (← getBytes))))
      | 17 => exprs := exprs.push (.lit (.strVal (← getStr)))
      | 18 => let s ← at_ names (← getNat); let i ← getNat; exprs := exprs.push (.proj s i (← at_ exprs (← getNat)))
      | 30 =>
        let n ← at_ names (← getNat); let t ← at_ exprs (← getNat)
        defs := defs.push (n, t, ← at_ exprs (← getNat))
      | 31 =>
        let s ← at_ exprs (← getNat)
        return { nonce, defs, st := s, srv := ← at_ exprs (← getNat) }
      | t => throw s!"bad record tag {t} in stream file"
    throw "stream file has no state"
  (go.run' { buf })

/-! ## Naming by pointer identity -/

structure G where
  pre : Lean.Name
  idx : Nat := 0
  count : Nat := 0
  /-- Native value (by address and type, kept alive) ↦ its constant. Immediate
  values such as empty lists and tries share an address across different types. -/
  memo : Std.HashMap (USize × Lean.Expr) (Lean.Name × NonScalar) := {}
  /-- Named definitions referenced by each alias. This keeps child-page aliases
  live when serialization reuses a whole unchanged group without visiting it. -/
  deps : Std.HashMap Lean.Name (Array Lean.Name) := {}
  defs : Array (Lean.Name × Lean.Expr × Lean.Expr) := #[]

abbrev GenM := StateT G IO

/-- Imported snapshot aliases participate when their dependency entries have
been seeded by the restoring chooser, even outside this stream's namespace. -/
def G.trackedAlias (g : G) (n : Lean.Name) : Bool :=
  g.pre.isPrefixOf n || g.deps.contains n

/-- A serializer of FFI states for streamed chains; `toExpr` unless an instance names parts. -/
class StreamExpr (α : Type) where
  ser : α → GenM Lean.Expr

instance (priority := low) {α : Type} [ToExpr α] : StreamExpr α := ⟨fun x => pure (toExpr x)⟩

unsafe def namedImpl {α : Type} (ty : Lean.Expr) (tag : String) (x : α) (ser : α → GenM Lean.Expr) : GenM Lean.Expr := do
  let p := ptrAddrUnsafe x
  if let some (n, _) := (← get).memo[(p, ty)]? then return mkConst n
  let e ← ser x
  let g ← get
  let n := g.pre ++ Lean.Name.mkSimple s!"{tag}{g.idx}_{g.count}"
  let deps := (ty.getUsedConstants ++ e.getUsedConstants).filter g.trackedAlias
  set { g with memo := g.memo.insert (p, ty) (n, unsafeCast x), deps := g.deps.insert n deps, defs := g.defs.push (n, ty, e), count := g.count + 1 }
  return mkConst n

/-- `x` as a constant: the one an earlier boundary defined for this native value, or a new one. -/
@[implemented_by namedImpl] opaque named {α : Type} (ty : Lean.Expr) (tag : String) (x : α) (ser : α → GenM Lean.Expr) : GenM Lean.Expr

/-- Retain native identities only for aliases reachable from the current
serialized state. Old files retain their definitions independently. Keeping
dependency edges lets a reused group retain its unvisited child-page aliases. -/
def sweep (g : G) (roots : Array Lean.Expr) : G := Id.run do
  let mut todo := roots.foldl (fun ns e => ns ++ e.getUsedConstants.filter g.trackedAlias) #[]
  let mut live : Std.HashSet Lean.Name := {}
  while h : todo.size > 0 do
    let n := todo[todo.size - 1]
    todo := todo.pop
    if live.contains n then continue
    live := live.insert n
    if let some ds := g.deps[n]? then todo := todo ++ ds.filter g.trackedAlias
  let memo := g.memo.fold (fun m k v => if live.contains v.1 then m.insert k v else m) {}
  let deps := g.deps.fold (fun m n ds => if live.contains n then m.insert n ds else m) {}
  return { g with memo, deps }

partial def trieE {β : Type} (tyβ : Lean.Expr) (leaf : β → GenM Lean.Expr) : Trie β → GenM Lean.Expr
  | .nil => pure (mkApp (mkConst ``Trie.nil) tyβ)
  | .node v a b c d => do
    let ve ← match v with
      | none => pure (mkApp (mkConst ``Option.none [.zero]) tyβ)
      | some x => do pure (mkApp2 (mkConst ``Option.some [.zero]) tyβ (← leaf x))
    pure (mkAppN (mkConst ``Trie.node) #[tyβ, ve, ← trieE tyβ leaf a, ← trieE tyβ leaf b, ← trieE tyβ leaf c, ← trieE tyβ leaf d])

/-- `trieE` with each value's key (the trie's digits are least significant first). -/
partial def trieEK {β : Type} (tyβ : Lean.Expr) (leaf : Nat → β → GenM Lean.Expr) (key pw : Nat) : Trie β → GenM Lean.Expr
  | .nil => pure (mkApp (mkConst ``Trie.nil) tyβ)
  | .node v a b c d => do
    let ve ← match v with
      | none => pure (mkApp (mkConst ``Option.none [.zero]) tyβ)
      | some x => do pure (mkApp2 (mkConst ``Option.some [.zero]) tyβ (← leaf key x))
    let ch (i : Nat) (t : Trie β) := trieEK tyβ leaf (key + i * pw) (pw * 4) t
    pure (mkAppN (mkConst ``Trie.node) #[tyβ, ve, ← ch 0 a, ← ch 1 b, ← ch 2 c, ← ch 3 d])

/-- A paged store with its pages and groups named, except the group and page holding `keep`
(inline: an abstraction rewrites inside them). -/
def ptrieE {α : Type} (tyα : Lean.Expr) (tag : String) (leaf : α → GenM Lean.Expr) (t : PTrie α)
    (keep : Option Nat := none) : GenM Lean.Expr := do
  let tP := mkApp (mkConst ``Trie) tyα
  let tG := mkApp (mkConst ``Trie) tP
  let page (gi pi : Nat) (p : Trie α) : GenM Lean.Expr := match p with
    | .nil => pure (mkApp (mkConst ``Trie.nil) tyα)
    | _ => if keep == some (gi * 4096 + pi * 64) then trieE tyα leaf p else named tP (tag ++ "p") p (trieE tyα leaf)
  let group (gi : Nat) (g : Trie (Trie α)) : GenM Lean.Expr := match g with
    | .nil => pure (mkApp (mkConst ``Trie.nil) tP)
    | _ => if keep.map (· / 4096) == some gi then trieEK tP (page gi) 0 1 g
      else named tG (tag ++ "g") g (trieEK tP (page gi) 0 1)
  pure (mkApp2 (mkConst ``PTrie.mk) tyα (← trieEK tG group 0 1 t.root))

/-- A list whose tail an earlier boundary named: the new prefix, then that constant; named itself. -/
unsafe def listNamedImpl {β : Type} [ToExpr β] (tag : String) (l : List β) : GenM Lean.Expr := do
  let tyβ := toTypeExpr β
  let tyL := mkApp (mkConst ``List [.zero]) tyβ
  let memo := (← get).memo
  let mut pre : Array β := #[]
  let mut cur := l
  let mut tail := mkApp (mkConst ``List.nil [.zero]) tyβ
  repeat
    if let some (n, _) := memo[(ptrAddrUnsafe cur, tyL)]? then
      tail := mkConst n
      break
    match cur with
    | [] => break
    | x :: r => pre := pre.push x; cur := r
  if pre.isEmpty then return tail
  let body := pre.foldr (fun x acc => mkApp3 (mkConst ``List.cons [.zero]) tyβ (toExpr x) acc) tail
  named tyL tag l fun _ => pure body

@[implemented_by listNamedImpl] opaque listNamed {β : Type} [ToExpr β] (tag : String) (l : List β) : GenM Lean.Expr

/-- A machine state: heap and trace by name, the rest inline, the FFI state by `serS`. -/
def stE {S : Type} (serS : S → GenM Lean.Expr) (tyS : Lean.Expr) (s : St S) (keep : Option Nat := none) : GenM Lean.Expr := do
  let heap ← ptrieE (mkConst ``HObj) "h" (fun x => pure (toExpr x)) s.heap (keep.map fun a => a / 64 * 64)
  let ffi ← serS s.aux.ffi
  let trace ← listNamed "t" s.aux.trace
  let aux := mkAppN (mkConst ``Aux.mk) #[tyS, toExpr s.aux.jobs, ffi, trace, toExpr s.aux.stores]
  pure (mkAppN (mkConst ``St.mk) #[tyS, heap, toExpr s.next, toExpr s.ctl, toExpr s.stack, aux])

/-! ## The generator -/

def streamDir : IO System.FilePath := do
  match ← IO.getEnv "HOST_STREAM_DIR" with
  | some d => pure d
  | none => pure ((← IO.currentDir) / ".host-stream")

def fileOf (dir : System.FilePath) (pre : Lean.Name) (i : Nat) : System.FilePath := dir / pre.toString / s!"{i}.bin"

/-- An abstraction of a push-only array over boundaries `i … j` (`host_chain_abs`): the binding's
name; the generator finds the array at boundary `i`. -/
structure AbsSpec where
  i : Nat
  j : Nat
  name : List Char

/-- The array `name` is bound to at state `s` (its address and elements). -/
def absArray (F : Ffi) (s : St F.S) (name : List Char) : Except String (Nat × List Val) := do
  let nameE := toExpr name
  let cells := (cellsNamed nameE (toExpr s.stack) ++ cellsNamed nameE (toExpr s.ctl)).eraseDups
  let addrs := (cells.filterMap fun c => match s.cell? c with
    | some (some (.obj a)) => some a
    | _ => none).eraseDups
  let [a] := addrs | throw s!"binding {String.ofList name}: arrays {addrs}"
  let some (_, es) := arrayOf F s a | throw "not an array"
  pure (a, es)

/-- Run chunks of `ks` steps from the state `skip` steps after `s₀`, answering tests at `ρ`,
writing boundaries `0 … N` (and the abstracted states of `abs`). Returns the oracle (in order),
the steps run, the bytes written, the number table at boundary 0 and the abstraction's base. -/
def generate (F : Ffi) (serS : F.S → GenM Lean.Expr) (tyS : Lean.Expr) (ρ : Nat → F64) (ks : List Nat) (skip : Nat)
    (abs : Option AbsSpec) (s₀ : St F.S) (tab : List SymE) (pre : Lean.Name) (nonce : String) :
    IO (List Ans × Nat × Nat × List SymE × List Val) := do
  let mut s₀ := s₀
  let mut c₀ : SSrv := ⟨tab, []⟩
  for _ in [0:skip] do
    match interpRec ρ (step F s₀).run c₀ [] with
    | some (s', c', _) => s₀ := s'; c₀ := c'
    | none => throw (IO.userError s!"host_stream {pre}: stuck while skipping")
  let tab := c₀.tab
  let dir ← streamDir
  IO.FS.createDirAll (dir / pre.toString)
  let oE := mkConst (pre ++ `O)
  let ansTy := mkConst ``Ans
  let valL := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
  let stTy := mkApp (mkConst ``St) tyS
  let mut arr : Option (Nat × List Val) := none
  let boundary (g : G) (i : Nat) (s : St F.S) (tab : List SymE) (m : Nat) (arr : Option (Nat × List Val)) :
      IO (G × Nat) := do
    -- Retain expressions touched in this or the previous boundary only.
    -- G's separately swept aliases preserve cross-boundary named sharing.
    Memo.beginEpoch
    let (sE, g) ← (stE serS tyS s).run { g with idx := i, count := 0, defs := #[] }
    let mut g := g
    let mut roots := #[sE]
    if let (some sp, some (a, base)) := (abs, arr) then
      if sp.i ≤ i ∧ i ≤ sp.j then
        let some (ob, es) := arrayOf F s a | throw (IO.userError s!"host_stream {pre}: the abstracted array is gone at {i}")
        unless es.length ≥ base.length do throw (IO.userError s!"host_stream {pre}: the abstracted array shrank at {i}")
        let s' := s.setObj a { ob with kind := .array (absSentinel :: es.drop base.length) }
        let (aE, g') ← (stE serS tyS s' (keep := some a)).run g
        roots := roots.push aE
        g := { g' with defs := g'.defs.push (pre ++ Lean.Name.mkSimple s!"a{i}", Lean.Expr.forallE `x valL stTy .default,
          .lam `fw valL (absReplace (toExpr absSentinel) aE) .default) }
    let oracle := mkApp3 (mkConst ``List.drop [.zero]) ansTy (mkRawNatLit m) oE
    let srv := mkApp2 (mkConst ``SSrv.mk) (toExpr tab) oracle
    let bytes := writeRoots { nonce, defs := g.defs, st := sE, srv }
    IO.FS.writeBinFile (fileOf dir pre i) bytes
    g := sweep { g with defs := #[] } (roots.push srv)
    pure (g, bytes.size)
  let findArr (i : Nat) (s : St F.S) (arr : Option (Nat × List Val)) : IO (Option (Nat × List Val)) :=
    match abs with
    | some sp =>
      if sp.i == i then
        match absArray F s sp.name with
        | .ok r => pure (some r)
        | .error e => throw (IO.userError s!"host_stream {pre}: {e}")
      else pure arr
    | none => pure arr
  arr ← findArr 0 s₀ arr
  let mut g : G := { pre }
  let (g', b0) ← boundary g 0 s₀ tab 0 arr
  g := g'
  let mut bytes := b0
  let mut s := s₀
  let mut c : SSrv := ⟨tab, []⟩
  let mut o : Array Ans := #[]
  let mut steps := 0
  for (k, i) in ks.zipIdx do
    for _ in [0:k] do
      if isHalt s.ctl then break
      match interpRec ρ (step F s).run c [] with
      | some (s', c', a) => s := s'; c := c'; o := o ++ a.reverse.toArray; steps := steps + 1
      | none => throw (IO.userError s!"host_stream {pre}: stuck after {steps} steps")
    arr ← findArr (i + 1) s arr
    let (g', b) ← boundary g (i + 1) s c.tab o.size arr
    g := g'
    bytes := bytes + b
  pure (o.toList, steps, bytes, tab, (arr.map Prod.snd).getD [])

partial def natIn (stx : Syntax) : Option Nat := stx.isNatLit?.orElse fun _ => stx.getArgs.findSome? natIn

/-- `host_stream P : F, boot, tab, ρ, k, N`: the chain's constants (`P.F`, `P.boot`, `P.O`,
`P.srv`, `P.ks`, `P.nonce`) after writing its `N + 1` boundaries. Optional
`chunks ks` uses the explicit sizes and their length instead of `k` and `N`. -/
elab "host_stream " p:ident " : " f:term ", " b:term ", " tab:term ", " ρ:term ", " k:term ", " n:term sk:((", " num)?)
    cs:((" chunks " term)?)
    ab:((" abs " num ", " num ", " str)?) : command =>
    liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let fE ← instantiateMVars (← Term.elabTermAndSynthesize f (some (mkConst ``Ffi)))
  let sTy := mkApp (mkConst ``Ffi.S) fE
  let stTy := mkApp (mkConst ``St) sTy
  let bE ← instantiateMVars (← Term.elabTermAndSynthesize b (some (mkApp (mkConst ``Option [.zero]) stTy)))
  astTabRef.set (← loadAstTab)
  let sRed ← whnf sTy
  let serS ← mkAppOptM ``StreamExpr.ser #[sRed, none]
  let tyS ← mkAppOptM ``Lean.ToExpr.toTypeExpr #[sRed, none]
  let tE ← instantiateMVars (← Term.elabTermAndSynthesize tab (some (mkApp (mkConst ``List [.zero]) (mkConst ``SymE))))
  let rE ← instantiateMVars (← Term.elabTermAndSynthesize ρ (some (← mkArrow (mkConst ``Nat) (mkConst ``F64))))
  let kV ← unsafe evalExpr Nat (mkConst ``Nat) (← instantiateMVars (← Term.elabTermAndSynthesize k (some (mkConst ``Nat))))
  let nV ← unsafe evalExpr Nat (mkConst ``Nat) (← instantiateMVars (← Term.elabTermAndSynthesize n (some (mkConst ``Nat))))
  let ksV ← match cs.raw.getArgs.toList with
    | [_, ks] =>
      let ty := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
      unsafe evalExpr (List Nat) ty (← instantiateMVars (← Term.elabTermAndSynthesize ks (some ty)))
    | _ => pure (List.replicate nV kV)
  let nV := ksV.length
  let skipV : Nat := (natIn sk.raw).getD 0
  let absV : Option (Nat × Nat × String) := match ab.raw.getArgs.toList with
    | [_, i, _, j, _, nm] => match i.isNatLit?, j.isNatLit?, nm.isStrLit? with
      | some i, some j, some nm => some (i, j, nm)
      | _, _, _ => none
    | _ => none
  let absE := match absV with
    | some (i, j, nm) => mkApp2 (mkConst ``Option.some [.zero]) (mkConst ``AbsSpec)
        (mkApp3 (mkConst ``AbsSpec.mk) (mkRawNatLit i) (mkRawNatLit j) (toExpr nm.toList))
    | none => mkApp (mkConst ``Option.none [.zero]) (mkConst ``AbsSpec)
  let nonce := s!"{pre}:{← IO.monoNanosNow}"
  let resTy := mkApp (mkConst ``IO) (← mkAppM ``Prod #[mkApp (mkConst ``List [.zero]) (mkConst ``Ans),
    ← mkAppM ``Prod #[mkConst ``Nat, ← mkAppM ``Prod #[mkConst ``Nat, ← mkAppM ``Prod #[mkApp (mkConst ``List [.zero]) (mkConst ``SymE), mkApp (mkConst ``List [.zero]) (mkConst ``Val)]]]])
  let call ← withLocalDeclD `s stTy fun s => do
    mkLambdaFVars #[s] (mkAppN (mkConst ``generate) #[fE, serS, tyS, rE, toExpr ksV, toExpr skipV, absE, s, tE, toExpr pre, toExpr nonce])
  let t0 ← IO.monoMsNow
  Memo.reset
  let gen ← unsafe evalExpr (Option (IO (List Ans × Nat × Nat × List SymE × List Val))) (mkApp (mkConst ``Option [.zero]) resTy)
    (← mkAppM ``Option.map #[call, bE])
  let some gen := gen | throwError "host_stream: boot failed"
  let (o, steps, bytes, tab₀, base) ← gen
  if let some (i, j, _) := absV then
    let valL := mkApp (mkConst ``List [.zero]) (mkConst ``Val)
    addDecl (Declaration.defnDecl { name := pre ++ `base, levelParams := [], type := valL, value := toExpr base, hints := .regular 0, safety := .safe })
    let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat)
    addDecl (Declaration.defnDecl { name := pre ++ `abs, levelParams := [], type := pairTy, value := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) (mkConst ``Nat) (mkConst ``Nat) (mkRawNatLit i) (mkRawNatLit j), hints := ReducibilityHints.abbrev, safety := .safe })
  let tE := toExpr tab₀
  let ansTy := mkApp (mkConst ``List [.zero]) (mkConst ``Ans)
  addDecl (Declaration.defnDecl { name := pre ++ `O, levelParams := [], type := ansTy, value := toExpr o, hints := ReducibilityHints.abbrev, safety := .safe })
  addDecl (Declaration.defnDecl { name := pre ++ `F, levelParams := [], type := mkConst ``Ffi, value := fE, hints := ReducibilityHints.abbrev, safety := .safe })
  let optSt := mkApp (mkConst ``Option [.zero]) stTy
  addDecl (Declaration.defnDecl { name := pre ++ `boot, levelParams := [], type := optSt, value := bE, hints := ReducibilityHints.abbrev, safety := .safe })
  addDecl (Declaration.defnDecl { name := pre ++ `srv, levelParams := [], type := mkConst ``SSrv, value := mkApp2 (mkConst ``SSrv.mk) tE (mkConst (pre ++ `O)), hints := ReducibilityHints.abbrev, safety := .safe })
  let ksTy := mkApp (mkConst ``List [.zero]) (mkConst ``Nat)
  let ks := toExpr ksV
  addDecl (Declaration.defnDecl { name := pre ++ `ks, levelParams := [], type := ksTy, value := ks, hints := ReducibilityHints.abbrev, safety := .safe })
  compileDecl (Declaration.defnDecl { name := pre ++ `ks, levelParams := [], type := ksTy, value := ks, hints := ReducibilityHints.abbrev, safety := .safe })
  addDecl (Declaration.defnDecl { name := pre ++ `nonce, levelParams := [], type := mkConst ``String, value := toExpr nonce, hints := ReducibilityHints.abbrev, safety := .safe })
  compileDecl (Declaration.defnDecl { name := pre ++ `nonce, levelParams := [], type := mkConst ``String, value := toExpr nonce, hints := ReducibilityHints.abbrev, safety := .safe })
  logInfo m!"host_stream {pre}: {nV} chunks from step {skipV} ({steps} run), oracle of {o.length} answers, {bytes} bytes, native {(← IO.monoMsNow) - t0} ms"

/-- `host_stream_state P i`: `P.s<i>`, `P.S<i>` and the constants boundary `i` names, from its file. -/
elab "host_stream_state " p:ident i:num : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ p.getId
  let i := i.getNat
  let nonce ← unsafe evalConst String (pre ++ `nonce)
  let file := fileOf (← streamDir) pre i
  unless ← file.pathExists do throwError "host_stream_state: {file} is missing (build {pre}'s States module first)"
  let r ← match readRoots (← IO.FS.readBinFile file) with
    | .ok r => pure r
    | .error e => throwError "host_stream_state: {file}: {e}"
  unless r.nonce == nonce do throwError "host_stream_state: {file} is from another build of {pre} (rebuild its States module)"
  for (n, t, v) in r.defs do
    addDecl (Declaration.defnDecl { name := n, levelParams := [], type := t, value := v, hints := .regular 0, safety := .safe })
  let stTy := mkApp (mkConst ``St) (mkApp (mkConst ``Ffi.S) (mkConst (pre ++ `F)))
  addDecl (Declaration.defnDecl { name := pre ++ Lean.Name.mkSimple s!"s{i}", levelParams := [], type := stTy, value := r.st, hints := .regular 0, safety := .safe })
  addDecl (Declaration.defnDecl { name := pre ++ Lean.Name.mkSimple s!"S{i}", levelParams := [], type := mkConst ``SSrv, value := r.srv, hints := .regular 0, safety := .safe })

end Stream
end Host.Ts
