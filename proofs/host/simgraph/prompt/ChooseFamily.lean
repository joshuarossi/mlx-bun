import host.simgraph.Choose
import host.simgraph.compose.Split
import host.simgraph.family.AneFamilies
namespace Host.Mlx.SimGraph
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval

/-! # Family certificates with the multi-parameter classifier (search, and the closure-aware check)

`simgraph_choose` searches a decode template's carriers (`InKey` inputs, no closures). A forward piece is a
segment `[lo, hi)` of a row family's expected graph (`familyGraph F.ops id o₀ n₀ ss₀`, keys `PKey`, or `AKey`
for the Neural Engine families) with compiled-closure nodes, read from the piece's end state through the
`PDim` classifier `clsOfP S B` on the piece's domain `tplDom NL N0 fixed`:

* `chooseFamD`: carriers for the segment — below `lo` the boundary carriers `bnd` (the caller's, or the
  previous piece's), inputs at `ins`, compute_g at its pattern, a closure node at the root of a replayed body
  whose leaves are its arguments' carriers (recording the closure object's kind), others by primitive and
  argument carriers (preferring ids from `N0`). Nothing here is trusted.
* `simgraph_choose_family X : (sEnd, SEnd), B, NL, N0, fixed, E, ins, lo, hi, bnd` (`simgraph_choose_family_at
  X : x, S, …` for a state term `x` and table `S`): defines `X.cert` and `X.kind` (closure objects and their kinds; `kindOf`).
* `simgraph_check_segment X : G, kind, E, d, lo, hi, cert, ins choosing C` (and `simgraph_check_segments X : D,
  G, …` at every `d : D`, as `simgraph_check_family`): the kernel checks each node of the segment
  (`segNodeOk`: `nodeOkED` and the input carrier) as its own `Eq.refl`; `X.matches : MatchesSeg d kind G E
  cert lo hi = true`, `X.inputs : InputsSeg E cert ins lo hi = true`.
* `matchesED_of_matchesD`: a segment without closure nodes checked by `simgraph_check_family`/`_template`
  (`MatchesD`) is a closure-aware match. -/

deriving instance Lean.ToExpr for PKey
deriving instance Lean.ToExpr for AKey
deriving instance Lean.ToExpr for Compiled

/-! ## The check -/

section
variable {δ κ : Type} [DecidableEq δ] [DecidableEq κ]

/-- The input carriers of a segment's nodes. -/
def InputsSeg (E : List (RNode δ κ)) (cert : List Nat) (ins : κ → Option Nat) (lo hi : Nat) : Bool :=
  (List.range E.length).all fun k => match E[k]? with
    | some e => !(decide (lo ≤ k) && decide (k < hi)) || inputNodeOkD cert ins k e
    | none => false

/-- A segment's check of node `k`: outside `[lo, hi)` nothing, inside the closure-aware match and the input
carrier. -/
def segNodeOk (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (cert : List Nat) (ins : κ → Option Nat)
    (lo hi k : Nat) (e : RNode δ κ) : Bool :=
  !(decide (lo ≤ k) && decide (k < hi)) || (nodeOkED kind G cert k e && inputNodeOkD cert ins k e)

theorem matchesSeg_of_checkNodes (d : κ) (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ))
    (E : List (RNode δ κ)) (cert : List Nat) (ins : κ → Option Nat) (lo hi : Nat)
    (h : checkNodesD (segNodeOk kind G cert ins lo hi) 0 E = true) : MatchesSeg d kind G E cert lo hi = true := by
  rw [matchesSeg_iff]
  intro k hk h1 h2
  have := checkNodesD_get _ E 0 h (List.getElem?_eq_getElem hk)
  simp only [Nat.zero_add, segNodeOk, h1, h2, decide_true, Bool.and_self, Bool.not_true, Bool.false_or,
    Bool.and_eq_true] at this
  exact this.1

