import host.ts.Source
namespace Host.Ts
open Lean Elab Command

/-! # AST constants

`source_ast` (in a source module's namespace) parses `source` natively and
adds `ast : Module` with `parse_ast : parse source.toList = some ast`,
kernel-checked from `lex_eq`. Machine runs then start from the constant
instead of re-parsing in every check. -/

deriving instance Lean.ToExpr for Host.Ts.UnOp
deriving instance Lean.ToExpr for Host.Ts.Lit
deriving instance Lean.ToExpr for Host.Ts.DeclKind
deriving instance Lean.ToExpr for Host.Ts.MethodKind
deriving instance Lean.ToExpr for Host.Ts.Expr, Host.Ts.Elem, Host.Ts.Key, Host.Ts.Property, Host.Ts.Pat,
  Host.Ts.Body, Host.Ts.Func, Host.Ts.Member, Host.Ts.Class, Host.Ts.ForHead, Host.Ts.Stmt
deriving instance Lean.ToExpr for Host.Ts.Spec
deriving instance Lean.ToExpr for Host.Ts.Item

end Host.Ts

namespace Host.Ts
open Lean Elab Command

private def addDef' (name : Lean.Name) (type value : Lean.Expr) : CoreM Unit :=
  addDecl <| .defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe }

/-- In a `source_parse`d namespace: `ast`, `ast_tokens` (kernel-checked
parse of the token constant) and `parse_ast`. -/
elab "source_ast" : command => do
  let ns ← getCurrNamespace
  let src := ns ++ `source
  let some (.defnInfo d) := (← getEnv).find? src | throwError "unknown source {src}"
  let .lit (.strVal text) := d.value | throwError "{src} is not a string literal"
  let some m := parse text.toList | throwError "source does not parse"
  let modTy := mkConst ``Module
  liftCoreM do
    addDef' (ns ++ `ast) modTy (toExpr m)
    compileDecl (.defnDecl { name := ns ++ `ast, levelParams := [], type := modTy, value := toExpr m, hints := .regular 0, safety := .safe })
    let lhs := mkApp3 (mkConst ``Sum.getLeft? [.zero, .zero]) modTy (mkApp (mkConst ``List [.zero]) (mkConst ``T))
      (mkApp (mkConst ``parseTokens) (mkConst (ns ++ `tokens)))
    let rhs := mkApp2 (mkConst ``Option.some [.zero]) modTy (mkConst (ns ++ `ast))
    let optTy := mkApp (mkConst ``Option [.zero]) modTy
    let ty := mkApp3 (mkConst ``Eq [.succ .zero]) optTy lhs rhs
    let pf := mkApp2 (mkConst ``Eq.refl [.succ .zero]) optTy lhs
    addDecl (.thmDecl { name := ns ++ `ast_tokens, levelParams := [], type := ty, value := pf })
  let i (n : String) : Ident := mkIdent (Name.mkSimple n)
  elabCommand (← `(theorem $(i "parse_ast") : parse ($(i "source")).toList = some $(i "ast") := by
    rw [$(mkIdent `chars.eq):term, parse_of_lex $(i "lex_eq")]; exact $(i "ast_tokens")))

end Host.Ts
