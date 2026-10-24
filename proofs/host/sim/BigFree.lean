import host.sim.BigFreeCheck
import host.sim.Rel
import host.sim.template.Keys

/-! # The relation under a change of the bigint map

`Rel` survives replacing the map's bigint image by `b` on a set `I` of
integers the source state never mentions (`Rel.rebig`): `I` avoids the
bigints the map fixes and the pointer integers, and the source's heap
entries, control, stack, jobs, stores and the events since the base are free
of `I` (`NoBigSt`; the base events are not mapped).

For a band `I = [lo, hi)` the freedom follows from Boolean checks the kernel
decides by evaluation: `stateNoBigB` checks the whole state, traversing the
heap over `PTrie.keys` as `host.sim.template.Check` does. A single kernel
check over a 168K-entry heap exceeds the 8 GB limit (as `checkHeapSupp`
does), so `NoBigSt.of_checks` also accepts the per-address check `noBigAtB`
at every present address, which block checks provide (`tpl_all_blocks`,
`Base.allPresent`). -/

namespace Host.Ts.Sim
open Host.Ts.Sim.Template (PTrie.keys PTrie.mem_keys)

/-- The events of `s` since `base`. -/
def freshOf {S : Type} (base : List Event) (s : St S) : List Event :=
  s.trace.take (s.trace.length - base.length)

/-- No part of the source state that `Rel` maps mentions a bigint in `I`. -/
structure NoBigSt {S : Type} (I : Int → Prop) (base : List Event) (s : St S) : Prop where
  heap : ∀ a h, s.heap.get a = some h → NoBig.hobj I h
  ctl : NoBig.ctl I s.ctl
  stack : ∀ f ∈ s.stack, NoBig.frame I f
  jobs : ∀ j ∈ s.jobs, NoBig.job I j
  stores : NoBig.stores I s.stores
  trace : ∀ e ∈ freshOf base s, NoBig.event I e

theorem freshOf_eq {S : Type} {s : St S} {fresh base : List Event} (h : s.trace = fresh ++ base) :
    freshOf base s = fresh := by
  simp [freshOf, h]

/-! ## Deciding freedom of a state -/

section
variable {S : Type} (lo hi : Int)

/-- The heap entry at `a` is free of `[lo, hi)`. -/
def noBigAtB (s : St S) (a : Nat) : Bool :=
  match s.heap.get a with
  | some h => noBigHobjB lo hi h
  | none => true

/-- Every heap entry is free of `[lo, hi)` (checked over the explicit address list). -/
def noBigHeapB (s : St S) : Bool := (PTrie.keys s.heap).all (noBigAtB lo hi s)

def noBigRootsB (base : List Event) (s : St S) : Bool :=
  noBigCtlB lo hi s.ctl && s.stack.all (noBigFrameB lo hi) && s.jobs.all (noBigJobB lo hi) &&
    noBigStoresB lo hi s.stores && (freshOf base s).all (noBigEventB lo hi)

def stateNoBigB (base : List Event) (s : St S) : Bool := noBigHeapB lo hi s && noBigRootsB lo hi base s

end

section
variable {S : Type} {lo hi : Int} {base : List Event} {s : St S}

theorem noBigHeapB_sound (h : noBigHeapB lo hi s = true) : ∀ a, Present s a → noBigAtB lo hi s a = true := by
  intro a ha
  obtain ⟨o, hg⟩ := Option.isSome_iff_exists.mp ha
  simp only [noBigHeapB, List.all_eq_true] at h
  exact h a (PTrie.mem_keys s.heap a o hg)

theorem NoBigSt.of_checks (hheap : ∀ a, Present s a → noBigAtB lo hi s a = true)
    (hroots : noBigRootsB lo hi base s = true) : NoBigSt (fun i => lo ≤ i ∧ i < hi) base s := by
  simp only [noBigRootsB, Bool.and_eq_true, List.all_eq_true] at hroots
  refine ⟨fun a o ha => ?_, noBigCtlB_sound hroots.1.1.1.1, fun f hf => noBigFrameB_sound (hroots.1.1.1.2 f hf),
    fun j hj => noBigJobB_sound (hroots.1.1.2 j hj), noBigStoresB_sound hroots.1.2,
    fun e he => noBigEventB_sound (hroots.2 e he)⟩
  have hp : Present s a := by unfold Present; rw [ha]; rfl
  have := hheap a hp
  unfold noBigAtB at this
  rw [ha] at this
  exact noBigHobjB_sound this

