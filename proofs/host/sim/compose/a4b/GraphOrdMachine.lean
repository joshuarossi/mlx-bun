import host.sim.compose.a4b.GraphOrd
import host.sim.compose.a4b.GraphStart
import host.sim.compose.a4b.GraphOrdInputs
import host.sim.compose.MachAt
import host.simgraph.iter.InputsPrefix
import host.simgraph.mach.DecodeLayout
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.DECGraph.Ord
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Run.Full _root_.Host.Mlx _root_.Host.Mlx.GlueStep
open _root_.Host.Load.Program
open _root_.Host.Ts.Sim.Full (fullWorldFb)
open _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Iter
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

section
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = Host.Load.Run.Full.Cached.Expected2.stages)
  (hhead : linLayout .affineRow w.head = Host.Load.Run.Full.Cached.Expected2.head)

theorem t_hs0 : (T w hs₀ hcaps₀ hlay hhead).hs₀ = hs₀ := rfl
theorem t_n0 : (T w hs₀ hcaps₀ hlay hhead).n₀ = 1 := rfl
theorem t_cert : (T w hs₀ hcaps₀ hlay hhead).cert = choice.cert := rfl
end

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  (env : FfiEval.Env InKey)

theorem layout_eq (table : List F64) :
    chainLayout (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles 256) =
      Host.Load.Run.Full.Cached.Expected2.stages := by
  exact Host.Mlx.SimGraph.Mach.decode_layout (contents M K env (firstFfiGraph table))

theorem head_eq (table : List F64) :
    linLayout .affineRow (weights (firstValues M K env table)).head =
      Host.Load.Run.Full.Cached.Expected2.head := by
  exact Host.Mlx.SimGraph.Mach.decode_head_layout (contents M K env (firstFfiGraph table))

theorem caps_eq (table : List F64) :
    CapsFor 256 (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles 256) := by
  exact Host.Mlx.SimGraph.Mach.decode_layout_caps (contents M K env (firstFfiGraph table))

/-- The actual ordinary end supplies the machine-reference template at its world's fixed prefix. -/
theorem caseTpl (b0 : Host.Mlx.FfiAne.St) (NB L i : Nat) (hNB : 15235 ≤ NB)
    (hsmall : L + i + 2 < 2 ^ 31) (interior : L + i + 2 < capL (L + i + 1)) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt DEC.inputs L
      Host.Load.Run.Tpl.DEC_ord.s11.ffi Host.Load.Run.Tpl.DEC_ord.S1D.tab
      (certAt choice.cert Tpl.Ordinary.tokenNode) choice.outputs i NB := by
  intro table P Mp n y ν hld hNL hN0 htime hnum hrope
  let w := weights (firstValues M K env table)
  let time := L + i + 1
  let c := capL time
  let l := loadedAt Mp.node DEC.cacheNodes
  let token := tensorAt (Mp.node tokenNode)
  let nextCache := cachesAt Mp.node choice.outputs
  have hin : ∀ key j, insT key = some j → inputNode l token key = some (Mp.node j) :=
    inputs_at_bound 15235 choice.inputs DEC.cacheNodes tokenNode inputs_prefix Mp.node
      (fun j hj => hld.mlx.nid j (Nat.lt_of_lt_of_le hj hNB))
  have hR : G.LoadR P NB Mp n endLoad.ffi (Host.Load.Layers.toLoad y) := hld
  have hnl : NL ≤ P.NL := by change 20000 ≤ P.NL; change P.NL = 20000 at hNL; omega
  have hn0 : P.N0 ≤ N0 := by change P.N0 ≤ 22539; change P.N0 = 22539 at hN0; omega
  have htv : ν 9 = F64.ofNat time := htime
  have hr : Mp.big 5554869888 = 5554869888 := hrope
  have ho : nextCache.map cacheNodePair = choice.outputs.map (fun p => (p.1.map Mp.node, p.2.map Mp.node)) :=
    cachesAt_nodes Mp.node choice.outputs
  have hgraph : Gr table ((fullWorldFb b0 NB).toMlx y) =
      Gr table (Host.Load.Layers.toLoad y).mlx :=
    congrArg (Gr table) ((fullProjFb b0 NB).mlx y).symm
  obtain ⟨hemb, hbr, hfb, hea, _, _, _⟩ :=
    graph_iter w (populatedLayoutHandles 256) (caps_eq M K env table) (layout_eq M K env table)
      (head_eq M K env table) table P NB Mp n (Host.Load.Layers.toLoad y) hR hnl hn0
      ν time htv (by dsimp [time]; omega) hnum hr l token (populatedHandlesFor (stageWeights w) c)
      nextCache c (Host.Mlx.SimGraph.Mach.caps_populated c _) (by dsimp [c, time]; omega) hin ho
  refine ⟨l, token, T w (populatedLayoutHandles 256) (caps_eq M K env table)
    (layout_eq M K env table) (head_eq M K env table), Mp.node, Mp.handle, ?_⟩
  refine And.intro ?_ ?_
  · rfl
  refine And.intro ?_ ?_
  · rfl
  refine And.intro ?_ ?_
  · rw [hgraph]
    exact hfb
  refine And.intro hea ?_
  refine And.intro hbr ?_
  refine And.intro ?_ ?_
  · rw [hgraph]
    exact hemb
  refine And.intro ?_ ?_
  · intro hs hcaps
    refine template_inputs w
      (T w (populatedLayoutHandles 256) (caps_eq M K env table)
        (layout_eq M K env table) (head_eq M K env table))
      hs c time hcaps hbr Mp.node insT (inputNode l token) ?_ hin
    show inputCarriersMatchD (templateOf w (populatedLayoutHandles 256) 1).1 choice.cert insT = true
    rw [templateOf_eq w (populatedLayoutHandles 256) (layout_eq M K env table) (head_eq M K env table)]
    exact check.inputs
  refine And.intro ?_ ?_
  · rw [t_hs0, t_n0, t_cert,
      templateOf_eq w (populatedLayoutHandles 256) (layout_eq M K env table) (head_eq M K env table)]
    change (cachesAt Mp.node choice.outputs).map _root_.Host.Load.cacheNodePair = _
    exact (cachesAt_nodes Mp.node choice.outputs).trans
      (outputs_pairs choice.cert Tpl.Ordinary.cacheOutputs choice.outputs Mp.node outputs_check)
  rw [t_hs0, t_n0, t_cert,
    templateOf_eq w (populatedLayoutHandles 256) (layout_eq M K env table) (head_eq M K env table)]

end Host.Ts.Sim.Compose.DECGraph.Ord
