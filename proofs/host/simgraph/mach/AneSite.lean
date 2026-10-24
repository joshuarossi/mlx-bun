import host.simgraph.mach.AneNodes
import host.simgraph.mach.AneOrderFwd
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph

/-! # A readback's site: its geometry, its taps' values

For a readback key at a tap site (`rbSite`) of a layer of the route's kinds (`KindsOk`) on the loaded weights:
its geometry is defined (`rbDim_of_site`), its taps' sizes are half writer counts (`writeRoute_sizes`), the
family's typed taps at the site are typed at those sizes (`tapsTy_site`, `SiteTy`), and the graph's and the
values' sites have equal lengths (`site_len`). With the facts of the expected graph (`facts_get`), the site's tap
nodes hold the values' taps (`site_mapM`). -/

theorem linLayout_dims {kind : Projector} {l : Linear} {steps rows : Nat} (h : LinTy kind l steps rows) :
    (linLayout kind l).rows = rows ∧ (linLayout kind l).cols = steps * 512 := by
  have hs : Ty l.scales .bfloat16 [rows, steps * 8] := by cases kind; exacts [h.2.2.1, h.2.2.1]
  refine ⟨by simp [linLayout, hs.2], by simp [linLayout, hs.2]; ring⟩

theorem delta_cols {dw : DeltaWeights} (h : DeltaTy dw) (conv rec : Option Value) :
    (dLay (deltaLayout dw conv rec) 0).cols = 5120 ∧ (dLay (deltaLayout dw conv rec) 1).cols = 5120 ∧
      (dLay (deltaLayout dw conv rec) 4).cols = 6144 :=
  ⟨(linLayout_dims h.qkv).2, (linLayout_dims h.z).2, (linLayout_dims h.out).2⟩

theorem attn_cols {aw : AttentionWeights} (h : AttnTy aw) (kb vb : Option Value) :
    (aLay (attnLayout aw kb vb) 0).cols = 5120 ∧ (aLay (attnLayout aw kb vb) 3).cols = 6144 :=
  ⟨(linLayout_dims h.q).2, (linLayout_dims h.o).2⟩

theorem deltaSite_cases {j s : Nat} (h : deltaSite j = some s) :
    (j = 0 ∧ s = 0) ∨ (j = 1 ∧ s = 1) ∨ (j = 3 ∧ s = 2) ∨ (j = 2 ∧ s = 3) ∨ (j = 4 ∧ s = 4) := by
  match j, h with
  | 0, h => cases h; simp
  | 1, h => cases h; simp
  | 2, h => cases h; simp
  | 3, h => cases h; simp
  | 4, h => cases h; simp
  | _ + 5, h => simp [deltaSite] at h

theorem attnSite_cases {j s : Nat} (h : attnSite j = some s) : j < 4 ∧ s = j := by
  unfold attnSite at h
  split at h
  · cases h; exact ⟨by omega, rfl⟩
  · cases h

/-- A readback at a tap site has its geometry. -/
theorem rbDim_of_site (kd : AneKinds) (n : Nat) (sl : StageLayout) (k : AKey) (s : Nat)
    (h : rbSite kd sl k = some s) : ∃ D sizes, rbDim kd n sl k = some (D, sizes) := by
  cases sl with
  | delta d =>
    cases k with
    | linOut p j =>
      simp only [rbSite] at h
      cases e : kd.delta j with
      | split nA => exact ⟨nA, [nA * (dLay d j).cols, (dLay d j).cols * n], by simp only [rbDim, e]⟩
      | dense => simp [e, projSplit] at h
      | plain => simp [e, projSplit] at h
    | mlpOut p => exact ⟨_, _, rfl⟩
    | _ => simp [rbSite] at h
  | attention a =>
    cases k with
    | linOut p j =>
      simp only [rbSite] at h
      cases e : kd.attn j with
      | split nA => exact ⟨nA, [nA * (aLay a j).cols, (aLay a j).cols * n], by simp only [rbDim, e]⟩
      | dense => simp [e, projSplit] at h
      | plain => simp [e, projSplit] at h
    | mlpOut p => exact ⟨_, _, rfl⟩
    | _ => simp [rbSite] at h

