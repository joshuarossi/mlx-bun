import host.sim.conv.Compact
import host.sim.template.Check
import host.sim.template.NShiftGen
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

/-! # Closedness from the call

A site template's start is the call state without the caller's frames, so its closedness is the
caller's (`site_closed`, from the caller's relation at the call: `site_run` reads it there and needs
no check of the start). A state derived from the call state by changing a list `l` of entries (the
canonical state after a compaction: the written caller entries and the result places) is closed when
the entries off `l` are the call's, the call's present addresses stay present, and the entries on `l`
are checked: `closed_of_call` and `bound_of_call` with the kernel checks `suppListB`, `boundListB`,
`keptPresentB` over `l` only. Natively the same over the changed nodes, objects and items, the queue
and the error handler (`sst_of_call`, `sstListB`). -/

section
variable {S' : Type}

/-- The support check of the entries `l` of `c` (references below `n`). -/
def suppListB (c : St S') (n : Nat) (l : List Nat) : Bool :=
  l.all fun a => match c.heap.get a with
    | some h => bHobj (presentB c) n h
    | none => true

theorem suppListB_sound {c : St S'} {n : Nat} {l : List Nat} (h : suppListB c n l = true) :
    ∀ a ∈ l, ∀ o, c.heap.get a = some o → Supp.hobj (Present c) n o := by
  intro a ha o ho
  simp only [suppListB, List.all_eq_true] at h
  have := h a ha
  rw [ho] at this
  exact bHobj_sound this

/-- The present entries of `l` are below `c`'s counter. -/
def boundListB (c : St S') (l : List Nat) : Bool := l.all fun a => !(presentB c a) || Nat.blt a c.next

theorem boundListB_sound {c : St S'} {l : List Nat} (h : boundListB c l = true) :
    ∀ a ∈ l, Present c a → a < c.next := by
  intro a ha hp
  simp only [boundListB, List.all_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  rcases h a ha with h | h
  · exact absurd hp (by unfold Present; simp only [presentB] at h; rw [h]; decide)
  · rwa [Nat.blt_eq] at h

/-- The entries of `l` present in `s` are present in `c`. -/
def keptPresentB (s c : St S') (l : List Nat) : Bool := l.all fun a => !(presentB s a) || presentB c a

theorem keptPresentB_sound {s c : St S'} {l : List Nat} (h : keptPresentB s c l = true) :
    ∀ a ∈ l, Present s a → Present c a := by
  intro a ha hp
  simp only [keptPresentB, List.all_eq_true, Bool.or_eq_true, Bool.not_eq_true'] at h
  rcases h a ha with h | h
  · exact absurd hp (by unfold Present; simp only [presentB] at h; rw [h]; decide)
  · exact h

/-- The call's present addresses stay present in a state keeping its entries off `l`. -/
theorem present_of_call {s c : St S'} {l : List Nat} (hkeep : ∀ a, a ∉ l → c.heap.get a = s.heap.get a)
    (hl : ∀ a ∈ l, Present s a → Present c a) : ∀ a, Present s a → Present c a := by
  intro a hp
  by_cases ha : a ∈ l
  · exact hl a ha hp
  · unfold Present at hp ⊢; rw [hkeep a ha]; exact hp

end

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
  {M : Map} {ν : Nat → F64} {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- **A site template start's closedness is the caller's**: the support facts of the caller's relation
at the call. -/
theorem site_closed {s0 : St F.S} (h : RelB F FR W stk M ν K s S t C) (hs0 : s0 = { s with stack := [] }) :
    (∀ a o, s0.heap.get a = some o → Supp.hobj (Present s0) S.tab.length o) ∧
      (∀ a, Present s0 a → a < s0.next) ∧ Supp.ctl (Present s0) S.tab.length s0.ctl ∧
      (∀ f ∈ s0.stack, Supp.frame (Present s0) S.tab.length f) ∧
      (∀ j ∈ s0.jobs, Supp.job (Present s0) S.tab.length j) ∧ Supp.stores (Present s0) S.tab.length s0.stores := by
  subst hs0
  exact ⟨h.heapSupp, h.presentBound, h.ctlSupp, (fun f hf => by cases hf), h.jobsSupp, h.storesSupp⟩

/-- **Closedness from the call** (the heap): a state keeping the call's entries off `l`, holding the
call's present addresses, with its entries on `l` supported, is supported. -/
theorem closed_of_call {c : St F.S} {n : Nat} {l : List Nat} (h : RelB F FR W stk M ν K s S t C)
    (hn : S.tab.length ≤ n) (hkeep : ∀ a, a ∉ l → c.heap.get a = s.heap.get a)
    (hP : ∀ a ∈ l, Present s a → Present c a)
    (hl : ∀ a ∈ l, ∀ o, c.heap.get a = some o → Supp.hobj (Present c) n o) :
    ∀ a o, c.heap.get a = some o → Supp.hobj (Present c) n o := by
  intro a o ho
  by_cases ha : a ∈ l
  · exact hl a ha o ho
  · rw [hkeep a ha] at ho
    exact Supp.hobj_mono (present_of_call hkeep hP) hn (h.heapSupp a o ho)

/-- **The counter bound from the call**: present entries off `l` are the call's, below its counter. -/
theorem bound_of_call {c : St F.S} {l : List Nat} (h : RelB F FR W stk M ν K s S t C) (hle : s.next ≤ c.next)
    (hkeep : ∀ a, a ∉ l → c.heap.get a = s.heap.get a) (hl : ∀ a ∈ l, Present c a → a < c.next) :
    ∀ a, Present c a → a < c.next := by
  intro a hp
  by_cases ha : a ∈ l
  · exact hl a ha hp
  · have : Present s a := by unfold Present at hp ⊢; rw [← hkeep a ha]; exact hp
    exact Nat.lt_of_lt_of_le (h.presentBound a this) hle

/-- Closedness from the call with the kernel checks over `l`. -/
theorem closed_of_callB {c : St F.S} {n : Nat} {l : List Nat} (h : RelB F FR W stk M ν K s S t C)
    (hn : S.tab.length ≤ n) (hle : s.next ≤ c.next) (hkeep : ∀ a, a ∉ l → c.heap.get a = s.heap.get a)
    (hP : keptPresentB s c l = true) (hs : suppListB c n l = true) (hb : boundListB c l = true) :
    (∀ a o, c.heap.get a = some o → Supp.hobj (Present c) n o) ∧ (∀ a, Present c a → a < c.next) ∧
      ∀ a, Present s a → Present c a :=
  ⟨closed_of_call h hn hkeep (keptPresentB_sound hP) (suppListB_sound hs),
    bound_of_call h hle hkeep (boundListB_sound hb), present_of_call hkeep (keptPresentB_sound hP)⟩

end

/-! ## The native start -/

section
variable {R : Nat → Prop}

/-- **Native closedness from the call**: a native state keeping the call's nodes, objects and items
off the lists `ln`, `lo`, `li`, with those, its queue and its error handler supported, is supported. -/
theorem sst_of_call {x c : NSt} (hx : SSt R x) {ln lo li : List Nat}
    (hn : ∀ i nd, c.nodes.get i = some nd → i ∉ ln → x.nodes.get i = some nd)
    (ho : ∀ h o, c.objs.get h = some o → h ∉ lo → x.objs.get h = some o)
    (hi : ∀ k v, c.items.get k = some v → k ∉ li → x.items.get k = some v)
    (hln : ∀ i ∈ ln, ∀ nd, c.nodes.get i = some nd → SNode R nd)
    (hlo : ∀ h ∈ lo, ∀ o, c.objs.get h = some o → SObj R o)
    (hli : ∀ k ∈ li, ∀ v, c.items.get k = some v → SN R v)
    (ht : ∀ v ∈ c.tokens, SN R v) (he : ∀ a, c.errh = some a → SA R a) : SSt R c := by
  refine ⟨fun i nd hg => ?_, fun h o hg => ?_, ht, fun k v hg => ?_, he⟩
  · by_cases hm : i ∈ ln
    · exact hln i hm nd hg
    · exact hx.1 i nd (hn i nd hg hm)
  · by_cases hm : h ∈ lo
    · exact hlo h hm o hg
    · exact hx.2.1 h o (ho h o hg hm)
  · by_cases hm : k ∈ li
    · exact hli k hm v hg
    · exact hx.2.2.2.1 k v (hi k v hg hm)

end

/-- The native checks of the changed entries, the queue and the error handler (references below `n`). -/
def sstListB (n : Nat) (c : NSt) (ln lo li : List Nat) : Bool :=
  ln.all (fun i => match c.nodes.get i with | some nd => bSNode n nd | none => true) &&
    lo.all (fun h => match c.objs.get h with | some o => bSObj n o | none => true) &&
    li.all (fun k => match c.items.get k with | some v => bSN n v | none => true) &&
    c.tokens.all (bSN n) && (match c.errh with | some a => bSA n a | none => true)

theorem sst_of_callB {n n0 : Nat} {x c : NSt} (hx : SSt (· < n0) x) (hn0 : n0 ≤ n) {ln lo li : List Nat}
    (hn : ∀ i nd, c.nodes.get i = some nd → i ∉ ln → x.nodes.get i = some nd)
    (ho : ∀ h o, c.objs.get h = some o → h ∉ lo → x.objs.get h = some o)
    (hi : ∀ k v, c.items.get k = some v → k ∉ li → x.items.get k = some v)
    (hc : sstListB n c ln lo li = true) : SSt (· < n) c := by
  simp only [sstListB, Bool.and_eq_true, List.all_eq_true] at hc
  obtain ⟨⟨⟨⟨hcn, hco⟩, hci⟩, hct⟩, hce⟩ := hc
  refine sst_of_call (hx.mono fun i hi => Nat.lt_of_lt_of_le hi hn0) hn ho hi (fun i hm nd hg => ?_)
    (fun h hm o hg => ?_) (fun k hm v hg => ?_) (fun v hv => bSN_sound (hct v hv)) (fun a ha => ?_)
  · have := hcn i hm; rw [hg] at this; exact bSNode_sound this
  · have := hco h hm; rw [hg] at this; exact bSObj_sound this
  · have := hci k hm; rw [hg] at this; exact bSN_sound this
  · rw [ha] at hce; exact bSA_sound hce

end Host.Ts.Sim.Conv
