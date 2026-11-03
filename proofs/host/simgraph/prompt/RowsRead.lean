import host.simgraph.prompt.ChooseRoute
set_option autoImplicit false
namespace Host.Mlx.SimGraph
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Load.Run.Full

/-! # A family's dimensions at a chain's reading

A chain reads the reference's dimensions at its own variables (`rowsAt`) or, on a literal row, as their values (`litAt`). -/

/-- A dimension as a literal row's chain holds it: its value. -/
def litAt (nu : Nat → Int) (d : PDim) : PDim := .lit (d.eval nu)

/-- Two equal numbers, a literal's included. -/
def sameNumL (a b : NumV) : Bool := decide (a = b)

/-- The numbers a dimension data node's bytes hold, literal or not. -/
def cellsNumsL : List Byte → Option (List NumV)
  | [] => some []
  | b0 :: b1 :: b2 :: b3 :: r => match cellAt 0 b0, cellAt 1 b1, cellAt 2 b2, cellAt 3 b3 with
    | some a, some a1, some a2, some a3 =>
      if sameNumL a a1 && sameNumL a a2 && sameNumL a a3 then (cellsNumsL r).map (a :: ·) else none
    | _, _, _, _ => none
  | _ => none

theorem sameNum_L {a b : NumV} (h : sameNum a b = true) : sameNumL a b = true := by
  cases a <;> cases b <;> simp_all [sameNum, sameNumL]

