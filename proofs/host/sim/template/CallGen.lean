import host.sim.conv.Merge
import host.sim.world.IterCut
import host.sim.template.ShiftJS
import host.sim.stage.Mlx
import host.sim.conv.CompactShift
import host.sim.conv.SiteMerge
namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim
open Host.Ts.Sim.Prefill (NumRefs)

/-! # A chain's call links and end as the chain generator states them

`genChain.ts` states a stage instance's footprint as its Foot module's heap equality (`Stage.setAll` of
the written and fresh entries) and the merged and end states' framed arrays as their elements past the
template start's (`arrOf`); here they become `Conv.StageFoot` (`stageFoot_of`), the arrays' shapes
(`arrExt_of`) and `NumRefs` (`numRefs_of`), which `Compose.cut_compactQ` and `IterEndW` take. -/

/-- **A stage template's footprint** from its heap equality: the written and fresh entries, distinct and
in range, those below the start's counter present at the start. -/
theorem stageFoot_of {S : Type} {s0 s2 : St S} {wrE : List (Nat × HObj)}
    (hh : s2.heap = Stage.setAll s0.heap wrE) (hnd : (wrE.map (·.1)).Nodup)
    (hbd : ∀ b ∈ wrE.map (·.1), b / 4096 < 4 ^ 31)
    (h0 : (wrE.map (·.1)).all (fun b => !Nat.blt b s0.next || (s0.heap.get b).isSome) = true)
    (hg : s0.next ≤ s2.next) : Conv.StageFoot (wrE.map (·.1)) s0 s2 where
  wrP b hb := by
    obtain ⟨⟨b', v⟩, hm, rfl⟩ := List.mem_map.1 hb
    show (s2.heap.get b').isSome = true
    rw [hh, Stage.setAll_get_mem _ _ _ _ hnd hm (fun e he => hbd _ (List.mem_map_of_mem he))]
    rfl
  wr0 b hb hlt := by
    have := List.all_eq_true.mp h0 b hb
    rw [Nat.blt_eq.mpr hlt] at this
    show (s0.heap.get b).isSome = true
    simpa using this
  same b hb := by
    rw [hh]
    exact Stage.setAll_get _ _ _ fun e he =>
      ⟨fun h => hb (h ▸ List.mem_map_of_mem (f := (·.1)) he), hbd _ (List.mem_map_of_mem he)⟩
  grows := hg

/-- The heap entry at `a` is an array object. -/
def isArrB {S : Type} (s : St S) (a : Nat) : Bool :=
  match s.heap.get a with
  | some (.obj o) => match o.kind with
    | .array _ => true
    | _ => false
  | _ => false

/-- **An array extended past a start's** (`Compose.cut_compactQ`'s `hfwd`, `hemit`; `IterEndW.fwd`, `emit`). -/
theorem arrExt_of {S S' : Type} {s : St S} {s0 : St S'} {a : Nat} {els : List Val}
    (h1 : arrOf s a = arrOf s0 a ++ els) (h2 : isArrB s a = true) :
    ∃ o, s.heap.get a = some (.obj o) ∧ o.kind = .array (arrOf s0 a ++ els) := by
  unfold isArrB at h2
  cases hg : s.heap.get a with
  | none => rw [hg] at h2; simp at h2
  | some v =>
    rw [hg] at h2
    cases v with
    | obj o =>
      cases hk : o.kind with
      | array es =>
        refine ⟨o, rfl, ?_⟩
        have he : arrOf s a = es := by unfold arrOf; rw [hg]; simp only [hk]
        rw [hk, ← h1, he]
      | _ => simp [hk] at h2
    | _ => simp at h2