theorem inputsSeg_of_checkNodes (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ))
    (E : List (RNode δ κ)) (cert : List Nat) (ins : κ → Option Nat) (lo hi : Nat)
    (h : checkNodesD (segNodeOk kind G cert ins lo hi) 0 E = true) : InputsSeg E cert ins lo hi = true := by
  apply List.all_eq_true.mpr
  intro k hk
  have hkl : k < E.length := List.mem_range.mp hk
  rw [List.getElem?_eq_getElem hkl]
  have := checkNodesD_get _ E 0 h (List.getElem?_eq_getElem hkl)
  simp only [Nat.zero_add, segNodeOk, Bool.or_eq_true, Bool.and_eq_true] at this ⊢
  rcases this with h' | h'
  · exact .inl h'
  · exact .inr h'.2

/-- **A closure-free match is a closure-aware one.** -/
theorem matchesED_of_matchesD (kind : Nat → Option Compiled) (G : Nat → Option (RNode δ κ)) (E : List (RNode δ κ))
    (cert : List Nat) (hc : ∀ e ∈ E, closureOf? e.prim = none) (h : MatchesD G E cert = true) :
    MatchesED kind G E cert = true := by
  unfold MatchesD at h
  unfold MatchesED
  refine List.all_eq_true.mpr fun k hk => ?_
  have hk' := List.all_eq_true.mp h k hk
  have hl : k < E.length := List.mem_range.mp hk
  rw [List.getElem?_eq_getElem hl] at hk' ⊢
  have hcl := hc E[k] (List.getElem_mem hl)
  generalize E[k] = e at hk' hcl
  simp only [nodeOkD, nodeOkED, closureCheck, hcl, Option.map_none, Option.getD_none, plainCheck] at hk' ⊢
  exact hk'

end

/-- **The boundary check of two adjacent pieces**: `c2`'s carriers of the arguments below `mid` of its nodes
`[mid, hi)` are `c1`'s (`matchesSeg_split`'s premise, decided). -/
def BoundaryOk {δ κ : Type} (E : List (RNode δ κ)) (c1 c2 : List Nat) (mid hi : Nat) : Bool :=
  (List.range E.length).all fun k => match E[k]? with
    | some e => !(decide (mid ≤ k) && decide (k < hi)) ||
        e.ins.all fun j => !(decide (j < mid)) || decide (certAt c2 j = certAt c1 j)
    | none => true

