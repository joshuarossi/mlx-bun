import host.simgraph.mach.AneStep
namespace Host.Mlx.SimGraph.Mach
open Host.Mlx.GlueStep Host.Mlx.GlueLayers
open Inference Inference.Contracts.Mlx Host.Mlx Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Ref (refRows refNu AneNet SplitSpec AneSt RSt splitRun aneNodes aneStep aneEnv withRb
  rowIds handlesOf)

/-! # A Neural Engine step is defined on well-typed handles: the run and the step -/

/-- The bucket's family. -/
abbrev aneFam (n : Nat) : RowTplX AKey := aneTpl refRows (aneKindsOf n) (aneRestOf n)

theorem mem_facts_fst {ts : List Nat} {vs : List Value} {q : Nat × Value} (h : q ∈ Handle.facts ts vs) : q.1 ∈ ts := by
  rw [facts_list] at h
  obtain ⟨p, hp, hq⟩ := List.mem_flatMap.mp h
  simp only [facts_nat, List.mem_singleton] at hq
  subst hq
  exact (List.of_mem_zip hp).1

theorem StageW.ty {s : StageWeights} (h : StageW s) : StageTy s := by
  cases s <;> exact h.1

theorem chainLayout_length {R : StageWeights → Handles → Prop} : ∀ {ws : List StageWeights} {hs : List Handles},
    List.Forall₂ R ws hs → (chainLayout ws hs).length = ws.length
  | [], [], .nil => rfl
  | _ :: _, _ :: _, .cons _ h => by simp [chainLayout, chainLayout_length h]

theorem forall₂_get {α β : Type} {R : α → β → Prop} : ∀ {as : List α} {bs : List β}, List.Forall₂ R as bs →
    ∀ {i : Nat} {a : α}, as[i]? = some a → ∃ b, bs[i]? = some b ∧ R a b
  | _ :: _, _ :: _, .cons h _, 0, _, e => by cases e; exact ⟨_, rfl, h⟩
  | _ :: _, _ :: _, .cons _ hr, i + 1, _, e => forall₂_get hr (by simpa using e)
  | [], [], .nil, _, _, e => by simp at e

section
variable {C : M1Max.Contract} {P : MlxPrefillContract C} {K : RouteKernelContract C} {NE : NeuralEngine} {net : AneNet}
  {weights : List Char → List Char → Option Value} {w : PipelineWeights} {o n : Nat} {ids : Value}
  {hs : List Handles}

/-- **Every node of the bucket family's graph has a value** at every environment holding typed readbacks. -/
theorem ane_goodAll (h : AneStepPre net w o n ids hs) :
    GoodAll P K net n (aneEnv net weights w o n ids hs)
      (familyGraph (aneFam n).toTpl.ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs)).1 := by
  intro rb hrb
  obtain ⟨r, hr, _⟩ := ane_valueRun (P := P) (K := K) (weights := weights) h hrb
  exact aneGraph_good refRows _ _ (refNu o n) o n _ r hr

