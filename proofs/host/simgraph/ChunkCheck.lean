import host.simgraph.Command

namespace Host.Mlx.SimGraph
open Host.Mlx Host.Mlx.FfiEval

/-! A range keeps the original expected graph, certificate and absolute indices.
Adjacent ranges compose; only a range from zero to `E.length` yields a full check.
The command below checks a chosen literal slice and each of its nodes in the kernel. -/

section
variable {δ κ : Type}

structure CheckRangeD (f : Nat → RNode δ κ → Bool) (E : List (RNode δ κ))
    (lo hi : Nat) : Prop where
  ordered : lo ≤ hi
  bounded : hi ≤ E.length
  node : ∀ {k e}, lo ≤ k → k < hi → E[k]? = some e → f k e = true

theorem checkRangeD_of_slice (f : Nat → RNode δ κ → Bool) (E chunk : List (RNode δ κ))
    (lo hi : Nat) (ho : lo ≤ hi) (hb : hi ≤ E.length)
    (he : chunk = (E.drop lo).take (hi - lo)) (hc : checkNodesD f lo chunk = true) :
    CheckRangeD f E lo hi := by
  refine ⟨ho, hb, ?_⟩
  intro k e hk hkh hget
  have hslice : chunk[k - lo]? = some e := by
    rw [he, List.getElem?_take_of_lt (by omega), List.getElem?_drop,
      Nat.add_sub_of_le hk]
    exact hget
  have h := checkNodesD_get f chunk lo hc hslice
  simpa only [Nat.add_sub_of_le hk] using h

theorem CheckRangeD.append {f : Nat → RNode δ κ → Bool} {E : List (RNode δ κ)}
    {lo mid hi : Nat} (a : CheckRangeD f E lo mid) (b : CheckRangeD f E mid hi) :
    CheckRangeD f E lo hi := by
  refine ⟨Nat.le_trans a.ordered b.ordered, b.bounded, ?_⟩
  intro k e hk hkh hget
  by_cases hkm : k < mid
  · exact a.node hk hkm hget
  · exact b.node (by omega) hkh hget

theorem checkNodesD_of_get (f : Nat → RNode δ κ → Bool) (E : List (RNode δ κ)) (offset : Nat)
    (h : ∀ {k e}, E[k]? = some e → f (offset + k) e = true) :
    checkNodesD f offset E = true := by
  induction E generalizing offset with
  | nil => rfl
  | cons e es ih =>
    apply checkNodesD_cons
    · simpa only [Nat.add_zero] using h (k := 0) rfl
    · apply ih
      intro k a hget
      have h' := h (k := k + 1) (e := a) (by simpa using hget)
      simpa only [Nat.add_assoc, Nat.add_comm 1 k] using h'

theorem CheckRangeD.checkNodes {f : Nat → RNode δ κ → Bool} {E : List (RNode δ κ)}
    (h : CheckRangeD f E 0 E.length) : checkNodesD f 0 E = true := by
  apply checkNodesD_of_get
  intro k e hget
  have hk : k < E.length := (List.getElem?_eq_some_iff.mp hget).1
  simpa only [Nat.zero_add] using h.node (Nat.zero_le k) hk hget

theorem matchesD_of_checkRange [DecidableEq δ] [DecidableEq κ]
    (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ)) (cert : List Nat)
    (h : CheckRangeD (nodeOkD G cert) E 0 E.length) : MatchesD G E cert = true :=
  matchesD_of_checkNodes G E cert h.checkNodes

theorem inputCarriersMatchD_of_checkRange (E : List (RNode δ κ)) (cert : List Nat)
    (ins : κ → Option Nat) (h : CheckRangeD (inputNodeOkD cert ins) E 0 E.length) :
    inputCarriersMatchD E cert ins = true :=
  inputCarriersMatchD_of_checkNodes E cert ins h.checkNodes

structure GraphRangeD [DecidableEq δ] [DecidableEq κ] (G : Nat → Option (RNode δ κ))
    (E : List (RNode δ κ)) (cert : List Nat) (ins : κ → Option Nat) (lo hi : Nat) : Prop where
  matchRange : CheckRangeD (nodeOkD G cert) E lo hi
  inputRange : CheckRangeD (inputNodeOkD cert ins) E lo hi

variable [DecidableEq δ] [DecidableEq κ]
variable {G : Nat → Option (RNode δ κ)} {E : List (RNode δ κ)} {cert : List Nat}
variable {ins : κ → Option Nat}

theorem GraphRangeD.append {lo mid hi : Nat} (a : GraphRangeD G E cert ins lo mid)
    (b : GraphRangeD G E cert ins mid hi) : GraphRangeD G E cert ins lo hi :=
  ⟨a.matchRange.append b.matchRange, a.inputRange.append b.inputRange⟩