theorem boundary_of_ok {δ κ : Type} (E : List (RNode δ κ)) (c1 c2 : List Nat) (mid hi : Nat)
    (h : BoundaryOk E c1 c2 mid hi = true) :
    ∀ k (hk : k < E.length), mid ≤ k → k < hi → ∀ j ∈ E[k].ins, j < mid → certAt c2 j = certAt c1 j := by
  intro k hk h1 h2 j hj hjm
  have := List.all_eq_true.mp h k (List.mem_range.mpr hk)
  rw [List.getElem?_eq_getElem hk] at this
  simp only [h1, h2, decide_true, Bool.and_self, Bool.not_true, Bool.false_or, List.all_eq_true, Bool.or_eq_true,
    Bool.not_eq_true', decide_eq_false_iff_not, decide_eq_true_eq] at this
  rcases this j hj with h' | h'
  · exact absurd hjm h'
  · exact h'

/-! ## The search -/

/-- A closure object's kind from the chosen table. -/
def kindOf (l : List (Nat × Compiled)) (c : Nat) : Option Compiled := (l.find? (·.1 == c)).map (·.2)

/-- The end state's nodes on the template domain `tplDom NL N0 fixed`, read through `N`, at any key type. -/
def domainNodesK {δ κ : Type} (N : Nums δ) (NL N0 : Nat) (fixed : List Int) (x : Ffi.St) :
    Array (Option (RNode δ κ)) := Id.run do
  let kn := kernelName? SourceKernels.sources x
  let mut actual : Array (Option (RNode δ κ)) := Array.replicate x.nnext none
  for i in [:x.nnext] do
    if tplDom NL N0 fixed x i then
      actual := actual.set! i ((x.nodes.get i).bind (resolveNode N kn))
  return actual

private def replayRoot {δ κ : Type} : RPrim δ κ → Option Nat
  | .replayed c p => if elementwise p then some c else none
  | _ => none

/-- **Carriers for the segment `[lo, hi)`** of `expected` among `actual` (a certificate of `expected`'s length):
outside the segment the boundary carriers `bnd` (the arguments below `lo`; `0` where none),
inputs at `ins`, compute_g at its pattern, closure nodes at a replayed body's root (their objects' kinds
recorded), others by primitive and argument carriers (preferring ids from `lower`). -/
def chooseFamD {δ κ : Type} [DecidableEq δ] [DecidableEq κ] (actual : Array (Option (RNode δ κ)))
    (expected : List (RNode δ κ)) (ins : κ → Option Nat) (bnd : Nat → Option Nat) (lo hi lower : Nat) :
    Except String (List Nat × List (Nat × Compiled)) := do
  let graph := fun i => actual[i]?.join
  let mut buckets : Std.HashMap (List Nat) (Array Nat) := {}
  let mut exponentials : Array Nat := #[]
  let mut roots : Array Nat := #[]
  for i in [:actual.size] do
    if let some n := graph i then
      buckets := buckets.insert n.ins ((buckets[n.ins]?).getD #[] |>.push i)
      if isExpD n.prim then exponentials := exponentials.push i
      if (replayRoot n.prim).isSome then roots := roots.push i
  let mut cert : Array Nat := #[]
  let mut used : Std.HashSet Nat := {}
  let mut kinds : List (Nat × Compiled) := []
  for e in expected do
    let k := cert.size
    if hi ≤ k || k < lo then
      cert := cert.push ((bnd k).getD 0)
      continue
    let carrier ← match e.prim with
      | .input key => match ins key with
        | some i => pure i
        | none => throw s!"missing input at expected node {k}"
      | _ => do
        let argC := e.ins.map (cert[·]?.getD 0)
        match closureOf? e.prim with
        | some c =>
          let fits := fun i => argC.all (· < i) && match graph i >>= fun r => replayRoot r.prim with
            | some cls =>
              let trial : Nat → Option Compiled := fun o => if o = cls then (kindOf kinds o).orElse fun _ => some c
                else kindOf kinds o
              decide (closureLeavesD trial graph i = some (c, argC))
            | none => false
          let found := (roots.find? fun i => lower ≤ i && !used.contains i && fits i).orElse fun _ =>
            roots.find? fits
          match found with
          | some i =>
            if let some cls := graph i >>= fun r => replayRoot r.prim then
              if (kindOf kinds cls).isNone then kinds := kinds ++ [(cls, c)]
            pure i
          | none => throw s!"no closure root at expected node {k}; roots={roots.size}; leaves={argC}"
        | none =>
          let candidates := if e.prim = .computeG then exponentials else (buckets[argC]?).getD #[]
          let accepts := fun i => argC.all (· < i) &&
            if e.prim = .computeG then decide (cgLeaves graph i = some argC)
            else !isExpD e.prim && match graph i with
              | none => false
              | some r => decide (strip r.prim = e.prim ∧ (r.prim = e.prim ∨ elementwise e.prim = false) ∧ r.ins = argC)
          let found := (candidates.find? fun i => lower ≤ i && !used.contains i && accepts i).orElse fun _ =>
            (candidates.find? fun i => !used.contains i && accepts i).orElse fun _ => candidates.find? accepts
          match found with
          | some i => pure i
          | none => throw s!"no carrier at expected node {k}; candidates={candidates.size}; ins={argC}"
    cert := cert.push carrier
    used := used.insert carrier
  return (cert.toList, kinds)

/-! ## The commands -/

private def addDefC (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit := do
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private unsafe def chooseFamKey {κ : Type} [DecidableEq κ] [ToExpr κ] (pre : Lean.Name) (x : Ffi.St) (S : SSrv)
    (B : Box) (NL N0 : Nat) (fixed : List Int) (κE E ins : Lean.Expr) (lo hi : Nat) (bnd : Nat → Option Nat) :
    TermElabM Unit := do
  let nodesTy := mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``RNode) (mkConst ``PDim) κE)
  let E ← evalExpr (List (RNode PDim κ)) nodesTy E
  let ins ← evalExpr (κ → Option Nat) (← mkArrow κE (mkApp (mkConst ``Option [.zero]) (mkConst ``Nat))) ins
  let actual : Array (Option (RNode PDim κ)) := domainNodesK (symNumsD (clsOfP S B) PDim.lit) NL N0 fixed x
  let (cert, kinds) ← match chooseFamD actual E ins bnd lo hi N0 with
    | .ok r => pure r
    | .error m => throwError "simgraph_choose_family: {m}"
  addDefC (pre ++ `cert) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (toExpr cert)
  addDefC (pre ++ `kind) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``Nat)
    (mkConst ``Compiled))) (toExpr kinds)
  logInfo m!"simgraph_choose_family {pre}: {cert.length} carriers ({hi - min lo hi} chosen), {kinds.length} closure \
    objects; domain nodes {(actual.toList.filter Option.isSome).length}"

