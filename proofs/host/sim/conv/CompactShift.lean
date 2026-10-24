import host.sim.conv.Closed
import host.sim.conv.NFix
import host.sim.BigFreeP
import host.sim.conv.MergeSt
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # The compaction's state shift

The compaction's `ShiftD` from the canonical state `sc` to the merged state `sm` of a call at `s`
(`compact_shift`, `compact`'s `hs`), the map `Map.compact` at the call's counters:

* the heap: off the checked list `l` the canonical and the merged state hold the call's entry, which the
  map fixes (the call's relation bounds its addresses and table references, `CallFacts`; the bookkeeping
  `JClean` keeps its bigints and regions old, which the map fixes, `FixOld`); on `l` but off the kept
  arrays the kernel's image check (`HeapImg`); the kept arrays the canonical state holds at their frames'
  prefixes (`hframed`);
* the frames: the context frames the addresses `Fd` below the call's counter (`Disp.Kp`), the frames `W`
  among them;
* the table: `compact_num`; the roots, their supports and the band's fixed bigints as given.

The bookkeeping `JClean c s` (no heap entry holds a bigint or a region past the counters `c`) is a cut's,
kept by its pieces' checks of their changed entries (`JClean.step`, `jcleanListB`); it gives the
canonical state's bigint freedom (`jclean_noBigSt`, `cut_compactQ`'s `hfree`). -/

section
variable {S : Type}

/-- The bigints past the counters `c`. -/
abbrev oldI (c : Cnt) : Int → Prop := fun i => (!oldBigB c i) = true

/-- The regions past the counters `c`. -/
abbrev oldR (c : Cnt) : Nat → Prop := fun r => (!oldRegB c r) = true

/-- **The JavaScript cut bookkeeping**: no heap entry holds a bigint or a region past the counters `c`. -/
abbrev JClean (c : Cnt) (s : St S) : Prop := Clean (oldI c) (oldR c) s

/-- The entry at `a` holds no bigint or region past `c`. -/
def jcleanAtB (c : Cnt) (s : St S) (a : Nat) : Bool :=
  match s.heap.get a with
  | some h => noBigHobjP (fun i => !oldBigB c i) h && noRegHobjB (fun r => !oldRegB c r) h
  | none => true

/-- The entries at `l`. -/
def jcleanListB (c : Cnt) (s : St S) (l : List Nat) : Bool := l.all (jcleanAtB c s)

theorem jcleanListB_sound {c : Cnt} {s : St S} {l : List Nat} (h : jcleanListB c s l = true) :
    ∀ a ∈ l, ∀ o, s.heap.get a = some o → NoBig.hobj (oldI c) o ∧ NoReg.hobj (oldR c) o := by
  intro a ha o ho
  simp only [jcleanListB, List.all_eq_true] at h
  have := h a ha
  unfold jcleanAtB at this
  rw [ho] at this
  simp only [Bool.and_eq_true] at this
  exact ⟨noBigHobjP_sound (fun _ hi => hi) this.1, noRegHobjB_sound this.2⟩

/-- The bookkeeping of a state whose entries are all checked. -/
theorem JClean.of_cover {c : Cnt} {s : St S} {l : List Nat} (hcov : ∀ a o, s.heap.get a = some o → a ∈ l)
    (hck : jcleanListB c s l = true) : JClean c s := fun a o ho =>
  jcleanListB_sound hck a (hcov a o ho) o ho

