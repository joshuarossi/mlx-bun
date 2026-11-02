import host.route.cert.Fin.Step
import host.route.cert.Seg
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr cachesAt cachesAt_below cachesAt_nodes)
open Host.Mlx.SimGraph.Mach (refPrompt refPrompt_start refPrompt_succ RefTokens compat_of_caps)
open Host.Ts.Sim (LoadP Map SegInst)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph
open Host.Route.Cert.Row (layout_eq head_eq caps_eq)
open Host.Ts.Sim.Compose.ColdGraph (coldIds)

/-! # A tailed class's sampled cut, from its certificate

`HeadCert`: the head and sampler's part of the ordinary template at the sampled cut. `hsmpV`: POST's first held time, from the forward's
part `memFin` kept. -/

/-- The step's nodes the sampled cut still names: the hidden state and the handles. -/
def keptOf (cr : Nat → Nat) : List (Nat × Nat) :=
  (4009, cr 4009) :: Tpl.Ordinary.cacheOutputs.flatMap fun q => [(q.1, cr q.1), (q.2, cr q.2)]

/-- The handles' carriers after the step. -/
def carriersOf (cr : Nat → Nat) : List (Option Nat × Option Nat) :=
  Tpl.Ordinary.cacheOutputs.map fun q => (some (cr q.1), some (cr q.2))

kernel_rfl ord_outs : Tpl.Ordinary.cacheOutputs.all (fun q => Nat.blt q.1 4010 && Nat.blt q.2 4010) = true
kernel_rfl ord_token : (Nat.ble 4010 Tpl.Ordinary.tokenNode && Nat.blt Tpl.Ordinary.tokenNode Tpl.Ordinary.graph.length) = true
kernel_rfl ord_boundary : (Tpl.Ordinary.graph.drop 4010).all (fun e => e.ins.all fun j => Nat.ble 4010 j || Nat.beq j 4009) = true
kernel_rfl ord_hidden : Nat.blt 4009 Tpl.Ordinary.graph.length = true

/-- The input check of node `k` from the forward's end: a parameter, at its carrier. -/
def headInputOk (cert : List Nat) (k : Nat) (e : RNode SDim InKey) : Bool :=
  !(decide (4010 ≤ k)) || match e.prim with
    | .input key =>
      !(decide (key = .tokenIds)) && !(isCacheKey key) &&
        decide ((parameterInput parameterChoice key).map Tensor.node = some (certAt cert k)) && decide (certAt cert k < 15235)
    | _ => true

/-- A sampled cut's checked certificate. -/
structure HeadCert (s : Ffi.St) (S : SSrv) (B : Box) (V : VarV) (d : Int) where
  cert : List Nat
  hm : checkNodesD (tailOk 4010 (gsV s S B V d) cert) 0 Tpl.Ordinary.graph = true
  hlen : Tpl.Ordinary.graph.length ≤ cert.length
  hinp : checkNodesD (headInputOk cert) 0 Tpl.Ordinary.graph = true
  toB : certAt cert Tpl.Ordinary.tokenNode < s.nnext
  outsB : ∀ q ∈ Tpl.Ordinary.cacheOutputs, certAt cert q.1 < s.nnext ∧ certAt cert q.2 < s.nnext
  hdown : (List.range s.nnext).all (downB (exactTplDom 15235 15235 [5554869888] s) s) = true

variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
  (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) {π : List Nat}

local notation "Mx" => P.toMlxContract
local notation "Kx" => KR.toKernelContract

