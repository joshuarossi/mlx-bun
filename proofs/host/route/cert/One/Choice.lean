import host.sim.compose.a4b.GraphColdEval
import host.sim.compose.a4b.GraphColdFullExpected
import host.simgraph.Choose
import host.simgraph.prompt.ChooseRoute
import host.sim.template.a4pre_d1_body.Endpoint
import host.sim.template.a4pre_pl_common.H0
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.One
open Lean Elab Command Meta
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl Host.Load.Run.Full Host.Load.Extract
open Host.Ts.Sim.Full (mlxOf)
open Host.Ts.Sim.Compose.ColdGraph (fullExpected coldNums)

/-! # The one-token prompt's choice of carriers (search only)

The first step's forward part is on the template at the forward's return, its head and sampler at the sampled cut, under one numbering.
Nothing here is trusted: the kernel checks each part on its own template. -/

def boxH : Box := [(9, 1, 1), (10, 1, 1), (11, 1, 1), (16, 256, 256)]

/-- The constant valuation of the box. -/
def nuH (j : Nat) : Int := if j = 16 then 256 else 1

/-- A number's value at the box's valuation. -/
def clsH (S : SSrv) (x : NumV) : Option PDim := (clsOfX S boxH x).map fun d => PDim.lit (d.eval nuH)

/-- The expected graph, built natively. -/
def Ecn : List (RNode PDim InKey) :=
  (stepGraph Expected.stages Expected.head 0).1.map (Host.Mlx.SimGraph.mapN PDim.lit)

/-- The first step's caches, empty. -/
def cacheInputs : List (Option Nat × Option Nat) := List.replicate 64 (none, none)

noncomputable def loadF : St Host.Load.LSt :=
  ⟨D1Body.s155.heap, D1Body.s155.next, D1Body.s155.ctl, D1Body.s155.stack,
    ⟨D1Body.s155.aux.jobs, Host.Load.Layers.toLoad D1Body.s155.aux.ffi, D1Body.s155.aux.trace, D1Body.s155.aux.stores⟩⟩
noncomputable def loadH : St Host.Load.LSt :=
  ⟨PRE_pl_common.s1.heap, PRE_pl_common.s1.next, PRE_pl_common.s1.ctl, PRE_pl_common.s1.stack,
    ⟨PRE_pl_common.s1.aux.jobs, Host.Load.Layers.toLoad PRE_pl_common.s1.aux.ffi, PRE_pl_common.s1.aux.trace,
      PRE_pl_common.s1.aux.stores⟩⟩

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(`srvF, ``D1Body.S155), (`srvH, ``PRE_pl_common.S1)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst ``SSrv, value := value, hints := .regular 0, safety := .safe })

private def addDef (name : Lean.Name) (type value : Lean.Expr) : TermElabM Unit := do
  addDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })
  compileDecl (.defnDecl { name, levelParams := [], type, value, hints := .regular 0, safety := .safe })

private unsafe def chooseOne (pre : Lean.Name) : TermElabM Unit := do
  let (eF, SF, _) ← Host.Ts.Sim.Template.restore (mkConst ``loadF) (mkConst ``srvF) `simgraphF
  let (eH, SH, _) ← Host.Ts.Sim.Template.restore (mkConst ``loadH) (mkConst ``srvH) `simgraphH
  let xF := eF.aux.ffi.mlx
  let xH := eH.aux.ffi.mlx
  let aF := domainNodes (coldNums SF) 15235 15235 [5554869888] xF
  let aH := domainNodes (symNumsD (clsH SH) PDim.lit) 15235 15235 [5554869888] xH
  let actual := (List.range (max aF.size aH.size)).toArray.map fun i => match aF[i]?.join with
    | some r => some r
    | none => aH[i]?.join
  let inputs := inputNode parameterChoice ⟨0, 15235, ⟨.zeros, [], [], 0⟩⟩
  let cert ← match chooseD actual Ecn inputs 15235 with
    | .ok c => pure c
    | .error m => throwError "simgraph_choose_one: {m}"
  let used : List (InKey × Nat) := (Ecn.zip cert).filterMap fun (n, c) => match n.prim with
    | .input key => some (key, c)
    | _ => none
  addDef (pre ++ `cert) (mkApp (mkConst ``List [.zero]) (mkConst ``Nat)) (toExpr cert)
  let pairTy := mkApp2 (mkConst ``Prod [.zero, .zero]) (mkConst ``InKey) (mkConst ``Nat)
  addDef (pre ++ `inputs) (mkApp (mkConst ``List [.zero]) pairTy) (toExpr used)
  logInfo m!"simgraph_choose_one {pre}: {cert.length} carriers, {used.length} inputs, nnext {xF.nnext} and {xH.nnext}, hidden {cert.getD 4009 0}"

set_option interpreter.prefer_native false in
run_elab do
  unsafe chooseOne ((← getCurrNamespace) ++ `choice)

def insT : InKey → Option Nat := inputsOf choice.inputs

theorem eval_literal_node (ν : Nat → Int) (r : RNode Int InKey) :
    Host.Mlx.SimGraph.mapN (PDim.eval ν) (Host.Mlx.SimGraph.mapN PDim.lit r) = r := by
  change ⟨mapP (PDim.eval ν) (mapP PDim.lit r.prim), r.ins⟩ = r
  rw [mapP_comp]
  exact mapN_id r

theorem full_expected_eval (ν : Nat → Int) :
    fullExpected.1.map (Host.Mlx.SimGraph.mapN (PDim.eval ν)) = Expected.graph := by
  change (Expected.graph.map (Host.Mlx.SimGraph.mapN PDim.lit)).map (Host.Mlx.SimGraph.mapN (PDim.eval ν)) = _
  have hf : (Host.Mlx.SimGraph.mapN (PDim.eval ν) ∘ Host.Mlx.SimGraph.mapN PDim.lit :
      RNode Int InKey → RNode Int InKey) = id :=
    funext (eval_literal_node ν)
  rw [List.map_map, hf, List.map_id]

end Host.Route.Cert.One
