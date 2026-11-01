import host.route.StepCert
import host.sim.compose.a4b.GraphColdOneValues
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (cachesAt cachesAt_nodes cachesAt_below loadedAt tensorAt Gr)
open Host.Mlx.SimGraph.Mach (routeVal refPrompt refPrompt_start RefTokens prefill_one initial_caps)
open Host.Ts.Sim (LoadP SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Compose.ColdGraph (choice.cert fullExpected coldIds coldIds_buffer cellsValue_singleton cacheInputs)
open Host.Ts.Sim.Compose.ColdGraph.One (full_expected_eval)

/-! # POST's first held time at one token

The sampled cut of the one-token prompt: the first decode step's graph at the carriers of the cold certificate, the
handles' carriers among them. The match at the target is a premise, a certificate on the cut's template. -/

/-- The handles' carriers after the first step. -/
def oneCarriers : List (Option Nat × Option Nat) :=
  Expected.cacheOutputs.map fun q => (some (certAt choice.cert q.1), some (certAt choice.cert q.2))

kernel_rfl one_outs : Expected.cacheOutputs.all (fun q => Nat.blt q.1 choice.cert.length && Nat.blt q.2 choice.cert.length &&
  Nat.blt (certAt choice.cert q.1) 17777 && Nat.blt (certAt choice.cert q.2) 17777) = true
kernel_rfl one_token_node : Nat.blt Expected.tokenNode choice.cert.length = true

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)

/-- **The sampled cut of the one-token prompt.** -/
theorem hsmpOne (a : Nat) (ha : a < 248320) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, RefTokens P KR NE KR.inPlace net env [a] tab)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr 1 = oneCarriers)
    (toks : Nat → Nat → Nat) (htoks : toks 1 0 = 17776) {x y : SegInst FF}
    (hnid : ∀ j, j < 15235 → y.M.node j = j) (hnall : ∀ j, j < 17777 → y.M.node j < (mlxOf y.t.ffi).nnext)
    (hmatch : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → Matches (Gr tab (mlxOf y.t.ffi)) Expected.graph
      (choice.cert.map y.M.node) = true)
    (hinp : Host.Ts.Sim.Compose.SetupD1Input.InputAt [a] (y.M.node 15235) y.t y.C)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (L : Nat)
    (hm : memExit P KR NE net env [a] Cr L x) : memPost P KR NE net env [a] 0 toks Cr L y := by
  intro hL
  have hL1 : L = 1 := hL
  subst hL1
  let κ : Nat → Option Compiled := fun _ => none
  refine ⟨κ, fun tab hC => ?_⟩
  obtain ⟨hb, -⟩ := (hm rfl).1 rfl κ tab (hle.trans hC)
  have hb' := hb.grow hg ht
  have hl := firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed
  obtain ⟨s, es, hss⟩ := prefill_one P KR NE KR.inPlace net env [a] rfl tab
  have hR0 : refPrompt P KR NE KR.inPlace net env [a] tab ([a].length - 1) = some (a, initialHandles) := by
    rw [refPrompt_start, es, Option.map_some, hss]
    rfl
  obtain ⟨tok, hs, tok', hs', h0, h1, -, hsh, -, -⟩ := (hRT tab).2 ([a].length - 1) le_rfl
  obtain ⟨rt, rh⟩ := Prod.mk.inj (Option.some.inj (h0.symm.trans hR0))
  have rt' := rt.symm
  subst rt' rh
  have hgr : stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) initialHandles ([a].length - 1) =
      (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) := initial_step_graph _
  have hins := Host.Ts.Sim.Compose.ColdGraph.inputs y.M.node hnid (fun _ => 0)
  rw [full_expected_eval] at hins
  have hip := (hinp.grow (Host.Mlx.Ffi.NGrow.refl _) hC).2
  have htok : routeVal P KR env κ (fun _ => none) tab (mlxOf y.t.ffi) (y.M.node 15235) = some (coldIds a) :=
    (Host.Mlx.SimGraph.Mach.routeVals_empty P KR env κ tab (mlxOf y.t.ffi) _).trans
      ((hostInt32_eval P KR env κ _ _ _ _ _ _ hip).trans (cellsValue_singleton a (by omega)))
  have hcaps := initial_caps P.toMlxContract KR.toKernelContract _ a hs' tok' (by
    have h := Host.Mlx.SimGraph.Mach.refPrompt_succ P KR NE KR.inPlace net env [a] tab ([a].length - 1) le_rfl
    rw [h1, hR0] at h
    exact h.symm)
  rw [hCr, show toks 1 = toks 1 from rfl]
  refine postAt_ofStep P env (kind := κ) (KR := KR) (NE := NE) (net := net) (π := [a]) (tab := tab) (y := y.t)
    (σ := y.M.node) (toks := toks 1) (Cr := oneCarriers) (tok0 := a) (t := tok') (hs := initialHandles) (hs' := hs')
    (by simp) hR0 h1 hb' (coldIds a)
    (bufferEmbed_eq _ _ _ _ _ _ (coldIds_buffer a (by omega)) hl.embedding.words.1 hl.embedding.words.2.1
      hl.embedding.scales.2.1 hl.embedding.biases.2.1) hl.finalNorm.2.1 hsh
    (by rw [show Host.Ts.Sim.capL ([a].length + 0) = 256 by simp [Host.Ts.Sim.capL]]; exact hcaps) (choice.cert.map y.M.node)
    ?_ ?_ ?_ ?_ ?_ ?_
  · rw [hgr]
    exact hmatch tab hC
  · rw [hgr]
    exact heldV_initial _ y.M.node cacheInputs _ _ _ _ _ _ (fun t ht => (hb'.params t ht).1) htok hins
  · rw [hgr, htoks]
    show y.M.node 17776 = certAt (choice.cert.map y.M.node) Expected.tokenNode
    have hret : certAt choice.cert Expected.tokenNode = 17776 := Host.Ts.Sim.Compose.ColdGraph.actual_return_node
    rw [certAt_map _ _ _ (Nat.blt_eq.mp one_token_node), hret]
  · rw [hgr]
    refine (cachesAt_nodes y.M.node oneCarriers).trans ?_
    simp only [oneCarriers, List.map_map]
    refine List.map_congr_left fun q hq => ?_
    have h := List.all_eq_true.mp one_outs q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    simp only [Function.comp, Option.map_some]
    rw [certAt_map _ _ _ h.1.1.2, certAt_map _ _ _ h.1.1.1]
  · rw [htoks]
    exact hnall _ (by decide)
  · refine cachesAt_below _ _ _ fun p hp j hj => ?_
    obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hp
    have h := List.all_eq_true.mp one_outs q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    rcases hj with hj | hj
    · obtain rfl := Option.some.inj hj
      exact hnall _ h.1.2
    · obtain rfl := Option.some.inj hj
      exact hnall _ h.2

end Host.Route.PrefGraph
