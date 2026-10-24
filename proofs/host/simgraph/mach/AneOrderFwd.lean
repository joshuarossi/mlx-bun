import host.simgraph.mach.AneOrder
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Inference.Contracts.Mlx

/-! # A Neural Engine family's readbacks come after their taps: layers, chain, forward

`LInv` through each layer of `aneTpl` (`linv_deltaLayer`, `linv_attnLayer`), the layers' taps in order
through the chain (`chainOrd`), and the family's graph and `tapsOf` (`aneOrder`). -/

section
variable (I : PDim → Int) (R : Rows) (kd : AneKinds) (rest : Nat) (o n : Nat)

theorem linv_deltaLayer (p : Nat) (d : DeltaLayout) (x : Nat) (g : List (RNode Int AKey)) :
    Spec ((aneTpl R kd rest).layer graphB I o n p (.delta d) x) g fun r g' =>
      LInv p (rbSite kd (.delta d)) g r.2 g' ∧ TapShape (.delta d) r.2 := by
  dsimp only [aneTpl]
  unfold aneDeltaLayerT
  have h0 := linv_start p (rbSite kd (.delta d)) g
  linv_peel
  refine spec_bind (spec_mono (linv_proj I R p kd.delta 0 _ _ (by assumption) (fun h => by simp [rbSite, deltaSite, h]))
    fun _ _ _ => ?_)
  refine spec_bind (spec_mono (linv_proj I R p kd.delta 1 _ _ (by assumption) (fun h => by simp [rbSite, deltaSite, h]))
    fun _ _ _ => ?_)
  linv_peel
  refine spec_bind (spec_mono (linv_proj I R p kd.delta 3 _ _ (by assumption) (fun h => by simp [rbSite, deltaSite, h]))
    fun _ _ _ => ?_)
  refine spec_bind (spec_mono (linv_proj I R p kd.delta 2 _ _ (by assumption) (fun h => by simp [rbSite, deltaSite, h]))
    fun _ _ _ => ?_)
  linv_peel
  refine spec_bind (spec_mono (linv_proj I R p kd.delta 4 _ _ (by assumption) (fun h => by simp [rbSite, deltaSite, h]))
    fun _ _ _ => ?_)
  linv_peel
  refine spec_bind (spec_mono (linv_mlp I R p rest _ _ (by assumption) (by simp [rbSite])) fun _ _ _ => ?_)
  linv_peel
  refine spec_pure ⟨by simpa using (by assumption : LInv p (rbSite kd (.delta d)) g _ _), ?_⟩
  exact ⟨_, _, _, _, _, _, _, _, _, _, _, rfl⟩

theorem linv_attnLayer (p : Nat) (a : AttnLayout) (x : Nat) (g : List (RNode Int AKey)) :
    Spec ((aneTpl R kd rest).layer graphB I o n p (.attention a) x) g fun r g' =>
      LInv p (rbSite kd (.attention a)) g r.2 g' ∧ TapShape (.attention a) r.2 := by
  dsimp only [aneTpl]
  unfold aneAttentionLayerT
  have h0 := linv_start p (rbSite kd (.attention a)) g
  linv_peel
  refine spec_bind (spec_mono (linv_proj I R p kd.attn 0 _ _ (by assumption) (fun h => by simp [rbSite, attnSite, h]))
    fun _ _ _ => ?_)
  linv_peel
  refine spec_bind (spec_mono (linv_proj I R p kd.attn 1 _ _ (by assumption) (fun h => by simp [rbSite, attnSite, h]))
    fun _ _ _ => ?_)
  refine spec_bind (spec_mono (linv_proj I R p kd.attn 2 _ _ (by assumption) (fun h => by simp [rbSite, attnSite, h]))
    fun _ _ _ => ?_)
  linv_peel
  refine spec_bind (spec_mono (linv_keys (keysB_kvStepT _ I R o n _ _ _ rfl) (by assumption))
    fun ⟨kb, keys⟩ _ _ => ?_)
  dsimp only
  refine spec_bind (spec_mono (linv_keys (keysB_kvStepT _ I R o n _ _ _ rfl) (by assumption))
    fun ⟨vb, values⟩ _ _ => ?_)
  dsimp only
  refine spec_bind (spec_mono (linv_keys (keysB_readCausal _ I R _ _ _ _) (by assumption)) fun _ _ _ => ?_)
  linv_peel
  refine spec_bind (spec_mono (linv_proj I R p kd.attn 3 _ _ (by assumption) (fun h => by simp [rbSite, attnSite, h]))
    fun _ _ _ => ?_)
  linv_peel
  refine spec_bind (spec_mono (linv_mlp I R p rest _ _ (by assumption) (by simp [rbSite])) fun _ _ _ => ?_)
  linv_peel
  refine spec_pure ⟨by simpa using (by assumption : LInv p (rbSite kd (.attention a)) g _ _), ?_⟩
  exact ⟨_, _, _, _, _, _, _, _, _, rfl⟩

