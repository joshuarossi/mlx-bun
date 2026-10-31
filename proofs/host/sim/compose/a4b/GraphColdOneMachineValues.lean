import host.sim.compose.a4b.GraphColdOneLoadedValues
import host.route.SingletonReference
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false

namespace Host.Ts.Sim.Compose.ColdGraph.OneMachine
open _root_.Host.Ts _root_.Host.Ts.Sim _root_.Host.Load _root_.Host.Load.Extract
open _root_.Host.Load.Program _root_.Host.Load.Run.Full _root_.Host.Load.Run.Tpl
open _root_.Host.Mlx _root_.Host.Mlx.GlueStep _root_.Host.Mlx.FfiEval _root_.Host.Mlx.SimGraph
open _root_.Host.Mlx.SimGraph.Mach
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

noncomputable def Values {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
    (NE : NeuralEngine) (net : Ref.AneNet) (env : FfiEval.Env InKey) (input : Fin 248320)
    (Mp : Map) (t : St Full.FF.S) (Cs : CSrv) : Prop :=
  ∃ tok hs, refPrompt P KR NE KR.inPlace net env [input.val] Cs.tab 1 = some (tok, hs) ∧
    tok < 248320 ∧
    (∃ r, evalR P.toMlxContract KR.toKernelContract env
      (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) (Mp.node 17776) = some r ∧
      itemUint32 r = some tok) ∧
    fullExpected.2.2.length = hs.length ∧
    (∀ h ∈ hs, (handleVals h).isSome) ∧
    ∀ q ∈ cacheFacts fullExpected.2.2 hs,
      evalR P.toMlxContract KR.toKernelContract env
        (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi))
        (certAt (choice.cert.map Mp.node) q.1) = some q.2