theorem writeRoute_rows {n c : Nat} (h1 : 224 ≤ n) (h2 : n ≤ 2048) (hc : c = 5120 ∨ c = 6144) : WriteRoute (c * n) :=
  .inl ⟨n, h1, h2, by rcases hc with rfl | rfl <;> simp [Nat.mul_comm]⟩

/-- **A readback's taps are half writer counts**: the split heads' and the hidden rows'. -/
theorem writeRoute_sizes {kd : AneKinds} (hk : KindsOk kd) {n : Nat} (h1 : 224 ≤ n) (h2 : n ≤ 2048)
    {s : StageWeights} (hs : StageTy s) (h : Handles) {k : AKey} {D : Nat} {sizes : List Nat}
    (hd : rbDim kd n (stageLayout s h) k = some (D, sizes)) : ∀ N ∈ sizes, WriteRoute N := by
  cases s with
  | delta dw =>
    have hl : ∃ conv rec, stageLayout (.delta dw) h = .delta (deltaLayout dw conv rec) := by
      cases h <;> exact ⟨_, _, rfl⟩
    obtain ⟨conv, rec, e⟩ := hl
    rw [e] at hd
    obtain ⟨c0, c1, c4⟩ := delta_cols hs conv rec
    cases k with
    | linOut p j =>
      simp only [rbDim] at hd
      cases e' : kd.delta j with
      | split nA =>
        rw [e'] at hd; simp only [Option.some.injEq, Prod.mk.injEq] at hd
        obtain ⟨rfl, rfl⟩ := hd
        rcases hk.dsplit j nA e' with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
        · intro N hN; simp only [List.mem_cons, List.not_mem_nil, or_false] at hN
          rcases hN with rfl | rfl
          · rw [c0]; exact .inr (.inl rfl)
          · exact writeRoute_rows h1 h2 (.inl c0)
        · intro N hN; simp only [List.mem_cons, List.not_mem_nil, or_false] at hN
          rcases hN with rfl | rfl
          · rw [c1]; exact .inr (.inr (.inl rfl))
          · exact writeRoute_rows h1 h2 (.inl c1)
        · intro N hN; simp only [List.mem_cons, List.not_mem_nil, or_false] at hN
          rcases hN with rfl | rfl
          · rw [c4]; exact .inr (.inr (.inl rfl))
          · exact writeRoute_rows h1 h2 (.inr c4)
      | dense => rw [e'] at hd; cases hd
      | plain => rw [e'] at hd; cases hd
    | mlpOut p =>
      simp only [rbDim, Option.some.injEq, Prod.mk.injEq] at hd
      obtain ⟨rfl, rfl⟩ := hd
      intro N hN; simp only [List.mem_cons, List.not_mem_nil, or_false] at hN
      subst hN; exact writeRoute_rows h1 h2 (.inl rfl)
    | _ => simp [rbDim] at hd
  | attention aw =>
    have hl : ∃ kb vb, stageLayout (.attention aw) h = .attention (attnLayout aw kb vb) := by
      cases h <;> exact ⟨_, _, rfl⟩
    obtain ⟨kb, vb, e⟩ := hl
    rw [e] at hd
    obtain ⟨c0, c3⟩ := attn_cols hs kb vb
    cases k with
    | linOut p j =>
      simp only [rbDim] at hd
      cases e' : kd.attn j with
      | split nA =>
        rw [e'] at hd; simp only [Option.some.injEq, Prod.mk.injEq] at hd
        obtain ⟨rfl, rfl⟩ := hd
        rcases hk.asplit j nA e' with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
        · intro N hN; simp only [List.mem_cons, List.not_mem_nil, or_false] at hN
          rcases hN with rfl | rfl
          · rw [c0]; exact .inr (.inr (.inr rfl))
          · exact writeRoute_rows h1 h2 (.inl c0)
        · intro N hN; simp only [List.mem_cons, List.not_mem_nil, or_false] at hN
          rcases hN with rfl | rfl
          · rw [c3]; exact .inr (.inr (.inl rfl))
          · exact writeRoute_rows h1 h2 (.inr c3)
      | dense => rw [e'] at hd; cases hd
      | plain => rw [e'] at hd; cases hd
    | mlpOut p =>
      simp only [rbDim, Option.some.injEq, Prod.mk.injEq] at hd
      obtain ⟨rfl, rfl⟩ := hd
      intro N hN; simp only [List.mem_cons, List.not_mem_nil, or_false] at hN
      subst hN; exact writeRoute_rows h1 h2 (.inl rfl)
    | _ => simp [rbDim] at hd

theorem siteTy_pair {a b : Value} {N M : Nat} (ha : Ty a .bfloat16 [N]) (hb : Ty b .bfloat16 [M]) :
    SiteTy [N, M] [a, b] :=
  .cons ⟨ha.1, by simp [Value.size, ha.2]⟩ (.cons ⟨hb.1, by simp [Value.size, hb.2]⟩ .nil)

theorem siteTy_one {a : Value} {N : Nat} (ha : Ty a .bfloat16 [N]) : SiteTy [N] [a] :=
  .cons ⟨ha.1, by simp [Value.size, ha.2]⟩ .nil

theorem tapTy_split {k : AneProj} {nA : Nat} (e : k = .split nA) {lay : LinLayout} {n : Nat}
    {r : Value × Value × Value} (h : TapTy k lay n r) : SiteTy [nA * lay.cols, lay.cols * n] [r.2.1, r.2.2] := by
  subst e; exact siteTy_pair h.1 h.2

/-- **The family's typed taps at a readback's site are typed at its sizes.** -/
theorem tapsTy_site (kd : AneKinds) (n : Nat) (sl : StageLayout) (lv : List (List Value)) (h : TapsTyL kd n sl lv)
    (k : AKey) (s D : Nat) (sizes : List Nat) (hs : rbSite kd sl k = some s) (hd : rbDim kd n sl k = some (D, sizes)) :
    ∃ vs, lv[s]? = some vs ∧ SiteTy sizes vs := by
  cases sl with
  | delta d =>
    obtain ⟨rq, rz, rb, ra, ro, rm, rfl, t0, t1, t3, t2, t4, tm⟩ := h
    cases k with
    | linOut p j =>
      simp only [rbSite] at hs
      cases e : kd.delta j with
      | split nA =>
        simp only [rbDim, e, Option.some.injEq, Prod.mk.injEq] at hd
        obtain ⟨rfl, rfl⟩ := hd
        simp [e, projSplit] at hs
        rcases deltaSite_cases hs with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
        · exact ⟨_, rfl, tapTy_split e t0⟩
        · exact ⟨_, rfl, tapTy_split e t1⟩
        · exact ⟨_, rfl, tapTy_split e t3⟩
        · exact ⟨_, rfl, tapTy_split e t2⟩
        · exact ⟨_, rfl, tapTy_split e t4⟩
      | dense => simp [e, projSplit] at hs
      | plain => simp [e, projSplit] at hs
    | mlpOut p =>
      simp only [rbSite, Option.some.injEq] at hs
      simp only [rbDim, Option.some.injEq, Prod.mk.injEq] at hd
      obtain ⟨rfl, rfl⟩ := hd
      subst hs
      exact ⟨_, rfl, siteTy_one tm⟩
    | _ => simp [rbSite] at hs
  | attention a =>
    obtain ⟨rq, rk, rv, ro, rm, rfl, t0, t1, t2, t3, tm⟩ := h
    cases k with
    | linOut p j =>
      simp only [rbSite] at hs
      cases e : kd.attn j with
      | split nA =>
        simp only [rbDim, e, Option.some.injEq, Prod.mk.injEq] at hd
        obtain ⟨rfl, rfl⟩ := hd
        simp [e, projSplit] at hs
        obtain ⟨hj, hsj⟩ := attnSite_cases hs
        rcases (show j = 0 ∨ j = 1 ∨ j = 2 ∨ j = 3 by omega) with rfl | rfl | rfl | rfl <;> subst hsj
        · exact ⟨_, rfl, tapTy_split e t0⟩
        · exact ⟨_, rfl, tapTy_split e t1⟩
        · exact ⟨_, rfl, tapTy_split e t2⟩
        · exact ⟨_, rfl, tapTy_split e t3⟩
      | dense => simp [e, projSplit] at hs
      | plain => simp [e, projSplit] at hs
    | mlpOut p =>
      simp only [rbSite, Option.some.injEq] at hs
      simp only [rbDim, Option.some.injEq, Prod.mk.injEq] at hd
      obtain ⟨rfl, rfl⟩ := hd
      subst hs
      exact ⟨_, rfl, siteTy_one tm⟩
    | _ => simp [rbSite] at hs

/-- The graph's and the values' taps at a site have equal lengths. -/
theorem site_len (kd : AneKinds) (n : Nat) (sl : StageLayout) (l : List (List Nat)) (lv : List (List Value))
    (h1 : TapShape sl l) (h2 : TapsTyL kd n sl lv) (s : Nat) (ts : List Nat) (vs : List Value) (ht : l[s]? = some ts)
    (hv : lv[s]? = some vs) : ts.length = vs.length := by
  cases sl with
  | delta d =>
    obtain ⟨a1, a2, b1, b2, c1, c2, d1, d2, e1, e2, f, rfl⟩ := h1
    obtain ⟨rq, rz, rb, ra, ro, rm, rfl, -⟩ := h2
    match s, ht, hv with
    | 0, ht, hv => cases ht; cases hv; rfl
    | 1, ht, hv => cases ht; cases hv; rfl
    | 2, ht, hv => cases ht; cases hv; rfl
    | 3, ht, hv => cases ht; cases hv; rfl
    | 4, ht, hv => cases ht; cases hv; rfl
    | 5, ht, hv => cases ht; cases hv; rfl
    | _ + 6, ht, _ => simp at ht
  | attention a =>
    obtain ⟨a1, a2, b1, b2, c1, c2, d1, d2, f, rfl⟩ := h1
    obtain ⟨rq, rk, rv, ro, rm, rfl, -⟩ := h2
    match s, ht, hv with
    | 0, ht, hv => cases ht; cases hv; rfl
    | 1, ht, hv => cases ht; cases hv; rfl
    | 2, ht, hv => cases ht; cases hv; rfl
    | 3, ht, hv => cases ht; cases hv; rfl
    | 4, ht, hv => cases ht; cases hv; rfl
    | _ + 5, ht, _ => simp at ht

/-! ## The expected graph's facts at a site -/

theorem facts_get {α β : Type} [Handle α β] (as : List α) (bs : List β) (i : Nat) (a : α) (b : β)
    (ha : as[i]? = some a) (hb : bs[i]? = some b) : ∀ q ∈ Handle.facts a b, q ∈ Handle.facts as bs := by
  intro q hq
  rw [facts_list]
  refine List.mem_flatMap.mpr ⟨(a, b), ?_, hq⟩
  exact List.mem_of_getElem? (List.getElem?_zip_eq_some.mpr ⟨ha, hb⟩)

/-- Indices whose values are known give the values. -/
theorem site_mapM (vals : List Value) : ∀ (ts : List Nat) (vs : List Value), ts.length = vs.length →
    (∀ q ∈ Handle.facts ts vs, vals[q.1]? = some q.2) → (ts.mapM fun t => vals[t]?) = some vs
  | [], [], _, _ => rfl
  | t :: ts, v :: vs, hl, h => by
    have h1 : vals[t]? = some v := h (t, v) (by simp [Handle.facts])
    have h2 := site_mapM vals ts vs (by simpa using hl) fun q hq => h q (by
      simp only [facts_list, List.zip_cons_cons, List.flatMap_cons, List.mem_append] at hq ⊢
      exact .inr hq)
    simp [List.mapM_cons, h1, h2]
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl

/-- Cache node pairs whose values are known give the cache values. -/
theorem caches_mapM (vals : List Value) : ∀ (gs : List (Nat × Nat)) (vs : List (Value × Value)), gs.length = vs.length →
    (∀ q ∈ Handle.facts gs vs, vals[q.1]? = some q.2) →
    (gs.mapM fun c => do pure ((← vals[c.1]?), (← vals[c.2]?))) = some vs
  | [], [], _, _ => rfl
  | c :: gs, v :: vs, hl, h => by
    have h1 : vals[c.1]? = some v.1 := h (c.1, v.1) (by simp [Handle.facts])
    have h2 : vals[c.2]? = some v.2 := h (c.2, v.2) (by simp [Handle.facts])
    have h3 := caches_mapM vals gs vs (by simpa using hl) fun q hq => h q (by
      simp only [facts_list, List.zip_cons_cons, List.flatMap_cons, List.mem_append] at hq ⊢
      exact .inr hq)
    rw [List.mapM_cons, h3]
    simp [h1, h2]
  | [], _ :: _, hl, _ => by simp at hl
  | _ :: _, [], hl, _ => by simp at hl

end Host.Mlx.SimGraph.Mach
