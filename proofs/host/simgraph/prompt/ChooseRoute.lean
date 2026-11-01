import host.simgraph.prompt.ChooseFamily
import host.simgraph.prompt.NormalizeX
import host.mlx.RouteKernel
import host.simgraph.GenLoadRel
import host.load.Inputs
import host.load.run.full.Initial
namespace Host.Mlx.SimGraph
open Lean Elab Command Meta Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Load.Extract Host.Load.Run.Full

/-! # A row family's certificate on a forward's end state

A prefill forward's end state read for the family's expected graph (`familyGraph`), through the route's kernel table and
the exact-quotient classifier (`clsOfX`):

* `symGraphR`: the template graph with `routeKernelName?` (`symGraphD` reads the decode kernels only).
* `routeDom NL N0 fixed s`: `exactTplDom` without `arange`, which the route resolves to data and a template reads as
  unsupported. A family reads it as an input.
* `insOf cells`: the input carriers: the prompt's ids at the node `promptN`, the checkpoint's at the loaded model's, the
  dimension data at `cells`.
* `simgraph_choose_route X : (sEnd, SEnd), B, NL, N0, fixed, E, promptN`: defines `X.cert`, `X.kind`, `X.cells`. The state
  is read by restoring its stream; a dimension data node holds a symbolic number, so it does not resolve, and those nodes
  in order are the family's dimension inputs in order. Nothing here is trusted: `simgraph_check_segment` checks it. -/

/-- The template graph with the route's kernel table. -/
def symGraphR {δ κ : Type} (cls : NumV → Option δ) (lit : Int → δ) (Ks : KernelSources) (s : Ffi.St) :
    Nat → Option (RNode δ κ) := fun i =>
  (s.nodes.get i).bind (resolveNode (symNumsD cls lit) (routeKernelName? Ks s))

/-- Not an `arange`, under its replay tags. -/
def notArange : Ffi.Prim → Bool
  | .arange _ _ _ => false
  | .replayed _ p => notArange p
  | _ => true

/-- The certificate's domain. -/
def routeDom (NL N0 : Nat) (fixed : List Int) (s : Ffi.St) (i : Nat) : Bool :=
  exactTplDom NL N0 fixed s i && match s.nodes.get i with
    | some nd => notArange nd.prim
    | none => true

/-- A dimension input's stage and index. -/
def auxId : SimGraph.PKey → Option (Nat × Nat)
  | .cells p j _ _ => some (p, j)
  | .iota p j _ => some (p, j)
  | _ => none

/-- The family's dimension inputs, in order. -/
def auxInputsOf (E : List (RNode PDim SimGraph.PKey)) : List (Nat × Nat) :=
  E.filterMap fun nd => match nd.prim with
    | .input key => auxId key
    | _ => none

/-- The input carriers. -/
def insOf (promptN : Nat) (cells : List ((Nat × Nat) × Nat)) : SimGraph.PKey → Option Nat
  | .promptIds => some promptN
  | .base .tokenIds => none
  | .base b => inputNode parameterChoice parameterChoice.model.finalNorm b
  | key => (auxId key).bind fun a => (cells.find? (·.1 == a)).map (·.2)

/-- The terms at the rows' variable. -/
def rowsTerms (x : Nat) (ts : List (Int × Nat)) : List (Int × Nat) :=
  ts.filterMap fun t => if t.2 = 1 then some (t.1, x) else none

/-- A reference dimension at offset `0` and the rows at variable `x`. -/
def rowsAt (x : Nat) : PDim → PDim
  | .lit i => .lit i
  | .lin c ts => Aff.toP ⟨c, rowsTerms x ts⟩
  | .fdiv d k => .fdiv (rowsAt x d) k
  | .cdiv d k => .cdiv (rowsAt x d) k
  | .rup k d => .rup k (rowsAt x d)

/-- The chain's end graph, on the certificate's domain. -/
noncomputable def famGs (s : Ffi.St) (S : SSrv) (B : Box) (fixed : List Int) : Nat → Option (RNode PDim SimGraph.PKey) :=
  restrictTo (routeDom 15235 15235 fixed s) (symGraphR (clsOfX S B) PDim.lit SourceKernels.sources s)

/-- Two equal numbers. -/
def sameNum : NumV → NumV → Bool
  | .ref i, .ref j => i == j
  | _, _ => false

/-- A byte of an int32 cell. -/
def cellAt (i : Nat) : Byte → Option NumV
  | .part .i32 (.num a) j => if j = i then some a else none
  | _ => none

/-- The numbers a dimension data node's bytes hold. -/
def cellsNums : List Byte → Option (List NumV)
  | [] => some []
  | b0 :: b1 :: b2 :: b3 :: r => match cellAt 0 b0, cellAt 1 b1, cellAt 2 b2, cellAt 3 b3 with
    | some a, some a1, some a2, some a3 =>
      if sameNum a a1 && sameNum a a2 && sameNum a a3 then (cellsNums r).map (a :: ·) else none
    | _, _, _, _ => none
  | _ => none