/-- The next step's handles at the capacity. -/
theorem step_caps (w : PipelineWeights) {c n token t : Nat} {hs hs' : List Handles} (hc : CapsFor c (stageWeights w) hs)
    (e : stepTrace Mx Kx w n token hs = some (t, hs')) : CapsFor (kvCap (some c) n) (stageWeights w) hs' := by
  unfold stepTrace at e
  obtain ⟨x, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨r2, e2, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨y, hs2⟩ := r2
  dsimp only at e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  obtain ⟨_, _, e⟩ := Option.bind_eq_some_iff.mp e
  split at e
  · obtain ⟨t7, _, e⟩ := Option.bind_eq_some_iff.mp e
    have hr : (t7, hs2) = (t, hs') := Option.some.inj e
    rw [← (Prod.mk.inj hr).2]
    exact chainTrace_caps Mx Kx c n _ _ hc x y hs2 e2
  · cases e

/-- **`hsmp` of a tailed class**: `memFin` here, the head and sampler's match here. -/
theorem hsmpV (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, RefTokens P KR NE KR.inPlace net env π tab) {s : Ffi.St} {S : SSrv} {B : Box} {V : VarV}
    (c : HeadCert s S B V (-1)) {NB : Nat} (hNB : 15235 ≤ NB) (hL1 : 2 ≤ π.length) (hL2 : π.length ≤ 224)
    (hB : InBox B (nuV V π.length)) (ha : π.getD (π.length - 1) 0 < 2 ^ 31)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr π.length = carriersOf (certAt c.cert))
    (Kept : Nat → List (Nat × Nat)) (hKept : Kept π.length = keptOf (certAt c.cert)) (Kn : Nat → Nat) (hKn : Kn π.length = 4010)
    (toks : Nat → Nat → Nat) (htoks : toks π.length 0 = certAt c.cert Tpl.Ordinary.tokenNode)
    {y : SegInst FF} {Pm : LoadP} {m : Nat} (hmr : Host.Ts.Sim.G.MR Pm NB y.M m s (mlxOf y.t.ffi)) (hband : Pm.NL = Pm.N0)
    (hrope : y.M.big 5554869888 = 5554869888)
    (hρ : ∀ j l h, B.get j = some (l, h) → y.ν j = F64.ofInt (nuV V π.length j))
    (hnum : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → ∀ i e, nth? S.tab i = some e →
      CSrv.val ⟨tab⟩ (y.M.nv (.ref i)) = some (e.eval y.ν))
    (L : Nat) (hm : memFin P KR NE net env π Kept Kn L y) : memPost P KR NE net env π 0 toks Cr L y := by
  intro hL
  subst hL
  obtain ⟨κ, hk⟩ := hm rfl
  refine ⟨κ, fun tab hC => ?_⟩
  obtain ⟨tok, hs, certT, hR, hF, hb, hK, hc0⟩ := hk tab hC
  have hcaps0 := hc0 hL1
  obtain ⟨tok0, hs0, tok', hs', h0, h1, -, hsh, -, -⟩ := (hRT tab).2 (π.length - 1) le_rfl
  obtain ⟨rt0, rh0⟩ := Prod.mk.inj (Option.some.inj (h0.symm.trans hR))
  subst rt0 rh0
  have htok : tok0 = π.getD (π.length - 1) 0 := by
    have h := h0
    rw [refPrompt_start] at h
    obtain ⟨_, _, e⟩ := Option.map_eq_some_iff.mp h
    exact (Prod.mk.inj e).1.symm
  have hst : stepTrace Mx Kx (weights (firstValues Mx Kx env tab)) (π.length - 1) tok0 hs0 = some (tok', hs') := by
    have h := refPrompt_succ P KR NE KR.inPlace net env π tab (π.length - 1) le_rfl
    rw [h1, h0] at h
    exact h.symm
  have hgr := step_eq _ (populatedLayoutHandles 256) (caps_eq P KR env tab) (layout_eq P KR env tab) (head_eq P KR env tab)
    hs0 256 (π.length - 1) hcaps0 (by omega)
  have hF' : FinAt P KR env κ tab hs0 (π.length - 1) tok0 4010 certT (mlxOf y.t.ffi) := by
    rw [hKn] at hF
    exact hF
  have hKk : ∀ q ∈ keptOf (certAt c.cert), certAt certT q.1 = y.M.node q.2 := fun q hq => hK q (hKept ▸ hq)
  have hcapsN : CapsFor (Host.Ts.Sim.capL (π.length + 0)) (stageWeights (weights (firstValues Mx Kx env tab))) hs' := by
    have h := step_caps P KR _ hcaps0 hst
    have e1 : kvCap (some 256) (π.length - 1) = 256 := by
      show (if 256 < π.length - 1 + 1 then (if (π.length - 1) % 256 = 0 then 256 else π.length - 1) + 256 else 256) = 256
      rw [if_neg (by omega)]
    have e2 : Host.Ts.Sim.capL (π.length + 0) = 256 := by
      unfold Host.Ts.Sim.capL
      omega
    rw [e1] at h
    rw [e2]
    exact h
  have hind : ∀ {k : Nat} {e : RNode Int InKey},
      (stepGraphOf (weights (firstValues Mx Kx env tab)) hs0 (π.length - 1)).1[k]? = some e →
      ∃ e0, Tpl.Ordinary.graph[k]? = some e0 ∧ e = mapN (SDim.eval (π.length - 1)) e0 := by
    intro k e he
    rw [hgr, List.getElem?_map] at he
    obtain ⟨e0, h0, rfl⟩ := Option.map_eq_some_iff.mp he
    exact ⟨e0, h0, rfl⟩
  have hout0 : Nat.ble 4010 Tpl.Ordinary.tokenNode = true ∧ Nat.blt Tpl.Ordinary.tokenNode Tpl.Ordinary.graph.length = true := by
    simpa only [Bool.and_eq_true] using ord_token
  have hlenT : Tpl.Ordinary.tokenNode < c.cert.length := Nat.lt_of_lt_of_le (Nat.blt_eq.mp hout0.2) c.hlen
  rw [hCr]
  refine postAt_ofFin leaves typed (σ := y.M.node) (toks := toks π.length) (Cr := carriersOf (certAt c.cert)) (by omega) h0
    (by rw [show π.length + 0 = π.length - 1 + 1 by omega]; exact h1) (by rw [htok]; exact ha) hF' hb hsh hcapsN
    (c.cert.map y.M.node) ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_
  · rw [hgr]
    have hchecked := Host.Route.PrefGraph.matchesD_tail (gsV s S B V (-1)) Tpl.Ordinary.graph .tokenIds 4010 c.cert c.hm
    have h1' := matchesD_map (SDim.eval (π.length - 1)) _ _ c.cert hchecked
    have emb := embedsV s S B V (L := π.length) (n := π.length - 1) (d := -1) (by omega) hB tab hmr hband hrope y.ν hρ (hnum tab hC) c.hdown
    have h2 := matches_embed (σ := y.M.node) (cl := y.M.handle) _ _ emb _ c.cert
      (by rw [List.length_map, maskSeg_length]; exact c.hlen) h1'
    rw [maskSeg_map] at h2
    rw [List.length_map]
    exact h2
  · intro k e hk he j hj hjk
    obtain ⟨e0, h0e, rfl⟩ := hind he
    have hmem : e0 ∈ Tpl.Ordinary.graph.drop 4010 := by
      refine List.mem_of_getElem? (i := k - 4010) ?_
      rw [List.getElem?_drop, show 4010 + (k - 4010) = k by omega]
      exact h0e
    have hbd := List.all_eq_true.mp ord_boundary e0 hmem
    simp only [List.all_eq_true, Bool.or_eq_true] at hbd
    have hj8 : j = 4009 := by
      rcases hbd j hj with h | h
      · have := Nat.le_of_ble_eq_true h
        omega
      · exact Nat.eq_of_beq_eq_true h
    subst hj8
    rw [certAt_map _ _ _ (Nat.lt_of_lt_of_le (Nat.blt_eq.mp ord_hidden) c.hlen)]
    exact (hKk (4009, certAt c.cert 4009) (by simp [keptOf])).symm
  · intro k e key v hk he hp hv
    obtain ⟨e0, h0e, rfl⟩ := hind he
    have hp0 : e0.prim = .input key := by
      cases hq : e0.prim <;> simp [Host.Mlx.SimGraph.mapN, mapP, hq] at hp ⊢ <;> exact hp
    have hchk := checkNodesD_get (headInputOk c.cert) Tpl.Ordinary.graph 0 c.hinp h0e
    rw [Nat.zero_add] at hchk
    unfold headInputOk at hchk
    rw [hp0] at hchk
    simp only [hk, decide_true, Bool.not_true, Bool.false_or, Bool.and_eq_true, Bool.not_eq_true', decide_eq_false_iff_not,
      decide_eq_true_eq] at hchk
    obtain ⟨⟨⟨hnt, hnc⟩, hnode⟩, hlt⟩ := hchk
    have hl := firstPipeline_loaded Mx Kx env tab leaves typed
    have loaded := stages_loaded Mx Kx (firstPipeline Mx Kx env tab leaves typed) _ hl
    have initial := cacheCompatible_of_holds Mx Kx _ _ initialHandles _ loaded (initialChainHolds _)
    have hie : (stepEnvWithIds env.weights (weights (firstValues Mx Kx env tab)) (coldIds tok0) hs0).inputs key =
        (parameterInput parameterChoice key).map (firstValues Mx Kx env tab) :=
      (stepInputsWithIds_parameter_eq _ _ hs0 initialHandles (compat_of_caps hcaps0) initial key hnc).trans
        (initial_input_values _ _ key hnt)
    rw [hie] at hv
    obtain ⟨t, ht, rfl⟩ := Option.map_eq_some_iff.mp hv
    rw [ht] at hnode
    have hnt' : t.node = certAt c.cert k := Option.some.inj hnode
    have hlk : k < c.cert.length := by
      have := (List.getElem?_eq_some_iff.mp h0e).1
      exact Nat.lt_of_lt_of_le this c.hlen
    rw [certAt_map _ _ _ hlk, ← hnt', hmr.nid _ (Nat.lt_of_lt_of_le (hnt' ▸ hlt) hNB)]
    exact (hb.params t (parameterInput_mem _ key ht)).1
  · rw [hgr]
    exact Nat.le_of_ble_eq_true hout0.1
  · rw [hgr, htoks]
    show y.M.node (certAt c.cert Tpl.Ordinary.tokenNode) = certAt (c.cert.map y.M.node) Tpl.Ordinary.tokenNode
    rw [certAt_map _ _ _ hlenT]
  · rw [hgr]
    refine (cachesAt_nodes y.M.node (carriersOf (certAt c.cert))).trans ?_
    simp only [carriersOf, List.map_map]
    refine List.map_congr_left fun q hq => ?_
    have h1 := hKk (q.1, certAt c.cert q.1) (by
      simp only [keptOf, List.mem_cons, List.mem_flatMap]
      exact .inr ⟨q, hq, by simp⟩)
    have h2 := hKk (q.2, certAt c.cert q.2) (by
      simp only [keptOf, List.mem_cons, List.mem_flatMap]
      exact .inr ⟨q, hq, by simp⟩)
    simp only [Function.comp, Option.map_some]
    rw [h1, h2]
  · rw [hgr]
    intro q hq
    have h := List.all_eq_true.mp ord_outs q hq
    simp only [Bool.and_eq_true, Nat.blt_eq] at h
    exact ⟨h.1, h.2⟩
  · rw [htoks]
    exact hmr.nall _ c.toB
  · refine cachesAt_below _ _ _ fun p hp j hj => ?_
    obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hp
    have h := c.outsB q hq
    rcases hj with hj | hj
    · obtain rfl := Option.some.inj hj
      exact hmr.nall _ h.1
    · obtain rfl := Option.some.inj hj
      exact hmr.nall _ h.2

end Host.Route.Cert.Fin
