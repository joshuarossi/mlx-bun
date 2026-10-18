import host.mlx.GraphCertificate
import Lean

namespace Host.Mlx.FfiEval
open Lean Elab Command Meta

/-- Search for a finite carrier certificate outside the kernel, then check
`Matches` on that explicit certificate inside the kernel. Neither the search
implementation nor its successful return is a proof premise. -/
elab "ffi_certificate " name:ident " : " graph:term ", " expected:term ", " inputs:term ", " upper:term : command =>
  liftTermElabM do
    let pre := (← getCurrNamespace) ++ name.getId
    let natTy := mkConst ``Nat
    let nodeTy := mkApp2 (mkConst ``RNode) (mkConst ``Int) (mkConst ``InKey)
    let listTy := mkApp (mkConst ``List [.zero]) natTy
    let option (ty : Lean.Expr) := mkApp (mkConst ``Option [.zero]) ty
    let elaborate (stx : Syntax) (ty : Lean.Expr) := do
      instantiateMVars (← Term.elabTermAndSynthesize stx (some ty))
    let g ← elaborate graph (← mkArrow natTy (option nodeTy))
    let es ← elaborate expected (mkApp (mkConst ``List [.zero]) nodeTy)
    let ins ← elaborate inputs (← mkArrow (mkConst ``InKey) (option natTy))
    let n ← elaborate upper natTy
    let request := mkApp4 (mkConst ``certify) g es ins n
    let some cert ← unsafe evalExpr (Option (List Nat)) (option listTy) request
      | throwError "ffi_certificate: no complete carrier certificate within the supplied graph bound"
    addDecl (.defnDecl { name := pre, levelParams := [], type := listTy, value := toExpr cert, hints := .regular 0, safety := .safe })
    let lhs ← mkAppM ``Matches #[g, es, mkConst pre]
    let boolTy := mkConst ``Bool
    let eqTy := mkApp3 (mkConst ``Eq [.succ .zero]) boolTy lhs (mkConst ``Bool.true)
    addDecl (.thmDecl { name := pre ++ `matches, levelParams := [], type := eqTy, value := mkApp2 (mkConst ``Eq.refl [.succ .zero]) boolTy lhs })
    logInfo m!"Kernel-checked FFI carrier certificate: {cert.length} nodes"

namespace CertificateCommandChecks

private def graph : Nat → Option (RNode Int InKey)
  | 3 => some ⟨.data [1, 0, 0, 0] [1] 7, []⟩
  | 6 => some ⟨.reshape [1, 1], [3]⟩
  | _ => none

private def expected : List (RNode Int InKey) :=
  [⟨.input .tokenIds, []⟩, ⟨.reshape [1, 1], [0]⟩]

private def inputs : InKey → Option Nat
  | .tokenIds => some 3
  | _ => none

ffi_certificate carried : graph, expected, inputs, 7
theorem found_actual_nodes : carried = [3, 6] := rfl

end CertificateCommandChecks
end Host.Mlx.FfiEval
