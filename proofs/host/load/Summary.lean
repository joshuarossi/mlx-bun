import host.load.Extract
import host.load.Expr
namespace Host.Load.Extract
open Lean Elab Command Meta

deriving instance Lean.ToExpr for Tensor
deriving instance Lean.ToExpr for Linear
deriving instance Lean.ToExpr for Trellis
deriving instance Lean.ToExpr for Mlp
deriving instance Lean.ToExpr for Stage
deriving instance Lean.ToExpr for Model
deriving instance Lean.ToExpr for Cache
deriving instance Lean.ToExpr for Loaded

/-- Choose a summary natively, then check its equality to the actual heap
projection in the kernel. The resulting constant exposes every tensor's
array handle, producing node, shape, dtype and primitive, plus the selected
stage and projection classes, in the source graph's own stage order. -/
elab "load_summary " name:ident " : " st:term ", " env:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ name.getId
  let stTy := mkApp (mkConst ``Host.Ts.St) (mkConst ``LSt)
  let s ← instantiateMVars (← Term.elabTermAndSynthesize st (some stTy))
  let e ← instantiateMVars (← Term.elabTermAndSynthesize env (some (mkConst ``Host.Ts.Env)))
  let ty := mkConst ``Loaded
  let optTy := mkApp (mkConst ``Option [.zero]) ty
  let lhs := mkApp2 (mkConst ``loaded) s e
  let some result ← unsafe evalExpr (Option Loaded) optTy lhs | throwError "load_summary: model/cache extraction failed"
  addDecl (.defnDecl { name := pre, levelParams := [], type := ty, value := toExpr result, hints := .regular 0, safety := .safe })
  let rhs := mkApp2 (mkConst ``Option.some [.zero]) ty (mkConst pre)
  let eqTy := mkApp3 (mkConst ``Eq [.succ .zero]) optTy lhs rhs
  addDecl (.thmDecl { name := pre ++ `matches, levelParams := [], type := eqTy, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) optTy lhs })

end Host.Load.Extract
