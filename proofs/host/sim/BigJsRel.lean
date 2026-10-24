import host.sim.RestartDrop
import host.sim.BigFreeP
import host.sim.steps.BigJs
namespace Host.Ts.Sim

/-! # Switching a relation's map to `withJs`

Where a chain changes its map (a compaction `κ`, an iso `σ`, a restart), the new map `M.after σ`
need not obey `BigJs`. `RelB.withJs` replaces a map `N` by `N.withJs` (which obeys it,
`BigJs.withJs`) when every JS pointer integer the source mentions is already sent to its image's
(`NoBigSt (JsBad N)`), by `RelB.rebig62`: `RelF.rebig` (`RestartDrop.lean`) at any stack base with
the changed bigints below `2 ^ 62` (the JS pointer band, apart from the native pointer integers).

For `N` agreeing with `M.after σ` on names and on the band (`M.after σ` itself; a restart's
`(M.after σ).rebig a b d` with `b ≤ 2^56`, `jsBig_rebig`), `BigJs M` reduces the condition to a
check on `σ` and the source alone (`jsBad_after`): every JS pointer integer `i = ptrInt (.js b) off`
the source mentions has `σ.big i = ptrInt (.js (σ.a b)) off` and `σ.a b < 2^29` (`jsShiftBadB σ`,
decided by `stateNoBigP`, or per address by `noBigAtP` and `noBigRootsP`). `RelB.afterJs` is the
site lemma. -/

