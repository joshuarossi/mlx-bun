import host.mlx.GraphCertificate
import host.mlx.GraphBuildCommand
import Lean

namespace Host.Mlx.FfiEval
open Lean Elab Command Meta

private def addDefinition (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

private def addProof (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type := ty, value })

private def checkTrue (name : Lean.Name) (value : Lean.Expr) : TermElabM Unit := do
  addProof name (← mkEq value (mkConst ``Bool.true)) (← mkEqRefl value)

/-- Check a supplied candidate one node at a time, then compose exactly
`Matches` and the independent source-input carrier check. The candidate and
node literals are untrusted; every equality is checked by the ordinary kernel. -/
elab "ffi_check_certificate " name:ident " : " graph:term ", " expected:term ", " certificate:term ", " inputs:term
    " choosing " chooser:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let natTy := mkConst ``Nat
  let nodeTy := mkApp2 (mkConst ``RNode) (mkConst ``Int) (mkConst ``InKey)
  let nodesTy := mkApp (mkConst ``List [.zero]) nodeTy
  let certTy := mkApp (mkConst ``List [.zero]) natTy
  let option (ty : Lean.Expr) := mkApp (mkConst ``Option [.zero]) ty
  let elaborate (stx : Syntax) (ty : Lean.Expr) := do
    instantiateMVars (← Term.elabTermAndSynthesize stx (some ty))
  let g ← elaborate graph (← mkArrow natTy (option nodeTy))
  let es ← elaborate expected nodesTy
  let cert ← elaborate certificate certTy
  let ins ← elaborate inputs (← mkArrow (mkConst ``InKey) (option natTy))
  let choice ← elaborate chooser nodesTy
  let nodes ← unsafe evalExpr (List (RNode Int InKey)) nodesTy choice
  let nodes := nodes.toArray
  let mut exprs := #[]
  for (node, i) in nodes.toList.zipIdx do
    let nm := pre ++ Name.mkSimple s!"node{i}"
    addDefinition nm nodeTy (toExpr node)
    exprs := exprs.push (mkConst nm)
  let mut tails := Array.replicate (nodes.size + 1) (mkConst ``Bool.true)
  for j in [:nodes.size + 1] do
    let i := nodes.size - j
    let nm := pre ++ Name.mkSimple s!"tail{i}"
    let value := if i == nodes.size then mkApp (mkConst ``List.nil [.zero]) nodeTy
      else mkApp3 (mkConst ``List.cons [.zero]) nodeTy exprs[i]! tails[i+1]!
    addDefinition nm nodesTy value
    tails := tails.set! i (mkConst nm)
  -- Check that the structural list used below is exactly the supplied graph.
  addProof (pre ++ `expected_eq) (← mkEq tails[0]! es) (← mkEqRefl tails[0]!)
  let matchF ← mkAppM ``nodeOk #[g, cert]
  let inputF ← mkAppM ``inputNodeOk #[cert, ins]
  for (label, f) in [("match", matchF), ("input", inputF)] do
    let mut next := mkConst ``Bool.true
    for j in [:nodes.size + 1] do
      let i := nodes.size - j
      let nm := pre ++ Name.mkSimple s!"{label}All{i}"
      let value ← mkAppM ``checkNodes #[f, mkRawNatLit i, tails[i]!]
      if i == nodes.size then checkTrue nm value
      else
        let head := pre ++ Name.mkSimple s!"{label}Head{i}"
        checkTrue head (mkApp2 f (mkRawNatLit i) exprs[i]!)
        let proof ← mkAppM ``checkNodes_cons #[f, mkRawNatLit i, exprs[i]!, tails[i+1]!, mkConst head, next]
        addProof nm (← mkEq value (mkConst ``Bool.true)) proof
      next := mkConst nm
    let proof ← if label == "match" then mkAppM ``matches_of_checkNodes #[g, tails[0]!, cert, next]
      else mkAppM ``inputCarriersMatch_of_checkNodes #[tails[0]!, cert, ins, next]
    let goal ← if label == "match" then mkAppM ``Matches #[g, es, cert]
      else mkAppM ``inputCarriersMatch #[es, cert, ins]
    addProof (pre ++ Name.mkSimple (if label == "match" then "matches" else "inputs"))
      (← mkEq goal (mkConst ``Bool.true)) proof
  logInfo m!"Kernel-checked {nodes.size} FFI nodes and their input carrier provenance"

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
ffi_check_certificate checked : graph, expected, carried, inputs choosing expected

end CertificateCommandChecks
end Host.Mlx.FfiEval
