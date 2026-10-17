import host.ts.Source
import Std.Data.HashMap
namespace Host.Ts
open Lean Elab Command

/-! # AST constants

`source_ast` (in a source module's namespace) parses `source` natively and
adds `ast : Module` with `parse_ast : parse source.toList = some ast`,
kernel-checked from `lex_eq`. Machine runs then start from the constant
instead of re-parsing in every check.

Every statement, function and class of the module is its own constant
(`ast_n<i>`, children first; structurally equal nodes share one), and
`ast` is the item list over them. A machine state holds AST nodes (closures
hold their function, frames the statements left in a block), and a
serialized state refers to them by these names (`AstTab`, `serStmt` …)
instead of copying source: states of a run stay small, and a kernel
comparison of two states meets the same constants. Native evaluation uses
`astNative`, the same module as one compiled constant (`implemented_by`). -/

deriving instance Hashable for Host.Ts.BinOp, Host.Ts.LogOp, Host.Ts.AsgOp
deriving instance BEq, Hashable for Host.Ts.Lit, Host.Ts.UnOp,
  Host.Ts.DeclKind, Host.Ts.MethodKind
deriving instance BEq, Hashable for Host.Ts.Expr, Host.Ts.Elem, Host.Ts.Key, Host.Ts.Property, Host.Ts.Pat,
  Host.Ts.Body, Host.Ts.Func, Host.Ts.Member, Host.Ts.Class, Host.Ts.ForHead, Host.Ts.Stmt

/-! ## Named AST nodes -/

/-- Constant names of AST nodes. -/
structure AstTab where
  stmts : Std.HashMap Stmt Lean.Name := {}
  funcs : Std.HashMap Func Lean.Name := {}
  classes : Std.HashMap Class Lean.Name := {}
deriving Inhabited

structure HoistSt where
  tab : AstTab := {}
  /-- Creation mode: the module namespace for new constants. -/
  pre : Option Lean.Name := none
  next : Nat := 0
  /-- New constants, newest first: name, type, value. -/
  decls : List (Lean.Name × Lean.Expr × Lean.Expr) := []

abbrev HoistM := StateM HoistSt

private def cE (n : Lean.Name) (args : List Lean.Expr) : Lean.Expr := mkAppN (mkConst n) args.toArray

private def listT (t : Lean.Expr) : Lean.Expr := mkApp (mkConst ``List [.zero]) t
private def optT (t : Lean.Expr) : Lean.Expr := mkApp (mkConst ``Option [.zero]) t
private def prodT (a b : Lean.Expr) : Lean.Expr := mkApp2 (mkConst ``Prod [.zero, .zero]) a b

private def listE (t : Lean.Expr) (es : List Lean.Expr) : Lean.Expr :=
  es.foldr (fun e acc => mkApp3 (mkConst ``List.cons [.zero]) t e acc) (mkApp (mkConst ``List.nil [.zero]) t)

private def optE (t : Lean.Expr) : Option Lean.Expr → Lean.Expr
  | some e => mkApp2 (mkConst ``Option.some [.zero]) t e
  | none => mkApp (mkConst ``Option.none [.zero]) t

private def pairE (a b : Lean.Expr) (x y : Lean.Expr) : Lean.Expr := mkApp4 (mkConst ``Prod.mk [.zero, .zero]) a b x y

private def tE : Lean.Expr := mkConst ``Expr
private def tElem : Lean.Expr := mkConst ``Elem
private def tKey : Lean.Expr := mkConst ``Key
private def tProp : Lean.Expr := mkConst ``Property
private def tPat : Lean.Expr := mkConst ``Pat
private def tFunc : Lean.Expr := mkConst ``Func
private def tMember : Lean.Expr := mkConst ``Member
private def tStmt : Lean.Expr := mkConst ``Stmt
private def tName : Lean.Expr := listT (mkConst ``Char)

private def nameE (n : Host.Ts.Name) : Lean.Expr := toExpr n
private def boolE (b : Bool) : Lean.Expr := toExpr b

private def listM {α : Type} (t : Lean.Expr) (f : α → HoistM Lean.Expr) (xs : List α) : HoistM Lean.Expr := do
  pure (listE t (← xs.mapM f))

private def optM {α : Type} (t : Lean.Expr) (f : α → HoistM Lean.Expr) : Option α → HoistM Lean.Expr
  | some x => do pure (optE t (some (← f x)))
  | none => pure (optE t none)

/-- Name node `x` (creation mode), or return its structural serialization `e`. -/
private def hoistWith {α : Type} [BEq α] [Hashable α] (sel : AstTab → Std.HashMap α Lean.Name)
    (upd : AstTab → Std.HashMap α Lean.Name → AstTab) (ty : Lean.Expr) (x : α) (e : Lean.Expr) : HoistM Lean.Expr := do
  let st ← get
  match st.pre with
  | none => pure e
  | some ns =>
    let n := ns ++ Lean.Name.mkSimple s!"ast_n{st.next}"
    set { st with tab := upd st.tab ((sel st.tab).insert x n), next := st.next + 1, decls := (n, ty, e) :: st.decls }
    pure (mkConst n)

mutual
partial def serExpr : Expr → HoistM Lean.Expr
  | .lit l => pure (cE ``Expr.lit [toExpr l])
  | .id n => pure (cE ``Expr.id [nameE n])
  | .this => pure (mkConst ``Expr.this)
  | .super => pure (mkConst ``Expr.super)
  | .template t qs ss => do pure (cE ``Expr.template [← optM tE serExpr t, toExpr qs, ← listM tE serExpr ss])
  | .array es => do pure (cE ``Expr.array [← listM tElem serElem es])
  | .object ps => do pure (cE ``Expr.object [← listM tProp serProp ps])
  | .func f => do pure (cE ``Expr.func [← serFunc f])
  | .arrow f => do pure (cE ``Expr.arrow [← serFunc f])
  | .cls c => do pure (cE ``Expr.cls [← serClass c])
  | .member o p opt => do pure (cE ``Expr.member [← serExpr o, nameE p, boolE opt])
  | .priv o p opt => do pure (cE ``Expr.priv [← serExpr o, nameE p, boolE opt])
  | .index o k opt => do pure (cE ``Expr.index [← serExpr o, ← serExpr k, boolE opt])
  | .call c as opt => do pure (cE ``Expr.call [← serExpr c, ← listM tElem serElem as, boolE opt])
  | .new c as => do pure (cE ``Expr.new [← serExpr c, ← listM tElem serElem as])
  | .chain e => do pure (cE ``Expr.chain [← serExpr e])
  | .unary op e => do pure (cE ``Expr.unary [toExpr op, ← serExpr e])
  | .update i p t => do pure (cE ``Expr.update [boolE i, boolE p, ← serExpr t])
  | .bin op a b => do pure (cE ``Expr.bin [toExpr op, ← serExpr a, ← serExpr b])
  | .log op a b => do pure (cE ``Expr.log [toExpr op, ← serExpr a, ← serExpr b])
  | .cond c a b => do pure (cE ``Expr.cond [← serExpr c, ← serExpr a, ← serExpr b])
  | .assign op t v => do pure (cE ``Expr.assign [toExpr op, ← serPat t, ← serExpr v])
  | .seq a b => do pure (cE ``Expr.seq [← serExpr a, ← serExpr b])
  | .yield a d => do pure (cE ``Expr.yield [← optM tE serExpr a, boolE d])
  | .await e => do pure (cE ``Expr.await [← serExpr e])

partial def serElem : Elem → HoistM Lean.Expr
  | .hole => pure (mkConst ``Elem.hole)
  | .expr e => do pure (cE ``Elem.expr [← serExpr e])
  | .spread e => do pure (cE ``Elem.spread [← serExpr e])

partial def serKey : Key → HoistM Lean.Expr
  | .id n => pure (cE ``Key.id [nameE n])
  | .str r => pure (cE ``Key.str [nameE r])
  | .num r => pure (cE ``Key.num [nameE r])
  | .priv n => pure (cE ``Key.priv [nameE n])
  | .computed e => do pure (cE ``Key.computed [← serExpr e])

partial def serProp : Property → HoistM Lean.Expr
  | .init k v => do pure (cE ``Property.init [← serKey k, ← serExpr v])
  | .short n => pure (cE ``Property.short [nameE n])
  | .method k key f => do pure (cE ``Property.method [toExpr k, ← serKey key, ← serFunc f])
  | .spread e => do pure (cE ``Property.spread [← serExpr e])

partial def serPat : Pat → HoistM Lean.Expr
  | .id n => pure (cE ``Pat.id [nameE n])
  | .expr e => do pure (cE ``Pat.expr [← serExpr e])
  | .array ps r => do pure (cE ``Pat.array [← listM (optT tPat) (optM tPat serPat) ps, ← optM tPat serPat r])
  | .object ps r => do
    pure (cE ``Pat.object [← listM (prodT tKey tPat) (fun (k, p) => do pure (pairE tKey tPat (← serKey k) (← serPat p))) ps,
      ← optM tPat serPat r])
  | .dflt p d => do pure (cE ``Pat.dflt [← serPat p, ← serExpr d])

partial def serBody : Body → HoistM Lean.Expr
  | .block ss => do pure (cE ``Body.block [← listM tStmt serStmt ss])
  | .expr e => do pure (cE ``Body.expr [← serExpr e])

partial def serFunc (f : Func) : HoistM Lean.Expr := do
  if let some n := (← get).tab.funcs[f]? then return mkConst n
  let .mk n ps r b a g pr := f
  let e := cE ``Func.mk [optE tName (n.map nameE), ← listM tPat serPat ps, ← optM tPat serPat r, ← serBody b,
    boolE a, boolE g, toExpr pr]
  hoistWith AstTab.funcs (fun t m => { t with funcs := m }) tFunc f e

partial def serMember : Member → HoistM Lean.Expr
  | .ctor f => do pure (cE ``Member.ctor [← serFunc f])
  | .method st k key f => do pure (cE ``Member.method [boolE st, toExpr k, ← serKey key, ← serFunc f])
  | .field st k i => do pure (cE ``Member.field [boolE st, ← serKey k, ← optM tE serExpr i])
  | .block ss => do pure (cE ``Member.block [← listM tStmt serStmt ss])

partial def serClass (c : Class) : HoistM Lean.Expr := do
  if let some n := (← get).tab.classes[c]? then return mkConst n
  let .mk n sup ms := c
  let e := cE ``Class.mk [optE tName (n.map nameE), ← optM tE serExpr sup, ← listM tMember serMember ms]
  hoistWith AstTab.classes (fun t m => { t with classes := m }) (mkConst ``Class) c e

partial def serForHead : ForHead → HoistM Lean.Expr
  | .decl k ds => do pure (cE ``ForHead.decl [toExpr k, ← serDecls ds])
  | .expr e => do pure (cE ``ForHead.expr [← serExpr e])

partial def serDecls (ds : List (Pat × Option Expr)) : HoistM Lean.Expr :=
  listM (prodT tPat (optT tE)) (fun (p, i) => do pure (pairE tPat (optT tE) (← serPat p) (← optM tE serExpr i))) ds

partial def serStmts (ss : List Stmt) : HoistM Lean.Expr := listM tStmt serStmt ss

partial def serStmt (st : Stmt) : HoistM Lean.Expr := do
  if let some n := (← get).tab.stmts[st]? then return mkConst n
  let e ← match st with
    | .expr e => do pure (cE ``Stmt.expr [← serExpr e])
    | .decl k ds => do pure (cE ``Stmt.decl [toExpr k, ← serDecls ds])
    | .func f => do pure (cE ``Stmt.func [← serFunc f])
    | .cls c => do pure (cE ``Stmt.cls [← serClass c])
    | .enum c n ms => do
      pure (cE ``Stmt.enum [boolE c, nameE n, ← listM (prodT tKey (optT tE))
        (fun (k, i) => do pure (pairE tKey (optT tE) (← serKey k) (← optM tE serExpr i))) ms])
    | .ret e => do pure (cE ``Stmt.ret [← optM tE serExpr e])
    | .if_ c t e => do pure (cE ``Stmt.if_ [← serExpr c, ← serStmt t, ← optM tStmt serStmt e])
    | .block ss => do pure (cE ``Stmt.block [← serStmts ss])
    | .for_ i t u b => do
      pure (cE ``Stmt.for_ [← optM (mkConst ``ForHead) serForHead i, ← optM tE serExpr t, ← optM tE serExpr u, ← serStmt b])
    | .forOf aw k p e b => do
      pure (cE ``Stmt.forOf [boolE aw, optE (mkConst ``DeclKind) (k.map toExpr), ← serPat p, ← serExpr e, ← serStmt b])
    | .forIn k p e b => do
      pure (cE ``Stmt.forIn [optE (mkConst ``DeclKind) (k.map toExpr), ← serPat p, ← serExpr e, ← serStmt b])
    | .while_ c b => do pure (cE ``Stmt.while_ [← serExpr c, ← serStmt b])
    | .doWhile b c => do pure (cE ``Stmt.doWhile [← serStmt b, ← serExpr c])
    | .switch d cs => do
      pure (cE ``Stmt.switch [← serExpr d, ← listM (prodT (optT tE) (listT tStmt))
        (fun (t, ss) => do pure (pairE (optT tE) (listT tStmt) (← optM tE serExpr t) (← serStmts ss))) cs])
    | .try_ b h f => do
      let hE ← optM (prodT (optT tPat) (listT tStmt))
        (fun (p, ss) => do pure (pairE (optT tPat) (listT tStmt) (← optM tPat serPat p) (← serStmts ss))) h
      pure (cE ``Stmt.try_ [← serStmts b, hE, ← optM (listT tStmt) serStmts f])
    | .throw e => do pure (cE ``Stmt.throw [← serExpr e])
    | .break l => pure (cE ``Stmt.break [optE tName (l.map nameE)])
    | .continue l => pure (cE ``Stmt.continue [optE tName (l.map nameE)])
    | .labeled l s => do pure (cE ``Stmt.labeled [nameE l, ← serStmt s])
    | .empty => pure (mkConst ``Stmt.empty)
  hoistWith AstTab.stmts (fun t m => { t with stmts := m }) tStmt st e
end

def serSpec : Spec → Lean.Expr := toExpr

def serItem : Item → HoistM Lean.Expr
  | .stmt s => do pure (cE ``Item.stmt [← serStmt s])
  | .import_ specs src => pure (cE ``Item.import_ [toExpr specs, nameE src])
  | .export_ s => do pure (cE ``Item.export_ [← serStmt s])
  | .exportDefault e => do pure (cE ``Item.exportDefault [← serExpr e])
  | .exportNamed specs src => pure (cE ``Item.exportNamed [toExpr specs, toExpr src])
  | .exportAll n src => pure (cE ``Item.exportAll [toExpr n, nameE src])

def serModule (m : Module) : HoistM Lean.Expr := listM (mkConst ``Item) serItem m

/-- Hoist module `m` of namespace `ns`: the item list over its node
constants, and the constants (in dependency order). -/
def hoistModule (ns : Lean.Name) (m : Module) (tab : AstTab := {}) : Lean.Expr × HoistSt :=
  (serModule m).run { tab, pre := some ns }

end Host.Ts

namespace Host.Ts
open Lean Elab Command

private def addDef' (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl <| .defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe }

/-- In a `source_parse`d namespace: `ast` over node constants `ast_n<i>`,
`astNative` (its native implementation), `ast_tokens` (the token constant's
parse, from `parse_tokens`) and `parse_ast`. -/
elab "source_ast" : command => do
  let ns ← getCurrNamespace
  let src := ns ++ `source
  let some (.defnInfo d) := (← getEnv).find? src | throwError "unknown source {src}"
  let .lit (.strVal text) := d.value | throwError "{src} is not a string literal"
  let some m := parse text.toList | throwError "source does not parse"
  let modTy := mkConst ``Module
  let (body, st) := hoistModule ns m
  liftCoreM do
    for (n, ty, v) in st.decls.reverse do addDef' n ty v
    let natN := ns ++ `astNative
    addDef' natN modTy (toExpr m)
    compileDecl (.defnDecl { name := natN, levelParams := [], type := modTy, value := toExpr m, hints := .regular 0, safety := .safe })
    addDef' (ns ++ `ast) modTy body
    match Compiler.implementedByAttr.setParam (← getEnv) (ns ++ `ast) natN with
    | .ok env => setEnv env
    | .error e => throwError e
    let lhs := mkApp3 (mkConst ``Sum.getLeft? [.zero, .zero]) modTy (mkApp (mkConst ``List [.zero]) (mkConst ``T))
      (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens)))
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) modTy (mkConst (ns ++ `ast))
    let optTy := mkApp (mkConst ``Option [.zero]) modTy
    let ty := mkApp3 (mkConst ``Eq [.succ .zero]) optTy lhs rhs
    -- From `parse_tokens : parseTokens tokens = .inl parsed`; `parsed` and `ast` are
    -- the same module, compared by unfolding.
    let tsTy := mkApp (mkConst ``List [.zero]) (mkConst ``T)
    let sumTy := mkApp2 (mkConst ``Sum [.zero, .zero]) modTy tsTy
    let inl := mkApp3 (mkConst ``Sum.inl [.zero, .zero]) modTy tsTy (mkConst (ns ++ `parsed))
    let getLeft := mkApp2 (mkConst ``Sum.getLeft? [.zero, .zero]) modTy tsTy
    let pf := mkAppN (mkConst ``Eq.trans [.succ .zero]) #[optTy, lhs, mkApp getLeft inl, rhs,
      mkAppN (mkConst ``congrArg [.succ .zero, .succ .zero]) #[sumTy, optTy,
        mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens)), inl, getLeft, mkConst (ns ++ `parse_tokens)],
      mkApp2 (mkConst ``Eq.refl [.succ .zero]) optTy rhs]
    addDecl (.thmDecl { name := ns ++ `ast_tokens, levelParams := [], type := ty, value := pf })
  let i (n : String) : Ident := mkIdent (Name.mkSimple n)
  elabCommand (← `(theorem $(i "parse_ast") : parse ($(i "source")).toList = some $(i "ast") := by
    rw [$(mkIdent `chars.eq):term, parse_of_lex $(i "lex_eq")]; exact $(i "ast_tokens")))

end Host.Ts