/-- The bookkeeping survives the counters' growth. -/
theorem JClean.mono {c c' : Cnt} {s : St S} (hc : c.Le c') (h : JClean c s) : JClean c' s :=
  Clean.mono h
    (fun i hi => by
      show (!oldBigB c i) = true; change (!oldBigB c' i) = true at hi; cases e : oldBigB c i
      · rfl
      · rw [oldBigB_mono hc e] at hi; cases hi)
    (fun r hr => by
      show (!oldRegB c r) = true; change (!oldRegB c' r) = true at hr; cases e : oldRegB c r
      · rfl
      · rw [oldRegB_mono hc e] at hr; cases hr)

/-- **A piece keeps the bookkeeping**: its counters grew, its end keeps its start's entries off `l`,
and those on `l` are checked. -/
theorem JClean.step {c c' : Cnt} {s s' : St S} {l : List Nat} (h : JClean c s) (hc : c.Le c')
    (hch : ∀ a, a ∉ l → s'.heap.get a = s.heap.get a) (hck : jcleanListB c' s' l = true) : JClean c' s' :=
  Clean.step (JClean.mono hc h) hch (jcleanListB_sound hck)

/-- **The canonical state's bigint freedom** (`cut_compactQ`'s `hfree`): the bookkeeping at the
state's counters, the roots checked. -/
theorem jclean_noBigSt {c : Cnt} {s : St S} {lo E : Nat} (hs : JClean c s) (hlo : c.xn ≤ lo)
    (hE : E ≤ RData.bigHi) (hroots : noBigRootsP (fun i => !oldBigB c i) s.trace s = true) :
    NoBigSt (fun i => (lo : Int) ≤ i ∧ i < E) s.trace s := by
  have hpI : ∀ i : Int, ((lo : Int) ≤ i ∧ i < E) → (!oldBigB c i) = true := by
    intro i ⟨h1, h2⟩
    obtain ⟨k, hk⟩ : ∃ k : Nat, i = (k : Int) := ⟨i.toNat, by omega⟩
    subst hk
    have hb : RData.bigHi = 131072 := rfl
    have h1' : lo ≤ k := by omega
    have h2' : k < E := by omega
    have hk : k < 2 ^ 62 := by omega
    show (!oldBigB c (Int.ofNat k)) = true
    rw [oldBigB_lo hk]
    have e1 : Nat.blt k c.xn = false := Bool.eq_false_iff.mpr fun h => by have := Nat.blt_eq.mp h; omega
    have e2 : Nat.ble RData.bigHi k = false := Bool.eq_false_iff.mpr fun h => by
      have := Nat.le_of_ble_eq_true h; omega
    rw [e1, e2]; rfl
  simp only [noBigRootsP, Bool.and_eq_true, List.all_eq_true] at hroots
  exact ⟨fun a o ha => NoBig.hobj_mono hpI (hs a o ha).1, noBigCtlP_sound hpI hroots.1.1.1.1,
    fun f hf => noBigFrameP_sound hpI (hroots.1.1.1.2 f hf), fun j hj => noBigJobP_sound hpI (hroots.1.1.2 j hj),
    noBigStoresP_sound hpI hroots.1.2, fun e he => noBigEventP_sound hpI (hroots.2 e he)⟩

/-- A state set from another at the entries of `l` (the generator's `setAll` of its own entries) holds
the other's entries off `l`. -/
theorem heap_off_setAll {s c : St S} {l : List Nat}
    (h : c.heap = Stage.setAll s.heap (l.filterMap fun a => (c.heap.get a).map (a, ·)))
    (hbd : ∀ a ∈ l, a / 4096 < 4 ^ 31) : ∀ a, a ∉ l → c.heap.get a = s.heap.get a := by
  intro a ha
  refine (congrArg (fun t => PTrie.get t a) h).trans (Stage.setAll_get _ _ a fun e he => ?_)
  obtain ⟨b, hb, hbe⟩ := List.mem_filterMap.1 he
  cases hg : c.heap.get b with
  | none => rw [hg] at hbe; cases hbe
  | some o =>
    rw [hg] at hbe; cases hbe
    exact ⟨fun hba => ha (by have e : b = a := hba; rw [← e]; exact hb), hbd b hb⟩

/-- The merged state holds the call's entries below its counter off a list holding the stage's written
ones there (the stage's fresh entries are past the counter). -/
theorem mergeSt_heap_off {τ : Map} {rs : List Frame} {wr l : List Nat} {s s2 s0 sm : St S} {x : S}
    (hmer : sm = mergeSt Map.id τ rs wr s s2 s0 x) (hbd : ∀ b ∈ wr, b / 4096 < 4 ^ 31)
    (hwl : ∀ b ∈ wr, b < s.next → b ∈ l) : ∀ a, a ∉ l → a < s.next → sm.heap.get a = s.heap.get a := by
  intro a ha hlt
  subst hmer
  show (mergeHeap Map.id τ wr s.heap s2.heap).get a = s.heap.get a
  exact mergeHeap_kept hbd fun b hb e => ha (by
    have e' : b = a := e
    rw [← e']; exact hwl b hb (by rw [e']; exact hlt))

end

/-! ## The call's facts -/

/-- **What the compaction reads of the call's relation**: its addresses below its counter, its
entries supported. -/
structure CallFacts {S : Type} (s : St S) (n : Nat) : Prop where
  bound : ∀ a, Present s a → a < s.next
  supp : ∀ a o, s.heap.get a = some o → Supp.hobj (Present s) n o

theorem CallFacts.of_rel {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame}
    {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}
    (h : RelB F FR W stk M ν K s S t C) : CallFacts s S.tab.length :=
  ⟨h.presentBound, h.heapSupp⟩

/-- The band's fixed bigints from the native shift (`ShiftD.bigFixed`), the context's band the
relation's. -/
theorem bigFixed_of_mshift {P : LoadP} {n0 : Nat} {σ : Map} {x y : NSt} {K : Ctx} (hs : MShift P n0 σ x y)
    (hlo : K.lo = P.lo) (hhi : K.hi = P.E) : ∀ i, BigFixed K.lo K.hi i → σ.big i = i := by
  intro i hi
  rw [hlo, hhi] at hi
  rcases hi with h | ⟨-, h⟩ | ⟨h1, h2⟩
  · exact hs.bigFix i (by omega)
  · exact hs.bigFix i h
  · exact hs.bigFixHi i h1 h2

private theorem kp_false {K : Ctx} {W : Nat → Option WFrame} {a : Nat} (hk : kpOf K W a = false)
    (hw : W a = none) : K.fr a = none := by
  simp only [kpOf, hw, Option.isNone_none, Bool.and_true, Option.isSome_eq_false_iff] at hk
  simpa using hk

private theorem kp_true {K : Ctx} {W : Nat → Option WFrame} {a : Nat} (hk : kpOf K W a = true) :
    (K.fr a).isSome = true ∧ W a = none := by
  simp only [kpOf, Bool.and_eq_true, Option.isNone_iff_eq_none] at hk
  exact hk

/-! ## The shift -/

/-- **The compaction's state shift** at the call state `s` (its table `tab`, its relation's facts
`hcall`, its bookkeeping `hclean` at the counters `c` the map fixes): the canonical state `sc` (the
call's table and the result variables `cws`) to the merged `sm` (its table `tabm` the call's and the
stage's fresh variables `ws`), the results at the merged references `nr`, every frame of the context
`K1` kept. -/
theorem compact_shift {F : Ffi} {W : Nat → Option WFrame} {s sc sm : St F.S} {tab tabm : List SymE}
    {ws cws nr pl Fd Xs l : List Nat} {n1 : Nat} {D : RData} {c : Cnt} {K1 : Ctx} {κ : Map}
    (hκ : κ = Map.compact s.next n1 tab.length pl (nr.map NumV.ref) D.big D.region D.nodeF)
    -- the call
    (hcall : CallFacts s tab.length) (hclean : JClean c s) (hfix : FixOld c κ)
    -- the map's places and counters
    (hpl : ∀ p ∈ pl, s.next ≤ p) (hpln : pl.Nodup) (hn1 : s.next ≤ n1) (hfirst : aFirst ≤ s.next)
    (hscn : sc.next = s.next + pl.length) (hsmn : sm.next = n1) (hgrow : sc.next ≤ sm.next)
    -- the tables
    (hmtab : tabm = tab ++ resTab ws) (hfresh : ∀ e ∈ tab, ∀ w ∈ cws, e.noVar w = true) (hndc : cws.Nodup)
    (hlenc : cws.length = nr.length) (hnrHi : ∀ r ∈ nr, r < tabm.length)
    -- the frames
    (hFd : ∀ a, K1.fr a ≠ none ↔ a ∈ Fd) (hFdlt : ∀ a ∈ Fd, a < s.next)
    (hXs : ∀ a, a ∈ Xs ↔ a ∈ Fd ∧ W a = none) (hWfr : ∀ a w, W a = some w → a ∈ Fd)
    (hframed : ∀ a pre pre', K1.fr a = some (pre, pre') → W a = none → ∃ o xs, sc.heap.get a = some (.obj o) ∧
      o.kind = .array pre ∧ sm.heap.get a = some (.obj { κ.obj o with kind := .array (pre ++ xs) }))
    (hWP : ∀ a w, W a = some w → Present sc a) (hWF : ∀ a w, W a = some w → WFix κ (Present sc) w)
    -- the heap: the call's off `l`, the checks on `l`
    (hcl : ∀ a, a ∉ l → sc.heap.get a = s.heap.get a) (hml : ∀ a, a ∉ l → a < s.next → sm.heap.get a = s.heap.get a)
    (hkeep : keptPresentB s sc l = true) (hsupp : suppListB sc (tab.length + cws.length) l = true)
    (hbd : boundListB sc l = true) (hfoot : HeapImg κ sc sm (l.filter fun a => !Xs.contains a))
    -- the roots
    (hctl : sm.ctl = κ.ctl sc.ctl) (hstack : sm.stack = sc.stack.map κ.frame)
    (hjobs : sm.jobs = sc.jobs.map κ.job) (hstores : sm.stores = κ.stores sc.stores)
    (hctlS : Supp.ctl (Present sc) (tab.length + cws.length) sc.ctl)
    (hstackS : ∀ f ∈ sc.stack, Supp.frame (Present sc) (tab.length + cws.length) f)
    (hjobsS : ∀ j ∈ sc.jobs, Supp.job (Present sc) (tab.length + cws.length) j)
    (hstoresS : Supp.stores (Present sc) (tab.length + cws.length) sc.stores)
    (hbigFixed : ∀ i, BigFixed K1.lo K1.hi i → κ.big i = i) :
    ShiftD F (fun _ _ _ => True) κ (compactθ cws (nr.map fun r => (nth? tabm r).getD (.var 0))) (kpOf K1 W) W K1
      sc ⟨tab ++ cws.map SymE.var, []⟩ sm ⟨tabm, []⟩ := by
  have hA : ∀ x, x < s.next → κ.a x = x := fun x hx => by rw [hκ]; exact Map.compact_lt hx
  have hN : ∀ i, i < tab.length → κ.num i = .ref i := fun i hi => by rw [hκ]; exact Map.compact_num_lt hi
  have hC : ∀ x, κ.a x = x ∨ s.next ≤ κ.a x := fun x => by rw [hκ]; exact Map.compact_cases hpl hn1 x
  have hB : ∀ i, ¬ oldI c i → κ.big i = i := fun i hi => hfix.big i (by
    have hi' : ¬ ((!oldBigB c i) = true) := hi
    cases e : oldBigB c i
    · rw [e] at hi'; exact absurd rfl hi'
    · rfl)
  have hR : ∀ r, ¬ oldR c r → κ.region r = r := fun r hr => hfix.region r (by
    have hr' : ¬ ((!oldRegB c r) = true) := hr
    cases e : oldRegB c r
    · rw [e] at hr'; exact absurd rfl hr'
    · rfl)
  have hlen : (tab ++ cws.map SymE.var).length = tab.length + cws.length := by simp
  -- the call's present entries, the canonical state's bound
  have hPs : ∀ a, Present s a → Present sc a := present_of_call hcl (keptPresentB_sound hkeep)
  have hpB : ∀ a, Present sc a → a < sc.next := fun a hp => by
    by_cases hal : a ∈ l
    · exact boundListB_sound hbd a hal hp
    · have hp' : Present s a := by unfold Present at hp ⊢; rw [← hcl a hal]; exact hp
      have := hcall.bound a hp'
      omega
  -- every entry off the kept arrays: its image the merged entry
  have hheap : ∀ a o, sc.heap.get a = some o → a ∉ Xs → sm.heap.get (κ.a a) = some (κ.hobj o) := by
    intro a o ho hx
    by_cases hal : a ∈ l
    · have hm : a ∈ l.filter fun a => !Xs.contains a :=
        List.mem_filter.mpr ⟨hal, by simpa [List.contains_iff_mem] using hx⟩
      rw [hfoot.mem hm, ho]; rfl
    · have ho' := ho
      rw [hcl a hal] at ho'
      have hlt := hcall.bound a (Present.of_get ho')
      rw [hA a hlt, hml a hal hlt, ho', Map.hobj_fix hA hN hB hR
        (Supp.hobj_mono (fun x hx => hcall.bound x hx) (Nat.le_refl _) (hcall.supp a o ho'))
        (hclean a o ho').1 (hclean a o ho').2]
  -- the table
  have hpre : ∀ i e, nth? tab i = some e → nth? (⟨tabm, []⟩ : SSrv).tab i = some e := fun i e he => by
    show nth? tabm i = some e
    rw [hmtab, nth?_append_lt _ _ _ (nth?_lt _ _ _ he)]; exact he
  have hr : ∀ j v, nth? (nr.map NumV.ref) j = some v →
      (⟨tabm, []⟩ : SSrv).val v = nth? (nr.map fun r => (nth? tabm r).getD (.var 0)) j := by
    intro j v hv
    rw [nth?_map] at hv
    cases hj : nth? nr j with
    | none => rw [hj] at hv; cases hv
    | some r =>
      rw [hj] at hv
      obtain rfl : NumV.ref r = v := Option.some.inj hv
      obtain ⟨e, he⟩ := nth?_some_of_lt (hnrHi r (nth?_mem_some hj))
      show nth? tabm r = _
      rw [nth?_map, hj]
      show nth? tabm r = some ((nth? tabm r).getD (.var 0))
      rw [he]; rfl
  have hnum := compact_num (S1 := (⟨tabm, []⟩ : SSrv)) (n0 := s.next) (n1 := n1) (pl := pl) (big := D.big)
    (region := D.region) (node := D.nodeF) hpre hfresh hndc (by simp [hlenc]) (by simp [hlenc]) hr
  exact {
    num := fun i e he => by rw [hκ]; exact hnum i e he
    heap := fun a h ho hk hw => hheap a h ho fun hx => ((hFd a).mpr ((hXs a).mp hx).1) (kp_false hk hw)
    unfr := fun a h ho hk hw => by
      have hfr := kp_false hk hw
      rcases hC a with e | hge
      · rw [e]; exact hfr
      · cases hf : K1.fr (κ.a a) with
        | none => rfl
        | some p =>
          have := hFdlt _ ((hFd _).mp (by rw [hf]; exact Option.some_ne_none p))
          omega
    framed := fun a hk => by
      obtain ⟨hsome, hw⟩ := kp_true hk
      cases hf : K1.fr a with
      | none => rw [hf] at hsome; cases hsome
      | some p =>
        obtain ⟨pre, pre'⟩ := p
        have hfd : a ∈ Fd := (hFd a).mp (by rw [hf]; exact Option.some_ne_none _)
        obtain ⟨o, xs, h1, h2, h3⟩ := hframed a pre pre' hf hw
        exact ⟨hA a (hFdlt a hfd), pre, pre', o, xs, rfl, h1, h2, h3⟩
    wide := fun a w hw => compact_wide hA hw (hFdlt a (hWfr a w hw)) ((hFd a).mpr (hWfr a w hw)) (hWP a w hw)
      (fun h hg => hheap a h hg fun hx => by rw [((hXs a).mp hx).2] at hw; cases hw) (hWF a w hw)
    next := fun k => by rw [hκ, hscn, hsmn]; exact Map.compact_next k
    grows := hgrow
    present := fun a hp => by
      obtain ⟨o, ho⟩ := Present.get hp
      by_cases hx : a ∈ Xs
      · obtain ⟨hfd, hw⟩ := (hXs a).mp hx
        cases hf : K1.fr a with
        | none => exact absurd hf ((hFd a).mpr hfd)
        | some p =>
          obtain ⟨pre, pre'⟩ := p
          obtain ⟨o', xs, -, -, h3⟩ := hframed a pre pre' hf hw
          rw [hA a (hFdlt a hfd)]; exact Present.of_get h3
      · exact Present.of_get (hheap a o ho hx)
    inj := fun a b ha hb he => by
      have h1 := hpB a ha
      have h2 := hpB b hb
      rw [hscn] at h1 h2
      rw [hκ] at he
      exact Map.compact_inj hpln hpl h1 h2 he
    presentBound := hpB
    ctl := hctl
    stack := hstack
    jobs := hjobs
    stores := hstores
    ffi := trivial
    heapSupp := fun a o ho => by
      show Supp.hobj (Present sc) (tab ++ cws.map SymE.var).length o
      rw [hlen]
      by_cases hal : a ∈ l
      · exact suppListB_sound hsupp a hal o ho
      · rw [hcl a hal] at ho
        exact Supp.hobj_mono hPs (Nat.le_add_right _ _) (hcall.supp a o ho)
    ctlSupp := by show Supp.ctl (Present sc) (tab ++ cws.map SymE.var).length sc.ctl; rw [hlen]; exact hctlS
    stackSupp := fun f hf => by
      show Supp.frame (Present sc) (tab ++ cws.map SymE.var).length f; rw [hlen]; exact hstackS f hf
    jobsSupp := fun j hj => by
      show Supp.job (Present sc) (tab ++ cws.map SymE.var).length j; rw [hlen]; exact hjobsS j hj
    storesSupp := by show Supp.stores (Present sc) (tab ++ cws.map SymE.var).length sc.stores; rw [hlen]; exact hstoresS
    bigFixed := hbigFixed
    bigExt := fun r off ho => by rw [hκ]; exact RData.big_ext D r off ho
    intr := fun a ha => hA a (Nat.lt_of_lt_of_le ha hfirst) }

/-- **The map's node identity below the chain start's nodes** (`cut_compactQ`'s `hκv`), the call's
counters past the start's. -/
theorem node_of_fixOld {c : Cnt} {κ : Map} (hfix : FixOld c κ) {m : Nat} (hm : m ≤ c.nn) :
    ∀ j, j < m → κ.node j = j :=
  fun j hj => hfix.node j (Nat.lt_of_lt_of_le hj hm)

end Host.Ts.Sim.Conv