theorem linv_layer (p : Nat) (s : StageLayout) (x : Nat) (g : List (RNode Int AKey)) :
    Spec ((aneTpl R kd rest).layer graphB I o n p s x) g fun r g' =>
      LInv p (rbSite kd s) g r.2 g' ∧ TapShape s r.2 := by
  cases s with
  | delta d => exact linv_deltaLayer I R kd rest o n p d x g
  | attention a => exact linv_attnLayer I R kd rest o n p a x g

/-- The chain from position `p` over `ss`, from graph `g`, to `g'` with the layers' taps `tss`: every new input of
a readback key is of a layer `q ≥ p` of the chain, at its site, after its taps. -/
def ChainOrd (p : Nat) (ss : List StageLayout) (g : List (RNode Int AKey)) (tss : List (List (List Nat)))
    (g' : List (RNode Int AKey)) : Prop :=
  (∃ t, g' = g ++ t) ∧ List.Forall₂ TapShape ss tss ∧
    ∀ i nd k q, g.length ≤ i → g'[i]? = some nd → nd.prim = .input k → rbLayer k = some q →
      p ≤ q ∧ ∃ sl l s ts, ss[q - p]? = some sl ∧ tss[q - p]? = some l ∧ rbSite kd sl k = some s ∧
        l[s]? = some ts ∧ ∀ t ∈ ts, t < i

theorem chainOrd_cons (p : Nat) (s : StageLayout) (ss : List StageLayout) {g g1 g2 : List (RNode Int AKey)}
    {ts : List (List Nat)} {tss : List (List (List Nat))} (h1 : LInv p (rbSite kd s) g ts g1 ∧ TapShape s ts)
    (h2 : ChainOrd kd (p + 1) ss g1 tss g2) : ChainOrd kd p (s :: ss) g (ts :: tss) g2 := by
  obtain ⟨⟨⟨t1, rfl⟩, _, hl⟩, hsh⟩ := h1
  obtain ⟨⟨t2, rfl⟩, hsh2, hc⟩ := h2
  refine ⟨⟨t1 ++ t2, by simp⟩, .cons hsh hsh2, fun i nd k q hi hg hk hq => ?_⟩
  by_cases hlt : i < (g ++ t1).length
  · rw [List.getElem?_append_left hlt] at hg
    obtain ⟨rfl, sIdx, ts', hs, hp, hlt'⟩ := hl i nd k q hi hg hk hq
    exact ⟨le_refl _, s, ts, sIdx, ts', by simp, by simp, hs, hp, hlt'⟩
  · obtain ⟨hpq, sl, l, sIdx, ts', h3, h4, h5, h6, h7⟩ := hc i nd k q (by omega) hg hk hq
    refine ⟨by omega, sl, l, sIdx, ts', ?_, ?_, h5, h6, h7⟩
    · rw [show q - p = (q - (p + 1)) + 1 by omega]; simpa using h3
    · rw [show q - p = (q - (p + 1)) + 1 by omega]; simpa using h4

/-- **The chain's readbacks come after their taps**, one cache pair per stage. -/
theorem chainOrd : ∀ (p : Nat) (ss : List StageLayout) (x : Nat) (g : List (RNode Int AKey)),
    Spec (chainTX (aneTpl R kd rest) graphB I o n p ss x) g fun r g' =>
      ChainOrd kd p ss g r.2.2 g' ∧ r.2.1.length = ss.length
  | p, [], x, g => spec_pure ⟨⟨⟨[], by simp⟩, .nil, fun i nd k q hi h _ _ => by
      rw [List.getElem?_eq_none (by omega)] at h; cases h⟩, rfl⟩
  | p, s :: ss, x, g => by
    unfold chainTX
    refine spec_bind (spec_mono (linv_layer I R kd rest o n p s x g) fun ⟨⟨y, c1, c2⟩, ts⟩ g1 h1 => ?_)
    dsimp only
    refine spec_bind (spec_mono (chainOrd (p + 1) ss y g1) fun ⟨z, cs, tss⟩ g2 h2 => ?_)
    dsimp only
    exact spec_pure ⟨chainOrd_cons kd p s ss h1 h2.1, by simp [h2.2]⟩

/-- **A Neural Engine family's readbacks come after their taps**: in the family's graph, every input of a readback
key is of a stage of the chain, at its site (`rbSite`), after the site's taps (`tapsOf`); the layers' taps have
their site shapes; the graph has one cache pair per stage. -/
theorem aneOrder (ss : List StageLayout) :
    List.Forall₂ TapShape ss ((aneTpl R kd rest).tapsOf I o n ss) ∧
    (familyGraph (aneTpl R kd rest).toTpl.ops I o n ss).2.2.length = ss.length ∧
    ∀ i nd k q, (familyGraph (aneTpl R kd rest).toTpl.ops I o n ss).1[i]? = some nd → nd.prim = .input k →
      rbLayer k = some q → ∃ sl l s ts, ss[q]? = some sl ∧ ((aneTpl R kd rest).tapsOf I o n ss)[q]? = some l ∧
        rbSite kd sl k = some s ∧ l[s]? = some ts ∧ ∀ t ∈ ts, t < i := by
  have hS : Spec (forwardTX (aneTpl R kd rest) graphB I o n ss) [] fun r g' =>
      List.Forall₂ TapShape ss r.2 ∧ r.1.2.length = ss.length ∧
      ∀ i nd k q, g'[i]? = some nd → nd.prim = .input k → rbLayer k = some q →
        ∃ sl l s ts, ss[q]? = some sl ∧ r.2[q]? = some l ∧ rbSite kd sl k = some s ∧ l[s]? = some ts ∧
          ∀ t ∈ ts, t < i := by
    unfold forwardTX
    refine spec_bind (spec_mono (show Spec ((aneTpl R kd rest).embed graphB I) [] fun _ g' =>
      NewKeys (fun k => rbLayer k = none) [] g' from keysB_embedT (fun k => rbLayer k = none) (AKey.p .promptIds) (fun k => AKey.p (.base k)) rfl (fun _ => rfl) []) fun x g1 h1 => ?_)
    refine spec_bind (spec_mono (chainOrd I R kd rest o n 0 ss x g1) fun ⟨y, cs, tss⟩ g2 h2 => ?_)
    dsimp only
    refine spec_bind (spec_mono (show Spec ((aneTpl R kd rest).final graphB I y) g2 fun _ g' =>
      NewKeys (fun k => rbLayer k = none) g2 g' from keysB_normT (fun k => rbLayer k = none) (AKey.p (.base .finalNorm)) y rfl g2) fun r g3 h3 => ?_)
    refine spec_pure ⟨h2.1.2.1, h2.2, fun i nd k q hg hk hq => ?_⟩
    obtain ⟨-, hk1⟩ := h1
    obtain ⟨⟨⟨t2, ht2⟩, _, hc⟩, _⟩ := h2
    obtain ⟨⟨t3, ht3⟩, hk3⟩ := h3
    by_cases hlt : i < g2.length
    · have hg2 : g2[i]? = some nd := by rw [ht3, List.getElem?_append_left hlt] at hg; exact hg
      by_cases hlt1 : i < g1.length
      · have hg1 : g1[i]? = some nd := by rw [ht2, List.getElem?_append_left hlt1] at hg2; exact hg2
        have := hk1 i nd k (by simp) hg1 hk
        rw [this] at hq; cases hq
      · obtain ⟨_, sl, l, s, ts, h4, h5, h6, h7, h8⟩ := hc i nd k q (by omega) hg2 hk hq
        exact ⟨sl, l, s, ts, by simpa using h4, by simpa using h5, h6, h7, h8⟩
    · have := hk3 i nd k (by omega) hg hk
      rw [this] at hq; cases hq
  rw [familyGraph_toTpl]
  exact hS

end

end Host.Mlx.SimGraph.Mach