/-- An address holding no array (a wide frame's map). -/
theorem notArr_of {S : Type} {s : St S} {a : Nat} (h : isArrB s a = false) {o : Obj} {es : List Val}
    (ho : s.heap.get a = some (.obj o)) (hk : o.kind = .array es) : False := by
  unfold isArrB at h
  rw [ho] at h
  simp only [hk] at h
  cases h

/-- The values are references below `n`. -/
def numRefsB (n : Nat) (vs : List Val) : Bool :=
  vs.all fun v => match v with
    | .num (.ref j) => Nat.blt j n
    | _ => false

theorem numRefs_of {n : Nat} {vs : List Val} (h : numRefsB n vs = true) : NumRefs n vs := by
  intro v hv
  have := List.all_eq_true.mp h v hv
  match v, this with
  | .num (.ref j), hj => exact ⟨j, Nat.blt_eq.mp hj, rfl⟩

/-- **The JS bookkeeping of a state whose present addresses are all checked** (a template's blocks and frames,
`tpl_all_blocks` over `Conv.jcleanAtB`). -/
theorem jclean_of_present {S : Type} {c : Conv.Cnt} {s : St S} (h : ∀ a, Present s a → Conv.jcleanAtB c s a = true) :
    Conv.JClean c s := fun a o ho =>
  Conv.jcleanListB_sound (l := [a])
    (by simp only [Conv.jcleanListB, List.all_cons, List.all_nil, Bool.and_true]; exact h a (Present.of_get ho))
    a (List.mem_singleton_self a) o ho


/-! ## A wide site: its footprint per stream state, its written list by lemma

A site instance with many fresh heap entries (a model forward) states its footprint per stream state:
`stageFoot_ofRF` from the state's heap equality over its written ranges and fresh range (`footRB` the
counters and the old written entries), composed from the start (`FootAcc`) with each state's written
addresses in the instance's written list `footW` (`incl_of_footW`, `coverB`). The written list's facts
(`Nodup`, the bound, a check over it) are lemmas over its old written part; the fresh part is never
evaluated. The merged state is the instance's return state address by address (`merged_relB`: the
relation moves along `RelB.srcCongr`, `Conv.mergeSt_site`). -/

section
variable {S : Type}

/-- The addresses of `s`'s heap entries at the written ranges `R` and fresh from `lo`. -/
def footW (s : St S) (R : List (Nat × Nat)) (lo : Nat) : List Nat :=
  (Stage.rangesOf s.heap R ++ Stage.freshOf s.heap lo s.next).map (·.1)

theorem get_of_mem_freshOf {α : Type} {h : PTrie α} {lo hi : Nat} {e : Nat × α} (he : e ∈ Stage.freshOf h lo hi) :
    h.get e.1 = some e.2 := by
  obtain ⟨a, _, hx⟩ := List.mem_filterMap.1 he
  cases hg : h.get a with
  | none => rw [hg] at hx; cases hx
  | some v => rw [hg] at hx; cases hx; exact hg

theorem get_of_mem_rangesOf {α : Type} {h : PTrie α} : ∀ {R : List (Nat × Nat)} {e : Nat × α},
    e ∈ Stage.rangesOf h R → h.get e.1 = some e.2
  | [], _, he => by cases he
  | (lo, hi) :: R, e, he => by
    rcases List.mem_append.mp he with h1 | h1
    · exact get_of_mem_freshOf h1
    · exact get_of_mem_rangesOf h1

theorem mem_freshOf_of {α : Type} {h : PTrie α} {lo hi a : Nat} {v : α} (h1 : lo ≤ a) (h2 : a < hi)
    (hg : h.get a = some v) : (a, v) ∈ Stage.freshOf h lo hi :=
  List.mem_filterMap.2 ⟨a, List.mem_range'.2 ⟨a - lo, by omega, by omega⟩, by simp [hg]⟩

