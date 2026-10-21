import host.sim.Rel
namespace Host.Ts.Sim

/-! # State operations under the cross-iteration relation

`Rel` survives extensions of the map (`Rel.extend`), updates of control,
stack and auxiliary state, heap reads, allocation and writes. Allocation and
writes use the paged-store laws, which need an address bound: checked runs
keep `s.next < bound`, so source addresses stay below `2 ^ 61` and target
addresses below `2 ^ 62` (`Rel.tnext`). Cells are never framed
(`Rel.fr_cell`), so cell reads need no framing hypothesis. -/

/-! ## Maps -/

section
variable {A : Nat → Prop} {n : Nat} {M M' : Map}

theorem Ext.agree (h : Ext M M' n) : Agree A n M M' :=
  ⟨fun x _ => (congrFun h.a x).symm, fun i hi => (h.num i hi).symm, h.big.symm, h.region.symm,
    h.node.symm⟩

theorem Ext.agree' (h : Ext M M' n) : Agree A n M' M :=
  ⟨fun x _ => congrFun h.a x, h.num, h.big, h.region, h.node⟩

end

/-! ## Heap lookups and presence -/

section
variable {S : Type}

theorem obj?_iff {s : St S} {a : Nat} {o : Obj} : s.obj? a = some o ↔ s.heap.get a = some (.obj o) := by
  unfold St.obj?
  cases s.heap.get a with
  | none => exact ⟨fun h => (nomatch h), fun h => (nomatch h)⟩
  | some h =>
    cases h with
    | cell _ => exact ⟨fun h => (nomatch h), fun h => (nomatch h)⟩
    | obj _ => exact ⟨fun h => (by cases h; rfl), fun h => (by cases h; rfl)⟩

theorem cell?_iff {s : St S} {a : Nat} {v : Option Val} :
    s.cell? a = some v ↔ s.heap.get a = some (.cell v) := by
  unfold St.cell?
  cases s.heap.get a with
  | none => exact ⟨fun h => (nomatch h), fun h => (nomatch h)⟩
  | some h =>
    cases h with
    | cell _ => exact ⟨fun h => (by cases h; rfl), fun h => (by cases h; rfl)⟩
    | obj _ => exact ⟨fun h => (nomatch h), fun h => (nomatch h)⟩

theorem Present.of_get {s : St S} {a : Nat} {h : HObj} (hg : s.heap.get a = some h) : Present s a := by
  unfold Present
  rw [hg]
  rfl

theorem Present.get {s : St S} {a : Nat} (hp : Present s a) : ∃ h, s.heap.get a = some h := by
  unfold Present at hp
  cases hg : s.heap.get a with
  | none =>
    rw [hg] at hp
    exact absurd hp Bool.false_ne_true
  | some h => exact ⟨h, rfl⟩

theorem Present.set {s : St S} {a b : Nat} (h : HObj) (hb : b < 2 ^ 64) (hp : Present s a) :
    Present { s with heap := s.heap.set b h } a := by
  unfold Present at hp ⊢
  change ((s.heap.set b h).get a).isSome = true
  rw [PTrie.get_set_u64 _ _ _ hb]
  by_cases hab : a = b
  · rw [ite_eq_left hab]
    rfl
  · rw [ite_eq_right hab]
    exact hp

theorem Present.of_set {s : St S} {a b : Nat} {h : HObj} (hb : b < 2 ^ 64)
    (hp : Present { s with heap := s.heap.set b h } a) : a = b ∨ Present s a := by
  unfold Present at hp ⊢
  change ((s.heap.set b h).get a).isSome = true at hp
  rw [PTrie.get_set_u64 _ _ _ hb] at hp
  by_cases hab : a = b
  · exact .inl hab
  · rw [ite_eq_right hab] at hp
    exact .inr hp

theorem alloc_get (s : St S) (h : HObj) (hn : s.next < 2 ^ 64) (a : Nat) :
    (s.alloc h).2.heap.get a = if a = s.next then some h else s.heap.get a :=
  PTrie.get_set_u64 _ _ _ hn a

theorem Present.alloc {s : St S} {a : Nat} (h : HObj) (hn : s.next < 2 ^ 64) (hp : Present s a) :
    Present (s.alloc h).2 a := by
  unfold Present at hp ⊢
  rw [alloc_get s h hn]
  by_cases has : a = s.next
  · rw [ite_eq_left has]
    rfl
  · rw [ite_eq_right has]
    exact hp

theorem Present.alloc_next (s : St S) (h : HObj) (hn : s.next < 2 ^ 64) : Present (s.alloc h).2 s.next := by
  unfold Present
  rw [alloc_get s h hn, ite_eq_left rfl]
  rfl

theorem Present.of_alloc {s : St S} {a : Nat} {h : HObj} (hn : s.next < 2 ^ 64)
    (hp : Present (s.alloc h).2 a) : a = s.next ∨ Present s a := by
  unfold Present at hp ⊢
  rw [alloc_get s h hn] at hp
  by_cases has : a = s.next
  · exact .inl has
  · rw [ite_eq_right has] at hp
    exact .inr hp

end

/-! ## Slots -/

/-- Replacing an object's kind before or after mapping gives the same mapped fields. -/
theorem Map.obj_kind (M : Map) (o : Obj) (k k' : Kind) :
    { M.obj { o with kind := k } with kind := k' } = { M.obj o with kind := k' } := by
  cases o
  rfl

section
variable {A : Nat → Prop} {n : Nat} {M M' : Map} {fr : Nat → Option (List Val × List Val)}

theorem SlotOK.none_iff {a : Nat} {h : HObj} {h' : Option HObj} (hfr : fr a = none) :
    SlotOK M fr a h h' ↔ h' = some (M.hobj h) := by
  simp only [SlotOK, hfr]

theorem SlotOK.some_iff {a : Nat} {pre pre' : List Val} {h : HObj} {h' : Option HObj}
    (hfr : fr a = some (pre, pre')) :
    SlotOK M fr a h h' ↔ ∃ o o', h = .obj o ∧ h' = some (.obj o') ∧ FramedObj M pre pre' o o' := by
  simp only [SlotOK, hfr]

theorem FramedObj.agree {pre pre' : List Val} {o o' : Obj} (hA : Agree A n M M') (hs : Supp.obj A n o)
    (h : FramedObj M pre pre' o o') : FramedObj M' pre pre' o o' := by
  obtain ⟨xs, hk, ho⟩ := h
  have hxs : Supp.vals A n xs := by
    have hk' := hs.1
    rw [hk] at hk'
    exact fun v hv => hk' v (List.mem_append_right pre hv)
  exact ⟨xs, hk, by rw [ho, Map.obj_agree hA hs, Map.vals_agree hA hxs]⟩

theorem SlotOK.agree {a : Nat} {h : HObj} {h' : Option HObj} (hA : Agree A n M M') (hs : Supp.hobj A n h)
    (hok : SlotOK M fr a h h') : SlotOK M' fr a h h' := by
  cases hfr : fr a with
  | none =>
    rw [SlotOK.none_iff hfr] at hok ⊢
    rw [hok, Map.hobj_agree hA hs]
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    rw [SlotOK.some_iff hfr] at hok ⊢
    obtain ⟨o, o', rfl, rfl, hfo⟩ := hok
    exact ⟨o, o', rfl, rfl, FramedObj.agree hA hs hfo⟩

end

/-! ## The relation -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64}
  {K : Ctx} {s : St F.S} {S : SSrv} {t : St F.S} {C : CSrv}

/-- Target addresses stay inside the stores' range. -/
theorem Rel.tnext (h : Rel F FR M ν K s S t C) (hn : s.next < Sim.bound) : t.next < 2 ^ 62 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  have ho := h.offset
  have hr := h.room
  rw [hb] at hn hr
  omega

/-- Extending the map at fresh number references (and growing both servers)
keeps the relation: the source is closed, so every image is unchanged. -/
theorem Rel.extend {M' : Map} {S' : SSrv} {C' : CSrv} (h : Rel F FR M ν K s S t C)
    (hext : Ext M M' S.tab.length) (hsrv : Srv M' ν S' C') (hle : S.tab.length ≤ S'.tab.length)
    (hstable : ∀ M M' n x y, FR M n x y → Ext M M' n → FR M' n x y)
    (hmono : ∀ M n n' x y, FR M n x y → n ≤ n' → FR M n' x y) :
    Rel F FR M' ν K s S' t C' := by
  have hA : Agree (Present s) S.tab.length M M' := hext.agree
  have ha : M'.a = M.a := hext.a
  have hP : ∀ a, Present s a → Present s a := fun _ hp => hp
  obtain ⟨fresh, hs, ht⟩ := h.trace
  obtain ⟨fresh', hs', hsupp'⟩ := h.traceSupp
  have hf : fresh' = fresh := List.append_cancel_right (hs'.symm.trans hs)
  have hsupp : ∀ e ∈ fresh, Supp.event (Present s) S.tab.length e := by
    rw [← hf]
    exact hsupp'
  exact {
    srv := hsrv
    bigFixed := fun i hi => by
      rw [hext.big]
      exact h.bigFixed i hi
    bigExt := fun r off ho => by
      rw [hext.big, hext.region]
      exact h.bigExt r off ho
    band := h.band
    intr := fun a ha' => by
      rw [ha]
      exact h.intr a ha'
    heap := fun a o hg => by
      rw [ha]
      exact SlotOK.agree hA (h.heapSupp a o hg) (h.heap a o hg)
    next := fun k => by
      rw [ha]
      exact h.next k
    offset := h.offset
    room := h.room
    bound := fun a hp => by
      rw [ha]
      exact h.bound a hp
    inj := fun a b hpa hpb he => h.inj a b hpa hpb (by rw [ha] at he; exact he)
    presentBound := h.presentBound
    framedPresent := h.framedPresent
    ctl := by rw [h.ctl, Map.ctl_agree hA h.ctlSupp]
    stack := by
      rw [h.stack]
      exact List.map_congr_left fun f hf => Map.frame_agree hA (h.stackSupp f hf)
    jobs := by
      rw [h.jobs]
      exact List.map_congr_left fun j hj => Map.job_agree hA (h.jobsSupp j hj)
    stores := by rw [h.stores, Map.stores_agree hA h.storesSupp]
    ffi := hmono _ _ _ _ _ (hstable _ _ _ _ _ h.ffi hext) hle
    trace := ⟨fresh, hs, by
      rw [ht, List.map_congr_left fun e he => Map.event_agree hA (hsupp e he)]⟩
    heapSupp := fun a o hg => Supp.hobj_mono hP hle (h.heapSupp a o hg)
    ctlSupp := Supp.ctl_mono hP hle h.ctlSupp
    stackSupp := fun f hf => Supp.frame_mono hP hle (h.stackSupp f hf)
    jobsSupp := fun j hj => Supp.job_mono hP hle (h.jobsSupp j hj)
    storesSupp := Supp.stores_mono hP hle h.storesSupp
    traceSupp := ⟨fresh, hs, fun e he => Supp.event_mono hP hle (hsupp e he)⟩ }

/-! ### Control, stack and auxiliary state -/

theorem Rel.go (h : Rel F FR M ν K s S t C) (c : Ctl)
    (hc : Supp.ctl (Present s) S.tab.length c) :
    Rel F FR M ν K (s.go c) S (t.go (M.ctl c)) C :=
  { h with ctl := rfl, ctlSupp := hc }

theorem Rel.ret (h : Rel F FR M ν K s S t C) (v : Val)
    (hv : Supp.val (Present s) S.tab.length v) :
    Rel F FR M ν K (s.ret v) S (t.ret (M.val v)) C :=
  { h with ctl := rfl, ctlSupp := hv }

theorem Rel.push (h : Rel F FR M ν K s S t C) (f : Frame)
    (hf : Supp.frame (Present s) S.tab.length f) :
    Rel F FR M ν K (s.push f) S (t.push (M.frame f)) C :=
  { h with
    stack := by
      show M.frame f :: t.stack = (f :: s.stack).map M.frame
      rw [h.stack, List.map_cons]
    stackSupp := fun g hg => by
      rcases List.mem_cons.1 hg with rfl | hg
      · exact hf
      · exact h.stackSupp g hg }

/-- Replace the whole stack by supported frames. -/
theorem Rel.restack (h : Rel F FR M ν K s S t C) (fs : List Frame)
    (hfs : ∀ f ∈ fs, Supp.frame (Present s) S.tab.length f) :
    Rel F FR M ν K { s with stack := fs } S { t with stack := fs.map M.frame } C :=
  { h with stack := rfl, stackSupp := hfs }

theorem Rel.pop (h : Rel F FR M ν K s S t C) {f : Frame} {fs : List Frame}
    (hs : s.stack = f :: fs) :
    t.stack = M.frame f :: fs.map M.frame ∧
      Rel F FR M ν K { s with stack := fs } S { t with stack := fs.map M.frame } C :=
  ⟨by rw [h.stack, hs, List.map_cons],
    h.restack fs fun g hg => h.stackSupp g (by rw [hs]; exact List.mem_cons_of_mem f hg)⟩

theorem Rel.setJobs (h : Rel F FR M ν K s S t C) (js : List Job)
    (hjs : ∀ j ∈ js, Supp.job (Present s) S.tab.length j) :
    Rel F FR M ν K (s.setJobs js) S (t.setJobs (js.map M.job)) C :=
  { h with jobs := rfl, jobsSupp := hjs }

theorem Rel.setStores (h : Rel F FR M ν K s S t C) (ss : List (Nat × Val))
    (hss : Supp.stores (Present s) S.tab.length ss) :
    Rel F FR M ν K (s.setStores ss) S (t.setStores (M.stores ss)) C :=
  { h with stores := rfl, storesSupp := hss }

theorem Rel.setFfi (h : Rel F FR M ν K s S t C) (x y : F.S) (hxy : FR M S.tab.length x y) :
    Rel F FR M ν K (s.setFfi x) S (t.setFfi y) C :=
  { h with ffi := hxy }

/-- One more event on both traces. -/
theorem Rel.event (h : Rel F FR M ν K s S t C) (e : Event)
    (he : Supp.event (Present s) S.tab.length e) :
    Rel F FR M ν K (s.setTrace (e :: s.trace)) S (t.setTrace (M.event e :: t.trace)) C := by
  obtain ⟨fresh, hs, ht⟩ := h.trace
  obtain ⟨fresh', hs', hsupp⟩ := h.traceSupp
  exact { h with
    trace := ⟨e :: fresh,
      by show e :: s.trace = (e :: fresh) ++ K.base; rw [hs, List.cons_append],
      by show M.event e :: t.trace = (e :: fresh).map M.event ++ K.base'; rw [ht, List.map_cons, List.cons_append]⟩
    traceSupp := ⟨e :: fresh',
      by show e :: s.trace = (e :: fresh') ++ K.base; rw [hs', List.cons_append],
      fun x hx => by
        rcases List.mem_cons.1 hx with rfl | hx
        · exact he
        · exact hsupp x hx⟩ }

/-! ### Heap reads -/

theorem Rel.get (h : Rel F FR M ν K s S t C) {a : Nat} {o : HObj}
    (hg : s.heap.get a = some o) (hfr : K.fr a = none) : t.heap.get (M.a a) = some (M.hobj o) :=
  (SlotOK.none_iff hfr).1 (h.heap a o hg)

/-- Framed addresses hold objects (so cells are never framed). -/
theorem Rel.framed_get (h : Rel F FR M ν K s S t C) {a : Nat} {p : List Val × List Val}
    (hfr : K.fr a = some p) : ∃ o, s.heap.get a = some (.obj o) := by
  obtain ⟨pre, pre'⟩ := p
  obtain ⟨o0, hg⟩ := (h.framedPresent a _ hfr).get
  obtain ⟨o, _, rfl, -, -⟩ := (SlotOK.some_iff hfr).1 (h.heap a o0 hg)
  exact ⟨o, hg⟩

theorem Rel.fr_cell (h : Rel F FR M ν K s S t C) {a : Nat} {v : Option Val}
    (hg : s.heap.get a = some (.cell v)) : K.fr a = none := by
  cases hfr : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨o, ho⟩ := h.framed_get hfr
    rw [hg] at ho
    cases ho

theorem Rel.obj? (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hfr : K.fr a = none) : t.obj? (M.a a) = some (M.obj o) :=
  obj?_iff.2 (h.get (obj?_iff.1 ho) hfr)

/-- Cell reads need no framing hypothesis: cells are never framed. -/
theorem Rel.cell? (h : Rel F FR M ν K s S t C) {a : Nat} {v : Option Val}
    (hc : s.cell? a = some v) : t.cell? (M.a a) = some (v.map M.val) :=
  cell?_iff.2 (h.get (cell?_iff.1 hc) (h.fr_cell (cell?_iff.1 hc)))

/-- A framed array read: the target object keeps its own prefix. -/
theorem Rel.obj?_framed (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj}
    {pre pre' : List Val} (ho : s.obj? a = some o) (hfr : K.fr a = some (pre, pre')) :
    ∃ o', t.obj? (M.a a) = some o' ∧ FramedObj M pre pre' o o' := by
  obtain ⟨o1, o', ho1, ht, hfo⟩ := (SlotOK.some_iff hfr).1 (h.heap a _ (obj?_iff.1 ho))
  cases ho1
  exact ⟨o', obj?_iff.2 ht, hfo⟩

theorem Rel.get_supp (h : Rel F FR M ν K s S t C) {a : Nat} {o : HObj}
    (hg : s.heap.get a = some o) : Supp.hobj (Present s) S.tab.length o :=
  h.heapSupp a o hg

theorem Rel.obj?_supp (h : Rel F FR M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) : Supp.obj (Present s) S.tab.length o :=
  h.heapSupp a _ (obj?_iff.1 ho)

theorem Rel.cell?_supp (h : Rel F FR M ν K s S t C) {a : Nat} {v : Val}
    (hc : s.cell? a = some (some v)) : Supp.val (Present s) S.tab.length v :=
  h.heapSupp a _ (cell?_iff.1 hc)

/-! ### Allocation -/

theorem Rel.alloc (h : Rel F FR M ν K s S t C) (o : HObj) (hn : s.next < Sim.bound)
    (ho : Supp.hobj (Present (s.alloc o).2) S.tab.length o) :
    (t.alloc (M.hobj o)).1 = M.a (s.alloc o).1 ∧
      Rel F FR M ν K (s.alloc o).2 S (t.alloc (M.hobj o)).2 C := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  have htn : t.next < 2 ^ 62 := h.tnext hn
  have hs64 : s.next < 2 ^ 64 := by rw [hb] at hn; omega
  have ht64 : t.next < 2 ^ 64 := by omega
  have hat : M.a s.next = t.next := by simpa using h.next 0
  have hfr : K.fr s.next = none := by
    cases hf : K.fr s.next with
    | none => rfl
    | some p => exact absurd (h.presentBound _ (h.framedPresent _ _ hf)) (Nat.lt_irrefl _)
  have hP : ∀ a, Present s a → Present (s.alloc o).2 a := fun _ hp => Present.alloc o hs64 hp
  have hP' : ∀ a, Present (s.alloc o).2 a → a = s.next ∨ Present s a := fun _ hp => Present.of_alloc hs64 hp
  have hle : S.tab.length ≤ S.tab.length := Nat.le_refl _
  obtain ⟨fresh, hs, hsupp⟩ := h.traceSupp
  refine ⟨hat.symm, ?_⟩
  exact {
    srv := h.srv
    bigFixed := h.bigFixed
    bigExt := h.bigExt
    band := h.band
    intr := h.intr
    heap := fun a o0 hg => by
      rw [alloc_get s o hs64] at hg
      by_cases ha : a = s.next
      · subst ha
        rw [ite_eq_left rfl] at hg
        obtain rfl := Option.some.inj hg
        rw [SlotOK.none_iff hfr, hat, alloc_get t _ ht64, ite_eq_left rfl]
      · rw [ite_eq_right ha] at hg
        have hne : M.a a ≠ t.next := Nat.ne_of_lt (h.bound a (Present.of_get hg))
        rw [alloc_get t _ ht64, ite_eq_right hne]
        exact h.heap a o0 hg
    next := fun k => by
      show M.a (s.next + 1 + k) = t.next + 1 + k
      rw [show s.next + 1 + k = s.next + (k + 1) by omega, h.next (k + 1),
        show t.next + (k + 1) = t.next + 1 + k by omega]
    offset := by
      show t.next + 1 = s.next + 1 + K.D
      have := h.offset
      omega
    room := h.room
    bound := fun a hp => by
      show M.a a < t.next + 1
      rcases hP' a hp with rfl | hp
      · omega
      · have := h.bound a hp
        omega
    inj := fun a b hpa hpb he => by
      rcases hP' a hpa with rfl | hpa <;> rcases hP' b hpb with rfl | hpb
      · rfl
      · have := h.bound b hpb
        omega
      · have := h.bound a hpa
        omega
      · exact h.inj a b hpa hpb he
    presentBound := fun a hp => by
      show a < s.next + 1
      rcases hP' a hp with rfl | hp
      · omega
      · have := h.presentBound a hp
        omega
    framedPresent := fun a p hf => hP a (h.framedPresent a p hf)
    ctl := h.ctl
    stack := h.stack
    jobs := h.jobs
    stores := h.stores
    ffi := h.ffi
    trace := h.trace
    heapSupp := fun a o0 hg => by
      rw [alloc_get s o hs64] at hg
      by_cases ha : a = s.next
      · rw [ite_eq_left ha] at hg
        obtain rfl := Option.some.inj hg
        exact ho
      · rw [ite_eq_right ha] at hg
        exact Supp.hobj_mono hP hle (h.heapSupp a o0 hg)
    ctlSupp := Supp.ctl_mono hP hle h.ctlSupp
    stackSupp := fun f hf => Supp.frame_mono hP hle (h.stackSupp f hf)
    jobsSupp := fun j hj => Supp.job_mono hP hle (h.jobsSupp j hj)
    storesSupp := Supp.stores_mono hP hle h.storesSupp
    traceSupp := ⟨fresh, hs, fun e he => Supp.event_mono hP hle (hsupp e he)⟩ }

theorem Rel.allocObj (h : Rel F FR M ν K s S t C) (k : Kind) (proto : Val) (props : Props)
    (hn : s.next < Sim.bound) (hk : Supp.kind (Present (s.allocObj k proto props).2) S.tab.length k)
    (hpr : Supp.val (Present (s.allocObj k proto props).2) S.tab.length proto)
    (hps : Supp.props (Present (s.allocObj k proto props).2) S.tab.length props) :
    (t.allocObj (M.kind k) (M.val proto) (M.props props)).1 = M.a (s.allocObj k proto props).1 ∧
      Rel F FR M ν K (s.allocObj k proto props).2 S
        (t.allocObj (M.kind k) (M.val proto) (M.props props)).2 C :=
  h.alloc (.obj ⟨k, proto, props, [], true⟩) hn ⟨hk, hpr, hps, fun _ hx => nomatch hx⟩

/-! ### Writes -/

/-- A write at a present address whose new target entry corresponds to the new source entry. -/
theorem Rel.write (h : Rel F FR M ν K s S t C) {a : Nat} (o : HObj) (o' : HObj)
    (hn : s.next < Sim.bound) (ha : Present s a) (hslot : SlotOK M K.fr a o (some o'))
    (ho : Supp.hobj (Present s) S.tab.length o) :
    Rel F FR M ν K { s with heap := s.heap.set a o } S { t with heap := t.heap.set (M.a a) o' } C := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  have htn : t.next < 2 ^ 62 := h.tnext hn
  have has : a < s.next := h.presentBound a ha
  have ha64 : a < 2 ^ 64 := by rw [hb] at hn; omega
  have hat : M.a a < t.next := h.bound a ha
  have hat64 : M.a a < 2 ^ 64 := by omega
  have hP : ∀ b, Present s b → Present { s with heap := s.heap.set a o } b := fun _ hp => Present.set o ha64 hp
  have hP' : ∀ b, Present { s with heap := s.heap.set a o } b → Present s b := fun b hp => by
    rcases Present.of_set ha64 hp with rfl | hp
    · exact ha
    · exact hp
  have hle : S.tab.length ≤ S.tab.length := Nat.le_refl _
  obtain ⟨fresh, hs, hsupp⟩ := h.traceSupp
  exact {
    srv := h.srv
    bigFixed := h.bigFixed
    bigExt := h.bigExt
    band := h.band
    intr := h.intr
    heap := fun b o0 hg => by
      change (s.heap.set a o).get b = some o0 at hg
      change SlotOK M K.fr b o0 ((t.heap.set (M.a a) o').get (M.a b))
      rw [PTrie.get_set_u64 _ _ _ ha64] at hg
      rw [PTrie.get_set_u64 _ _ _ hat64]
      by_cases hba : b = a
      · rw [ite_eq_left hba] at hg
        rw [ite_eq_left (congrArg M.a hba)]
        obtain rfl := Option.some.inj hg
        rw [hba]
        exact hslot
      · rw [ite_eq_right hba] at hg
        have hne : M.a b ≠ M.a a := fun he => hba (h.inj b a (Present.of_get hg) ha he)
        rw [ite_eq_right hne]
        exact h.heap b o0 hg
    next := h.next
    offset := h.offset
    room := h.room
    bound := fun b hp => h.bound b (hP' b hp)
    inj := fun b c hpb hpc he => h.inj b c (hP' b hpb) (hP' c hpc) he
    presentBound := fun b hp => h.presentBound b (hP' b hp)
    framedPresent := fun b p hf => hP b (h.framedPresent b p hf)
    ctl := h.ctl
    stack := h.stack
    jobs := h.jobs
    stores := h.stores
    ffi := h.ffi
    trace := h.trace
    heapSupp := fun b o0 hg => by
      change (s.heap.set a o).get b = some o0 at hg
      rw [PTrie.get_set_u64 _ _ _ ha64] at hg
      by_cases hba : b = a
      · rw [ite_eq_left hba] at hg
        obtain rfl := Option.some.inj hg
        exact Supp.hobj_mono hP hle ho
      · rw [ite_eq_right hba] at hg
        exact Supp.hobj_mono hP hle (h.heapSupp b o0 hg)
    ctlSupp := Supp.ctl_mono hP hle h.ctlSupp
    stackSupp := fun f hf => Supp.frame_mono hP hle (h.stackSupp f hf)
    jobsSupp := fun j hj => Supp.job_mono hP hle (h.jobsSupp j hj)
    storesSupp := Supp.stores_mono hP hle h.storesSupp
    traceSupp := ⟨fresh, hs, fun e he => Supp.event_mono hP hle (hsupp e he)⟩ }

theorem Rel.set (h : Rel F FR M ν K s S t C) {a : Nat} (o : HObj) (hn : s.next < Sim.bound)
    (ha : Present s a) (hfr : K.fr a = none) (ho : Supp.hobj (Present s) S.tab.length o) :
    Rel F FR M ν K { s with heap := s.heap.set a o } S
      { t with heap := t.heap.set (M.a a) (M.hobj o) } C :=
  h.write o (M.hobj o) hn ha ((SlotOK.none_iff hfr).2 rfl) ho

theorem Rel.setObj (h : Rel F FR M ν K s S t C) {a : Nat} (o : Obj) (hn : s.next < Sim.bound)
    (ha : Present s a) (hfr : K.fr a = none) (ho : Supp.obj (Present s) S.tab.length o) :
    Rel F FR M ν K (s.setObj a o) S (t.setObj (M.a a) (M.obj o)) C :=
  h.set (.obj o) hn ha hfr ho

theorem Rel.setCell (h : Rel F FR M ν K s S t C) {a : Nat} (v : Val) (hn : s.next < Sim.bound)
    (ha : Present s a) (hfr : K.fr a = none) (hv : Supp.val (Present s) S.tab.length v) :
    Rel F FR M ν K (s.setCell a v) S (t.setCell (M.a a) (M.val v)) C :=
  h.set (.cell (some v)) hn ha hfr hv

/-- Appending `ys` to a framed array: each side keeps its own prefix. -/
theorem Rel.setFramed (h : Rel F FR M ν K s S t C) {a : Nat} {pre pre' xs ys : List Val}
    {o o' : Obj} (hn : s.next < Sim.bound) (hfr : K.fr a = some (pre, pre')) (ho : s.obj? a = some o)
    (hfo : FramedObj M pre pre' o o') (hk : o.kind = .array (pre ++ xs))
    (hys : Supp.vals (Present s) S.tab.length ys) :
    Rel F FR M ν K (s.setObj a { o with kind := .array (pre ++ xs ++ ys) }) S
      (t.setObj (M.a a) { o' with kind := .array (pre' ++ M.vals (xs ++ ys)) }) C := by
  have hg := obj?_iff.1 ho
  obtain ⟨xs0, hk0, rfl⟩ := hfo
  have hxs : xs0 = xs := by
    have he := hk0.symm.trans hk
    injection he with he
    exact List.append_cancel_left he
  subst xs
  have hso : Supp.obj (Present s) S.tab.length o := h.heapSupp a _ hg
  have hvs : Supp.vals (Present s) S.tab.length (pre ++ xs0) := by
    have hk' := hso.1
    rw [hk] at hk'
    exact hk'
  have hnew : Supp.obj (Present s) S.tab.length { o with kind := .array (pre ++ xs0 ++ ys) } :=
    ⟨fun v hv => by
      rcases List.mem_append.1 hv with hv | hv
      · exact hvs v hv
      · exact hys v hv, hso.2.1, hso.2.2.1, hso.2.2.2⟩
  have hslot : SlotOK M K.fr a (.obj { o with kind := .array (pre ++ xs0 ++ ys) })
      (some (.obj { M.obj o with kind := .array (pre' ++ M.vals (xs0 ++ ys)) })) := by
    refine (SlotOK.some_iff hfr).2 ⟨_, _, rfl, rfl, xs0 ++ ys, ?_, (Map.obj_kind M o _ _).symm⟩
    show Kind.array (pre ++ xs0 ++ ys) = Kind.array (pre ++ (xs0 ++ ys))
    rw [List.append_assoc]
  exact h.write _ _ hn (Present.of_get hg) hslot hnew

end

end Host.Ts.Sim
