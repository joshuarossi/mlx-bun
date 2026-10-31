import host.sim.compose.a4b.GraphColdOne
import host.sim.compose.a4b.GraphColdEndpointReturn5
import host.load.run.full.FirstStep
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.One
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Program _root_.Host.Load.Run.Full _root_.Host.Mlx
open _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

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

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)

/-- The checked actual One graph computes the first model step for an arbitrary
singleton vocabulary token. Loaded parameter values are the ordinary input
obligation; the operational producer supplies them separately on the same run. -/
theorem sample (env : FfiEval.Env InKey) (table : List F64)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (parameters : TokenSequenceRanges.Parameters (firstPipeline M K env table leaves typed))
    (input : Fin 248320) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat)
    (t : St Full.FF.S) (Cs : CSrv)
    (hR : G.MR P NB Mp n native (Full.mlxOf t.ffi)) (hNB : 15235 ≤ NB)
    (hband : P.NL = P.N0) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? Host.Load.Run.Tpl.D1PostOne.S10.tab i = some e →
      Cs.val (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (hinput : SetupD1Input.InputAt [input.val] (Mp.node tokenNode) t Cs)
    (hp : ∀ u ∈ parameterTensors parameterChoice,
      evalR M K (stepEnvWithIds env.weights (weights (firstValues M K env table))
        (coldIds input.val) initialHandles)
        (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) u.node =
          some (firstValues M K env table u)) :
    let after := (firstContext M K env table leaves typed parameters).run input 1 (by decide)
    ∃ hs', (∃ r, evalR M K env
        (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) (Mp.node 17776) = some r ∧
        itemUint32 r = some after.token.val) ∧
      ChainHolds (firstPipeline M K env table leaves typed).graph.stages hs' after.cache ∧
      fullExpected.2.2.length = hs'.length ∧
      (∀ h ∈ hs', (handleVals h).isSome) ∧
      ∀ q ∈ cacheFacts fullExpected.2.2 hs',
        evalR M K env (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi))
          (certAt (choice.cert.map Mp.node) q.1) = some q.2 := by
  let p := firstPipeline M K env table leaves typed
  let w := weights (firstValues M K env table)
  let Gr := ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)
  let decodeEnv := stepEnvWithIds env.weights w (coldIds input.val) initialHandles
  have hg := initial_step_graph (contents M K env (firstFfiGraph table))
  change stepGraphOf w initialHandles 0 = (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) at hg
  have hm : Matches Gr (stepGraphOf w initialHandles 0).1 (choice.cert.map Mp.node) = true := by
    rw [hg]
    have checked := One.matches Cs.tab P NB Mp n (Full.mlxOf t.ffi) hR hband ρ hρ hnum hrope (fun _ => 0)
    rw [full_expected_eval] at checked
    exact checked
  obtain ⟨hi, hb⟩ := input_values_of_inputAt M K (firstValues M K env table) env.weights
    P NB Mp n t Cs hR hNB input.val input.isLt hinput hp (fun _ => 0)
  have hin : InputsHeld M K decodeEnv Gr (stepGraphOf w initialHandles 0).1 (choice.cert.map Mp.node) := by
    rw [hg]
    rw [full_expected_eval] at hi
    exact hi
  have hb' : TokenBuffer (coldIds input.val)
      ((GlueM1Max.context M K p w (firstPipeline_loaded M K env table leaves typed) parameters).run input 0
        (by decide)).token.val := hb
  obtain ⟨hs', ht, hc, hlen, hsome, hv⟩ := ffi_context_step_ids_caches M K p w
    (firstPipeline_loaded M K env table leaves typed) parameters input 0 (by decide)
    (coldIds input.val) hb' initialHandles (initialChainHolds p) env.weights Gr
    (choice.cert.map Mp.node) hm hin
  rw [hg] at ht hlen hv
  have hlt : fullExpected.2.1 < choice.cert.length := by
    have hl := cert_length
    rw [full_length] at hl
    rw [full_output]
    omega
  have hout : certAt (choice.cert.map Mp.node) Expected.tokenNode = Mp.node 17776 := by
    change certAt (choice.cert.map Mp.node) fullExpected.2.1 = _
    rw [certAt_map Mp.node choice.cert _ hlt, actual_return_node]
  have stable (i : Nat) : evalR M K env Gr i = evalR M K decodeEnv Gr i :=
    evalFfi_inputs M K env decodeEnv rfl (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi) i
  refine ⟨hs', ?_, hc, hlen, hsome, ?_⟩
  · obtain ⟨r, hr, htok⟩ := ht
    rw [hout] at hr
    exact ⟨r, (stable _).trans hr, htok⟩
  · intro q hq
    exact (stable _).trans (hv q hq)

end Host.Ts.Sim.Compose.ColdGraph.One