theorem mem_rangesOf_of {α : Type} {h : PTrie α} {a : Nat} {v : α} (hg : h.get a = some v) :
    ∀ {R : List (Nat × Nat)} {p : Nat × Nat}, p ∈ R → p.1 ≤ a → a < p.2 → (a, v) ∈ Stage.rangesOf h R
  | [], _, hp, _, _ => by cases hp
  | (lo, hi) :: R, p, hp, h1, h2 => by
    show (a, v) ∈ Stage.freshOf h lo hi ++ Stage.rangesOf h R
    rcases List.mem_cons.mp hp with rfl | hp
    · exact List.mem_append_left _ (mem_freshOf_of h1 h2 hg)
    · exact List.mem_append_right _ (mem_rangesOf_of hg hp h1 h2)

theorem lt_of_mem_footW {s : St S} {R : List (Nat × Nat)} {lo b : Nat} (hR : ∀ p ∈ R, p.2 ≤ s.next)
    (hb : b ∈ footW s R lo) : b < s.next := by
  obtain ⟨e, he, rfl⟩ := List.mem_map.1 hb
  rcases List.mem_append.mp he with h1 | h1
  · obtain ⟨p, hp, _, h2⟩ := Stage.mem_rangesOf h1
    exact Nat.lt_of_lt_of_le h2 (hR p hp)
  · exact (Stage.mem_freshOf h1).2

theorem present_of_mem_footW {s : St S} {R : List (Nat × Nat)} {lo b : Nat} (hb : b ∈ footW s R lo) :
    Present s b := by
  obtain ⟨e, he, rfl⟩ := List.mem_map.1 hb
  rcases List.mem_append.mp he with h1 | h1
  · exact Present.of_get (get_of_mem_rangesOf h1)
  · exact Present.of_get (get_of_mem_freshOf h1)

/-- A check over the written list from its old written part (the fresh part passes it). -/
theorem footW_all {s : St S} {R : List (Nat × Nat)} {lo : Nat} {f : Nat → Bool}
    (hR : (Stage.rangesOf s.heap R).all (fun e => f e.1) = true) (hF : ∀ b, lo ≤ b → f b = true) :
    (footW s R lo).all f = true := by
  refine List.all_eq_true.mpr fun b hb => ?_
  obtain ⟨e, he, rfl⟩ := List.mem_map.1 hb
  rcases List.mem_append.mp he with h1 | h1
  · exact List.all_eq_true.mp hR e h1
  · exact hF _ (Stage.mem_freshOf h1).1

/-- A check of the written addresses below `n ≤ lo` (`SiteL`'s `wr0B`, `SiteZ`'s `zwr`). -/
theorem footW_lowAll {s : St S} {R : List (Nat × Nat)} {lo n : Nat} {g : Nat → Bool} (hn : Nat.ble n lo = true)
    (hR : (Stage.rangesOf s.heap R).all (fun e => !Nat.blt e.1 n || g e.1) = true) :
    (footW s R lo).all (fun b => !Nat.blt b n || g b) = true :=
  footW_all hR fun b hb => by
    have : Nat.blt b n = false := by
      cases h : Nat.blt b n
      · rfl
      · have := Nat.blt_eq.mp h; have := Nat.le_of_ble_eq_true hn; omega
    rw [this]; rfl

theorem keys_filterMap_nodup {α : Type} (h : PTrie α) : ∀ (l : List Nat), l.Nodup →
    ((l.filterMap fun a => (h.get a).map (a, ·)).map (·.1)).Nodup
  | [], _ => List.nodup_nil
  | a :: l, hn => by
    have hn' := List.nodup_cons.mp hn
    have ih := keys_filterMap_nodup h l hn'.2
    cases hg : h.get a with
    | none => rw [List.filterMap_cons_none (by simp [hg])]; exact ih
    | some v =>
      rw [List.filterMap_cons_some (b := (a, v)) (by simp [hg]), List.map_cons]
      refine List.nodup_cons.mpr ⟨fun hm => hn'.1 ?_, ih⟩
      obtain ⟨e, he, hea⟩ := List.mem_map.1 hm
      obtain ⟨c, hc, hce⟩ := List.mem_filterMap.1 he
      cases hgc : h.get c with
      | none => rw [hgc] at hce; cases hce
      | some w =>
        rw [hgc] at hce; cases hce
        have : c = a := hea
        exact this ▸ hc

