import host.ts.Parser
import Lean
namespace Host.Ts
open Lean Elab Command

/-! # Kernel-checked parsing of an embedded source literal

`source_parse s` reads the literal of `s : String` and adds:

* `chars : List Char` — explicit `Char.ofNat` cells — and `chars.eq :
  s.toList = chars`. `String.toList` on a literal reduces through UTF-8
  decoding and costs seconds per hundred characters in the kernel; the
  kernel instead checks `chars.eq` from `String.toList_ofList`, unfolding
  the literal to `String.ofList` of the same cells.
* `tokens : List T`, as chunks `toks0 ++ (toks1 ++ ...)`, and
  `lex_eq : lex chars = tokens`. Chunk theorems `lex<j>` state that the
  lexer, started in its state at chunk `j` (fuel, line-break and
  regular-expression flags, template depths and the remaining input
  `rest<j>`, a shared suffix of `chars`), emits `toks<j>` and reaches the
  state of chunk `j + 1`. Each is a separate kernel check, which bounds the
  kernel's caches: lexing and parsing the 170 KB graph file in one check
  peaks at 15 GB, its parse alone at 8 GB.
* `parsed : Module` and `parse_tokens : parseTokens tokens = .inl parsed`,
  in one check for a small file and in bounded steps otherwise (see
  *Parse checks* below), and `parsesTokens : (parseTokens tokens).isLeft = true`.

Everything is added with `addDecl` and checked by the kernel alone: the
elaborator evaluates the lexer natively only to choose the chunk states
and tokens, which the kernel then re-derives. A wrong choice fails the
kernel check; it cannot produce a false theorem. -/

deriving instance Lean.ToExpr for Host.Ts.Kw
deriving instance Lean.ToExpr for Host.Ts.P
deriving instance Lean.ToExpr for Host.Ts.BinOp
deriving instance Lean.ToExpr for Host.Ts.LogOp
deriving instance Lean.ToExpr for Host.Ts.AsgOp
deriving instance Lean.ToExpr for Host.Ts.Tok
deriving instance Lean.ToExpr for Host.Ts.T
deriving instance Lean.ToExpr for Host.Ts.UnOp
deriving instance Lean.ToExpr for Host.Ts.Lit
deriving instance Lean.ToExpr for Host.Ts.DeclKind
deriving instance Lean.ToExpr for Host.Ts.MethodKind
deriving instance Lean.ToExpr for Host.Ts.Expr, Host.Ts.Elem, Host.Ts.Key, Host.Ts.Property, Host.Ts.Pat,
  Host.Ts.Body, Host.Ts.Func, Host.Ts.Member, Host.Ts.Class, Host.Ts.ForHead, Host.Ts.Stmt
deriving instance Lean.ToExpr for Host.Ts.Spec
deriving instance Lean.ToExpr for Host.Ts.Item
deriving instance BEq for Host.Ts.Kw, Host.Ts.P, Host.Ts.BinOp, Host.Ts.LogOp, Host.Ts.AsgOp, Host.Ts.Tok, Host.Ts.T
deriving instance Inhabited for Host.Ts.Tok, Host.Ts.T

/-- Tokens per lexer chunk theorem. -/
def chunkTokens : Nat := 2000

def charCells (cs : List Char) : Lean.Expr :=
  cs.foldr (fun c acc => mkApp3 (mkConst ``List.cons [.zero]) (mkConst ``Char)
    (mkApp (mkConst ``Char.ofNat) (mkRawNatLit c.toNat)) acc)
    (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Char))

/-- The `n`-th tail of an explicit list expression, sharing its cells. -/
private partial def dropCells : Nat → Lean.Expr → Lean.Expr
  | 0, e => e
  | n + 1, e => dropCells n e.appArg!

/-- One native lexer step: tokens it emits and the next state, or `none` at
the end of input. -/
private def step (nl re : Bool) (d : List Nat) (cs : List Char) :
    Except String (List T × Option (Bool × Bool × List Nat × List Char)) :=
  let marker : K := fun nl re d cs => [.mk nl (.err cs), .mk re (.num (d.map Char.ofNat))]
  let rec split : List T → List T → Except String (List T × Option (Bool × Bool × List Nat × List Char))
    | acc, [.mk nl (.err cs), .mk re (.num d)] => .ok (acc.reverse, some (nl, re, d.map Char.toNat, cs))
    | _, [.mk _ (.err cs)] => .error s!"lexical error at: {String.ofList (cs.take 60)}"
    | acc, t :: ts => split (t :: acc) ts
    | acc, [] => .ok (acc.reverse, none)
  split [] (lexStep marker nl re d cs)

structure Chunk where
  fuel : Nat
  nl : Bool
  re : Bool
  depth : List Nat
  /-- Characters consumed before the chunk. -/
  offset : Nat
  toks : List T
deriving Inhabited