theorem cellsNums_L : ∀ (b : List Byte) (xs : List NumV), cellsNums b = some xs → cellsNumsL b = some xs
  | [], xs, h => by simpa [cellsNums, cellsNumsL] using h
  | [_], _, h => by simp [cellsNums] at h
  | [_, _], _, h => by simp [cellsNums] at h
  | [_, _, _], _, h => by simp [cellsNums] at h
  | b0 :: b1 :: b2 :: b3 :: r, xs, h => by
    unfold cellsNums at h
    unfold cellsNumsL
    revert h
    generalize cellAt 0 b0 = c0
    generalize cellAt 1 b1 = c1
    generalize cellAt 2 b2 = c2
    generalize cellAt 3 b3 = c3
    intro h
    rcases c0 with _ | a <;> rcases c1 with _ | a1 <;> rcases c2 with _ | a2 <;> rcases c3 with _ | a3 <;>
      first | cases h | skip
    dsimp only at h ⊢
    split at h
    · rename_i hs
      simp only [Bool.and_eq_true] at hs
      obtain ⟨⟨e1, e2⟩, e3⟩ := hs
      obtain ⟨xs', hr, rfl⟩ := Option.map_eq_some_iff.mp h
      rw [if_pos (by simp only [Bool.and_eq_true]; exact ⟨⟨sameNum_L e1, sameNum_L e2⟩, sameNum_L e3⟩), cellsNums_L r xs' hr]
      rfl
    · cases h

/-- `cellKeyOk` at any reading of the reference's dimensions. -/
def cellKeyOkR (r : PDim → PDim) (S : SSrv) (B : Box) (fixed : List Int) (s : Ffi.St) (ins : SimGraph.PKey → Option Nat) :
    SimGraph.PKey → Bool
  | .cells p j vals shape => match ins (.cells p j vals shape) with
    | some c => routeDom 15235 15235 fixed s c && match s.nodes.get c with
      | some nd => match nd.prim with
        | .data b => match cellsNumsL b with
          | some xs => nd.ins.isEmpty && decide (nd.dtype = Ffi.dtInt32) &&
              decide (xs.mapM (clsOfX S B) = some (vals.map r)) &&
              decide (nd.shape.mapM (symNumsD (clsOfX S B) PDim.lit).d = some (shape.map r))
          | none => false
        | _ => false
      | none => false
    | none => false
  | .iota p j count => match ins (.iota p j count), r count with
    | some c, .lit N => routeDom 15235 15235 fixed s c && match s.nodes.get c with
      | some nd => match nd.prim with
        | .data b => match cellsNumsL b with
          | some xs => nd.ins.isEmpty && decide (nd.dtype = Ffi.dtInt32) &&
              decide (xs.mapM (clsOfX S B) = some ((List.range N.toNat).map fun (k : Nat) => PDim.lit (Int.ofNat k))) &&
              decide (nd.shape.mapM (symNumsD (clsOfX S B) PDim.lit).d = some [PDim.lit N])
          | none => false
        | _ => false
      | none => false
    | _, _ => false
  | _ => true

/-- Node `k`'s dimension input is held. -/
def cellNodeOkR (r : PDim → PDim) (S : SSrv) (B : Box) (fixed : List Int) (s : Ffi.St) (ins : SimGraph.PKey → Option Nat)
    (_ : Nat) (e : RNode PDim SimGraph.PKey) : Bool :=
  match e.prim with
  | .input key => cellKeyOkR r S B fixed s ins key
  | _ => true

/-- Node `k`'s kernel is plain and its dimension input held. -/
def extraOkR (G : Nat → Option (RNode PDim SimGraph.PKey)) (cert : List Nat) (r : PDim → PDim) (S : SSrv) (B : Box) (fixed : List Int)
    (s : Ffi.St) (ins : SimGraph.PKey → Option Nat) (k : Nat) (e : RNode PDim SimGraph.PKey) : Bool :=
  plainKOk G cert k e && cellNodeOkR r S B fixed s ins k e

theorem cellKeyOkR_of {x : Nat} {S : SSrv} {B : Box} {fixed : List Int} {s : Ffi.St} {ins : SimGraph.PKey → Option Nat}
    {key : SimGraph.PKey} (h : cellKeyOk x S B fixed s ins key = true) : cellKeyOkR (rowsAt x) S B fixed s ins key = true := by
  cases key with
  | cells p j vals shape =>
    simp only [cellKeyOk] at h
    simp only [cellKeyOkR]
    generalize ins (.cells p j vals shape) = o at h ⊢
    cases o with
    | none => exact h
    | some c =>
      dsimp only at h ⊢
      generalize s.nodes.get c = on at h ⊢
      cases on with
      | none => simp at h
      | some nd =>
        obtain ⟨prim, ins', sh, dt⟩ := nd
        cases prim with
        | data b =>
          dsimp only at h ⊢
          cases hb : cellsNums b with
          | none => rw [hb] at h; simp at h
          | some xs => rw [hb] at h; rw [cellsNums_L b xs hb]; exact h
        | _ => simp at h
  | iota p j count => simp [cellKeyOk] at h
  | _ => exact h

theorem extraOkR_of {G : Nat → Option (RNode PDim SimGraph.PKey)} {cert : List Nat} {x : Nat} {S : SSrv} {B : Box}
    {fixed : List Int} {s : Ffi.St} {ins : SimGraph.PKey → Option Nat} {k : Nat} {e : RNode PDim SimGraph.PKey}
    (h : extraOk G cert x S B fixed s ins k e = true) : extraOkR G cert (rowsAt x) S B fixed s ins k e = true := by
  unfold extraOk at h
  unfold extraOkR cellNodeOkR
  simp only [Bool.and_eq_true] at h ⊢
  refine ⟨h.1, ?_⟩
  have h2 := h.2
  unfold cellNodeOk at h2
  revert h2
  cases e.prim with
  | input key => exact cellKeyOkR_of
  | _ => exact id

theorem checkNodesD_mono {δ κ : Type} {f g : Nat → RNode δ κ → Bool} (hfg : ∀ k e, f k e = true → g k e = true) :
    ∀ (i : Nat) (E : List (RNode δ κ)), checkNodesD f i E = true → checkNodesD g i E = true
  | _, [] => fun _ => rfl
  | i, e :: es => fun h => by
    simp only [checkNodesD, Bool.and_eq_true] at h ⊢
    exact ⟨hfg i e h.1, checkNodesD_mono hfg (i + 1) es h.2⟩

/-- A family's dimension inputs on a literal row: each key's value at the chain's reading. -/
def auxKeys (E : List (RNode PDim SimGraph.PKey)) : List (SimGraph.PKey) :=
  E.filterMap fun nd => match nd.prim with
    | .input key => (auxId key).map fun _ => key
    | _ => none

/-- The carriers of a literal row's dimension inputs: in the template's order, the next data node holding each one's cells. -/
def literalCells (x : Ffi.St) (S : SSrv) (B : Box) (fixed : List Int) (N0 : Nat) (r : PDim → PDim)
    (keys : List SimGraph.PKey) : Except String (List ((Nat × Nat) × Nat)) := do
  let mut from_ := N0 + 1
  let mut out : List ((Nat × Nat) × Nat) := []
  for key in keys do
    let want : Option (List PDim × List PDim) := match key with
      | .cells _ _ vals shape => some (vals.map r, shape.map r)
      | .iota _ _ count => match r count with
        | .lit N => some ((List.range N.toNat).map fun (k : Nat) => PDim.lit (Int.ofNat k), [PDim.lit N])
        | _ => none
      | _ => none
    match want, auxId key with
    | some (vals, shape), some a =>
      let mut found : Option Nat := none
      for i in [from_:x.nnext] do
        if routeDom 15235 15235 fixed x i then
          match x.nodes.get i with
          | some nd => match nd.prim with
            | .data b => match cellsNumsL b with
              | some xs =>
                if nd.ins.isEmpty && decide (nd.dtype = Ffi.dtInt32) && decide (xs.mapM (clsOfX S B) = some vals) &&
                    decide (nd.shape.mapM (symNumsD (clsOfX S B) PDim.lit).d = some shape) then
                  found := some i
                  break
              | none => pure ()
            | _ => pure ()
          | none => pure ()
      match found with
      | some i =>
        out := (a, i) :: out
        from_ := i + 1
      | none => throw s!"no data node holds the cells of input {a} after node {from_}"
    | _, _ => throw "a dimension input that is neither cells nor a literal iota"
  return out.reverse

private def addDefL (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

private unsafe def chooseRouteL (pre : Lean.Name) (x : Ffi.St) (S : SSrv) (B NL N0 fixed E promptN r : Lean.Expr) :
    TermElabM Unit := do
  let natTy := mkConst ``Nat
  let B ← evalExpr Box (mkConst ``Box) B
  let NL ← evalExpr Nat natTy NL
  let N0 ← evalExpr Nat natTy N0
  let promptN ← evalExpr Nat natTy promptN
  let fixed ← evalExpr (List Int) (mkApp (mkConst ``List [.zero]) (mkConst ``Int)) fixed
  let expected ← evalExpr (List (RNode PDim SimGraph.PKey)) (← inferType E) E
  let rf ← evalExpr (PDim → PDim) (← mkArrow (mkConst ``PDim) (mkConst ``PDim)) r
  let N := symNumsD (clsOfX S B) PDim.lit
  let kn := routeKernelName? SourceKernels.sources x
  let mut actual : Array (Option (RNode PDim SimGraph.PKey)) := Array.replicate x.nnext none
  for i in [:x.nnext] do
    if routeDom NL N0 fixed x i then
      actual := actual.set! i ((x.nodes.get i).bind (resolveNode N kn))
  let cells ← match literalCells x S B fixed N0 rf (auxKeys expected) with
    | .ok c => pure c
    | .error m => throwError "simgraph_choose_route_lit: {m}"
  match chooseFamD actual expected (insOf promptN cells) (fun _ => none) 0 expected.length N0 with
  | .error m => throwError "simgraph_choose_route_lit: {m}"
  | .ok (cert, kinds) =>
    addDefL (pre ++ `cert) (mkApp (mkConst ``List [.zero]) natTy) (toExpr cert)
    addDefL (pre ++ `kind) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) natTy
      (mkConst ``Compiled))) (toExpr kinds)
    addDefL (pre ++ `cells) (toTypeExpr (List ((Nat × Nat) × Nat))) (toExpr cells)
    logInfo m!"simgraph_choose_route_lit {pre}: {cert.length} carriers, {kinds.length} closure objects, \
      {cells.length} dimension inputs"

/-- `simgraph_choose_route` on a literal row: the dimension inputs' data nodes resolve, so they are found by their cells at the
reading `r`. Nothing here is trusted. -/
elab "simgraph_choose_route_lit " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " B:term ", " NL:term ", " N0:term ", "
    fixed:term ", " E:term ", " promptN:term ", " r:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let (e, S, _) ← unsafe Host.Ts.Sim.Template.restore (mkConst (← realizeGlobalConstNoOverloadWithInfo sE))
      (mkConst (← realizeGlobalConstNoOverloadWithInfo SE)) `simgraphRouteEnd
    let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
    let natTy := mkConst ``Nat
    unsafe chooseRouteL ((← getCurrNamespace) ++ name.getId) e.aux.ffi.mlx S (← el B (mkConst ``Box)) (← el NL natTy)
      (← el N0 natTy) (← el fixed (mkApp (mkConst ``List [.zero]) (mkConst ``Int))) (← el E none) (← el promptN natTy)
      (← el r none)

end Host.Mlx.SimGraph