theorem GraphRangeD.matchesD (h : GraphRangeD G E cert ins 0 E.length) :
    MatchesD G E cert = true := matchesD_of_checkRange G E cert h.matchRange

theorem GraphRangeD.inputCarriersMatchD (h : GraphRangeD G E cert ins 0 E.length) :
    inputCarriersMatchD E cert ins = true := inputCarriersMatchD_of_checkRange E cert ins h.inputRange

end

open Lean Elab Command Meta

private def addChunkDefinition (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

private def addChunkProof (name : Lean.Name) (params : Array Lean.Expr) (ty value : Lean.Expr) :
    TermElabM Unit := do
  let ty ← mkForallFVars params ty
  let value ← mkLambdaFVars params value
  addDecl (.thmDecl { name, levelParams := [], type := ty, value })

private def checkChunkTrue (name : Lean.Name) (params : Array Lean.Expr) (value : Lean.Expr) :
    TermElabM Unit := do
  addChunkProof name params (← mkEq value (mkConst ``Bool.true)) (← mkEqRefl value)

private def checkChunkBound (name : Lean.Name) (p : Lean.Expr) : TermElabM Lean.Expr := do
  let b ← mkAppOptM ``decide #[some p, none]
  checkChunkTrue (name ++ `decide_eq) #[] b
  let h ← mkAppM ``of_decide_eq_true #[mkConst (name ++ `decide_eq)]
  addChunkProof name #[] p h
  return mkConst name

