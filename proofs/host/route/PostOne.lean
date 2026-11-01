import host.route.FinGraph
import host.sim.compose.a4b.GraphColdOneValues
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (cachesAt cachesAt_nodes cachesAt_below loadedAt tensorAt Gr)
open Host.Mlx.SimGraph.Mach (routeVal HeldV refPrompt refPrompt_start RefTokens prefill_one initial_caps)
open Host.Ts.Sim (SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Compose.ColdGraph (choice.cert fullExpected coldIds cellsValue_singleton cacheInputs)
open Host.Ts.Sim.Compose.ColdGraph.One (full_expected_eval)

/-! # POST's first held time at one token

The first decode step's graph at the carriers of the cold certificate, read in two parts: the forward up to the hidden state
at the forward's return (`hfinOne`), the head and sampler at the sampled cut (`hsmpOne`). The matches at the target are
premises, certificates on the cuts' templates. -/

/-- The handles' carriers after the first step. -/
def oneCarriers : List (Option Nat × Option Nat) :=
  Expected.cacheOutputs.map fun q => (some (certAt choice.cert q.1), some (certAt choice.cert q.2))

/-- The step's nodes POST's template still names: the hidden state and the handles. -/
def oneKept : List (Nat × Nat) :=
  (4009, 17763) :: Expected.cacheOutputs.flatMap fun q => [(q.1, certAt choice.cert q.1), (q.2, certAt choice.cert q.2)]

kernel_rfl one_outs : Expected.cacheOutputs.all (fun q => Nat.blt q.1 4010 && Nat.blt q.2 4010 &&
  Nat.blt (certAt choice.cert q.1) 17764 && Nat.blt (certAt choice.cert q.2) 17764) = true
kernel_rfl one_cert_len : choice.cert.length = 4020
kernel_rfl one_token_node : Nat.blt 4010 Expected.tokenNode && Nat.blt Expected.tokenNode 4020 = true
kernel_rfl one_hidden : certAt choice.cert 4009 = 17763
-- The tail reads the head only at the hidden state.
kernel_rfl one_boundary : (Expected.graph.drop 4010).all
  (fun e => e.ins.all fun j => Nat.ble 4010 j || Nat.beq j 4009) = true

theorem oneKept_mem {q : Nat × Nat} (hq : q ∈ oneKept) : q.1 < 4020 ∧ certAt choice.cert q.1 = q.2 := by
  simp only [oneKept, List.mem_cons, List.mem_flatMap] at hq
  rcases hq with rfl | ⟨r, hr, h⟩
  · exact ⟨by decide, one_hidden⟩
  · have hb := List.all_eq_true.mp one_outs r hr
    simp only [Bool.and_eq_true, Nat.blt_eq] at hb
    simp only [List.mem_singleton, List.not_mem_nil, or_false] at h
    rcases h with rfl | rfl
    · exact ⟨by have := hb.1.1.1; show r.1 < 4020; omega, rfl⟩
    · exact ⟨by have := hb.1.1.2; show r.2 < 4020; omega, rfl⟩

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)

variable {P KR NE net env} in
/-- The reference at time `0` of a one-token prompt. -/
theorem one_ref (a : Nat) (tab : List F64) :
    refPrompt P KR NE KR.inPlace net env [a] tab ([a].length - 1) = some (a, initialHandles) := by
  obtain ⟨s, es, hss⟩ := prefill_one P KR NE KR.inPlace net env [a] rfl tab
  rw [refPrompt_start, es, Option.map_some, hss]
  rfl

variable {P KR env} in
/-- The first step's inputs at the target. -/
theorem one_held {kind : Nat → Option Compiled} {a : Nat} (ha : a < 248320) {tab : List F64} {y : SegInst FF}
    (hnid : ∀ j, j < 15235 → y.M.node j = j) (hb : Base P KR env (routeVs P KR env kind) tab y.t)
    (hC : Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩)
    (hinp : Host.Ts.Sim.Compose.SetupD1Input.InputAt [a] (y.M.node 15235) y.t y.C) :
    HeldV (routeVal P KR env kind (fun _ => none) tab (mlxOf y.t.ffi)) Expected.graph (choice.cert.map y.M.node)
      (stepEnvWithIds env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) (coldIds a) initialHandles) := by
  have hins := Host.Ts.Sim.Compose.ColdGraph.inputs y.M.node hnid (fun _ => 0)
  rw [full_expected_eval] at hins
  have hip := (hinp.grow (Host.Mlx.Ffi.NGrow.refl _) hC).2
  have htok : routeVal P KR env kind (fun _ => none) tab (mlxOf y.t.ffi) (y.M.node 15235) = some (coldIds a) :=
    (Host.Mlx.SimGraph.Mach.routeVals_empty P KR env kind tab (mlxOf y.t.ffi) _).trans
      ((hostInt32_eval P KR env kind _ _ _ _ _ _ hip).trans (cellsValue_singleton a (by omega)))
  exact heldV_initial _ y.M.node cacheInputs _ _ _ _ _ _ (fun t ht => (hb.params t ht).1) htok hins

