import host.simgraph.Match
import host.mlx.GraphBuildCommand
import Lean
namespace Host.Mlx.SimGraph
open Lean Elab Command Meta Host.Mlx Host.Mlx.FfiEval

/-! # Kernel checks of symbolic certificates

`simgraph_check_template name : G, E, cert, ins choosing C` checks
`MatchesD G E cert` and `inputCarriersMatchD E cert ins` one node at a time
(as `ffi_check_certificate` does for integer dimensions), for any dimension
type with `ToExpr` and decidable equality, in particular `SDim`:

* `C` (an untrusted choice of `E`'s literal nodes) is evaluated outside the
  kernel and split into node constants `name.node<i>` and list tails;
  `name.expected_eq : tail0 = E` is checked by the kernel;
* each `name.matchHead<i> : nodeOkD G cert i node<i> = true` and
  `name.inputHead<i>` is a separate `Eq.refl` the kernel decides;
* `name.matches : MatchesD G E cert = true`,
  `name.inputs : inputCarriersMatchD E cert ins = true`.

`simgraph_check_family name : D, G, …` checks the same for `G d` at every
`d : D`. -/

deriving instance Lean.ToExpr for SDim

section
variable {δ κ : Type}

def checkNodesD (f : Nat → RNode δ κ → Bool) : Nat → List (RNode δ κ) → Bool
  | _, [] => true
  | i, e :: es => f i e && checkNodesD f (i + 1) es

theorem checkNodesD_cons (f : Nat → RNode δ κ → Bool) (i : Nat) (e : RNode δ κ) (es : List (RNode δ κ))
    (hh : f i e = true) (ht : checkNodesD f (i + 1) es = true) : checkNodesD f i (e :: es) = true := by
  simp only [checkNodesD, hh, ht, Bool.and_self]

theorem checkNodesD_get (f : Nat → RNode δ κ → Bool) (es : List (RNode δ κ)) (offset : Nat) {i : Nat}
    {e : RNode δ κ} (h : checkNodesD f offset es = true) (he : es[i]? = some e) : f (offset + i) e = true := by
  induction es generalizing offset i with
  | nil => simp at he
  | cons a es ih =>
    simp only [checkNodesD, Bool.and_eq_true] at h
    cases i with
    | zero =>
      have ha : a = e := by simpa using he
      simpa [ha] using h.1
    | succ i =>
      have := ih (offset + 1) h.2 (by simpa using he)
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this

def inputNodeOkD (cert : List Nat) (inputs : κ → Option Nat) (i : Nat) (e : RNode δ κ) : Bool :=
  match e.prim with
  | .input key => decide (inputs key = some (certAt cert i))
  | _ => true

theorem matchesD_of_checkNodes [DecidableEq δ] [DecidableEq κ] (G : Nat → Option (RNode δ κ))
    (E : List (RNode δ κ)) (cert : List Nat) (h : checkNodesD (nodeOkD G cert) 0 E = true) :
    MatchesD G E cert = true := by
  apply List.all_eq_true.mpr
  intro i hi
  have hil : i < E.length := List.mem_range.mp hi
  have he := List.getElem?_eq_getElem hil
  simp only [he]
  simpa using checkNodesD_get (nodeOkD G cert) E 0 h he

theorem inputCarriersMatchD_of_checkNodes (E : List (RNode δ κ)) (cert : List Nat) (inputs : κ → Option Nat)
    (h : checkNodesD (inputNodeOkD cert inputs) 0 E = true) : inputCarriersMatchD E cert inputs = true := by
  apply List.all_eq_true.mpr
  intro i hi
  have hil : i < E.length := List.mem_range.mp hi
  have he := List.getElem?_eq_getElem hil
  simp only [he]
  have h2 := checkNodesD_get (inputNodeOkD cert inputs) E 0 h he
  simp only [Nat.zero_add, inputNodeOkD] at h2
  generalize E[i].prim = q at h2 ⊢
  cases q <;> simp_all

end

private def addDefinition (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

private def addProof (name : Lean.Name) (params : Array Lean.Expr) (ty value : Lean.Expr) : TermElabM Unit := do
  addDecl (.thmDecl { name, levelParams := [], type := ← mkForallFVars params ty, value := ← mkLambdaFVars params value })

private def checkTrue (name : Lean.Name) (params : Array Lean.Expr) (value : Lean.Expr) : TermElabM Unit := do
  addProof name params (← mkEq value (mkConst ``Bool.true)) (← mkEqRefl value)

/-- The elements of a list literal. -/
private partial def listElems (e : Lean.Expr) (acc : Array Lean.Expr := #[]) : MetaM (Array Lean.Expr) := do
  let e ← whnfR e
  if e.isAppOfArity ``List.nil 1 then return acc
  unless e.isAppOfArity ``List.cons 3 do throwError "simgraph_check: the choice is not a list literal"
  listElems e.appArg! (acc.push e.appFn!.appArg!)

private def checkSym (pre : Lean.Name) (params : Array Lean.Expr) (g es cert ins choice : Lean.Expr) :
    TermElabM Unit := do
  let nodesTy ← inferType es
  let nodeTy ← match (← whnfR nodesTy).getAppFnArgs with
    | (``List, #[t]) => pure t
    | _ => throwError "simgraph_check: the expected graph is not a list"
  let encode ← mkAppOptM ``Lean.ToExpr.toExpr #[nodesTy, none, choice]
  let lit ← unsafe evalExpr Lean.Expr (mkConst ``Lean.Expr) encode
  let nodes ← listElems lit
  let mut exprs := #[]
  for i in [:nodes.size] do
    let nm := pre ++ Name.mkSimple s!"node{i}"
    addDefinition nm nodeTy nodes[i]!
    exprs := exprs.push (mkConst nm)
  let mut tails := Array.replicate (nodes.size + 1) (mkConst ``Bool.true)
  for j in [:nodes.size + 1] do
    let i := nodes.size - j
    let nm := pre ++ Name.mkSimple s!"tail{i}"
    let value := if i == nodes.size then mkApp (mkConst ``List.nil [.zero]) nodeTy
      else mkApp3 (mkConst ``List.cons [.zero]) nodeTy exprs[i]! tails[i+1]!
    addDefinition nm nodesTy value
    tails := tails.set! i (mkConst nm)
  addProof (pre ++ `expected_eq) #[] (← mkEq tails[0]! es) (← mkEqRefl tails[0]!)
  let matchF ← mkAppM ``nodeOkD #[g, cert]
  let (δ, κ) ← match (← whnfR nodeTy).getAppFnArgs with
    | (``RNode, #[d, k]) => pure (d, k)
    | _ => throwError "simgraph_check: the expected graph is not a list of resolved nodes"
  let inputF ← mkAppOptM ``inputNodeOkD #[some δ, some κ, some cert, some ins]
  for (label, f) in [("match", matchF), ("input", inputF)] do
    let mut next := mkConst ``Bool.true
    for j in [:nodes.size + 1] do
      let i := nodes.size - j
      let nm := pre ++ Name.mkSimple s!"{label}All{i}"
      let value ← mkAppM ``checkNodesD #[f, mkRawNatLit i, tails[i]!]
      if i == nodes.size then checkTrue nm params value
      else
        let head := pre ++ Name.mkSimple s!"{label}Head{i}"
        checkTrue head params (mkApp2 f (mkRawNatLit i) exprs[i]!)
        let proof ← mkAppM ``checkNodesD_cons
          #[f, mkRawNatLit i, exprs[i]!, tails[i+1]!, mkAppN (mkConst head) params, next]
        addProof nm params (← mkEq value (mkConst ``Bool.true)) proof
      next := mkAppN (mkConst nm) params
    let proof ← if label == "match" then mkAppM ``matchesD_of_checkNodes #[g, tails[0]!, cert, next]
      else mkAppM ``inputCarriersMatchD_of_checkNodes #[tails[0]!, cert, ins, next]
    let goal ← if label == "match" then mkAppM ``MatchesD #[g, es, cert]
      else mkAppM ``inputCarriersMatchD #[es, cert, ins]
    let motive ← withLocalDeclD `x nodesTy fun x => do
      let body ← if label == "match" then mkAppM ``MatchesD #[g, x, cert] else mkAppM ``inputCarriersMatchD #[x, cert, ins]
      mkLambdaFVars #[x] (← mkEq body (mkConst ``Bool.true))
    let proof ← mkEqNDRec motive proof (mkConst (pre ++ `expected_eq))
    addProof (pre ++ Name.mkSimple (if label == "match" then "matches" else "inputs")) params
      (← mkEq goal (mkConst ``Bool.true)) proof
  logInfo m!"Kernel-checked {nodes.size} symbolic nodes and their input carriers"

private def elaborateSym (name : Syntax) (domain : Option Syntax) (graph expected certificate inputs chooser : Syntax) :
    CommandElabM Unit :=
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let elaborate (stx : Syntax) (ty : Option Lean.Expr) := do
    instantiateMVars (← Term.elabTermAndSynthesize stx ty)
  let es ← elaborate expected none
  let nodesTy ← inferType es
  let nodeTy ← match (← whnfR nodesTy).getAppFnArgs with
    | (``List, #[t]) => pure t
    | _ => throwError "simgraph_check: the expected graph is not a list"
  let κ ← match (← whnfR nodeTy).getAppFnArgs with
    | (``RNode, #[_, k]) => pure k
    | _ => throwError "simgraph_check: the expected graph is not a list of resolved nodes"
  let natTy := mkConst ``Nat
  let option (t : Lean.Expr) := mkApp (mkConst ``Option [.zero]) t
  let cert ← elaborate certificate (some (mkApp (mkConst ``List [.zero]) natTy))
  let ins ← elaborate inputs (some (← mkArrow κ (option natTy)))
  let choice ← elaborate chooser (some nodesTy)
  let graphTy ← mkArrow natTy (option nodeTy)
  match domain with
  | none => checkSym pre #[] (← elaborate graph (some graphTy)) es cert ins choice
  | some domain =>
    let ty ← elaborate domain (some (mkSort (.succ .zero)))
    let g ← elaborate graph (some (← mkArrow ty graphTy))
    withLocalDeclD `parameter ty fun parameter =>
      checkSym pre #[parameter] (mkApp g parameter) es cert ins choice

elab "simgraph_check_template " name:ident " : " graph:term ", " expected:term ", " certificate:term ", "
    inputs:term " choosing " chooser:term : command =>
  elaborateSym name none graph expected certificate inputs chooser

elab "simgraph_check_family " name:ident " : " domain:term ", " graph:term ", " expected:term ", "
    certificate:term ", " inputs:term " choosing " chooser:term : command =>
  elaborateSym name (some domain) graph expected certificate inputs chooser

end Host.Mlx.SimGraph