/-- **Every readback input's split completes** from the run so far: its taps precede it and hold the family's
typed taps; the in-place fills, the program and the readback complete. -/
theorem ane_splitsRun (h : AneStepPre net w o n ids hs) (hNE : NE.Succeeds net) :
    SplitsRun P K NE K.inPlace net n (aneEnv net weights w o n ids hs)
      ((aneFam n).tapsOf (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs))
      (familyGraph (aneFam n).toTpl.ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) hs)).1 := by
  intro i nd k sp st hi hp hsp hrun _
  obtain ⟨q, hq⟩ : ∃ q, rbLayer k = some q := Option.ne_none_iff_exists'.mp (h.net.keys n k sp hsp)
  obtain ⟨hshape, _, hord⟩ := aneOrder (PDim.eval (refNu o n)) refRows (aneKindsOf n) (aneRestOf n) o n
    (chainLayout (stageWeights w) hs)
  obtain ⟨sl, l, s, ts, hsl, hl, hs', hts, hlt⟩ := hord i nd k q hi hp hq
  obtain ⟨sq, hq', hws, hhs, rfl⟩ := chainLayout_get hsl
  obtain ⟨D, sizes, hd⟩ := rbDim_of_site _ n _ k s hs'
  obtain ⟨sp', hsp', hok⟩ := (h.net.layers n h.lo h.hi q sq hq' hws).1 k s D sizes hq hs' hd
  rw [hsp] at hsp'
  cases hsp'
  obtain ⟨r, hr, -, -, htaps⟩ := ane_valueRun (P := P) (K := K) (weights := weights) h hrun.rbTy
  have hall := familyGraphX_eval (aneFam n) (aneTpl_simulates refRows _ _) (refNu o n) o n _ r.1.1 r.1.2 r.2 hr
  obtain ⟨lv, hlv, htl⟩ := forall₂_get htaps hsl
  obtain ⟨vs, hvs, hsty⟩ := tapsTy_site _ n _ lv htl k s D sizes hs' hd
  obtain ⟨l', hl', hsh⟩ := forall₂_get hshape hsl
  rw [hl] at hl'
  cases hl'
  have hlen := site_len _ n _ l lv hsh htl s ts vs hts hvs
  have hsite : (ts.mapM fun t => st.vals[t]?) = some vs := by
    refine site_mapM st.vals ts vs hlen fun x hx => ?_
    have hm := facts_get _ _ q l lv hl hlv x (facts_get l lv s ts vs hts hvs x hx)
    have he := hall x (List.mem_append_right _ hm)
    rw [hrun.vals x.1 (hlt x.1 (mem_facts_fst hx))]
    exact he.2
  have hsz := writeRoute_sizes (kindsOk_of n) h.lo h.hi (h.stages sq (List.mem_of_getElem? hws)).ty _ hd
  obtain ⟨fills, σ', y, hf, hc, hrb, hy⟩ := splitCall_ok K NE hok vs hsty
    (fun N hN => hsz N hN) (hNE n h.lo h.hi k sp hsp) st.surf
  refine ⟨y, ⟨st.vals ++ [y], fun k' => if k' = k then some y else st.rb k', σ',
    st.log ++ [⟨k, sp, vs, fills, st.surf, σ', y⟩]⟩, ?_, rfl, rfl, by rw [hok.m_eq, hok.d_eq]; exact hy⟩
  unfold splitRun
  rw [hok.layer, hok.site, hl]
  simp only [Option.bind_eq_bind, Option.bind_some, hts, hsite, hf, hc, hrb, Option.pure_def]

/-- **A Neural Engine step from the prefill handles**: defined, its handles at offset `o + n`. -/
theorem aneStep_ok (π : List Nat) (hnet : AneNetOk net (stageWeights w)) (hNE : NE.Succeeds net) (h1 : 224 ≤ n)
    (h2 : n ≤ 2048) (hg : Grows o n) (hpw : PipeTy w) (hw : ∀ s ∈ stageWeights w, StageW s) (s : RSt)
    (hh : List.Forall₂ (StagePre o) (stageWeights w) s.hs) (hπ : o + n ≤ π.length) (htok : ∀ t ∈ π, t < 2 ^ 31) :
    ∃ s', aneStep P K NE K.inPlace net weights w π (aneFam n) o n s = some s' ∧
      List.Forall₂ (StagePre (o + n)) (stageWeights w) s'.hs := by
  obtain ⟨ids, eids, hids, hb⟩ := rowIds_ok π o n hπ htok
  have hpre : AneStepPre net w o n ids s.hs := ⟨hnet, h1, h2, hg, hpw, hw, hh, hids, hb⟩
  obtain ⟨stF, hrun, hinv⟩ := aneNodes_ok P K NE K.inPlace net n (aneEnv net weights w o n ids s.hs) _ _
    (ane_goodAll (P := P) (K := K) hpre) (ane_splitsRun (weights := weights) hpre hNE) s.surf
  obtain ⟨r, hr, -, hcs, -⟩ := ane_valueRun (P := P) (K := K) (weights := weights) hpre hinv.rbTy
  have hall := familyGraphX_eval (aneFam n) (aneTpl_simulates refRows _ _) (refNu o n) o n _ r.1.1 r.1.2 r.2 hr
  obtain ⟨-, hcl, -⟩ := aneOrder (PDim.eval (refNu o n)) refRows (aneKindsOf n) (aneRestOf n) o n
    (chainLayout (stageWeights w) s.hs)
  have hcache := caches_mapM stF.vals
    (familyGraph (aneFam n).toTpl.ops (PDim.eval (refNu o n)) o n (chainLayout (stageWeights w) s.hs)).2.2 r.1.2
    (by rw [hcl, chainLayout_length hh, hcs.length_eq]) fun x hx => by
      have he := hall x (List.mem_append_left _ (List.mem_append_right _ hx))
      rw [hinv.vals x.1 he.1]
      exact he.2
  obtain ⟨hs', ehs, hh'⟩ := handlesOf_ok (by omega) _ _ hcs
  refine ⟨⟨hs', stF.surf, s.anes ++ [stF]⟩, ?_, hh'⟩
  simp only [Option.bind_eq_bind, Option.pure_def] at hcache
  unfold aneStep
  simp only [eids, Option.bind_eq_bind, Option.bind_some, hrun, hcache, ehs, Option.pure_def]

end

end Host.Mlx.SimGraph.Mach