theorem stateNoBigB_sound (h : stateNoBigB lo hi base s = true) : NoBigSt (fun i => lo ≤ i ∧ i < hi) base s := by
  simp only [stateNoBigB, Bool.and_eq_true] at h
  exact NoBigSt.of_checks (noBigHeapB_sound h.1) h.2

end

/-! ## Slots -/

section
variable {I : Int → Prop} {M : Map} {b : Int → Int} {fr : Nat → Option (List Val × List Val)}

theorem FramedObj.rebig (hb : ∀ i, ¬ I i → b i = M.big i) {pre pre' : List Val} {o o' : Obj}
    (hx : NoBig.obj I o) (h : FramedObj M pre pre' o o') : FramedObj (M.withBig b) pre pre' o o' := by
  obtain ⟨xs, hk, ho⟩ := h
  have hxs : NoBig.vals I xs := by
    have hk' := hx.1
    rw [hk] at hk'
    exact fun v hv => hk' v (List.mem_append_right pre hv)
  exact ⟨xs, hk, by rw [ho, Map.obj_rebig hb hx, Map.vals_rebig hb hxs]⟩

theorem SlotOK.rebig (hb : ∀ i, ¬ I i → b i = M.big i) {a : Nat} {h : HObj} {h' : Option HObj}
    (hx : NoBig.hobj I h) (hok : SlotOK M fr a h h') : SlotOK (M.withBig b) fr a h h' := by
  unfold SlotOK at hok ⊢
  cases hfr : fr a with
  | none =>
    rw [hfr] at hok
    rw [hok, Map.hobj_rebig hb hx]
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    rw [hfr] at hok
    obtain ⟨o, o', rfl, rfl, hfo⟩ := hok
    exact ⟨o, o', rfl, rfl, FramedObj.rebig hb hx hfo⟩

end

/-! ## The relation -/

/-- Pointer integers into native memory are at least `2 ^ 56`. -/
private theorem ptrInt_ext_ge (r off : Nat) : (2 : Int) ^ 56 ≤ ptrInt (.ext r) off := by
  have : (2 : Nat) ^ 56 ≤ 2 ^ 62 + r * 2 ^ 24 + off :=
    Nat.le_trans (Nat.pow_le_pow_right (by decide) (by decide)) (Nat.le_add_right_of_le (Nat.le_add_right _ _))
  show ((2 : Nat) ^ 56 : Int) ≤ ((2 ^ 62 + r * 2 ^ 24 + off : Nat) : Int)
  exact Int.ofNat_le.mpr this

theorem Rel.rebig {F FR FR' M ν K s S t C} {I : Int → Prop} {b : Int → Int}
    (h : Rel F FR M ν K s S t C) (hb : ∀ i, ¬ I i → b i = M.big i)
    (hI : ∀ i, I i → ¬ BigFixed K.lo K.hi i ∧ 0 ≤ i ∧ i < 2 ^ 56)
    (hfree : NoBigSt I K.base s)
    (hffi : FR' (M.withBig b) S.tab.length s.ffi t.ffi) :
    Rel F FR' (M.withBig b) ν K s S t C := by
  obtain ⟨fresh, hs, ht⟩ := h.trace
  have hfresh : ∀ e ∈ fresh, NoBig.event I e := fun e he =>
    hfree.trace e (by rw [freshOf_eq hs]; exact he)
  exact {
    srv := ⟨fun i e he => h.srv.num i e he, h.srv.good⟩
    heap := fun a o hg => SlotOK.rebig hb (hfree.heap a o hg) (h.heap a o hg)
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
        Int.lt_irrefl _ (Int.lt_of_lt_of_le (hI _ hIi).2.2 (ptrInt_ext_ge r off))
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
      exact congrArg (· ++ []) (List.map_congr_left fun f hf => (Map.frame_rebig hb (hfree.stack f hf)).symm)
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

end Host.Ts.Sim
