import host.route.cert.Fin.Cls
import host.simgraph.Choose
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Extract

/-! # Choosing a sampled cut's carriers (search only)

`simgraph_choose_head X : (sEnd, SEnd), B, V, d, low, K, prefix, ins, G` (`ins : InKey → Option Nat`): the carriers of `G` from node `K` on, on the end state
read through `numsV SEnd B V d`; the first `K` are `prefix`'s, the final forward's. It defines `X.cert`. Nothing here is trusted: the
kernel checks the result. -/

private def addDefH (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit := do
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

/-- `chooseD` from node `K` on, with the first `K` carriers given. -/
def chooseFrom {δ : Type} [DecidableEq δ] (actual : Array (Option (RNode δ InKey))) (expected : List (RNode δ InKey))
    (inputs : InKey → Option Nat) (lower K : Nat) (pre : List Nat) : Except String (List Nat) := do
  let graph := fun i => actual[i]?.join
  let mut buckets : Std.HashMap (List Nat) (Array Nat) := {}
  let mut exponentials : Array Nat := #[]
  for i in [:actual.size] do
    if let some n := graph i then
      buckets := buckets.insert n.ins ((buckets[n.ins]?).getD #[] |>.push i)
      if isExpD n.prim then exponentials := exponentials.push i
  let mut cert : Array Nat := (pre.take K).toArray
  let mut used : Std.HashSet Nat := {}
  for c in pre.take K do used := used.insert c
  for e in expected.drop K do
    let k := cert.size
    let carrier ← match e.prim with
      | .input key => match inputs key with
        | some i => pure i
        | none => throw s!"missing input at expected node {k}"
      | _ => do
        let ins := e.ins.map (cert[·]?.getD 0)
        let candidates := if e.prim = .computeG then exponentials else (buckets[ins]?).getD #[]
        let accepts := fun i => ins.all (· < i) &&
          if e.prim = .computeG then decide (cgLeaves graph i = some ins)
          else !isExpD e.prim && match graph i with
            | none => false
            | some r => decide (strip r.prim = e.prim ∧ (r.prim = e.prim ∨ elementwise e.prim = false) ∧ r.ins = ins)
        let found := (candidates.find? fun i => lower ≤ i && !used.contains i && accepts i).orElse fun _ =>
          (candidates.find? fun i => !used.contains i && accepts i).orElse fun _ => candidates.find? accepts
        match found with
        | some i => pure i
        | none => throw s!"no carrier at expected node {k}; candidates={candidates.size}; ins={ins}"
    cert := cert.push carrier
    used := used.insert carrier
  return cert.toList

private unsafe def chooseHeadCmd (pre : Lean.Name) (sEnd SEnd : Lean.Name) (bE vE dE lowE kE preE insE expected : Lean.Expr) :
    TermElabM Unit := do
  let (e, S, _) ← Host.Ts.Sim.Template.restore (mkConst sEnd) (mkConst SEnd) `simgraphHead
  let natTy := mkConst ``Nat
  let B ← evalExpr Box (mkConst ``Box) bE
  let V ← evalExpr VarV (mkConst ``VarV) vE
  let d ← evalExpr Int (mkConst ``Int) dE
  let low ← evalExpr Nat natTy lowE
  let K ← evalExpr Nat natTy kE
  let listNat := mkApp (mkConst ``List [.zero]) natTy
  let prefix_ ← evalExpr (List Nat) listNat preE
  let ins ← evalExpr (InKey → Option Nat) (← mkArrow (mkConst ``InKey) (mkApp (mkConst ``Option [.zero]) natTy)) insE
  let nodesTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``RNode) (mkConst ``SDim) (mkConst ``InKey))
  let G ← evalExpr (List (RNode SDim InKey)) nodesTy expected
  let x := e.aux.ffi.mlx
  let actual := domainNodes (numsV S B V d) 15235 15235 [5554869888] x
  let cert ← match chooseFrom actual G ins low K prefix_ with
    | .ok c => pure c
    | .error m => throwError "simgraph_choose_head: {m}"
  addDefH (pre ++ `cert) listNat (toExpr cert)
  logInfo m!"simgraph_choose_head {pre}: {cert.length} carriers, end nnext {x.nnext}"

elab "simgraph_choose_head " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " B:term ", " V:term ", " d:term ", "
    low:term ", " K:term ", " pre:term ", " ins:term ", " expected:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
    let resolve (i : Syntax) := do realizeGlobalConstNoOverloadWithInfo i
    let natTy := mkConst ``Nat
    unsafe chooseHeadCmd ((← getCurrNamespace) ++ name.getId) (← resolve sE) (← resolve SE) (← el B (some (mkConst ``Box)))
      (← el V (some (mkConst ``VarV))) (← el d (some (mkConst ``Int))) (← el low (some natTy)) (← el K (some natTy))
      (← el pre none) (← el ins none) (← el expected none)

end Host.Route.Cert.Fin