/-- **The final forward's return of the one-token prompt.** -/
theorem hfinOne (a : Nat) (ha : a < 248320) (Cr : Nat → List (Option Nat × Option Nat)) (Kept : Nat → List (Nat × Nat))
    (hKept : Kept 1 = oneKept) (Kn : Nat → Nat) (hKn : Kn 1 = 4010) {x y : SegInst FF}
    (hnid : ∀ j, j < 15235 → y.M.node j = j) (hnall : ∀ j, j < 17764 → y.M.node j < (mlxOf y.t.ffi).nnext)
    (hcb : ∀ k, k < 4010 → certAt choice.cert k < 17764)
    (hseg : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → ∀ z, Host.Mlx.Ffi.NGrow (mlxOf y.t.ffi) z →
      Matches (Gr tab z) (Expected.graph.take 4010) (choice.cert.map y.M.node) = true)
    (hinp : Host.Ts.Sim.Compose.SetupD1Input.InputAt [a] (y.M.node 15235) y.t y.C)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (L : Nat)
    (hm : memExit P KR NE net env [a] Cr L x) : memFin P KR NE net env [a] Kept Kn L y := by
  intro hL
  have hL1 : L = 1 := hL
  subst hL1
  let κ : Nat → Option Compiled := fun _ => none
  refine ⟨κ, fun tab hC => ?_⟩
  obtain ⟨hb, -⟩ := (hm rfl).1 rfl κ tab (hle.trans hC)
  have hb' := hb.grow hg ht
  have hgr : stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) initialHandles (1 - 1) =
      (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) := initial_step_graph _
  have hheld := one_held (P := P) (KR := KR) (env := env) (kind := κ) ha hnid hb' hC hinp
  refine ⟨a, initialHandles, choice.cert.map y.M.node, one_ref a tab, ?_, hb', fun q hq => ?_, fun h => absurd h (by decide)⟩
  · rw [hKn]
    refine ⟨fun z hz => ?_, ?_, fun k hk => ?_, fun k e key v _ he hp hv => ?_⟩
    · rw [hgr]
      exact hseg tab hC z hz
    · rw [List.length_map, one_cert_len]
      decide
    · rw [certAt_map _ _ _ (by rw [one_cert_len]; omega)]
      exact hnall _ (hcb k hk)
    · rw [hgr] at he
      exact hheld k e key v he hp hv
  · rw [hKept] at hq
    obtain ⟨hlt, he⟩ := oneKept_mem hq
    rw [certAt_map _ _ _ (by rw [one_cert_len]; exact hlt), he]