private partial def chunkElems (e : Lean.Expr) (acc : Array Lean.Expr := #[]) :
    MetaM (Array Lean.Expr) := do
  let e ← withTransparency .all <| whnf e
  if e.isAppOfArity ``List.nil 1 then return acc
  unless e.isAppOfArity ``List.cons 3 do
    throwError "simgraph_check_range: the choice is not a list"
  let node ← withTransparency .all <| Meta.reduce e.appFn!.appArg! (skipTypes := true)
  chunkElems e.appArg! (acc.push node)

private def checkChunk (pre : Lean.Name) (params : Array Lean.Expr)
    (g es cert ins choice : Lean.Expr) (lo hi : Nat) : TermElabM Unit := do
  let nodesTy ← inferType es
  let nodeTy ← match (← whnfR nodesTy).getAppFnArgs with
    | (``List, #[t]) => pure t
    | _ => throwError "simgraph_check_range: expected graph is not a list"
  let (δ, κ) ← match (← whnfR nodeTy).getAppFnArgs with
    | (``RNode, #[d, k]) => pure (d, k)
    | _ => throwError "simgraph_check_range: expected graph is not a list of resolved nodes"
  let slice (xs : Lean.Expr) := do
    let dropped ← mkAppM ``List.drop #[mkRawNatLit lo, xs]
    mkAppM ``List.take #[mkRawNatLit (hi - lo), dropped]
  -- Reduction chooses data only. No reduction of G or a proof result is trusted.
  let nodes ← chunkElems (← slice choice)
  let ordered ← checkChunkBound (pre ++ `ordered) (← mkAppM ``LE.le #[mkRawNatLit lo, mkRawNatLit hi])
  let length ← mkAppM ``List.length #[es]
  let bounded ← checkChunkBound (pre ++ `bounded) (← mkAppM ``LE.le #[mkRawNatLit hi, length])
  let mut exprs := #[]
  for i in [:nodes.size] do
    let nm := pre ++ Name.mkSimple s!"node{lo + i}"
    addChunkDefinition nm nodeTy nodes[i]!
    exprs := exprs.push (mkConst nm)
  let mut tails := Array.replicate (nodes.size + 1) (mkConst ``Bool.true)
  for j in [:nodes.size + 1] do
    let i := nodes.size - j
    let nm := pre ++ Name.mkSimple s!"tail{i}"
    let value := if i == nodes.size then mkApp (mkConst ``List.nil [.zero]) nodeTy
      else mkApp3 (mkConst ``List.cons [.zero]) nodeTy exprs[i]! tails[i+1]!
    addChunkDefinition nm nodesTy value
    tails := tails.set! i (mkConst nm)
  addChunkProof (pre ++ `expected_eq) #[] (← mkEq tails[0]! (← slice es)) (← mkEqRefl tails[0]!)
  let matchF ← mkAppM ``nodeOkD #[g, cert]
  let inputF ← mkAppOptM ``inputNodeOkD #[some δ, some κ, some cert, some ins]
  let mut ranges := #[]
  for (label, f) in [("match", matchF), ("input", inputF)] do
    let mut next := mkConst ``Bool.true
    for j in [:nodes.size + 1] do
      let i := nodes.size - j
      let k := lo + i
      let nm := pre ++ Name.mkSimple s!"{label}All{k}"
      let value ← mkAppM ``checkNodesD #[f, mkRawNatLit k, tails[i]!]
      if i == nodes.size then checkChunkTrue nm params value
      else
        let head := pre ++ Name.mkSimple s!"{label}Head{k}"
        checkChunkTrue head params (mkApp2 f (mkRawNatLit k) exprs[i]!)
        let proof ← mkAppM ``checkNodesD_cons
          #[f, mkRawNatLit k, exprs[i]!, tails[i+1]!, mkAppN (mkConst head) params, next]
        addChunkProof nm params (← mkEq value (mkConst ``Bool.true)) proof
      next := mkAppN (mkConst nm) params
    let proof ← mkAppM ``checkRangeD_of_slice
      #[f, es, tails[0]!, mkRawNatLit lo, mkRawNatLit hi, ordered, bounded,
        mkConst (pre ++ `expected_eq), next]
    let goal ← mkAppM ``CheckRangeD #[f, es, mkRawNatLit lo, mkRawNatLit hi]
    let nm := pre ++ Name.mkSimple (if label == "match" then "matches" else "inputs")
    addChunkProof nm params goal proof
    ranges := ranges.push (mkAppN (mkConst nm) params)
  let goal ← mkAppM ``GraphRangeD #[g, es, cert, ins, mkRawNatLit lo, mkRawNatLit hi]
  let proof ← mkAppM ``GraphRangeD.mk ranges
  addChunkProof (pre ++ `checked) params goal proof
  logInfo m!"Kernel-checked symbolic range [{lo}, {hi}): {nodes.size} nodes and input carriers"

private def elaborateChunk (name : Syntax) (domain : Option Syntax)
    (graph expected certificate inputs chooser : Syntax) (lo hi : Nat) : CommandElabM Unit :=
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  if hi < lo then throwError "simgraph_check_range: reversed range [{lo}, {hi})"
  let pre := (← getCurrNamespace) ++ name.getId
  let elaborate (stx : Syntax) (ty : Option Lean.Expr) := do
    instantiateMVars (← Term.elabTermAndSynthesize stx ty)
  let es ← elaborate expected none
  let nodesTy ← inferType es
  let nodeTy ← match (← whnfR nodesTy).getAppFnArgs with
    | (``List, #[t]) => pure t
    | _ => throwError "simgraph_check_range: expected graph is not a list"
  let κ ← match (← whnfR nodeTy).getAppFnArgs with
    | (``RNode, #[_, k]) => pure k
    | _ => throwError "simgraph_check_range: expected graph is not a list of resolved nodes"
  let natTy := mkConst ``Nat
  let option (t : Lean.Expr) := mkApp (mkConst ``Option [.zero]) t
  let cert ← elaborate certificate (some (mkApp (mkConst ``List [.zero]) natTy))
  let ins ← elaborate inputs (some (← mkArrow κ (option natTy)))
  let choice ← elaborate chooser (some nodesTy)
  let graphTy ← mkArrow natTy (option nodeTy)
  match domain with
  | none => checkChunk pre #[] (← elaborate graph (some graphTy)) es cert ins choice lo hi
  | some domain =>
    let ty ← elaborate domain (some (mkSort (.succ .zero)))
    let g ← elaborate graph (some (← mkArrow ty graphTy))
    withLocalDeclD `parameter ty fun parameter =>
      checkChunk pre #[parameter] (mkApp g parameter) es cert ins choice lo hi

/-- Check `[lo, hi)` of the original graph, selecting that slice of the choice.
Produces `name.matches`, `name.inputs` and the paired `name.checked : GraphRangeD … lo hi`.
Each module can import only shared graph/certificate data and check its own range. -/
elab "simgraph_check_range " name:ident " : " graph:term ", " expected:term ", "
    certificate:term ", " inputs:term " from " lo:num " to " hi:num " choosing " chooser:term : command =>
  elaborateChunk name none graph expected certificate inputs chooser lo.getNat hi.getNat

/-- The same absolute range for every member of a graph family. -/
elab "simgraph_check_family_range " name:ident " : " domain:term ", " graph:term ", " expected:term ", "
    certificate:term ", " inputs:term " from " lo:num " to " hi:num " choosing " chooser:term : command =>
  elaborateChunk name (some domain) graph expected certificate inputs chooser lo.getNat hi.getNat

end Host.Mlx.SimGraph