/-- A family's dimension input: its carrier holds the cells, as the chain reads them at variable `x`. -/
def cellKeyOk (x : Nat) (S : SSrv) (B : Box) (fixed : List Int) (s : Ffi.St) (ins : SimGraph.PKey → Option Nat) :
    SimGraph.PKey → Bool
  | .cells p j vals shape => match ins (.cells p j vals shape) with
    | some c => routeDom 15235 15235 fixed s c && match s.nodes.get c with
      | some nd => match nd.prim with
        | .data b => match cellsNums b with
          | some xs => nd.ins.isEmpty && decide (nd.dtype = Ffi.dtInt32) &&
              decide (xs.mapM (clsOfX S B) = some (vals.map (rowsAt x))) &&
              decide (nd.shape.mapM (symNumsD (clsOfX S B) PDim.lit).d = some (shape.map (rowsAt x)))
          | none => false
        | _ => false
      | none => false
    | none => false
  | .iota _ _ _ => false
  | _ => true

/-- Node `k`'s dimension input is held. -/
def cellNodeOk (x : Nat) (S : SSrv) (B : Box) (fixed : List Int) (s : Ffi.St) (ins : SimGraph.PKey → Option Nat)
    (_ : Nat) (e : RNode PDim SimGraph.PKey) : Bool :=
  match e.prim with
  | .input key => cellKeyOk x S B fixed s ins key
  | _ => true

/-- Node `k`'s kernel is at its carrier unreplayed. -/
def plainKOk (G : Nat → Option (RNode PDim SimGraph.PKey)) (cert : List Nat) (k : Nat) (e : RNode PDim SimGraph.PKey) : Bool :=
  match e.prim with
  | .kernel _ _ _ => match G (certAt cert k) with
    | some r => decide (r.prim = e.prim)
    | none => false
  | _ => true

/-- Node `k`'s kernel is plain and its dimension input held. -/
def extraOk (G : Nat → Option (RNode PDim SimGraph.PKey)) (cert : List Nat) (x : Nat) (S : SSrv) (B : Box) (fixed : List Int)
    (s : Ffi.St) (ins : SimGraph.PKey → Option Nat) (k : Nat) (e : RNode PDim SimGraph.PKey) : Bool :=
  plainKOk G cert k e && cellNodeOk x S B fixed s ins k e

private def addDefR (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.defnDecl { name, levelParams := [], type := ty, value, hints := .regular 0, safety := .safe })

