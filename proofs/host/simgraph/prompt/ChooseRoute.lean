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
  | .base b => inputNode parameterChoice parameterChoice.model.finalNorm b
  | key => (auxId key).bind fun a => (cells.find? (·.1 == a)).map (·.2)

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

end Host.Mlx.SimGraph