/-- **The written list is distinct**: its old written part (checked) below `lo`, the fresh part distinct. -/
theorem footW_nodup {s : St S} {R : List (Nat × Nat)} {lo : Nat}
    (hR : ((Stage.rangesOf s.heap R).map (·.1)).Nodup) (hlo : ∀ p ∈ R, p.2 ≤ lo) : (footW s R lo).Nodup := by
  unfold footW
  rw [List.map_append]
  refine List.nodup_append.mpr ⟨hR, keys_filterMap_nodup s.heap _ (List.nodup_range' ..), fun a ha b hb hab => ?_⟩
  obtain ⟨e, he, rfl⟩ := List.mem_map.1 ha
  obtain ⟨e', he', rfl⟩ := List.mem_map.1 hb
  obtain ⟨p, hp, _, h2⟩ := Stage.mem_rangesOf he
  have := (Stage.mem_freshOf he').1
  have := hlo p hp
  omega

theorem footW_bound {s : St S} {R : List (Nat × Nat)} {lo : Nat} (hR : ∀ p ∈ R, p.2 ≤ s.next)
    (hs : s.next / 4096 < 4 ^ 31) : ∀ b ∈ footW s R lo, b / 4096 < 4 ^ 31 := fun _ hb =>
  Nat.lt_of_le_of_lt (Nat.div_le_div_right (Nat.le_of_lt (lt_of_mem_footW hR hb))) hs

theorem wr0_of_footW {s0 s : St S} {R : List (Nat × Nat)} {lo b : Nat} (hlo : s0.next ≤ lo)
    (h0 : (Stage.rangesOf s.heap R).all (fun e => !Nat.blt e.1 s0.next || (s0.heap.get e.1).isSome) = true)
    (hb : b ∈ footW s R lo) (hlt : b < s0.next) : Present s0 b := by
  obtain ⟨e, he, rfl⟩ := List.mem_map.1 hb
  rcases List.mem_append.mp he with h1 | h1
  · have := List.all_eq_true.mp h0 e h1
    rw [Nat.blt_eq.mpr hlt] at this
    show (s0.heap.get e.1).isSome = true
    simpa using this
  · have := (Stage.mem_freshOf h1).1; omega

/-- A stream state's footprint check: the counters grow and stay in range, the written ranges end below the
state's counter, the written entries below the previous state's counter present there. -/
def footRB (s0 s2 : St S) (R : List (Nat × Nat)) : Bool :=
  Nat.ble s0.next s2.next && Nat.blt (s2.next / 4096) (4 ^ 31) && R.all (fun p => Nat.ble p.2 s2.next) &&
    (Stage.rangesOf s2.heap R).all (fun e => !Nat.blt e.1 s0.next || (s0.heap.get e.1).isSome)

theorem footRB_ranges {s0 s2 : St S} {R : List (Nat × Nat)} (hb : footRB s0 s2 R = true) :
    ∀ p ∈ R, p.2 ≤ s2.next := by
  simp only [footRB, Bool.and_eq_true] at hb
  exact fun p hp => Nat.le_of_ble_eq_true (List.all_eq_true.mp hb.1.2 p hp)

/-- **A stream state's footprint** from its heap equality over its written ranges `R` and fresh range. -/
theorem stageFoot_ofRF {s0 s2 : St S} {R : List (Nat × Nat)}
    (hh : s2.heap = Stage.setAll s0.heap (Stage.rangesOf s2.heap R ++ Stage.freshOf s2.heap s0.next s2.next))
    (hb : footRB s0 s2 R = true) : Conv.StageFoot (footW s2 R s0.next) s0 s2 := by
  have hR' := footRB_ranges hb
  simp only [footRB, Bool.and_eq_true] at hb
  obtain ⟨⟨⟨hg, hbd⟩, _⟩, h0⟩ := hb
  have hbd' : s2.next / 4096 < 4 ^ 31 := Nat.blt_eq.mp hbd
  exact {
    wrP := fun _ hb => present_of_mem_footW hb
    wr0 := fun _ hb hlt => wr0_of_footW (Nat.le_refl _) h0 hb hlt
    same := fun b hb => by
      rw [hh]
      refine Stage.setAll_get _ _ _ fun e he => ⟨fun h => hb (h ▸ List.mem_map_of_mem (f := (·.1)) he), ?_⟩
      exact footW_bound (lo := s0.next) hR' hbd' e.1 (List.mem_map_of_mem (f := (·.1)) he)
    grows := Nat.le_of_ble_eq_true hg }

theorem stageFoot_trans {w1 w2 : List Nat} {s0 s1 s2 : St S} (h1 : Conv.StageFoot w1 s0 s1)
    (h2 : Conv.StageFoot w2 s1 s2) : Conv.StageFoot (w1 ++ w2) s0 s2 where
  wrP b hb := by
    by_cases hb2 : b ∈ w2
    · exact h2.wrP b hb2
    · rcases List.mem_append.mp hb with hb1 | hb2'
      · show (s2.heap.get b).isSome = true
        rw [h2.same b hb2]; exact h1.wrP b hb1
      · exact absurd hb2' hb2
  wr0 b hb hlt := by
    by_cases hb1 : b ∈ w1
    · exact h1.wr0 b hb1 hlt
    · rcases List.mem_append.mp hb with hb1' | hb2
      · exact absurd hb1' hb1
      · have := h2.wr0 b hb2 (Nat.lt_of_lt_of_le hlt h1.grows)
        show (s0.heap.get b).isSome = true
        rw [← h1.same b hb1]; exact this
  same b hb := by
    rw [h2.same b (fun h => hb (List.mem_append_right _ h)), h1.same b (fun h => hb (List.mem_append_left _ h))]
  grows := Nat.le_trans h1.grows h2.grows

/-- **A wide site's footprint so far**: from the instance's start to `s`, its addresses present at the return
state `sF` on the written list `wr`. -/
def FootAcc (wr : List Nat) (sF s0 s : St S) : Prop :=
  ∃ w, Conv.StageFoot w s0 s ∧ ∀ b ∈ w, Present sF b → b ∈ wr

theorem FootAcc.start (wr : List Nat) (sF s0 : St S) : FootAcc wr sF s0 s0 :=
  ⟨[], ⟨fun _ h => (by cases h), fun _ h => (by cases h), fun _ _ => rfl, Nat.le_refl _⟩, fun _ h => (by cases h)⟩

theorem FootAcc.step {wr w2 : List Nat} {sF s0 s1 s2 : St S} (h : FootAcc wr sF s0 s1)
    (h2 : Conv.StageFoot w2 s1 s2) (hi : ∀ b ∈ w2, Present sF b → b ∈ wr) : FootAcc wr sF s0 s2 :=
  let ⟨w, h1, hw⟩ := h
  ⟨w ++ w2, stageFoot_trans h1 h2, fun b hb hp => (List.mem_append.mp hb).elim (hw b · hp) (hi b · hp)⟩

/-- The return state's written ranges `W` cover a state's below the start's counter `n0`. -/
def coverB (R W : List (Nat × Nat)) (n0 : Nat) : Bool :=
  R.all fun p => Nat.ble n0 p.1 || W.any fun q => Nat.ble q.1 p.1 && Nat.ble (min p.2 n0) q.2

/-- **A state's written addresses are on the instance's written list** when present at its return state. -/
theorem incl_of_footW {s0 si s2 sF : St S} {R W : List (Nat × Nat)} (hb : footRB si s2 R = true)
    (hc : (Nat.ble s0.next si.next && Nat.ble s2.next sF.next && coverB R W s0.next) = true) :
    ∀ b ∈ footW s2 R si.next, Present sF b → b ∈ footW sF W s0.next := by
  have hR := footRB_ranges hb
  simp only [Bool.and_eq_true] at hc
  obtain ⟨⟨h1, h2⟩, h3⟩ := hc
  have h1 := Nat.le_of_ble_eq_true h1
  have h2 := Nat.le_of_ble_eq_true h2
  intro b hb hp
  obtain ⟨v, hv⟩ := Present.get hp
  have hlt : b < sF.next := Nat.lt_of_lt_of_le (lt_of_mem_footW hR hb) h2
  show b ∈ (Stage.rangesOf sF.heap W ++ Stage.freshOf sF.heap s0.next sF.next).map (·.1)
  by_cases hge : s0.next ≤ b
  · exact List.mem_map.2 ⟨(b, v), List.mem_append_right _ (mem_freshOf_of hge hlt hv), rfl⟩
  · obtain ⟨e, he, rfl⟩ := List.mem_map.1 hb
    rcases List.mem_append.mp he with he | he
    · obtain ⟨p, hp', hp1, hp2⟩ := Stage.mem_rangesOf he
      have hcov := List.all_eq_true.mp h3 p hp'
      simp only [Bool.or_eq_true] at hcov
      rcases hcov with hl | hr
      · have := Nat.le_of_ble_eq_true hl; omega
      · obtain ⟨q, hq, hq'⟩ := List.any_eq_true.mp hr
        simp only [Bool.and_eq_true] at hq'
        have q1 := Nat.le_of_ble_eq_true hq'.1
        have q2 := Nat.le_of_ble_eq_true hq'.2
        have : e.1 < min p.2 s0.next := Nat.lt_min.mpr ⟨hp2, by omega⟩
        exact List.mem_map.2 ⟨(e.1, v), List.mem_append_left _ (mem_rangesOf_of hv hq (by omega) (by omega)), rfl⟩
    · have := (Stage.mem_freshOf he).1; omega

/-- **The instance's footprint** over its written list `footW sF W s0.next`, from the composed states. -/
theorem FootAcc.finish {W : List (Nat × Nat)} {s0 sF : St S} (h : FootAcc (footW sF W s0.next) sF s0 sF)
    (h0 : (Stage.rangesOf sF.heap W).all (fun e => !Nat.blt e.1 s0.next || (s0.heap.get e.1).isSome) = true) :
    Conv.StageFoot (footW sF W s0.next) s0 sF :=
  let ⟨_, hf, hw⟩ := h
  { wrP := fun _ hb => present_of_mem_footW hb
    wr0 := fun _ hb hlt => wr0_of_footW (Nat.le_refl _) h0 hb hlt
    same := fun b hb => hf.same b (fun h => hb (hw b h (hf.wrP b h)))
    grows := hf.grows }

end

/-- **The relation at a site's merged state** `sr`, the instance's return state `s2` address by address with the
caller's frames back (`Conv.mergeSt_site`; the merged state's facts at its concrete boundary). -/
theorem merged_relB {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
    {M : Map} {ν : Nat → F64} {K : Ctx} {S : SSrv} {t : St F.S} {C : CSrv} {wr : List Nat} {s s0 s2 sr : St F.S}
    {n0 : Nat} (hs0 : s0 = { s with stack := [] }) (hfoot : Conv.StageFoot wr s0 s2) (hnd : wr.Nodup)
    (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31) (htr : ∃ fr, s2.trace = fr ++ s0.trace)
    (hh : sr.heap = s2.heap) (hn : sr.next = s2.next) (hc : sr.ctl = s2.ctl) (hst : sr.stack = s2.stack ++ s.stack)
    (hj : sr.jobs = s2.jobs) (hf : sr.ffi = s2.ffi) (ht : sr.trace = s2.trace) (hso : sr.stores = s2.stores)
    (h : RelB F FR W stk M ν K (Conv.mergeSt Map.id (Map.id.res n0 n0) s.stack wr s s2 s0 s2.ffi) S t C) :
    RelB F FR W stk M ν K sr S t C := by
  obtain ⟨mh, mn, mc, mst, mj, mf, mt, mso⟩ := Conv.mergeSt_site (s := s) (n0 := n0) hs0 hfoot hnd hbd htr rfl
  exact h.srcCongr (fun a => by rw [hh, mh a]) (hn.trans mn.symm) (hc.trans mc.symm) (hst.trans mst.symm)
    (hj.trans mj.symm) (hf.trans mf.symm) (ht.trans mt.symm) (hso.trans mso.symm)


/-! ## The call link's native shift from the call's relation

`SiteR<k>`'s `cshiftR<k>`: the compaction's native shift (`cshift<k>`) with its parameters from the call state's full
relation, the canonical closedness from the call's (`sst_of_callK`: `Conv.sst_of_callB` over `SiteK`'s keep
equalities, `sst_clear` for the token-cleared state). -/

/-- A kept trie's entry off the changed list is the call's. -/
theorem keep_get {α : Type} {t t0 : PTrie α} {l : List Nat}
    (he : t = Stage.setAll t0 (l.filterMap fun i => (t.get i).map (i, ·))) (hb : ∀ i ∈ l, i / 4096 < 4 ^ 31)
    {i : Nat} (hi : i ∉ l) : t.get i = t0.get i := by
  rw [he]
  refine Stage.setAll_get _ _ _ fun e hm => ?_
  obtain ⟨j, hj, he'⟩ := List.mem_filterMap.1 hm
  cases hg : t.get j with
  | none => rw [hg] at he'; cases he'
  | some v => rw [hg] at he'; cases he'; exact ⟨fun h => hi (h ▸ hj), hb j hj⟩

/-- **The canonical state's native closedness** from the call's, over the keep equalities and the checked changes. -/
theorem sst_of_callK {n n0 : Nat} {x c : NSt} {ln lo li : List Nat} (hx : SSt (· < n0) x) (hn0 : n0 ≤ n)
    (hN : c.nodes = Stage.setAll x.nodes (ln.filterMap fun i => (c.nodes.get i).map (i, ·)))
    (hO : c.objs = Stage.setAll x.objs (lo.filterMap fun i => (c.objs.get i).map (i, ·)))
    (hI : c.items = Stage.setAll x.items (li.filterMap fun i => (c.items.get i).map (i, ·)))
    (hbd : (lo ++ ln ++ li).all (fun i => Nat.blt (i / 4096) (4 ^ 31)) = true)
    (hc : Conv.sstListB n c ln lo li = true) : SSt (· < n) c := by
  have hb : ∀ i ∈ lo ++ ln ++ li, i / 4096 < 4 ^ 31 := fun i hi => Nat.blt_eq.mp (List.all_eq_true.mp hbd i hi)
  refine Conv.sst_of_callB hx hn0 (fun i nd hg hi => ?_) (fun h o hg hh => ?_) (fun k v hg hk => ?_) hc
  · rw [← keep_get hN (fun j hj => hb j (by simp [hj])) hi]; exact hg
  · rw [← keep_get hO (fun j hj => hb j (by simp [hj])) hh]; exact hg
  · rw [← keep_get hI (fun j hj => hb j (by simp [hj])) hk]; exact hg

theorem sst_clear {R : Nat → Prop} {x : Host.Load.LSt} (h : SSt R x.mlx) : SSt R (clearTokens x).mlx :=
  ⟨h.1, h.2.1, fun _ ht => (by cases ht), h.2.2.2⟩

end Host.Ts.Sim.Template