/-- **The sampled cut of the one-token prompt**: `memFin` here, the head and sampler's match here. -/
theorem hsmpOne (a : Nat) (ha : a < 248320) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, RefTokens P KR NE KR.inPlace net env [a] tab)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr 1 = oneCarriers) (Kept : Nat → List (Nat × Nat))
    (hKept : Kept 1 = oneKept) (Kn : Nat → Nat) (hKn : Kn 1 = 4010)
    (toks : Nat → Nat → Nat) (htoks : toks 1 0 = 17776) {y : SegInst FF}
    (hnid : ∀ j, j < 15235 → y.M.node j = j) (hnall : ∀ j, j < 17777 → y.M.node j < (mlxOf y.t.ffi).nnext)
    (hmH : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → Matches (Gr tab (mlxOf y.t.ffi))
      (maskSeg .tokenIds 4010 Expected.graph.length Expected.graph) (choice.cert.map y.M.node) = true)
    (hinp : Host.Ts.Sim.Compose.SetupD1Input.InputAt [a] (y.M.node 15235) y.t y.C) (L : Nat)
    (hm : memFin P KR NE net env [a] Kept Kn L y) : memPost P KR NE net env [a] 0 toks Cr L y := by
  intro hL
  have hL1 : L = 1 := hL
  subst hL1
  obtain ⟨κ, hk⟩ := hm rfl
  refine ⟨κ, fun tab hC => ?_⟩
  obtain ⟨tok, hs, certT, hR, hF, hb, hK, -⟩ := hk tab hC
  have hR0 := one_ref (P := P) (KR := KR) (NE := NE) (net := net) (env := env) a tab
  obtain ⟨rt, rh⟩ := Prod.mk.inj (Option.some.inj ((show refPrompt P KR NE KR.inPlace net env [a] tab ([a].length - 1) = some (tok, hs) from hR).symm.trans hR0))
  have rt' := rt.symm
  subst rt' rh
  obtain ⟨tok0, hs0, tok', hs', h0, h1, -, hsh, -, -⟩ := (hRT tab).2 ([a].length - 1) le_rfl
  obtain ⟨rt0, rh0⟩ := Prod.mk.inj (Option.some.inj (h0.symm.trans hR0))
  have rt0' := rt0.symm
  subst rt0' rh0
  have hgr : stepGraphOf (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) initialHandles ([a].length - 1) =
      (Expected.graph, Expected.tokenNode, Expected.cacheOutputs) := initial_step_graph _
  have hheld := one_held (P := P) (KR := KR) (env := env) (kind := κ) ha hnid hb hC hinp
  have hcaps := initial_caps P.toMlxContract KR.toKernelContract _ a hs' tok' (by
    have h := Host.Mlx.SimGraph.Mach.refPrompt_succ P KR NE KR.inPlace net env [a] tab ([a].length - 1) le_rfl
    rw [h1, hR0] at h
    exact h.symm)
  have hKk : ∀ q ∈ oneKept, certAt certT q.1 = y.M.node q.2 := fun q hq => hK q (hKept ▸ hq)
  have hF' : FinAt P KR env κ tab initialHandles ([a].length - 1) a 4010 certT (mlxOf y.t.ffi) := by
    rw [hKn] at hF
    exact hF
  rw [hCr, show toks 1 = toks 1 from rfl]
  refine postAt_ofFin leaves typed (σ := y.M.node) (toks := toks 1) (Cr := oneCarriers) (by simp) hR0 h1 (by omega) hF' hb hsh
    (by rw [show Host.Ts.Sim.capL ([a].length + 0) = 256 by simp [Host.Ts.Sim.capL]]; exact hcaps)
    (choice.cert.map y.M.node) ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_
  · rw [hgr]
    exact hmH tab hC
  · rw [hgr]
    intro k e hk he j hj hjk
    have hmem : e ∈ Expected.graph.drop 4010 := by
      refine List.mem_of_getElem? (i := k - 4010) ?_
      rw [List.getElem?_drop, show 4010 + (k - 4010) = k by omega]
      exact he
    have hb := List.all_eq_true.mp one_boundary e hmem
    simp only [List.all_eq_true, Bool.or_eq_true] at hb
    have hj8 : j = 4009 := by
      rcases hb j hj with h | h
      · have := Nat.le_of_ble_eq_true h
        omega
      · exact Nat.eq_of_beq_eq_true h
    subst hj8
    rw [certAt_map _ _ _ (by rw [one_cert_len]; decide), one_hidden]
    exact (hKk (4009, 17763) (by simp [oneKept])).symm
  · rw [hgr]
    intro k e key v _ he hp hv
    exact hheld k e key v he hp hv
  · rw [hgr]
    have h := one_token_node
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact Nat.le_of_lt h.1
  · rw [hgr, htoks]
    show y.M.node 17776 = certAt (choice.cert.map y.M.node) Expected.tokenNode
    have h := one_token_node
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    have hret : certAt choice.cert Expected.tokenNode = 17776 := Host.Ts.Sim.Compose.ColdGraph.actual_return_node
    rw [certAt_map _ _ _ (by rw [one_cert_len]; exact of_decide_eq_true h.2), hret]
  · rw [hgr]
    refine (cachesAt_nodes y.M.node oneCarriers).trans ?_
    simp only [oneCarriers, List.map_map]
    refine List.map_congr_left fun q hq => ?_
    have h1 := hKk (q.1, certAt choice.cert q.1) (by
      simp only [oneKept, List.mem_cons, List.mem_flatMap]
      exact .inr ⟨q, hq, by simp⟩)
    have h2 := hKk (q.2, certAt choice.cert q.2) (by
      simp only [oneKept, List.mem_cons, List.mem_flatMap]
      exact .inr ⟨q, hq, by simp⟩)
    simp only [Function.comp, Option.map_some]
    rw [h1, h2]
  · rw [hgr]
    intro q hq
    have h := List.all_eq_true.mp one_outs q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact ⟨h.1.1.1, h.1.1.2⟩
  · rw [htoks]
    exact hnall _ (by decide)
  · refine cachesAt_below _ _ _ fun p hp j hj => ?_
    obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hp
    have h := List.all_eq_true.mp one_outs q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    rcases hj with hj | hj
    · obtain rfl := Option.some.inj hj
      exact hnall _ (by have := h.1.2; omega)
    · obtain rfl := Option.some.inj hj
      exact hnall _ (by have := h.2; omega)

end Host.Route.PrefGraph
