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
  lexer, started in its state at chunk `j` (fuel, template depths and the
  remaining input `rest<j>`, a shared suffix of `chars`), emits `toks<j>`
  and reaches the state of chunk `j + 1`. Each is a separate kernel check,
  which bounds the kernel's caches: lexing and parsing the 170 KB graph file
  in one check peaks at 15 GB, the separate parse check at 8 GB.
* `parsesTokens : (parseTokens tokens).isLeft = true`.

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
private def step (nl : Bool) (d : List Nat) (cs : List Char) :
    Except String (List T × Option (Bool × List Nat × List Char)) :=
  let marker : K := fun nl d cs => [.mk nl (.err cs), .mk false (.num (d.map Char.ofNat))]
  let rec split : List T → List T → Except String (List T × Option (Bool × List Nat × List Char))
    | acc, [.mk nl (.err cs), .mk _ (.num d)] => .ok (acc.reverse, some (nl, d.map Char.toNat, cs))
    | _, [.mk _ (.err cs)] => .error s!"lexical error at: {String.ofList (cs.take 60)}"
    | acc, t :: ts => split (t :: acc) ts
    | acc, [] => .ok (acc.reverse, none)
  split [] (lexStep marker nl d cs)

structure Chunk where
  fuel : Nat
  nl : Bool
  depth : List Nat
  /-- Characters consumed before the chunk. -/
  offset : Nat
  toks : List T
deriving Inhabited

/-- Chunks of about `chunkTokens` tokens, each starting after a token. -/
private partial def chunks (n : Nat) (cs : List Char) : Except String (List Chunk) :=
  let rec go (fuel : Nat) (nl : Bool) (d : List Nat) (cs : List Char)
      (start : Chunk) (count : Nat) (acc : List T) (out : List Chunk) : Except String (List Chunk) := do
    match fuel with
    | 0 => throw "lexer fuel exhausted"
    | fuel + 1 =>
      let (ts, next) ← step nl d cs
      let acc := ts.reverse ++ acc
      let count := count + ts.length
      match next with
      | none => pure ({ start with toks := acc.reverse } :: out).reverse
      | some (nl', d', cs') =>
        if count ≥ chunkTokens && !ts.isEmpty then
          let c := { start with toks := acc.reverse }
          go fuel nl' d' cs' ⟨fuel, nl', d', n - cs'.length, []⟩ 0 [] (c :: out)
        else go fuel nl' d' cs' start count acc out
  go (n + 1) true [] cs ⟨n + 1, true, [], 0, []⟩ 0 [] []

private def listTy (α : Lean.Expr) : Lean.Expr := mkApp (mkConst ``List [.zero]) α
private def tTy : Lean.Expr := mkConst ``T

private def addDef (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl <| .defnDecl { name, levelParams := [], type, value, hints := .abbrev, safety := .safe }

private def addThm (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl <| .thmDecl { name, levelParams := [], type, value }

private def eqE (α a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``Eq [.succ .zero]) α a b
private def appendE (a b : Lean.Expr) : Lean.Expr := mkApp3 (mkConst ``List.append [.zero]) tTy a b

elab "source_parse " src:ident : command => do
  let ns ← getCurrNamespace
  let src := ns ++ src.getId
  let some (.defnInfo d) := (← getEnv).find? src | throwError "unknown source {src}"
  let .lit (.strVal text) := d.value | throwError "{src} is not a string literal"
  let cs := text.toList
  let n := cs.length
  let cells := charCells cs
  let charsN := ns ++ `chars
  liftCoreM do
    addDef charsN (listTy (mkConst ``Char)) cells
    addThm (charsN ++ `eq) (eqE (listTy (mkConst ``Char)) (mkApp (mkConst ``String.toList) (mkConst src)) (mkConst charsN))
      (mkApp (mkConst ``String.toList_ofList) cells)
  let parts ← match chunks n cs with
    | .ok ps => pure ps.toArray
    | .error e => throwError e
  match parseTokens (parts.toList.flatMap (·.toks)) with
  | .inl _ => pure ()
  | .inr rest => throwError "parse error at {rest.length} tokens before the end"
  let m := parts.size
  let restE (j : Nat) : Lean.Expr := if j = 0 then mkConst charsN else mkConst (ns ++ .mkSimple s!"rest{j}")
  let state (j : Nat) : Lean.Expr :=
    let c := parts[j]!
    mkAppN (mkConst ``lexAux) #[mkRawNatLit c.fuel, toExpr c.nl, toExpr c.depth, restE j]
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
    let isLeft := mkApp3 (mkConst ``Sum.isLeft [.zero, .zero]) (listTy (mkConst ``Item)) (listTy tTy)
      (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens)))
    addThm (ns ++ `parsesTokens) (eqE (mkConst ``Bool) isLeft (mkConst ``Bool.true))
      (mkApp2 (mkConst ``Eq.refl [.succ .zero]) (mkConst ``Bool) (mkConst ``Bool.true))

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