private theorem mapped_sample (Mp : Map) :
    certAt (choice.cert.map Mp.node) Expected.tokenNode = Mp.node 17776 := by
  have hlt : fullExpected.2.1 < choice.cert.length := by
    have hl := cert_length
    rw [full_length] at hl
    rw [full_output]
    omega
  change certAt (choice.cert.map Mp.node) fullExpected.2.1 = _
  rw [certAt_map Mp.node choice.cert _ hlt, actual_return_node]

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C)
  {G : Metal.Gpu C} (RP : KernelGpu.RoutePipelines G)
  (hK : KR.toKernelContract.apply = KernelGpu.apply G)
  (NE : NeuralEngine) (net : Ref.AneNet) (env : FfiEval.Env InKey)
  (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

include RP hK leaves typed in
/-- The actual graph holds the exact machine-reference token and cache handles.
GPU typing supplies the reference step; no model range certificate is assumed. -/
theorem values (input : Fin 248320) {T : Nat} {tk : Nat → Nat} {x : SegInst Full.FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (LP : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (t : St Full.FF.S) (Cs : CSrv)
    (hg : Host.Mlx.Ffi.NGrow (Full.mlxOf x.t.ffi) (Full.mlxOf t.ffi))
    (hR : _root_.Host.Ts.Sim.G.MR LP NB Mp n One.native (Full.mlxOf t.ffi)) (hNB : 15235 ≤ NB)
    (hband : LP.NL = LP.N0) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOne.S10.tab i = some e → Cs.val (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (hinput : SetupD1Input.InputAt [input.val] (Mp.node tokenNode) t Cs) :
    Values P KR NE net env input Mp t Cs := by
  let M := P.toMlxContract
  let K := KR.toKernelContract
  let w := weights (firstValues M K env [])
  let Gr := ffiGraph (κ := InKey) (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)
  let decodeEnv := stepEnvWithIds env.weights w (coldIds input.val) initialHandles
  have refs := refPrompt_tokens_short P KR NE KR.inPlace net env [input.val] RP hK leaves typed
    (by simp) (by simp) []
  obtain ⟨tok0, hs0, tok, hs, h0, h1, htok, hsh, _⟩ := refs.2 0 (by simp)
  have heq : (input.val, initialHandles) = (tok0, hs0) :=
    Option.some.inj ((_root_.Host.Route.SingletonReference.start P KR NE KR.inPlace net env input.val []).symm.trans h0)
  cases heq
  have htrace : stepTrace M K w 0 input.val initialHandles = some (tok, hs) :=
    (_root_.Host.Route.SingletonReference.next P KR NE KR.inPlace net env input.val []).symm.trans h1
  have modelGraph := initial_step_graph (contents M K env (firstFfiGraph []))
  change stepGraphOf w initialHandles 0 = (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) at modelGraph
  have hm : Matches Gr (stepGraphOf w initialHandles 0).1 (choice.cert.map Mp.node) = true := by
    rw [modelGraph]
    have checked := One.matches Cs.tab LP NB Mp n (Full.mlxOf t.ffi) hR hband ρ hρ hnum hrope (fun _ => 0)
    rw [One.full_expected_eval] at checked
    exact checked
  have hp := SetupD1Parameters.cold_parameters M K env [] leaves h t Cs input.val hg
  obtain ⟨hi, hb⟩ := One.input_values_of_inputAt M K (firstValues M K env []) env.weights
    LP NB Mp n t Cs hR hNB input.val input.isLt hinput hp (fun _ => 0)
  have hin : InputsHeld M K decodeEnv Gr (stepGraphOf w initialHandles 0).1 (choice.cert.map Mp.node) := by
    rw [modelGraph]
    rw [One.full_expected_eval] at hi
    exact hi
  have hl := firstPipeline_loaded M K env [] leaves typed
  have hembed := bufferEmbed_eq M w.embedWords w.embedScales w.embedBiases (coldIds input.val) input.val hb
    hl.embedding.words.1 hl.embedding.words.2.1 hl.embedding.scales.2.1 hl.embedding.biases.2.1
  obtain ⟨ht, hc⟩ := ffi_step_ids M K env.weights w 0 input.val (coldIds input.val) hembed
    initialHandles hs tok hl.finalNorm.2.1 hsh htrace Gr (choice.cert.map Mp.node) hm hin
  obtain ⟨_, hlen, hsome, _⟩ := stepGraph_eval_ids M K env.weights w 0 input.val (coldIds input.val) hembed
    initialHandles hs tok hl.finalNorm.2.1 hsh htrace
  rw [modelGraph] at ht hc hlen
  have href : refPrompt P KR NE KR.inPlace net env [input.val] Cs.tab 1 = some (tok, hs) :=
    (congrFun (_root_.Host.Route.refPrompt_table P KR NE net env [input.val] Cs.tab) 1).trans h1
  have stable (i : Nat) : evalR M K env Gr i = evalR M K decodeEnv Gr i :=
    evalFfi_inputs M K env decodeEnv rfl (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi) i
  refine ⟨tok, hs, href, htok, ?_, hlen, hsome, ?_⟩
  · obtain ⟨r, hr, hrTok⟩ := ht
    rw [mapped_sample] at hr
    exact ⟨r, (stable _).trans hr, hrTok⟩
  · intro q hq
    exact (stable _).trans (hc q hq)

include RP hK leaves typed in
theorem values_eos (input : Fin 248320) {T : Nat} {tk : Nat → Nat} {x : SegInst Full.FF}
    (h : (SetupD1Values.forwardValuesInputCut 15235 T tk).R x D1Call.s1 ⟨D1Call.S1.tab, []⟩)
    (LP : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (t : St Full.FF.S) (Cs : CSrv)
    (hg : Host.Mlx.Ffi.NGrow (Full.mlxOf x.t.ffi) (Full.mlxOf t.ffi))
    (hR : _root_.Host.Ts.Sim.G.MR LP NB Mp n OneEos.native (Full.mlxOf t.ffi)) (hNB : 15235 ≤ NB)
    (hband : LP.NL = LP.N0) (ρ : Nat → F64) (hρ : ρ 9 = F64.ofNat 1)
    (hnum : ∀ i e, nth? D1PostOneEos.S10.tab i = some e → Cs.val (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (hinput : SetupD1Input.InputAt [input.val] (Mp.node tokenNode) t Cs) :
    Values P KR NE net env input Mp t Cs :=
  values P KR RP hK NE net env leaves typed input h LP NB Mp n t Cs hg
    (OneEos.native_relation LP NB Mp n (Full.mlxOf t.ffi) hR) hNB hband ρ hρ
    (fun i e he => hnum i e (by rw [OneEos.table_same]; exact he)) hrope hinput

theorem forward_at (input : Fin 248320) (Mp : Map) (t : St Full.FF.S) (Cs : CSrv)
    (h : Values P KR NE net env input Mp t Cs) (cs : List Cache)
    (hnodes : cs.map cacheNodePair = fullExpected.2.2.map (fun p =>
      (some (certAt (choice.cert.map Mp.node) p.1), some (certAt (choice.cert.map Mp.node) p.2)))) :
    ForwardAtM P.toMlxContract KR.toKernelContract env
      (refPrompt P KR NE KR.inPlace net env [input.val]) Cs.tab 1 cs (Mp.node 17776)
      (ffiGraph (concrete Cs.val) SourceKernels.sources (Full.mlxOf t.ffi)) := by
  obtain ⟨tok, hs, href, _, ht, hlen, hsome, hc⟩ := h
  exact ⟨tok, hs, href, ht, cacheValues_of_facts P.toMlxContract KR.toKernelContract env _
    cs fullExpected.2.2 hs (certAt (choice.cert.map Mp.node)) hnodes hlen hsome hc⟩

end Host.Ts.Sim.Compose.ColdGraph.OneMachine
