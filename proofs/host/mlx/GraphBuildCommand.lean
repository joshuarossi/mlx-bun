import host.mlx.GraphBuild
import host.ts.Chunk

namespace Host.Mlx.FfiEval
open Lean Elab Command Meta

deriving instance Lean.ToExpr for LinKey
deriving instance Lean.ToExpr for MlpKey
deriving instance Lean.ToExpr for SKey
deriving instance Lean.ToExpr for InKey
deriving instance Lean.ToExpr for RCfg
deriving instance Lean.ToExpr for RPrim
deriving instance Lean.ToExpr for RNode
deriving instance Lean.ToExpr for Host.Mlx.GlueLayers.Projector
deriving instance Lean.ToExpr for LinLayout
deriving instance Lean.ToExpr for MlpLayout
deriving instance Lean.ToExpr for DeltaLayout
deriving instance Lean.ToExpr for AttnLayout
deriving instance Lean.ToExpr for StageLayout

private def literalValue (name : Syntax) (term : Syntax) : TermElabM Unit := do
  let pre := (← getCurrNamespace) ++ name.getId
  let original ← instantiateMVars (← Term.elabTermAndSynthesize term none)
  let ty ← inferType original
  let encode ← mkAppOptM ``Lean.ToExpr.toExpr #[ty, none, original]
  let value ← unsafe evalExpr Lean.Expr (mkConst ``Lean.Expr) encode
  withOptions (fun opts => opts.setBool `Elab.async false) do
    addDecl (.defnDecl { name := pre, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name := pre, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

/-- A typed, untrusted literal choice, usable as the input of another builder.
The separate equality command checks it against the original computation. -/
elab "ffi_value_literal " name:ident " : " term:term : command => liftTermElabM do
  literalValue name term

elab "ffi_value_literal_eq " name:ident " : " term:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ name.getId
  let original ← instantiateMVars (← Term.elabTermAndSynthesize term none)
  let ty ← inferType original
  let level ← getLevel ty
  let literal := mkConst pre
  let eq := mkApp3 (mkConst ``Eq [level]) ty literal original
  let started ← IO.monoMsNow
  withOptions (fun opts => opts.setBool `Elab.async false) do
    addDecl (.thmDecl { name := pre ++ `eq_original, levelParams := [], type := eq, value := mkApp2 (mkConst ``Eq.refl [level]) ty literal })
  logInfo m!"Kernel-checked {pre} equality in {(← IO.monoMsNow) - started} ms"

/-- Choose a literal graph outside the kernel. Its type is checked here;
`ffi_graph_literal_eq` independently checks equality with the original builder.
Separating the commands lets conversion run in its own checking process. -/
elab "ffi_graph_literal " name:ident " : " expected:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ name.getId
  let nodeTy := mkApp2 (mkConst ``RNode) (mkConst ``Int) (mkConst ``InKey)
  let listTy := mkApp (mkConst ``List [.zero]) nodeTy
  let es ← instantiateMVars (← Term.elabTermAndSynthesize expected (some listTy))
  let nodes ← unsafe evalExpr (List (RNode Int InKey)) listTy es
  withOptions (fun opts => opts.setBool `Elab.async false) do
    addDecl (.defnDecl { name := pre, levelParams := [], type := listTy, value := toExpr nodes, hints := .regular 0, safety := .safe })
  logInfo m!"Staged expected graph: {nodes.length} literal nodes (equality not yet checked)"

/-- An ordinary kernel conversion, without native computation as a proof.
Use the resulting equality to transport graph matches to the original builder. -/
elab "ffi_graph_literal_eq " name:ident " : " expected:term : command => liftTermElabM do
  let pre := (← getCurrNamespace) ++ name.getId
  let nodeTy := mkApp2 (mkConst ``RNode) (mkConst ``Int) (mkConst ``InKey)
  let listTy := mkApp (mkConst ``List [.zero]) nodeTy
  let es ← instantiateMVars (← Term.elabTermAndSynthesize expected (some listTy))
  let literal := mkConst pre
  let ty := mkApp3 (mkConst ``Eq [.succ .zero]) listTy literal es
  let started ← IO.monoMsNow
  withOptions (fun opts => opts.setBool `Elab.async false) do
    addDecl (.thmDecl { name := pre ++ `eq_original, levelParams := [], type := ty, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) listTy literal })
  logInfo m!"Kernel-checked original expected graph equality in {(← IO.monoMsNow) - started} ms"

end Host.Mlx.FfiEval