/-- Chunks of about `chunkTokens` tokens, each starting after a token. -/
private partial def chunks (n : Nat) (cs : List Char) : Except String (List Chunk) :=
  let rec go (fuel : Nat) (nl re : Bool) (d : List Nat) (cs : List Char)
      (start : Chunk) (count : Nat) (acc : List T) (out : List Chunk) : Except String (List Chunk) := do
    match fuel with
    | 0 => throw "lexer fuel exhausted"
    | fuel + 1 =>
      let (ts, next) ← step nl re d cs
      let acc := ts.reverse ++ acc
      let count := count + ts.length
      match next with
      | none => pure ({ start with toks := acc.reverse } :: out).reverse
      | some (nl', re', d', cs') =>
        if count ≥ chunkTokens && !ts.isEmpty then
          let c := { start with toks := acc.reverse }
          go fuel nl' re' d' cs' ⟨fuel, nl', re', d', n - cs'.length, []⟩ 0 [] (c :: out)
        else go fuel nl' re' d' cs' start count acc out
  go (n + 1) true true [] cs ⟨n + 1, true, true, [], 0, []⟩ 0 [] []

private def listTy (α : Lean.Expr) : Lean.Expr := mkApp (mkConst ``List [.zero]) α
private def tTy : Lean.Expr := mkConst ``T

private def addDef (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl <| .defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }

register_option hostTs.traceChecks : Bool := {
  defValue := false, descr := "print each kernel-checked parse theorem with its check time" }

/-- With `hostTs.traceChecks`, each theorem is checked synchronously and its
name, check time and the process's resident memory after it are appended to
`/tmp/host-ts-checks.txt`. -/
private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit := do
  let decl := Declaration.thmDecl { name, levelParams := [], type, value }
  if hostTs.traceChecks.get (← getOptions) then
    let h ← IO.FS.Handle.mk "/tmp/host-ts-checks.txt" .append
    h.putStrLn s!"check {name}"; h.flush
    let t₀ ← IO.monoMsNow
    withOptions (Elab.async.set · false) (addDecl decl)
    let dt := (← IO.monoMsNow) - t₀
    let ps ← IO.Process.output { cmd := "ps", args := #["-o", "rss=", "-p", toString (← IO.Process.getPID)] }
    h.putStrLn s!"  {dt} ms {ps.stdout.trimAscii.toString.toNat! / 1024} MB"; h.flush
  else addDecl decl

private def eqE (α a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``Eq [.succ .zero]) α a b
private def appendE (a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``List.append [.zero]) tTy a b

/-! ## Parse checks

A file of at most `hostTs.parseWhole` tokens is parsed in one check. A larger
one is parsed in steps (`Run`): module items, and inside an item that is
too large the class members or function-body statements it contains, each
chunk of steps covering at most `hostTs.parseChunk` tokens. A step whose
nested list is chunked separately is checked in three parts: `hdr` shows,
for an arbitrary member/statement-list parser `M` installed `k` grammar
levels down, that the step calls `M` only at the list's start; the
list's own run gives the real parser's result there; and `fin` evaluates
the step with that result. -/

register_option hostTs.parseWhole : Nat := {
  defValue := 2000, descr := "files with at most this many tokens are parsed in one kernel check" }
register_option hostTs.parseChunk : Nat := {
  defValue := 2000, descr := "tokens per parse chunk theorem of a larger file" }

private inductive Kind where | item | member | stmt
deriving Inhabited, BEq

/-- Step parser: `itemP (knot lvl)`, `memberP (knot lvl)` or `(knot lvl).stmt`. -/
private structure EP where
  kind : Kind
  lvl : Nat
deriving Inhabited

private inductive Field where | stmts | members
deriving Inhabited, BEq

private def knotE (n : Nat) : Lean.Expr := mkApp (mkConst ``knot) (mkRawNatLit n)
private def tsTy : Lean.Expr := listTy tTy
private def optTy (α : Lean.Expr) : Lean.Expr := mkApp (mkConst ``Option [.zero]) α
private def prodTy (α β : Lean.Expr) : Lean.Expr := mkApp2 (mkConst ``Prod [.zero, .zero]) α β
private def rTy (α : Lean.Expr) : Lean.Expr := optTy (prodTy α tsTy)
private def someE (α a : Lean.Expr) : Lean.Expr := mkApp2 (mkConst ``Option.some [.zero]) α a
private def noneE (α : Lean.Expr) : Lean.Expr := mkApp (mkConst ``Option.none [.zero]) α
private def pairE (α β a b : Lean.Expr) : Lean.Expr := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) α β a b
private def reflE (α a : Lean.Expr) : Lean.Expr := mkApp2 (mkConst ``Eq.refl [.succ .zero]) α a
private def transE (α a b c h₁ h₂ : Lean.Expr) : Lean.Expr := mkAppN (mkConst ``Eq.trans [.succ .zero]) #[α, a, b, c, h₁, h₂]
private def congrE (α β a b f h : Lean.Expr) : Lean.Expr :=
  mkAppN (mkConst ``congrArg [.succ .zero, .succ .zero]) #[α, β, a, b, f, h]