private unsafe def chooseFamCmd (pre : Lean.Name) (x : Ffi.St) (S : SSrv) (B NL N0 fixed E ins lo hi bnd : Lean.Expr) :
    TermElabM Unit := do
  let natTy := mkConst ``Nat
  let B ← evalExpr Box (mkConst ``Box) B
  let NL ← evalExpr Nat natTy NL
  let N0 ← evalExpr Nat natTy N0
  let fixed ← evalExpr (List Int) (mkApp (mkConst ``List [.zero]) (mkConst ``Int)) fixed
  let lo ← evalExpr Nat natTy lo
  let hi ← evalExpr Nat natTy hi
  let bnd ← evalExpr (Nat → Option Nat) (← mkArrow natTy (mkApp (mkConst ``Option [.zero]) natTy)) bnd
  let κE ← match (← whnfR (← inferType E)).getAppFnArgs with
    | (``List, #[t]) => match (← whnfR t).getAppFnArgs with
      | (``RNode, #[_, k]) => pure k
      | _ => throwError "simgraph_choose_family: the expected graph is not a list of resolved nodes"
    | _ => throwError "simgraph_choose_family: the expected graph is not a list"
  match κE.constName? with
  | some ``PKey => chooseFamKey (κ := PKey) pre x S B NL N0 fixed κE E ins lo hi bnd
  | some ``AKey => chooseFamKey (κ := AKey) pre x S B NL N0 fixed κE E ins lo hi bnd
  | some ``InKey => chooseFamKey (κ := InKey) pre x S B NL N0 fixed κE E ins lo hi bnd
  | _ => throwError "simgraph_choose_family: key type {κE} (PKey, AKey or InKey)"

syntax famArgs := term ", " term ", " term ", " term ", " term ", " term ", " term ", " term ", " term

private def famElab (pre : Lean.Name) (x : Ffi.St) (S : SSrv) (args : TSyntax ``famArgs) : TermElabM Unit := do
  let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
  let natTy := mkConst ``Nat
  let option (t : Lean.Expr) := mkApp (mkConst ``Option [.zero]) t
  match args with
  | `(famArgs| $B, $NL, $N0, $fixed, $E, $ins, $lo, $hi, $bnd) => do
    let E ← el E none
    let κ ← match (← whnfR (← inferType E)).getAppFnArgs with
      | (``List, #[t]) => match (← whnfR t).getAppFnArgs with
        | (``RNode, #[_, k]) => pure k
        | _ => throwError "simgraph_choose_family: the expected graph is not a list of resolved nodes"
      | _ => throwError "simgraph_choose_family: the expected graph is not a list"
    unsafe chooseFamCmd pre x S (← el B (mkConst ``Box)) (← el NL natTy) (← el N0 natTy)
      (← el fixed (mkApp (mkConst ``List [.zero]) (mkConst ``Int))) E (← el ins (← mkArrow κ (option natTy)))
      (← el lo natTy) (← el hi natTy) (← el bnd (← mkArrow natTy (option natTy)))
  | _ => throwError "simgraph_choose_family: arguments"

elab "simgraph_choose_family " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " args:famArgs : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let (e, S, _) ← unsafe Host.Ts.Sim.Template.restore (mkConst (← realizeGlobalConstNoOverloadWithInfo sE))
      (mkConst (← realizeGlobalConstNoOverloadWithInfo SE)) `simgraphFamEnd
    famElab ((← getCurrNamespace) ++ name.getId) e.aux.ffi.mlx S args

elab "simgraph_choose_family_at " name:ident " : " x:term ", " S:term ", " args:famArgs : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let x ← unsafe evalExpr Ffi.St (mkConst ``Ffi.St) (← instantiateMVars (← Term.elabTermAndSynthesize x (mkConst ``Ffi.St)))
    let S ← unsafe evalExpr SSrv (mkConst ``SSrv) (← instantiateMVars (← Term.elabTermAndSynthesize S (mkConst ``SSrv)))
    famElab ((← getCurrNamespace) ++ name.getId) x S args

/-- The closure table as a function. -/
def kindFn (l : List (Nat × Compiled)) : Nat → Option Compiled := kindOf l

private def addDefinitionC (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

private def addProofC (name : Lean.Name) (params : Array Lean.Expr) (ty value : Lean.Expr) : TermElabM Unit := do
  addDecl (.thmDecl { name, levelParams := [], type := ← mkForallFVars params ty, value := ← mkLambdaFVars params value })

private partial def listElemsC (e : Lean.Expr) (acc : Array Lean.Expr := #[]) : MetaM (Array Lean.Expr) := do
  let e ← whnfR e
  if e.isAppOfArity ``List.nil 1 then return acc
  unless e.isAppOfArity ``List.cons 3 do throwError "simgraph_check_segment: the choice is not a list literal"
  listElemsC e.appArg! (acc.push e.appFn!.appArg!)

/-- Check `segNodeOk kind g cert ins lo hi` at every node of `es`, each its own `Eq.refl`. -/
private def checkSeg (pre : Lean.Name) (params : Array Lean.Expr) (g kind es d lo hi cert ins choice : Lean.Expr) :
    TermElabM Unit := do
  let nodesTy ← inferType es
  let nodeTy ← match (← whnfR nodesTy).getAppFnArgs with
    | (``List, #[t]) => pure t
    | _ => throwError "simgraph_check_segment: the expected graph is not a list"
  let encode ← mkAppOptM ``Lean.ToExpr.toExpr #[nodesTy, none, choice]
  let lit ← unsafe evalExpr Lean.Expr (mkConst ``Lean.Expr) encode
  let nodes ← listElemsC lit
  let mut exprs := #[]
  for i in [:nodes.size] do
    let nm := pre ++ Name.mkSimple s!"node{i}"
    addDefinitionC nm nodeTy nodes[i]!
    exprs := exprs.push (mkConst nm)
  let mut tails := Array.replicate (nodes.size + 1) (mkConst ``Bool.true)
  for j in [:nodes.size + 1] do
    let i := nodes.size - j
    let nm := pre ++ Name.mkSimple s!"tail{i}"
    let value := if i == nodes.size then mkApp (mkConst ``List.nil [.zero]) nodeTy
      else mkApp3 (mkConst ``List.cons [.zero]) nodeTy exprs[i]! tails[i+1]!
    addDefinitionC nm nodesTy value
    tails := tails.set! i (mkConst nm)
  addProofC (pre ++ `expected_eq) #[] (← mkEq tails[0]! es) (← mkEqRefl tails[0]!)
  let f ← mkAppM ``segNodeOk #[kind, g, cert, ins, lo, hi]
  let mut next := mkConst ``Bool.true
  for j in [:nodes.size + 1] do
    let i := nodes.size - j
    let nm := pre ++ Name.mkSimple s!"all{i}"
    let value ← mkAppM ``checkNodesD #[f, mkRawNatLit i, tails[i]!]
    if i == nodes.size then
      addProofC nm params (← mkEq value (mkConst ``Bool.true)) (← mkEqRefl value)
    else
      let head := pre ++ Name.mkSimple s!"head{i}"
      let hv := mkApp2 f (mkRawNatLit i) exprs[i]!
      addProofC head params (← mkEq hv (mkConst ``Bool.true)) (← mkEqRefl hv)
      let proof ← mkAppM ``checkNodesD_cons #[f, mkRawNatLit i, exprs[i]!, tails[i+1]!, mkAppN (mkConst head) params, next]
      addProofC nm params (← mkEq value (mkConst ``Bool.true)) proof
    next := mkAppN (mkConst nm) params
  let motive ← withLocalDeclD `x nodesTy fun x => do
    mkLambdaFVars #[x] (← mkEq (← mkAppM ``checkNodesD #[f, mkRawNatLit 0, x]) (mkConst ``Bool.true))
  let all ← mkEqNDRec motive next (mkConst (pre ++ `expected_eq))
  addProofC (pre ++ `matches) params
    (← mkEq (← mkAppM ``MatchesSeg #[d, kind, g, es, cert, lo, hi]) (mkConst ``Bool.true))
    (← mkAppM ``matchesSeg_of_checkNodes #[d, kind, g, es, cert, ins, lo, hi, all])
  addProofC (pre ++ `inputs) params
    (← mkEq (← mkAppM ``InputsSeg #[es, cert, ins, lo, hi]) (mkConst ``Bool.true))
    (← mkAppM ``inputsSeg_of_checkNodes #[kind, g, es, cert, ins, lo, hi, all])
  logInfo m!"Kernel-checked the segment of {nodes.size} expected nodes"

private def elabSeg (name : Syntax) (domain : Option Syntax) (graph kind expected d lo hi cert ins chooser : Syntax) :
    CommandElabM Unit :=
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
  let pre := (← getCurrNamespace) ++ name.getId
  let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
  let es ← el expected none
  let nodesTy ← inferType es
  let nodeTy ← match (← whnfR nodesTy).getAppFnArgs with
    | (``List, #[t]) => pure t
    | _ => throwError "simgraph_check_segment: the expected graph is not a list"
  let κ ← match (← whnfR nodeTy).getAppFnArgs with
    | (``RNode, #[_, k]) => pure k
    | _ => throwError "simgraph_check_segment: the expected graph is not a list of resolved nodes"
  let natTy := mkConst ``Nat
  let option (t : Lean.Expr) := mkApp (mkConst ``Option [.zero]) t
  let kind ← el kind (some (← mkArrow natTy (option (mkConst ``Compiled))))
  let d ← el d (some κ)
  let lo ← el lo (some natTy)
  let hi ← el hi (some natTy)
  let cert ← el cert (some (mkApp (mkConst ``List [.zero]) natTy))
  let ins ← el ins (some (← mkArrow κ (option natTy)))
  let choice ← el chooser (some nodesTy)
  let graphTy ← mkArrow natTy (option nodeTy)
  match domain with
  | none => checkSeg pre #[] (← el graph (some graphTy)) kind es d lo hi cert ins choice
  | some domain =>
    let ty ← el domain (some (mkSort (.succ .zero)))
    let g ← el graph (some (← mkArrow ty graphTy))
    withLocalDeclD `parameter ty fun parameter =>
      checkSeg pre #[parameter] (mkApp g parameter) kind es d lo hi cert ins choice

elab "simgraph_check_segment " name:ident " : " graph:term ", " kind:term ", " expected:term ", " d:term ", "
    lo:term ", " hi:term ", " certificate:term ", " inputs:term " choosing " chooser:term : command =>
  elabSeg name none graph kind expected d lo hi certificate inputs chooser

elab "simgraph_check_segments " name:ident " : " domain:term ", " graph:term ", " kind:term ", " expected:term ", "
    d:term ", " lo:term ", " hi:term ", " certificate:term ", " inputs:term " choosing " chooser:term : command =>
  elabSeg name (some domain) graph kind expected d lo hi certificate inputs chooser

end Host.Mlx.SimGraph