section
variable {F : Ffi} {FR FR' : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
  {M N σ : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- `RelF.rebig` at any stack base, for bigints changed below `2 ^ 62`. -/
theorem RelB.rebig62 {I : Int → Prop} {b : Int → Int}
    (h : RelB F FR W stk M ν K s S t C) (hb : ∀ i, ¬ I i → b i = M.big i)
    (hI : ∀ i, I i → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 62)
    (hfree : NoBigSt I K.base s)
    (hffi : FR' (M.withBig b) S.tab.length s.ffi t.ffi) :
    RelB F FR' W stk (M.withBig b) ν K s S t C := by
  obtain ⟨fresh, hs, ht⟩ := h.trace
  have hfresh : ∀ e ∈ fresh, NoBig.event I e := fun e he =>
    hfree.trace e (by rw [freshOf_eq hs]; exact he)
  have hge : ∀ r off : Nat, (2 : Int) ^ 62 ≤ ptrInt (.ext r) off := fun r off => by
    show ((2 : Nat) ^ 62 : Int) ≤ ((2 ^ 62 + r * 2 ^ 24 + off : Nat) : Int)
    exact Int.ofNat_le.mpr (Nat.le_add_right_of_le (Nat.le_add_right _ _))
  exact {
    srv := ⟨fun i e he => h.srv.num i e he, h.srv.good⟩
    heap := fun a o hg => SlotW.rebig hb (hfree.heap a o hg) (h.heap a o hg)
    next := h.next
    offset := h.offset
    room := h.room
    bigFixed := fun i hi => by
      show b i = i
      rw [hb i fun hIi => (hI i hIi).1 hi]
      exact h.bigFixed i hi
    bigExt := fun r off ho => by
      show b (ptrInt (.ext r) off) = ptrInt (.ext (M.region r)) off
      have hn : ¬ I (ptrInt (.ext r) off) := fun hIi =>
        Int.lt_irrefl _ (Int.lt_of_lt_of_le (hI _ hIi).2.2 (hge r off))
      rw [hb _ hn]
      exact h.bigExt r off ho
    band := h.band
    intr := h.intr
    bound := h.bound
    inj := h.inj
    presentBound := h.presentBound
    framedPresent := h.framedPresent
    ctl := h.ctl.trans (Map.ctl_rebig hb hfree.ctl).symm
    stack := by
      rw [h.stack]
      exact congrArg (· ++ stk) (List.map_congr_left fun f hf => (Map.frame_rebig hb (hfree.stack f hf)).symm)
    jobs := by
      rw [h.jobs]
      exact List.map_congr_left fun j hj => (Map.job_rebig hb (hfree.jobs j hj)).symm
    stores := h.stores.trans (Map.stores_rebig hb hfree.stores).symm
    ffi := hffi
    trace := ⟨fresh, hs, by
      rw [ht, List.map_congr_left fun e he => Map.event_rebig hb (hfresh e he)]⟩
    heapSupp := h.heapSupp
    ctlSupp := h.ctlSupp
    stackSupp := h.stackSupp
    jobsSupp := h.jobsSupp
    storesSupp := h.storesSupp
    traceSupp := h.traceSupp }

/-- A JS pointer integer `N` does not send to its image's. -/
def JsBad (N : Map) (i : Int) : Prop :=
  ∃ b off, jsPtrOf i = some (b, off) ∧ N.big i ≠ ptrInt (.js (N.a b)) off

theorem jsPtrOf_ge {i : Int} {b off : Nat} (h : jsPtrOf i = some (b, off)) :
    (72057594037927936 : Int) ≤ i ∧ i < 4611686018427387904 := by
  obtain ⟨rfl, hb, hoff⟩ := jsPtrOf_some h
  rw [ptrInt_js]
  have hb' : b < 536870912 := hb
  have ho' : off < 4294967296 := hoff
  simp only [jsBase, jsOff]
  constructor
  · show ((72057594037927936 : Nat) : Int) ≤ _; exact Int.ofNat_le.mpr (by omega)
  · show _ < ((4611686018427387904 : Nat) : Int); exact Int.ofNat_lt.mpr (by omega)

/-- **The switch to `N.withJs`**, where the source's JS pointer integers already follow their memory
under `N` (the context's handle band below `2 ^ 56`). -/
theorem RelB.withJs (h : RelB F FR W stk N ν K s S t C) (hlo : K.lo ≤ 2 ^ 56)
    (hfree : NoBigSt (JsBad N) K.base s) (hffi : FR' N.withJs S.tab.length s.ffi t.ffi) :
    RelB F FR' W stk N.withJs ν K s S t C := by
  have hb : ∀ i, ¬ JsBad N i → N.withJs.big i = N.big i := by
    intro i hi
    rw [Map.withJs_big_eq]
    cases hp : jsPtrOf i with
    | none => rfl
    | some q =>
      obtain ⟨b, off⟩ := q
      exact (Classical.byContradiction fun hne => hi ⟨b, off, hp, fun e => hne e.symm⟩)
  have hI : ∀ i, JsBad N i → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 62 := by
    rintro i ⟨b, off, hp, -⟩
    obtain ⟨h1, h2⟩ := jsPtrOf_ge hp
    have e56 : (2 : Int) ^ 56 = 72057594037927936 := by decide
    have e62 : (2 : Int) ^ 62 = 4611686018427387904 := by decide
    refine ⟨fun hf => ?_, by omega, by rw [e62]; exact h2⟩
    unfold BigFixed at hf
    rw [e56] at hf
    have hlo' : K.lo ≤ 72057594037927936 := hlo
    have : (K.lo : Int) ≤ 72057594037927936 := by exact_mod_cast hlo'
    omega
  exact h.rebig62 (b := N.withJs.big) hb hI hfree hffi

/-- A JS pointer integer `σ` does not send to its image's below `2 ^ 29`: the source check. -/
def jsShiftBadB (σ : Map) (i : Int) : Bool :=
  match jsPtrOf i with
  | some (b, off) => !(decide (σ.big i = ptrInt (.js (σ.a b)) off) && Nat.blt (σ.a b) 536870912)
  | none => false

/-- Under `BigJs M`, a JS pointer integer a map `N` with the names and band of `M.after σ` gets wrong
is one `σ` gets wrong. -/
theorem jsBad_after (hM : BigJs M) (ha : N.a = (M.after σ).a)
    (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) {i : Int} (h : JsBad N i) :
    jsShiftBadB σ i = true := by
  obtain ⟨b, off, hp, hne⟩ := h
  obtain ⟨hi, hb, hoff⟩ := jsPtrOf_some hp
  have hN : N.big i = M.big (σ.big i) := hbig i (by rw [hp]; exact Option.some_ne_none _)
  have key : ¬ (σ.big i = ptrInt (.js (σ.a b)) off ∧ σ.a b < 2 ^ 29) := by
    rintro ⟨e1, e2⟩
    apply hne
    rw [hN, e1, hM _ off e2 hoff, ha, Map.after_a]
  show (match jsPtrOf i with
    | some (b, off) => !(decide (σ.big i = ptrInt (.js (σ.a b)) off) && Nat.blt (σ.a b) 536870912)
    | none => false) = true
  rw [hp]
  show (!(decide (σ.big i = ptrInt (.js (σ.a b)) off) && Nat.blt (σ.a b) 536870912)) = true
  rw [Bool.not_eq_true', Bool.and_eq_false_iff]
  by_cases e1 : σ.big i = ptrInt (.js (σ.a b)) off
  · right
    rw [Bool.eq_false_iff, ne_eq, Nat.blt_eq]
    exact fun e2 => key ⟨e1, e2⟩
  · left
    exact decide_eq_false e1

/-- `M.after σ` has its own names and band. -/
theorem jsBad_after_self (hM : BigJs M) {i : Int} (h : JsBad (M.after σ) i) : jsShiftBadB σ i = true :=
  jsBad_after hM rfl (fun _ _ => rfl) h

/-- A restart's reassignment of fresh handle images (`Map.rebig a b d`, `b ≤ 2^56`) keeps the band. -/
theorem jsBig_rebig {X : Map} {a b d : Nat} (hb : b ≤ 2 ^ 56) {i : Int} (hi : jsPtrOf i ≠ none) :
    (X.rebig a b d).big i = X.big i := by
  cases hp : jsPtrOf i with
  | none => exact absurd hp hi
  | some q =>
    obtain ⟨b', off⟩ := q
    have hge := (jsPtrOf_ge hp).1
    show (if (a : Int) ≤ i ∧ i < b then i - a + d else X.big i) = X.big i
    split
    · rename_i hc
      have hb' : b ≤ 72057594037927936 := hb
      have : (b : Int) ≤ 72057594037927936 := by exact_mod_cast hb'
      omega
    · rfl

/-- **The site lemma**: a relation under `N` (with the names and band of `M.after σ`, `BigJs M`)
becomes one under `N.withJs` when the source passes `σ`'s check (`stateNoBigP (jsShiftBadB σ)`). -/
theorem RelB.afterJs (h : RelB F FR W stk N ν K s S t C) (hM : BigJs M) (ha : N.a = (M.after σ).a)
    (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hchk : stateNoBigP (jsShiftBadB σ) K.base s = true) (hffi : FR' N.withJs S.tab.length s.ffi t.ffi) :
    RelB F FR' W stk N.withJs ν K s S t C :=
  h.withJs hlo (stateNoBigP_sound (fun _ hi => jsBad_after hM ha hbig hi) hchk) hffi

/-- `RelB.afterJs` with the check per present address (`tpl_all_blocks`-style blocks) and on the roots. -/
theorem RelB.afterJsBlocks (h : RelB F FR W stk N ν K s S t C) (hM : BigJs M) (ha : N.a = (M.after σ).a)
    (hbig : ∀ i, jsPtrOf i ≠ none → N.big i = M.big (σ.big i)) (hlo : K.lo ≤ 2 ^ 56)
    (hheap : ∀ a, Present s a → noBigAtP (jsShiftBadB σ) s a = true)
    (hroots : noBigRootsP (jsShiftBadB σ) K.base s = true) (hffi : FR' N.withJs S.tab.length s.ffi t.ffi) :
    RelB F FR' W stk N.withJs ν K s S t C :=
  h.withJs hlo (NoBigSt.of_checksP (fun _ hi => jsBad_after hM ha hbig hi) hheap hroots) hffi

end
end Host.Ts.Sim