private def natAddE (a b : Lean.Expr) : Lean.Expr := mkApp2 (mkConst ``Nat.add) a b
/-- Proof of `n < f` for closed numerals, by `Nat.ble`. -/
private def ltE (n f : Lean.Expr) : Lean.Expr :=
  mkApp3 (mkConst ``Nat.le_of_ble_eq_true) (mkApp (mkConst ``Nat.succ) n) f (reflE (mkConst ``Bool) (mkConst ``Bool.true))

namespace EP
private def elemTy (ep : EP) : Lean.Expr :=
  match ep.kind with | .item => mkConst ``Item | .member => mkConst ``Member | .stmt => mkConst ``Stmt
/-- `p` as the loop lemmas state it. -/
private def pE (ep : EP) : Lean.Expr :=
  match ep.kind with
  | .item => mkApp (mkConst ``itemP) (knotE ep.lvl)
  | .member => mkApp (mkConst ``memberP) (knotE ep.lvl)
  | .stmt => mkApp (mkConst ``Rec.stmt) (knotE ep.lvl)
/-- `p ≡ f (knot fLvl)`. -/
private def fLvl (ep : EP) : Nat := match ep.kind with | .stmt => ep.lvl - 1 | _ => ep.lvl
private def fE (ep : EP) (r ts : Lean.Expr) : Lean.Expr :=
  match ep.kind with
  | .item => mkApp2 (mkConst ``itemP) r ts
  | .member => mkApp2 (mkConst ``memberP) r ts
  | .stmt => mkApp2 (mkConst ``stmtP) r ts
private def stopE (ep : EP) : Lean.Expr := match ep.kind with | .item => mkConst ``stopNil | _ => mkConst ``stopRc
private def stopN (ep : EP) (ts : Ts) : Bool := match ep.kind with | .item => stopNil ts | _ => stopRc ts
private def conv {α : Type} [ToExpr α] : R (Option α) → Option (Option Lean.Expr × Ts)
  | some (x, ts) => some (x.map toExpr, ts)
  | none => none
private def fN (ep : EP) (r : Rec) (ts : Ts) : Option (Option Lean.Expr × Ts) :=
  match ep.kind with
  | .item => conv (itemP r ts)
  | .member => conv (memberP r ts)
  | .stmt => conv (stmtP r ts)
end EP

