import host.sim.conv.Iso
import host.sim.conv.SuppMap
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim

/-! # Merge: from a stage's return back to the caller's relation

At the return of a stage call isolated by `isolate` (`host.sim.conv.Iso`), the stage's relation
holds at the template's return state `s2` (under `M2`, an extension of `M.after σ`, with the
caller's frames as the target-only stack base), and the caller-only target entries are as at the
call (`StageTpl.HoldsZ`). The caller's merged state `sr` is the caller's call state `s` with the
stage's written and fresh entries `wr` (a fact of the template: every other entry of `s2` is
`s0`'s) pushed into the caller's names by `τ = σ.res …` (`σ`'s names; the template's number
references past the call's table become fresh references of the caller, `Map.res`), its control,
stack, jobs, stores and new events the images of `s2`'s (`Mer`). `merge`: the target is related to
`sr` under the glued map `Map.glue M M2` (the caller's names, the stage's images at the new
references) at a valuation `νr` that evaluates the new table entries `es` as the stage's entries
(fresh table variables bound to the stage's numeric results, or any expressions with the same
values) and keeps the caller's table's values. The native part is a parameter (`hffi`: the
world's merge law, `host.sim.conv.Native` for the gen relation).

Kernel checks: none for `sr` (it is the definition `mergeSt`, `mergeSt_mer`); the template facts
`StageFoot` once per stage template; per call only what the merged state's later use evaluates. -/

/-- The template's references below `n0` keep `σ`'s images; those from `n0` on become the
caller's references from `nS` on (the merge's fresh references). -/
def _root_.Host.Ts.Sim.Map.res (σ : Map) (n0 nS : Nat) : Map :=
  { σ with num := fun i => bif Nat.blt i n0 then σ.num i else .ref (nS + (i - n0)) }

/-- The caller's map with the references from `nS` on bound to the stage map's images from `n0`
on. -/
def _root_.Host.Ts.Sim.Map.glue (M M2 : Map) (nS n0 : Nat) : Map :=
  { M with num := fun k => bif Nat.blt k nS then M.num k else M2.num (n0 + (k - nS)) }

theorem _root_.Host.Ts.Sim.Map.res_ext (σ : Map) (n0 nS : Nat) : Ext σ (σ.res n0 nS) n0 :=
  ⟨rfl, rfl, rfl, rfl, fun i hi => by simp [Map.res, Nat.blt_eq, hi]⟩

theorem _root_.Host.Ts.Sim.Map.glue_ext (M M2 : Map) (nS n0 : Nat) : Ext M (M.glue M2 nS n0) nS :=
  ⟨rfl, rfl, rfl, rfl, fun i hi => by simp [Map.glue, Nat.blt_eq, hi]⟩

theorem _root_.Host.Ts.Sim.Map.res_new (σ : Map) {n0 nS i : Nat} (hi : n0 ≤ i) : (σ.res n0 nS).num i = .ref (nS + (i - n0)) := by
  have : Nat.blt i n0 = false := Bool.eq_false_iff.mpr (fun h => by simp only [Nat.blt_eq] at h; omega)
  show (bif Nat.blt i n0 then σ.num i else NumV.ref (nS + (i - n0))) = _
  rw [this]; rfl

theorem _root_.Host.Ts.Sim.Map.glue_new (M M2 : Map) {nS n0 k : Nat} (hk : nS ≤ k) : (M.glue M2 nS n0).num k = M2.num (n0 + (k - nS)) := by
  have : Nat.blt k nS = false := Bool.eq_false_iff.mpr (fun h => by simp only [Nat.blt_eq] at h; omega)
  show (bif Nat.blt k nS then M.num k else M2.num (n0 + (k - nS))) = _
  rw [this]; rfl

/-- **Facts of a stage template** about its run from `s0` to `s2`: the written and fresh present
addresses `wr`; every other entry is the start's; the written ones below the start's counter were
present at the start. -/
structure StageFoot {S : Type} (wr : List Nat) (s0 s2 : St S) : Prop where
  wrP : ∀ b ∈ wr, Present s2 b
  wr0 : ∀ b ∈ wr, b < s0.next → Present s0 b
  same : ∀ b, b ∉ wr → s2.heap.get b = s0.heap.get b
  grows : s0.next ≤ s2.next

/-- **The merged state** `sr`: the call state `s` with the template's written and fresh entries
pushed by `τ` (at `σ`'s addresses), the rest of the call heap kept, and the template's control,
stack (above the caller's frames `rs`), jobs, stores and new events pushed by `τ`. -/
structure Mer {S : Type} (σ τ : Map) (rs : List Frame) (wr : List Nat) (s0 s s2 sr : St S) : Prop where
  ovr : ∀ b ∈ wr, sr.heap.get (σ.a b) = (s2.heap.get b).map τ.hobj
  kept : ∀ a, (∀ b ∈ wr, σ.a b ≠ a) → sr.heap.get a = s.heap.get a
  next : sr.next = s.next + (s2.next - s0.next)
  ctl : sr.ctl = τ.ctl s2.ctl
  stack : sr.stack = s2.stack.map τ.frame ++ rs
  jobs : sr.jobs = s2.jobs.map τ.job
  stores : sr.stores = τ.stores s2.stores
  trace : ∃ fresh, s2.trace = fresh ++ s0.trace ∧ sr.trace = fresh.map τ.event ++ s.trace

section
variable {F : Ffi} {FR FR2 : Map → Nat → F.S → F.S → Prop} {FS : Map → F.S → F.S → Prop}
  {W W2 : Nat → Option WFrame} {stk : List Frame}
  {M M2 σ : Map} {ν νr : Nat → F64} {θ : Nat → SymE} {K : Ctx} {rs : List Frame}
  {s0 s s2 sr t t' : St F.S} {S0 S S2 : SSrv} {es : List SymE} {or : List Ans} {C C' : CSrv} {wr : List Nat}

/-- The hypotheses of the merge, bundled. -/
structure MergeIn (F : Ffi) (FR FR2 : Map → Nat → F.S → F.S → Prop) (FS : Map → F.S → F.S → Prop)
    (W W2 : Nat → Option WFrame) (stk : List Frame) (M M2 σ : Map) (ν : Nat → F64) (θ : Nat → SymE) (K : Ctx)
    (rs : List Frame) (wr : List Nat) (s0 s s2 sr t t' : St F.S) (S0 S S2 : SSrv) (C C' : CSrv) : Prop where
  hc : RelB F FR W stk M ν K s S t C
  iso : Iso F FS σ θ K rs s0 S0 s S
  h2 : RelB F FR2 W2 (rs.map M.frame ++ stk) M2 (Shift.valuation θ ν) (isoCtx K s0 t) s2 S2 t' C'
  ext : Ext (M.after σ) M2 S0.tab.length
  len : S0.tab.length ≤ S2.tab.length
  frozen : ∀ a, CallerOnly (M.after σ) s0 t a → t'.heap.get a = t.heap.get a
  cle : CSrv.Le C C'
  foot : StageFoot wr s0 s2
  mer : Mer σ (σ.res S0.tab.length S.tab.length) rs wr s0 s s2 sr

set_option linter.unusedSectionVars false

namespace MergeIn
variable (H : MergeIn F FR FR2 FS W W2 stk M M2 σ ν θ K rs wr s0 s s2 sr t t' S0 S S2 C C')
include H

theorem tnext_ge : s0.next ≤ t.next := by
  have := H.hc.offset; have := H.iso.grows; omega

theorem t'next : t'.next = t.next + (s2.next - s0.next) := by
  have h1 := H.h2.offset
  have := H.tnext_ge
  have := H.foot.grows
  simp only [isoCtx] at h1
  omega

/-- Fresh template addresses go to the caller's fresh addresses. -/
theorem σ_fresh {b : Nat} (hb : s0.next ≤ b) : σ.a b = s.next + (b - s0.next) := by
  have := H.iso.next (b - s0.next)
  rwa [Nat.add_sub_cancel' hb] at this

/-- A present address of the template's end: an old one is present at the start, a fresh one maps
at or above the caller's counter. -/
theorem s2_old {b : Nat} (hb : Present s2 b) (hlt : b < s0.next) : Present s0 b := by
  by_cases hw : b ∈ wr
  · exact H.foot.wr0 b hw hlt
  · unfold Present at hb ⊢; rw [← H.foot.same b hw]; exact hb

theorem s0_s2 {b : Nat} (hb : Present s0 b) : Present s2 b := by
  by_cases hw : b ∈ wr
  · exact H.foot.wrP b hw
  · unfold Present at hb ⊢; rw [H.foot.same b hw]; exact hb

/-- The footprint and the fresh addresses are unframed in the caller. -/
theorem unfr2 {b : Nat} (hb : Present s2 b) : K.fr (σ.a b) = none := by
  by_cases hlt : b < s0.next
  · exact H.iso.unfr b (H.s2_old hb hlt)
  · cases hk : K.fr (σ.a b) with
    | none => rfl
    | some p =>
      have := H.hc.presentBound _ (H.hc.framedPresent _ _ hk)
      rw [H.σ_fresh (by omega)] at this
      omega

theorem present_s {a : Nat} (ha : Present s a) : Present sr a := by
  by_cases hw : ∃ b ∈ wr, σ.a b = a
  · obtain ⟨b, hb, rfl⟩ := hw
    obtain ⟨h2, hg⟩ := Present.get (H.foot.wrP b hb)
    have := H.mer.ovr b hb
    rw [hg] at this
    exact Present.of_get this
  · have := H.mer.kept a (fun b hb e => hw ⟨b, hb, e⟩)
    unfold Present at ha ⊢; rw [this]; exact ha

theorem present_s2 {b : Nat} (hb : Present s2 b) : Present sr (σ.a b) := by
  by_cases hw : b ∈ wr
  · obtain ⟨h2, hg⟩ := Present.get hb
    have := H.mer.ovr b hw
    rw [hg] at this
    exact Present.of_get this
  · have hb0 : Present s0 b := by unfold Present at hb ⊢; rw [← H.foot.same b hw]; exact hb
    exact H.present_s (H.iso.present hb0)

/-- A present address of the merged state is the caller's or a fresh image. -/
theorem present_cases {a : Nat} (ha : Present sr a) :
    Present s a ∨ ∃ b, Present s2 b ∧ s0.next ≤ b ∧ σ.a b = a := by
  by_cases hw : ∃ b ∈ wr, σ.a b = a
  · obtain ⟨b, hb, rfl⟩ := hw
    by_cases hlt : b < s0.next
    · exact .inl (H.iso.present (H.foot.wr0 b hb hlt))
    · exact .inr ⟨b, H.foot.wrP b hb, by omega, rfl⟩
  · have := H.mer.kept a (fun b hb e => hw ⟨b, hb, e⟩)
    unfold Present at ha ⊢; rw [← this]; exact .inl ha

theorem τ_agree : Agree (Present s0) S0.tab.length σ (σ.res S0.tab.length S.tab.length) :=
  (Map.res_ext σ _ _).agree

theorem ag2 : Agree (Present s2) S2.tab.length M2 ((M.glue M2 S.tab.length S0.tab.length).after
    (σ.res S0.tab.length S.tab.length)) where
  a x _ := by rw [H.ext.a]; rfl
  num i hi := by
    by_cases h0 : i < S0.tab.length
    · rw [H.ext.num i h0]
      show M.nv (σ.num i) = (M.glue M2 _ _).nv ((σ.res _ _).num i)
      rw [(Map.res_ext σ _ _).num i h0]
      exact (Map.nv_agree (A := fun _ => True) ((Map.glue_ext M M2 _ _).agree) (H.iso.numSupp h0))
    · show M2.num i = (M.glue M2 _ _).nv ((σ.res _ _).num i)
      rw [Map.res_new σ (by omega)]
      show M2.num i = (M.glue M2 _ _).num _
      rw [Map.glue_new M M2 (by omega)]
      congr 1; omega
  big := by rw [H.ext.big]; rfl
  region := by rw [H.ext.region]; rfl
  node := by rw [H.ext.node]; rfl

theorem agS : Agree (Present s) S.tab.length M (M.glue M2 S.tab.length S0.tab.length) :=
  (Map.glue_ext M M2 _ _).agree

/-- The image of a template entry of the end, in the glued names, is the stage map's image. -/
theorem img2 {b : Nat} {h : HObj} (hg : s2.heap.get b = some h) :
    M2.hobj h = (M.glue M2 S.tab.length S0.tab.length).hobj ((σ.res S0.tab.length S.tab.length).hobj h) := by
  rw [Map.hobj_after]
  exact Map.hobj_agree H.ag2 (H.h2.heapSupp b h hg)

theorem heapSlot (a : Nat) (h : HObj) (ha : sr.heap.get a = some h) :
    SlotW (M.glue M2 S.tab.length S0.tab.length) K.fr W a h
      (t'.heap.get ((M.glue M2 S.tab.length S0.tab.length).a a)) := by
  show SlotW _ K.fr W a h (t'.heap.get (M.a a))
  by_cases hw : ∃ b ∈ wr, σ.a b = a
  · obtain ⟨b, hb, rfl⟩ := hw
    have hP := H.foot.wrP b hb
    obtain ⟨h2, hg⟩ := Present.get hP
    have ho := H.mer.ovr b hb
    rw [hg, ha] at ho
    cases ho
    refine (SlotW.of_fr_none (H.unfr2 hP)).2 ?_
    have ht := (SlotW.of_fr_none rfl).1 (H.h2.heap b h2 hg)
    rw [show M.a (σ.a b) = M2.a b by rw [H.ext.a]; rfl, ht, H.img2 hg]
  · have hk := H.mer.kept a (fun b hb e => hw ⟨b, hb, e⟩)
    rw [hk] at ha
    by_cases hf : ∃ b, Present s0 b ∧ σ.a b = a
    · obtain ⟨b, hb0, rfl⟩ := hf
      have hbw : b ∉ wr := fun hb => hw ⟨b, hb, rfl⟩
      obtain ⟨h0, hg0⟩ := Present.get hb0
      have hs := H.iso.heap b h0 hg0
      rw [ha] at hs
      cases hs
      have hg2 : s2.heap.get b = some h0 := by rw [H.foot.same b hbw]; exact hg0
      refine (SlotW.of_fr_none (H.iso.unfr b hb0)).2 ?_
      have ht := (SlotW.of_fr_none rfl).1 (H.h2.heap b h0 hg2)
      rw [show M.a (σ.a b) = M2.a b by rw [H.ext.a]; rfl, ht, H.img2 hg2,
        Map.hobj_agree H.τ_agree (H.iso.heapSupp b h0 hg0)]
    · have hpa : Present s a := Present.of_get ha
      have hfz : t'.heap.get (M.a a) = t.heap.get (M.a a) := by
        refine H.frozen _ ⟨H.hc.bound a hpa, fun b hb e => hf ⟨b, hb, ?_⟩⟩
        exact H.hc.inj _ _ (H.iso.present hb) hpa e
      rw [hfz]
      exact SlotW.ext (Map.glue_ext M M2 _ _) (H.hc.heapSupp a h ha) (H.hc.heap a h ha)

theorem nextF (k : Nat) : (M.glue M2 S.tab.length S0.tab.length).a (sr.next + k) = t'.next + k := by
  show M.a (sr.next + k) = t'.next + k
  rw [H.mer.next, show s.next + (s2.next - s0.next) + k = s.next + ((s2.next - s0.next) + k) by omega,
    H.hc.next, H.t'next]
  omega

theorem boundF (a : Nat) (ha : Present sr a) : (M.glue M2 S.tab.length S0.tab.length).a a < t'.next := by
  show M.a a < t'.next
  rcases H.present_cases ha with hs | ⟨b, hb, _, rfl⟩
  · have := H.hc.bound a hs; have := H.t'next; omega
  · rw [show M.a (σ.a b) = M2.a b by rw [H.ext.a]; rfl]
    exact H.h2.bound b hb

theorem injF (a b : Nat) (ha : Present sr a) (hb : Present sr b)
    (he : (M.glue M2 S.tab.length S0.tab.length).a a = (M.glue M2 S.tab.length S0.tab.length).a b) : a = b := by
  change M.a a = M.a b at he
  have hfresh : ∀ x b', Present s x → Present s2 b' → s0.next ≤ b' → M.a x ≠ M.a (σ.a b') := by
    intro x b' hx hb' hge e
    have h1 := H.hc.bound x hx
    rw [H.σ_fresh hge, H.hc.next] at e
    omega
  rcases H.present_cases ha with ha | ⟨a', ha', hga, rfl⟩ <;>
    rcases H.present_cases hb with hb | ⟨b', hb', hgb, rfl⟩
  · exact H.hc.inj a b ha hb he
  · exact absurd he (hfresh a b' ha hb' hgb)
  · exact absurd he.symm (hfresh b a' hb ha' hga)
  · rw [show M.a (σ.a a') = M2.a a' by rw [H.ext.a]; rfl,
      show M.a (σ.a b') = M2.a b' by rw [H.ext.a]; rfl] at he
    rw [H.h2.inj a' b' ha' hb' he]

theorem presentBoundF (a : Nat) (ha : Present sr a) : a < sr.next := by
  rw [H.mer.next]
  rcases H.present_cases ha with hs | ⟨b, hb, hge, rfl⟩
  · have := H.hc.presentBound a hs; omega
  · rw [H.σ_fresh hge]
    have := H.h2.presentBound b hb
    omega

theorem ctlF : t'.ctl = (M.glue M2 S.tab.length S0.tab.length).ctl sr.ctl := by
  rw [H.h2.ctl, H.mer.ctl, Map.ctl_after]
  exact Map.ctl_agree H.ag2 H.h2.ctlSupp

theorem rsSupp : ∀ f ∈ rs, Supp.frame (Present s) S.tab.length f := fun f hf =>
  H.hc.stackSupp f (by rw [H.iso.stack]; exact List.mem_append_right _ hf)

theorem stackF : t'.stack = sr.stack.map (M.glue M2 S.tab.length S0.tab.length).frame ++ stk := by
  rw [H.h2.stack, H.mer.stack, List.map_append, List.map_map, List.append_assoc]
  congr 1
  · exact List.map_congr_left fun f hf => by
      rw [Function.comp_apply, Map.frame_after]
      exact Map.frame_agree H.ag2 (H.h2.stackSupp f hf)
  · congr 1
    exact List.map_congr_left fun f hf => Map.frame_agree H.agS (H.rsSupp f hf)

theorem jobsF : t'.jobs = sr.jobs.map (M.glue M2 S.tab.length S0.tab.length).job := by
  rw [H.h2.jobs, H.mer.jobs, List.map_map]
  exact List.map_congr_left fun j hj => by
    rw [Function.comp_apply, Map.job_after]
    exact Map.job_agree H.ag2 (H.h2.jobsSupp j hj)

theorem storesF : t'.stores = (M.glue M2 S.tab.length S0.tab.length).stores sr.stores := by
  rw [H.h2.stores, H.mer.stores, Map.stores_after]
  exact Map.stores_agree H.ag2 H.h2.storesSupp

/-- The template's new events since the call, with their support. -/
theorem fresh2 : ∃ fresh, s2.trace = fresh ++ s0.trace ∧ sr.trace = fresh.map (σ.res S0.tab.length S.tab.length).event ++ s.trace ∧
    t'.trace = fresh.map M2.event ++ t.trace ∧ ∀ e ∈ fresh, Supp.event (Present s2) S2.tab.length e := by
  obtain ⟨fr, h1, h2⟩ := H.mer.trace
  obtain ⟨fr2, g1, g2⟩ := H.h2.trace
  obtain ⟨fr3, k1, k2⟩ := H.h2.traceSupp
  simp only [isoCtx] at g1 g2 k1
  have e2 : fr2 = fr := List.append_cancel_right (g1.symm.trans h1)
  have e3 : fr3 = fr := List.append_cancel_right (k1.symm.trans h1)
  subst e2 e3
  exact ⟨_, h1, h2, g2, k2⟩

theorem traceF : ∃ fresh, sr.trace = fresh ++ K.base ∧
    t'.trace = fresh.map (M.glue M2 S.tab.length S0.tab.length).event ++ K.base' := by
  obtain ⟨fr, -, h2, g2, k2⟩ := H.fresh2
  obtain ⟨fc, c1, c2⟩ := H.hc.trace
  obtain ⟨fc', d1, d2⟩ := H.hc.traceSupp
  have ec : fc' = fc := List.append_cancel_right (d1.symm.trans c1)
  subst ec
  refine ⟨fr.map (σ.res S0.tab.length S.tab.length).event ++ fc', by rw [h2, d1, List.append_assoc], ?_⟩
  rw [g2, c2, List.map_append, List.map_map, List.append_assoc]
  congr 1
  · exact List.map_congr_left fun e he => by
      rw [Function.comp_apply, Map.event_after]
      exact Map.event_agree H.ag2 (k2 e he)
  · congr 1
    exact List.map_congr_left fun e he => Map.event_agree H.agS (d2 e he)

/-! ### Closedness of the merged state -/

theorem resNum (hlen : S.tab.length + (S2.tab.length - S0.tab.length) ≤ nR) :
    ∀ i, i < S2.tab.length → Supp.nv (Present sr) nR ((σ.res S0.tab.length S.tab.length).num i) := by
  intro i hi
  by_cases h0 : i < S0.tab.length
  · rw [(Map.res_ext σ _ _).num i h0]
    exact Supp.nv_mono (fun _ h => h) (by omega) (H.iso.numSupp (A := Present sr) h0)
  · rw [Map.res_new σ (by omega)]
    show _ < nR
    omega

theorem heapSuppF {nR : Nat} (hlen : S.tab.length + (S2.tab.length - S0.tab.length) ≤ nR) (a : Nat) (h : HObj)
    (ha : sr.heap.get a = some h) : Supp.hobj (Present sr) nR h := by
  by_cases hw : ∃ b ∈ wr, σ.a b = a
  · obtain ⟨b, hb, rfl⟩ := hw
    obtain ⟨h2, hg⟩ := Present.get (H.foot.wrP b hb)
    have ho := H.mer.ovr b hb
    rw [hg, ha] at ho
    cases ho
    exact Supp.hobj_map (σ := σ.res S0.tab.length S.tab.length) (fun x hx => H.present_s2 hx) (H.resNum hlen) (H.h2.heapSupp b h2 hg)
  · have hk := H.mer.kept a (fun b hb e => hw ⟨b, hb, e⟩)
    rw [hk] at ha
    exact Supp.hobj_mono (fun x hx => H.present_s hx) (by omega) (H.hc.heapSupp a h ha)

end MergeIn

/-- **Merge.** At a stage's return, the target is related to the merged caller state `sr` under the
glued map, at a valuation `νr` that keeps the values of the caller's table and gives the new
entries `es` the values of the stage's entries past the call's table (`hes`), with the caller's
frames `W`, stack base `stk` and context `K`. The native relation at the merged state is the
world's merge law (`hffi`). -/
theorem merge (H : MergeIn F FR FR2 FS W W2 stk M M2 σ ν θ K rs wr s0 s s2 sr t t' S0 S S2 C C')
    (hesl : es.length = S2.tab.length - S0.tab.length)
    (hνS : ∀ e ∈ S.tab, e.eval νr = e.eval ν)
    (hes : ∀ j e, nth? es j = some e → ∃ e2, nth? S2.tab (S0.tab.length + j) = some e2 ∧
      e.eval νr = e2.eval (Shift.valuation θ ν))
    (hgood : Good νr or)
    (hffi : FR (M.glue M2 S.tab.length S0.tab.length) (S.tab.length + es.length) sr.ffi t'.ffi) :
    RelB F FR W stk (M.glue M2 S.tab.length S0.tab.length) νr K sr ⟨S.tab ++ es, or⟩ t' C' := by
  have hlenR : S.tab.length + (S2.tab.length - S0.tab.length) ≤ (S.tab ++ es).length := by
    simp [hesl]
  have hP : ∀ x, Present s x → Present sr x := fun _ hx => H.present_s hx
  have hle : S.tab.length ≤ (S.tab ++ es).length := by simp
  refine
    { srv := ⟨fun i e he => ?_, hgood⟩
      heap := H.heapSlot
      next := H.nextF
      offset := ?_
      room := H.hc.room
      bigFixed := H.hc.bigFixed
      bigExt := H.hc.bigExt
      band := H.hc.band
      intr := H.hc.intr
      bound := H.boundF
      inj := H.injF
      presentBound := H.presentBoundF
      framedPresent := fun a p hp => hP a (H.hc.framedPresent a p hp)
      ctl := H.ctlF
      stack := H.stackF
      jobs := H.jobsF
      stores := H.storesF
      ffi := by simpa using hffi
      trace := H.traceF
      heapSupp := H.heapSuppF hlenR
      ctlSupp := ?_
      stackSupp := ?_
      jobsSupp := ?_
      storesSupp := ?_
      traceSupp := ?_ }
  · -- numbers
    simp only at he
    by_cases hi : i < S.tab.length
    · rw [nth?_append_lt _ _ _ hi] at he
      rw [(Map.glue_ext M M2 _ _).num i hi, hνS e (nth?_mem_some he)]
      exact H.cle.val (H.hc.srv.num i e he)
    · have hj : nth? es (i - S.tab.length) = some e := by
        have : ∀ (l1 l2 : List SymE) (k : Nat), l1.length ≤ k → nth? (l1 ++ l2) k = nth? l2 (k - l1.length) := by
          intro l1
          induction l1 with
          | nil => intro l2 k _; simp
          | cons x l1 ih =>
            intro l2 k hk
            cases k with
            | zero => simp at hk
            | succ k =>
              simp only [List.cons_append, List.length_cons, Nat.succ_sub_succ]
              exact ih l2 k (by simp at hk; omega)
        rw [← this _ _ _ (by omega)]; exact he
      obtain ⟨e2, he2, hv⟩ := hes _ e hj
      rw [Map.glue_new M M2 (by omega), hv]
      exact H.h2.srv.num _ e2 he2
  · have := H.hc.offset; have := H.t'next; have := H.mer.next; have := H.iso.grows; have := H.foot.grows
    omega
  · rw [H.mer.ctl]
    exact Supp.ctl_map (σ := σ.res S0.tab.length S.tab.length) (fun x hx => H.present_s2 hx) (H.resNum hlenR) H.h2.ctlSupp
  · intro f hf
    rw [H.mer.stack] at hf
    rcases List.mem_append.1 hf with hf | hf
    · obtain ⟨g, hg, rfl⟩ := List.mem_map.1 hf
      exact Supp.frame_map (σ := σ.res S0.tab.length S.tab.length) (fun x hx => H.present_s2 hx) (H.resNum hlenR) (H.h2.stackSupp g hg)
    · exact Supp.frame_mono hP hle (H.rsSupp f hf)
  · intro j hj
    rw [H.mer.jobs] at hj
    obtain ⟨g, hg, rfl⟩ := List.mem_map.1 hj
    exact Supp.job_map (σ := σ.res S0.tab.length S.tab.length) (fun x hx => H.present_s2 hx) (H.resNum hlenR) (H.h2.jobsSupp g hg)
  · rw [H.mer.stores]
    exact Supp.stores_map (σ := σ.res S0.tab.length S.tab.length) (fun x hx => H.present_s2 hx) (H.resNum hlenR) H.h2.storesSupp
  · obtain ⟨fr, -, h2, -, k2⟩ := H.fresh2
    obtain ⟨fc, d1, d2⟩ := H.hc.traceSupp
    refine ⟨fr.map (σ.res S0.tab.length S.tab.length).event ++ fc, by rw [h2, d1, List.append_assoc], ?_⟩
    intro e he
    rcases List.mem_append.1 he with he | he
    · obtain ⟨g, hg, rfl⟩ := List.mem_map.1 he
      exact Supp.event_map (σ := σ.res S0.tab.length S.tab.length) (fun x hx => H.present_s2 hx) (H.resNum hlenR) (k2 g hg)
    · exact Supp.event_mono hP hle (d2 e he)

end

end Host.Ts.Sim.Conv