private unsafe def chooseRoute (pre : Lean.Name) (x : Ffi.St) (S : SSrv) (B NL N0 fixed E promptN : Lean.Expr) :
    TermElabM Unit := do
  let natTy := mkConst ``Nat
  let B ← evalExpr Box (mkConst ``Box) B
  let NL ← evalExpr Nat natTy NL
  let N0 ← evalExpr Nat natTy N0
  let promptN ← evalExpr Nat natTy promptN
  let fixed ← evalExpr (List Int) (mkApp (mkConst ``List [.zero]) (mkConst ``Int)) fixed
  let expected ← evalExpr (List (RNode PDim SimGraph.PKey)) (← inferType E) E
  let N := symNumsD (clsOfX S B) PDim.lit
  let kn := routeKernelName? SourceKernels.sources x
  let mut actual : Array (Option (RNode PDim SimGraph.PKey)) := Array.replicate x.nnext none
  for i in [:x.nnext] do
    if routeDom NL N0 fixed x i then
      actual := actual.set! i ((x.nodes.get i).bind (resolveNode N kn))
  let unresolved := (List.range actual.size).filter fun i =>
    decide (N0 < i) && (actual[i]?.join).isNone && notArangeAt x i
  let aux := auxInputsOf expected
  unless aux.length == unresolved.length do
    throwError "simgraph_choose_route: {aux.length} dimension inputs, {unresolved.length} unresolved nodes"
  let cells := aux.zip unresolved
  match chooseFamD actual expected (insOf promptN cells) (fun _ => none) 0 expected.length N0 with
  | .error m => throwError "simgraph_choose_route: {m}"
  | .ok (cert, kinds) =>
    addDefR (pre ++ `cert) (mkApp (mkConst ``List [.zero]) natTy) (toExpr cert)
    addDefR (pre ++ `kind) (mkApp (mkConst ``List [.zero]) (mkApp2 (mkConst ``Prod [.zero, .zero]) natTy
      (mkConst ``Compiled))) (toExpr kinds)
    addDefR (pre ++ `cells) (toTypeExpr (List ((Nat × Nat) × Nat))) (toExpr cells)
    logInfo m!"simgraph_choose_route {pre}: {cert.length} carriers, {kinds.length} closure objects, \
      {cells.length} dimension inputs"
where
  notArangeAt (x : Ffi.St) (i : Nat) : Bool := match x.nodes.get i with
    | some nd => notArange nd.prim
    | none => false

elab "simgraph_choose_route " name:ident " : " "(" sE:ident ", " SE:ident ")" ", " B:term ", " NL:term ", " N0:term ", "
    fixed:term ", " E:term ", " promptN:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let (e, S, _) ← unsafe Host.Ts.Sim.Template.restore (mkConst (← realizeGlobalConstNoOverloadWithInfo sE))
      (mkConst (← realizeGlobalConstNoOverloadWithInfo SE)) `simgraphRouteEnd
    let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
    let natTy := mkConst ``Nat
    unsafe chooseRoute ((← getCurrNamespace) ++ name.getId) e.aux.ffi.mlx S (← el B (mkConst ``Box)) (← el NL natTy)
      (← el N0 natTy) (← el fixed (mkApp (mkConst ``List [.zero]) (mkConst ``Int))) (← el E none) (← el promptN natTy)

private def addThmR (name : Lean.Name) (ty value : Lean.Expr) : TermElabM Unit :=
  addDecl (.thmDecl { name, levelParams := [], type := ty, value })

private partial def listElemsR (e : Lean.Expr) (acc : Array Lean.Expr := #[]) : MetaM (Array Lean.Expr) := do
  let e ← whnfR e
  if e.isAppOfArity ``List.nil 1 then return acc
  unless e.isAppOfArity ``List.cons 3 do throwError "simgraph_check_nodes: the choice is not a list literal"
  listElemsR e.appArg! (acc.push e.appFn!.appArg!)

/-- `simgraph_check_nodes X : f, E choosing C`: `f` at every node of `E`, each its own `Eq.refl`; `X.all :
checkNodesD f 0 E = true`. `C` is the same list in compiled form. -/
elab "simgraph_check_nodes " name:ident " : " f:term ", " expected:term " choosing " chooser:term : command =>
  liftTermElabM <| withOptions (fun o => o.setBool `Elab.async false) do
    let pre := (← getCurrNamespace) ++ name.getId
    let el (stx : Syntax) (ty : Option Lean.Expr) := do instantiateMVars (← Term.elabTermAndSynthesize stx ty)
    let es ← el expected none
    let nodesTy ← inferType es
    let nodeTy ← match (← whnfR nodesTy).getAppFnArgs with
      | (``List, #[t]) => pure t
      | _ => throwError "simgraph_check_nodes: the expected graph is not a list"
    let f ← el f (some (← mkArrow (mkConst ``Nat) (← mkArrow nodeTy (mkConst ``Bool))))
    let choice ← el chooser (some nodesTy)
    let encode ← mkAppOptM ``Lean.ToExpr.toExpr #[nodesTy, none, choice]
    let lit ← unsafe evalExpr Lean.Expr (mkConst ``Lean.Expr) encode
    let nodes ← listElemsR lit
    let mut exprs := #[]
    for i in [:nodes.size] do
      let nm := pre ++ Name.mkSimple s!"node{i}"
      addDefR nm nodeTy nodes[i]!
      exprs := exprs.push (mkConst nm)
    let mut tails := Array.replicate (nodes.size + 1) (mkConst ``Bool.true)
    for j in [:nodes.size + 1] do
      let i := nodes.size - j
      let nm := pre ++ Name.mkSimple s!"tail{i}"
      let value := if i == nodes.size then mkApp (mkConst ``List.nil [.zero]) nodeTy
        else mkApp3 (mkConst ``List.cons [.zero]) nodeTy exprs[i]! tails[i+1]!
      addDefR nm nodesTy value
      tails := tails.set! i (mkConst nm)
    addThmR (pre ++ `expected_eq) (← mkEq tails[0]! es) (← mkEqRefl tails[0]!)
    let mut next := mkConst ``Bool.true
    for j in [:nodes.size + 1] do
      let i := nodes.size - j
      let nm := pre ++ Name.mkSimple s!"all{i}"
      let value ← mkAppM ``checkNodesD #[f, mkRawNatLit i, tails[i]!]
      if i == nodes.size then
        addThmR nm (← mkEq value (mkConst ``Bool.true)) (← mkEqRefl value)
      else
        let head := pre ++ Name.mkSimple s!"head{i}"
        let hv := mkApp2 f (mkRawNatLit i) exprs[i]!
        addThmR head (← mkEq hv (mkConst ``Bool.true)) (← mkEqRefl hv)
        let proof ← mkAppM ``checkNodesD_cons #[f, mkRawNatLit i, exprs[i]!, tails[i+1]!, mkConst head, next]
        addThmR nm (← mkEq value (mkConst ``Bool.true)) proof
      next := mkConst nm
    let motive ← withLocalDeclD `x nodesTy fun x => do
      mkLambdaFVars #[x] (← mkEq (← mkAppM ``checkNodesD #[f, mkRawNatLit 0, x]) (mkConst ``Bool.true))
    addThmR (pre ++ `all) (← mkEq (← mkAppM ``checkNodesD #[f, mkRawNatLit 0, es]) (mkConst ``Bool.true))
      (← mkEqNDRec motive next (mkConst (pre ++ `expected_eq)))
    logInfo m!"Kernel-checked {nodes.size} nodes"

end Host.Mlx.SimGraph