namespace Field
private def elemTy : Field → Lean.Expr | .stmts => mkConst ``Stmt | .members => mkConst ``Member
private def resTy (F : Field) : Lean.Expr := rTy (listTy F.elemTy)
private def fnTy (F : Field) : Lean.Expr := mkForall `ts .default tsTy F.resTy
private def withE (F : Field) (r m : Lean.Expr) : Lean.Expr :=
  mkApp2 (mkConst (match F with | .stmts => ``Rec.withStmts | .members => ``Rec.withMembers)) r m
private def projE (F : Field) (r : Lean.Expr) : Lean.Expr :=
  mkApp (mkConst (match F with | .stmts => ``Rec.stmts | .members => ``Rec.members)) r
/-- Elements of the list `(knot base).F` parses. -/
private def inner (F : Field) (base : Nat) : EP :=
  match F with | .stmts => ⟨.stmt, base - 1⟩ | .members => ⟨.member, base - 1⟩
private def lemma : Field → Lean.Name | .stmts => ``stmtsLoop_run | .members => ``membersLoop_run
end Field

/-- `mkRec^[k] ((knot base).withF M)`. -/
private def patchE (F : Field) (k base : Nat) (m : Lean.Expr) : Lean.Expr :=
  k.repeat (mkApp (mkConst ``mkRec)) (F.withE (knotE base) m)

private inductive Plan where
  /-- Steps of `ep` from token `a` to its stop at token `e`. -/
  | run (ep : EP) (a e : Nat) (steps : Array Plan)
  /-- One step `a → b` producing `x`, checked by evaluation. -/
  | atom (a b : Nat) (x : Option Lean.Expr)
  /-- A step `a → b` producing `x`, whose `F` list at `c` (result `v`) is the run `inner`. -/
  | split (a b : Nat) (x : Lean.Expr) (F : Field) (k base c : Nat) (v : Lean.Expr) (inner : Plan)
deriving Inhabited

private def Plan.a : Plan → Nat | .run _ a _ _ => a | .atom a _ _ => a | .split a .. => a
private def Plan.b : Plan → Nat | .run _ _ e _ => e | .atom _ b _ => b | .split _ b .. => b

private structure PlanCx where
  toks : Array T
  n : Nat
  chunk : Nat

private def PlanCx.drop (cx : PlanCx) (i : Nat) : Ts := (cx.toks.extract i cx.n).toList

/-- Returns the grammar with the field-`F` list parser answering only at
input length `len`, the same grammar with that parser always failing, the
list and the input after it. -/
private def patchN (F : Field) (k : Nat) (base : Rec) (len : Nat) (cTs : Ts) : Option (Rec × Rec × Lean.Expr × Ts) :=
  match F with
  | .stmts => match base.stmts cTs with
    | some (v, rest) => some (k.repeat mkRec (base.withStmts fun ts => bif ts.length == len then some (v, rest) else none),
        k.repeat mkRec (base.withStmts fun _ => none), toExpr v, rest)
    | none => none
  | .members => match base.members cTs with
    | some (v, rest) => some (k.repeat mkRec (base.withMembers fun ts => bif ts.length == len then some (v, rest) else none),
        k.repeat mkRec (base.withMembers fun _ => none), toExpr v, rest)
    | none => none

private def sameRes (cx : PlanCx) : Option (Option Lean.Expr × Ts) → Option (Option Lean.Expr × Ts) → Bool
  | some (x, ts), some (y, us) => x == y && ts.length == us.length && ts.length ≤ cx.n
  | _, _ => false

mutual
/-- Steps from `a` until `ep` stops. -/
private partial def planRun (cx : PlanCx) (ep : EP) (a : Nat) : Except String Plan := do
  let r := knot ep.fLvl
  let mut pos := a
  let mut steps : Array Plan := #[]
  repeat
    let ts := cx.drop pos
    if ep.stopN ts then break
    let some (x, rest) := ep.fN r ts | throw s!"parse error at token {pos}"
    let b := cx.n - rest.length
    unless b > pos && rest == cx.drop b do throw s!"step at token {pos} does not end at a token suffix"
    if b - pos > cx.chunk then
      match ← trySplit cx ep pos b x with
      | some sp => steps := steps.push sp
      | none => steps := steps.push (.atom pos b x)
    else steps := steps.push (.atom pos b x)
    pos := b
  return .run ep a pos steps

/-- A nested list of a large step to check separately, if one is found. -/
private partial def trySplit (cx : PlanCx) (ep : EP) (a b : Nat) (x : Option Lean.Expr) :
    Except String (Option Plan) := do
  let some xE := x | return none
  let cands := ((List.range (b - a)).map (a + ·)).filter fun i =>
    i > a && match cx.toks[i - 1]? with | some (.mk _ (.p .lc)) => true | _ => false
  for c in cands.take 64 do
    for F in [Field.members, .stmts] do
      for k in [0, 1, 2] do
        if k + 2 > ep.fLvl then continue
        let base := ep.fLvl - k
        let some (pr, dead, vE, rest) := patchN F k (knot base) (cx.n - c) (cx.drop c) | continue
        -- The step must call the list parser there, and nowhere else that matters.
        if !sameRes cx (ep.fN pr (cx.drop a)) (some (x, cx.drop b)) then continue
        if (ep.fN dead (cx.drop a)).isSome then continue
        let inner ← planRun cx (F.inner base) c
        let rc := inner.b
        unless rest.length + rc + 1 == cx.n do continue
        return some (.split a b xE F k base c vE inner)
  return none
end

/-- Token positions that get a suffix constant. -/
private partial def Plan.positions : Plan → Array Nat → Array Nat
  | .run ep a e steps, acc =>
    let acc := (acc.push a).push e
    let acc := match ep.kind with | .item => acc | _ => acc.push (e + 1)
    steps.foldl (fun acc s => s.positions acc) acc
  | .atom a b _, acc => (acc.push a).push b
  | .split a b _ _ _ _ c _ inner, acc => inner.positions (((acc.push a).push b).push c)

private structure EmitSt where
  next : Nat := 0

private abbrev EmitM := StateT EmitSt CoreM

private structure EmitCx where
  ns : Lean.Name
  toks : Array T
  chunk : Nat

private def tsE (cx : EmitCx) (i : Nat) : Lean.Expr := mkConst (cx.ns ++ .mkSimple s!"pts{i}")

private def fresh (cx : EmitCx) (pre : String) : EmitM Lean.Name := do
  let i := (← get).next
  modify fun s => { s with next := i + 1 }
  return cx.ns ++ .mkSimple s!"{pre}{i}"

private def runTy (ep : EP) (a xs b n : Lean.Expr) : Lean.Expr :=
  mkAppN (mkConst ``Run) #[ep.elemTy, ep.pE, ep.stopE, a, xs, b, n]

private def stepRes (ep : EP) (x : Option Lean.Expr) (b : Lean.Expr) : Lean.Expr :=
  let oα := optTy ep.elemTy
  someE (prodTy oα tsTy) (pairE oα tsTy (match x with | some x => someE ep.elemTy x | none => noneE ep.elemTy) b)

private def emitThm (n : Lean.Name) (ty pf : Lean.Expr) : EmitM Unit := liftM (addThm n ty pf : CoreM Unit)
private def emitDef (n : Lean.Name) (ty v : Lean.Expr) : EmitM Unit := liftM (addDef n ty v : CoreM Unit)

/-- `Run.some` / `Run.none` of one step onto `acc : Run p stop b xs e n`. -/
private def consStep (ep : EP) (a b e : Lean.Expr) (x : Option Lean.Expr) (xs n hp acc : Lean.Expr) : Lean.Expr :=
  let hs := reflE (mkConst ``Bool) (mkConst ``Bool.false)
  match x with
  | some x => mkAppN (mkConst ``Run.some) #[ep.elemTy, ep.pE, ep.stopE, a, b, e, x, xs, n, hs, hp, acc]
  | none => mkAppN (mkConst ``Run.none) #[ep.elemTy, ep.pE, ep.stopE, a, b, e, xs, n, hs, hp, acc]

/-- `e` in the kernel's head normal form, with the major premise of a stuck
recursor (or projection) normalized in turn: a stuck evaluation reduced
down to the free variable application it waits on. -/
private partial def normStuck (env : Lean.Environment) (lctx : LocalContext) : Nat → Lean.Expr → Except String Lean.Expr
  | 0, _ => .error "stuck term too deep"
  | fuel + 1, e => do
    let e ← match Kernel.whnf env lctx e with
      | .ok e => pure e
      | .error _ => throw "kernel whnf failed"
    match e with
    | .proj s i b => return .proj s i (← normStuck env lctx fuel b)
    | _ =>
      let .const c _ := e.getAppFn | return e
      let some (.recInfo r) := env.find? c | return e
      let args := e.getAppArgs
      let i := r.getMajorIdx
      if h : i < args.size then return mkAppN e.getAppFn (args.set i (← normStuck env lctx fuel args[i]))
      return e

mutual
/-- Emits the run's chunk theorems; returns its element list, step count and `Run` proof. -/
private partial def emitRun (cx : EmitCx) : Plan → EmitM (Lean.Expr × Lean.Expr × Lean.Expr)
  | .run ep a e steps => do
    -- Chunks: maximal groups of atoms within the budget; a split step alone.
    let mut groups : Array (Array Plan) := #[]
    let mut cur : Array Plan := #[]
    let mut size := 0
    for s in steps do
      match s with
      | .split .. =>
        if !cur.isEmpty then groups := groups.push cur
        groups := groups.push #[s]; cur := #[]; size := 0
      | _ =>
        if !cur.isEmpty && size + (s.b - s.a) > cx.chunk then
          groups := groups.push cur; cur := #[]; size := 0
        cur := cur.push s; size := size + (s.b - s.a)
    if !cur.isEmpty then groups := groups.push cur
    let lα := listTy ep.elemTy
    let mut parts : Array (Lean.Expr × Lean.Expr × Lean.Expr × Nat × Nat) := #[]
    for g in groups do
      let ga := g[0]!.a
      let gb := g[g.size - 1]!.b
      -- Steps of the group, last first, over explicit element lists.
      let mut acc := mkAppN (mkConst ``Run.nil) #[ep.elemTy, ep.pE, ep.stopE, tsE cx gb]
      let mut xs := mkApp (mkConst ``List.nil [.zero]) ep.elemTy
      let mut k := 0
      for s in g.reverse do
        let (x, hp) ← match s with
          | .atom _ b x => pure (x, reflE (rTy (optTy ep.elemTy)) (stepRes ep x (tsE cx b)))
          | .split .. => do let (x, h) ← emitSplit cx ep s; pure (some x, h)
          | .run .. => throwError "nested run in a step list"
        acc := consStep ep (tsE cx s.a) (tsE cx s.b) (tsE cx gb) x xs (mkRawNatLit k) hp acc
        if let some x := x then xs := mkApp3 (mkConst ``List.cons [.zero]) ep.elemTy x xs
        k := k + 1
      let xsN ← fresh cx "pxs"
      emitDef xsN lα xs
      let thmN ← fresh cx "prun"
      if hostTs.traceChecks.get (← getOptions) then
        let h ← IO.FS.Handle.mk "/tmp/host-ts-checks.txt" .append
        h.putStrLn s!"chunk {thmN}: tokens {ga}..{gb} ({gb - ga}), {g.size} steps"; h.flush
      emitThm thmN (runTy ep (tsE cx ga) (mkConst xsN) (tsE cx gb) (mkRawNatLit k)) acc
      parts := parts.push (mkConst xsN, mkRawNatLit k, mkConst thmN, ga, gb)
    if parts.isEmpty then
      return (mkApp (mkConst ``List.nil [.zero]) ep.elemTy, mkRawNatLit 0, mkAppN (mkConst ``Run.nil) #[ep.elemTy, ep.pE, ep.stopE, tsE cx a])
    -- Compose right to left with `Run.append`.
    let (xs₀, n₀, h₀, _, _) := parts[parts.size - 1]!
    let mut xs := xs₀
    let mut n := n₀
    let mut h := h₀
    for i' in [0:parts.size - 1] do
      let i := parts.size - 2 - i'
      let (xsi, ni, hi, ai, bi) := parts[i]!
      h := mkAppN (mkConst ``Run.append) #[ep.elemTy, ep.pE, ep.stopE, tsE cx ai, tsE cx bi, tsE cx e, xsi, xs, ni, n, hi, h]
      xs := mkApp3 (mkConst ``List.append [.zero]) ep.elemTy xsi xs
      n := natAddE ni n
    let allN ← fresh cx "prunAll"
    emitThm allN (runTy ep (tsE cx a) xs (tsE cx e) n) h
    return (xs, n, mkConst allN)
  | _ => throwError "expected a run"

/-- Emits a split step's theorems; returns its element and step proof. -/
private partial def emitSplit (cx : EmitCx) (ep : EP) : Plan → EmitM (Lean.Expr × Lean.Expr)
  | .split a b x F k base c v inner => do
    let (xsI, nI, hI) ← emitRun cx inner
    let rc := inner.b
    let nl := (cx.toks[rc]!).nl
    let tsc := tsE cx c
    let tse := tsE cx (rc + 1)
    let resF := F.resTy
    let vRes := someE (prodTy (listTy F.elemTy) tsTy) (pairE (listTy F.elemTy) tsTy xsI tse)
    -- Inner list: `(knot base).F ts_c = some (xsI, ts_e)`.
    let innerN ← fresh cx "pinner"
    emitThm innerN (eqE resF (mkApp (F.projE (knotE base)) tsc) vRes)
      (mkAppN (mkConst F.lemma) #[knotE (base - 1), tsc, tse, toExpr nl, xsI, nI, mkConst ``loopFuel, hI,
        ltE nI (mkConst ``loopFuel)])
    let x' := x.replace fun e => if e == v then some xsI else none
    let sα := rTy (optTy ep.elemTy)
    let tsa := tsE cx a
    -- The step's stuck normal form `N[M]` for a free list parser `M`: the
    -- kernel's head normal form with the major premises of stuck recursors
    -- normalized, down to the one call `M ts_c`.
    let mId : FVarId := ⟨`_hostTsM⟩
    let yId : FVarId := ⟨`_hostTsY⟩
    let lctx := (LocalContext.empty.mkLocalDecl mId `M F.fnTy).mkLocalDecl yId `y resF
    let m := Lean.Expr.fvar mId
    let lhsM := ep.fE (patchE F k base m) tsa
    let env ← getEnv
    let n ← match normStuck env lctx 64 lhsM with
      | .ok n => pure n
      | .error e => throwError "split at token {a}: {e}"
    let isCall (e : Lean.Expr) : Bool := match e with | .app (.fvar f) _ => f == mId | _ => false
    let some (.app _ tsc') := n.find? isCall | throwError "split at token {a}: no list call"
    let nY := n.replace fun e => if isCall e then some (.fvar yId) else none
    unless nY.replaceFVar (.fvar yId) (mkApp m tsc') == n do throwError "split at token {a}: list calls differ"
    -- `K M y`: the normal form with the call replaced by `y`.
    let kFn := Lean.mkLambda `M .default F.fnTy (Lean.mkLambda `y .default resF ((nY.abstract #[m, .fvar yId])))
    -- `hdr : ∀ M, f (P M) ts_a = K M (M ts_c)`.
    let hdrN ← fresh cx "phdr"
    if hostTs.traceChecks.get (← getOptions) then
      let h ← IO.FS.Handle.mk "/tmp/host-ts-checks.txt" .append
      h.putStrLn s!"split {hdrN}: step {a}..{b}, {if F == .members then "members" else "statements"} {c}..{rc}"; h.flush
    let lhsAbs := lhsM.abstract #[m]
    emitThm hdrN (.forallE `M F.fnTy (eqE sα lhsAbs (mkApp2 kFn (.bvar 0) (mkApp (.bvar 0) (tsc'.abstract #[m])))) .default)
      (.lam `M F.fnTy (reflE sα lhsAbs) .default)
    -- `fin : K real (some (xsI, ts_e)) = some (some x', ts_b)`.
    let proj := F.projE (knotE base)
    let finN ← fresh cx "pfin"
    let finL := mkApp2 kFn proj vRes
    let res := stepRes ep (some x') (tsE cx b)
    emitThm finN (eqE sα finL res) (reflE sα res)
    -- The step, through the real list parser.
    let real := ep.fE (patchE F k base proj) tsa
    let mid := mkApp2 kFn proj (mkApp proj tsc')
    let stepN ← fresh cx "pstep"
    emitThm stepN (eqE sα (mkApp ep.pE tsa) res)
      (transE sα real mid res (mkApp (mkConst hdrN) proj)
        (transE sα mid finL res (congrE resF sα (mkApp proj tsc') vRes (mkApp kFn proj) (mkConst innerN)) (mkConst finN)))
    return (x', mkConst stepN)
  | _ => throwError "expected a split step"
end

/-- The parse check of a large file: `pts<i>` token suffixes, `tokens_flat`,
the run of items and `parse_tokens`. -/
private def emitChunked (ns : Lean.Name) (toks : Array T) (chunk : Nat) : CoreM Unit := do
  let cx : PlanCx := ⟨toks, toks.size, chunk⟩
  let plan ← match planRun cx ⟨.item, depthFuel⟩ 0 with
    | .ok p => pure p
    | .error e => throwError e
  let pos := ((plan.positions #[0, toks.size]).qsort (· < ·)).toList.eraseDups.toArray
  let tokE := toks.map toExpr
  let ecx : EmitCx := ⟨ns, toks, chunk⟩
  -- Suffix constants, last first: each is its tokens up to the next one.
  addDef (ns ++ .mkSimple s!"pts{toks.size}") tsTy (mkApp (mkConst ``List.nil [.zero]) tTy)
  for j' in [0:pos.size - 1] do
    let j := pos.size - 2 - j'
    let (i, i') := (pos[j]!, pos[j + 1]!)
    let cells := (List.range (i' - i)).foldr (fun d acc => mkApp3 (mkConst ``List.cons [.zero]) tTy tokE[i + d]! acc) (tsE ecx i')
    addDef (ns ++ .mkSimple s!"pts{i}") tsTy cells
  addThm (ns ++ `tokens_flat) (eqE tsTy (mkConst (ns ++ `tokens)) (tsE ecx 0)) (reflE tsTy (tsE ecx 0))
  let ((xs, n, h), _) ← (emitRun ecx plan).run {}
  let modTy := listTy (mkConst ``Item)
  addDef (ns ++ `parsed) modTy xs
  let sumTy := mkApp2 (mkConst ``Sum [.zero, .zero]) modTy tsTy
  let loopE (t : Lean.Expr) := mkApp4 (mkConst ``itemsLoop) (knotE depthFuel) (mkConst ``loopFuel) (mkApp (mkConst ``List.nil [.zero]) (mkConst ``Item)) t
  let inl := mkApp3 (mkConst ``Sum.inl [.zero, .zero]) modTy tsTy (mkConst (ns ++ `parsed))
  let run := mkAppN (mkConst ``itemsLoop_run) #[knotE depthFuel, tsE ecx 0, mkConst (ns ++ `parsed), n, mkConst ``loopFuel, h, ltE n (mkConst ``loopFuel)]
  addThm (ns ++ `parse_tokens) (eqE sumTy (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens))) inl)
    (transE sumTy (loopE (mkConst (ns ++ `tokens))) (loopE (tsE ecx 0)) inl
      (congrE tsTy sumTy (mkConst (ns ++ `tokens)) (tsE ecx 0) (Lean.mkLambda `t .default tsTy (loopE (.bvar 0))) (mkConst (ns ++ `tokens_flat)))
      run)

elab "source_parse " src:ident : command => do
  let ns ← getCurrNamespace
  let src := ns ++ src.getId
  let some (.defnInfo d) := (← getEnv).find? src | throwError "unknown source {src}"
  let .lit (.strVal text) := d.value | throwError "{src} is not a string literal"
  let cs := text.toList
  let n := cs.length
  let cells := charCells cs
  let charsN := ns ++ `chars
  let whole := hostTs.parseWhole.get (← getOptions)
  let chunk := hostTs.parseChunk.get (← getOptions)
  liftCoreM do
    addDef charsN (listTy (mkConst ``Char)) cells
    addThm (charsN ++ `eq) (eqE (listTy (mkConst ``Char)) (mkApp (mkConst ``String.toList) (mkConst src)) (mkConst charsN))
      (mkApp (mkConst ``String.toList_ofList) cells)
  let parts ← match chunks n cs with
    | .ok ps => pure ps.toArray
    | .error e => throwError e
  let allToks := parts.toList.flatMap (·.toks)
  let mod ← match parseTokens allToks with
    | .inl m => pure m
    | .inr rest => throwError "parse error at {rest.length} tokens before the end"
  let m := parts.size
  let restE (j : Nat) : Lean.Expr := if j = 0 then mkConst charsN else mkConst (ns ++ .mkSimple s!"rest{j}")
  let state (j : Nat) : Lean.Expr :=
    let c := parts[j]!
    mkAppN (mkConst ``lexAux) #[mkRawNatLit c.fuel, toExpr c.nl, toExpr c.re, toExpr c.depth, restE j]
  let toksE (j : Nat) : Lean.Expr := mkConst (ns ++ .mkSimple s!"toks{j}")
  liftCoreM do
    for j in [0:m] do
      let c := parts[j]!
      if j > 0 then addDef (ns ++ .mkSimple s!"rest{j}") (listTy (mkConst ``Char)) (dropCells c.offset cells)
      addDef (ns ++ .mkSimple s!"toks{j}") (listTy tTy) (toExpr c.toks)
    -- Chunk theorems, last first: `lex<j> : state j = toks<j> ++ state (j+1)`.
    for j in [0:m] do
      let rhs := if j + 1 = m then toksE j else appendE (toksE j) (state (j + 1))
      addThm (ns ++ .mkSimple s!"lex{j}") (eqE (listTy tTy) (state j) rhs)
        (mkApp2 (mkConst ``Eq.refl [.succ .zero]) (listTy tTy) (state j))
    -- tokens = toks0 ++ (toks1 ++ ... toks<m-1>), lex_eq by chaining.
    let mut tail := toksE (m - 1)
    let mut proof := mkConst (ns ++ .mkSimple s!"lex{m - 1}")
    for j' in [0:m - 1] do
      let j := m - 2 - j'
      let prev := tail
      tail := appendE (toksE j) tail
      proof := mkApp6 (mkConst ``Eq.trans [.succ .zero]) (listTy tTy) (state j)
        (appendE (toksE j) (state (j + 1))) tail (mkConst (ns ++ .mkSimple s!"lex{j}"))
        (mkApp6 (mkConst ``congrArg [.succ .zero, .succ .zero]) (listTy tTy) (listTy tTy)
          (state (j + 1)) prev (mkApp2 (mkConst ``List.append [.zero]) tTy (toksE j)) proof)
    addDef (ns ++ `tokens) (listTy tTy) tail
    addThm (ns ++ `lex_eq) (eqE (listTy tTy) (mkApp (mkConst ``lex) (mkConst charsN)) (mkConst (ns ++ `tokens))) proof
    let modTy := listTy (mkConst ``Item)
    let sumTy := mkApp2 (mkConst ``Sum [.zero, .zero]) modTy (listTy tTy)
    let inl := mkApp3 (mkConst ``Sum.inl [.zero, .zero]) modTy (listTy tTy) (mkConst (ns ++ `parsed))
    if allToks.length ≤ whole then
      addDef (ns ++ `parsed) modTy (toExpr mod)
      addThm (ns ++ `parse_tokens) (eqE sumTy (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens))) inl) (reflE sumTy inl)
    else emitChunked ns allToks.toArray chunk
    let isLeft (x : Lean.Expr) := mkApp3 (mkConst ``Sum.isLeft [.zero, .zero]) modTy (listTy tTy) x
    let tru := mkConst ``Bool.true
    addThm (ns ++ `parsesTokens) (eqE (mkConst ``Bool) (isLeft (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens)))) tru)
      (transE (mkConst ``Bool) (isLeft (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens)))) (isLeft inl) tru
        (congrE sumTy (mkConst ``Bool) (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens))) inl
          (mkApp2 (mkConst ``Sum.isLeft [.zero, .zero]) modTy (listTy tTy)) (mkConst (ns ++ `parse_tokens)))
        (reflE (mkConst ``Bool) tru))


/-- `chars!"abc"`: the character list `['a', 'b', 'c']` as explicit cells. -/
elab:max "chars!" s:str : term => return charCells s.getString.toList

/-- `source_chars c s`: only `c` and `c.eq : s.toList = c`, for small test literals. -/
elab "source_chars " c:ident src:ident : command => do
  let ns ← getCurrNamespace
  let src := ns ++ src.getId
  let some (.defnInfo d) := (← getEnv).find? src | throwError "unknown source {src}"
  let .lit (.strVal text) := d.value | throwError "{src} is not a string literal"
  let cells := charCells text.toList
  liftCoreM do
    addDef (ns ++ c.getId) (listTy (mkConst ``Char)) cells
    addThm (ns ++ c.getId ++ `eq) (eqE (listTy (mkConst ``Char)) (mkApp (mkConst ``String.toList) (mkConst src)) (mkConst (ns ++ c.getId)))
      (mkApp (mkConst ``String.toList_ofList) cells)

/-- `kernel_rfl n : a = b` proves an equation by `Eq.refl a`, checked only
by the kernel (the elaborator does not reduce `a`). -/
elab "kernel_rfl " n:ident " : " t:term : command => do
  let ns ← getCurrNamespace
  liftTermElabM do
    let ty ← Term.elabType t
    Term.synthesizeSyntheticMVarsNoPostponing
    let ty ← instantiateMVars ty
    let some (α, a, _) := ty.eq? | throwError "expected an equation"
    let u ← Meta.getLevel α
    addDecl (.thmDecl { name := ns ++ n.getId, levelParams := [], type := ty, value := mkApp2 (mkConst ``Eq.refl [u]) α a })

end Host.Ts
