import host.sim.StageRel
import host.sim.Wide
namespace Host.Ts.Sim.Conv
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Stage

/-! # Frozen caller entries

A stage template runs on the isolated part of a caller's state: the callee frames, the heap the
callee reaches and the static band. The caller's own entries are target entries no address of the
template maps to (`RelB` leaves such entries unconstrained: the target may hold more). For the
caller's relation to hold again after the return, the stage's run must leave them as they were.

`RelZ … Z z` is `RelB` (unchanged) with the target entries at the addresses `Z` frozen at `z`:
`Z` lies below the target's counter and outside the images of the source's present addresses
(`out`), so every target write the state lemmas of `host.sim.State` make lands outside `Z`
(writes at images of present addresses, allocations at the target's counter). It is a layer:
`RelZ.toB` projects it to `RelB`, and with no frozen entries it is `RelB` (`relZ_none_iff`).

* `FrozenT`: the frozen entries; `FrozenT.set`, `FrozenT.alloc`: a write outside `Z`, an
  allocation at or above every frozen address keep them.
* The state lemmas of `host.sim.State` for `RelZ`: `extend`, `go`, `ret`, `push`, `restack`, `pop`,
  `setJobs`, `setStores`, `setFfi`, `event`, `alloc`, `allocObj`, `write`, `set`, `setObj`,
  `setCell`, `setFramed`, `heapCongr`; each is the `RelB` lemma plus the frame fact.
* `RelXZ`, the frozen form of `RelXB`; `Disp.StepSimZB`, the frozen one-step obligation, with its
  projection to `Disp.StepSimXLB` (`StepSimZB.toXLB`) and the run (`runOk_simZB`).
* `StageTpl.HoldsZ`: **the frozen contract** of a stage template (every caller-only target entry
  below the call's counter unchanged, the native part up to `NK`), and `StageTpl.holdsZ`: a
  frozen one-step simulation gives it. The merge at the return (`host.sim.conv.Merge`) consumes
  `HoldsZ`.

Not shown here: that the dispatcher's one-step theorem (`Disp.stepSimXLB`) lifts to
`StepSimZB`. Its proof builds every target state with the lemmas below, but its statement only
exports `RelXB`, so the lift is a re-proof of the step lemmas through the `RelZ` versions (or a
locality theorem of the interpreter). -/

/-- The target entries at `Z` are `z`. -/
def FrozenT {S : Type} (Z : Nat → Prop) (z : Nat → Option HObj) (t : St S) : Prop :=
  ∀ a, Z a → t.heap.get a = z a

section
variable {S : Type} {Z : Nat → Prop} {z : Nat → Option HObj}

/-- A write outside the frozen addresses keeps them (addresses below `2 ^ 64`). -/
theorem FrozenT.set {t : St S} (h : FrozenT Z z t) {b : Nat} (o : HObj) (hb : b < 2 ^ 64) (hz : ¬ Z b) :
    FrozenT Z z { t with heap := t.heap.set b o } := by
  intro a ha
  show (t.heap.set b o).get a = z a
  rw [PTrie.get_set_u64 _ _ _ hb]
  have hab : a ≠ b := fun e => hz (e ▸ ha)
  rw [ite_eq_right hab]
  exact h a ha

/-- An allocation at the target's counter, above every frozen address, keeps them. -/
theorem FrozenT.alloc {t : St S} (h : FrozenT Z z t) (o : HObj) (hn : t.next < 2 ^ 64)
    (hb : ∀ a, Z a → a < t.next) : FrozenT Z z (t.alloc o).2 := by
  intro a ha
  show (t.heap.set t.next o).get a = z a
  rw [PTrie.get_set_u64 _ _ _ hn]
  rw [ite_eq_right (Nat.ne_of_lt (hb a ha))]
  exact h a ha

/-- The frozen entries only depend on the target's heap. -/
theorem FrozenT.congr {t t' : St S} (h : FrozenT Z z t) (hh : ∀ a, Z a → t'.heap.get a = t.heap.get a) :
    FrozenT Z z t' := fun a ha => by rw [hh a ha]; exact h a ha

end

/-- **`RelB` with frozen caller entries**: the target entries at `Z` (below the target's
counter, outside the images of the source's present addresses) are `z`. -/
structure RelZ (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame)
    (Z : Nat → Prop) (z : Nat → Option HObj) (M : Map) (ν : Nat → F64) (K : Ctx) (s : St F.S) (S : SSrv)
    (t : St F.S) (C : CSrv) : Prop where
  rel : RelB F FR W stk M ν K s S t C
  out : ∀ a, Present s a → ¬ Z (M.a a)
  below : ∀ a, Z a → a < t.next
  frozen : FrozenT Z z t

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
  {Z : Nat → Prop} {z : Nat → Option HObj} {M : Map} {ν : Nat → F64} {K : Ctx} {s : St F.S} {S : SSrv}
  {t : St F.S} {C : CSrv}

/-- **Projection** to the base relation. -/
theorem RelZ.toB (h : RelZ F FR W stk Z z M ν K s S t C) : RelB F FR W stk M ν K s S t C := h.rel

/-- With no frozen entries the layer is the base relation. -/
theorem RelZ.ofB (h : RelB F FR W stk M ν K s S t C) : RelZ F FR W stk (fun _ => False) z M ν K s S t C :=
  ⟨h, fun _ _ hz => hz, fun _ hz => hz.elim, fun _ hz => hz.elim⟩

theorem relZ_none_iff :
    RelZ F FR W stk (fun _ => False) z M ν K s S t C ↔ RelB F FR W stk M ν K s S t C :=
  ⟨RelZ.toB, RelZ.ofB⟩

/-- **Freezing at a state**: the target's own entries at `Z` (below its counter, outside the
images) are frozen at their current values. -/
theorem RelZ.freeze (h : RelB F FR W stk M ν K s S t C) (hout : ∀ a, Present s a → ¬ Z (M.a a))
    (hb : ∀ a, Z a → a < t.next) : RelZ F FR W stk Z (fun a => t.heap.get a) M ν K s S t C :=
  ⟨h, hout, hb, fun _ _ => rfl⟩

/-- The caller-only addresses of a target: below its counter, no present address maps there. -/
def CallerOnly (M : Map) (s : St F.S) (t : St F.S) (a : Nat) : Prop :=
  a < t.next ∧ ∀ b, Present s b → M.a b ≠ a

/-- Every caller-only address is frozen at its current entry. -/
theorem RelZ.freezeAll (h : RelB F FR W stk M ν K s S t C) :
    RelZ F FR W stk (CallerOnly M s t) (fun a => t.heap.get a) M ν K s S t C :=
  RelZ.freeze h (fun a ha hz => hz.2 a ha rfl) (fun _ hz => hz.1)

/-! ## The state lemmas -/

theorem RelZ.extend {M' : Map} {S' : SSrv} {C' : CSrv} (h : RelZ F FR W stk Z z M ν K s S t C)
    (hext : Ext M M' S.tab.length) (hsrv : Srv M' ν S' C') (hle : S.tab.length ≤ S'.tab.length)
    (hstable : ∀ M M' n x y, FR M n x y → Ext M M' n → FR M' n x y)
    (hmono : ∀ M n n' x y, FR M n x y → n ≤ n' → FR M n' x y) :
    RelZ F FR W stk Z z M' ν K s S' t C' :=
  ⟨h.rel.extend hext hsrv hle hstable hmono, fun a ha => by rw [hext.a]; exact h.out a ha, h.below, h.frozen⟩

theorem RelZ.go (h : RelZ F FR W stk Z z M ν K s S t C) (c : Ctl) (hc : Supp.ctl (Present s) S.tab.length c) :
    RelZ F FR W stk Z z M ν K (s.go c) S (t.go (M.ctl c)) C :=
  ⟨h.rel.go c hc, h.out, h.below, h.frozen⟩

theorem RelZ.ret (h : RelZ F FR W stk Z z M ν K s S t C) (v : Val) (hv : Supp.val (Present s) S.tab.length v) :
    RelZ F FR W stk Z z M ν K (s.ret v) S (t.ret (M.val v)) C :=
  ⟨h.rel.ret v hv, h.out, h.below, h.frozen⟩

theorem RelZ.push (h : RelZ F FR W stk Z z M ν K s S t C) (f : Frame) (hf : Supp.frame (Present s) S.tab.length f) :
    RelZ F FR W stk Z z M ν K (s.push f) S (t.push (M.frame f)) C :=
  ⟨h.rel.push f hf, h.out, h.below, h.frozen⟩

theorem RelZ.restack (h : RelZ F FR W stk Z z M ν K s S t C) (fs : List Frame)
    (hfs : ∀ f ∈ fs, Supp.frame (Present s) S.tab.length f) :
    RelZ F FR W stk Z z M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C :=
  ⟨h.rel.restack fs hfs, h.out, h.below, h.frozen⟩

theorem RelZ.pop (h : RelZ F FR W stk Z z M ν K s S t C) {f : Frame} {fs : List Frame} (hs : s.stack = f :: fs) :
    t.stack = M.frame f :: (fs.map M.frame ++ stk) ∧
      RelZ F FR W stk Z z M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C :=
  ⟨(h.rel.pop hs).1, ⟨(h.rel.pop hs).2, h.out, h.below, h.frozen⟩⟩

theorem RelZ.setJobs (h : RelZ F FR W stk Z z M ν K s S t C) (js : List Job)
    (hjs : ∀ j ∈ js, Supp.job (Present s) S.tab.length j) :
    RelZ F FR W stk Z z M ν K (s.setJobs js) S (t.setJobs (js.map M.job)) C :=
  ⟨h.rel.setJobs js hjs, h.out, h.below, h.frozen⟩

theorem RelZ.setStores (h : RelZ F FR W stk Z z M ν K s S t C) (ss : List (Nat × Val))
    (hss : Supp.stores (Present s) S.tab.length ss) :
    RelZ F FR W stk Z z M ν K (s.setStores ss) S (t.setStores (M.stores ss)) C :=
  ⟨h.rel.setStores ss hss, h.out, h.below, h.frozen⟩

theorem RelZ.setFfi (h : RelZ F FR W stk Z z M ν K s S t C) (x y : F.S) (hxy : FR M S.tab.length x y) :
    RelZ F FR W stk Z z M ν K (s.setFfi x) S (t.setFfi y) C :=
  ⟨h.rel.setFfi x y hxy, h.out, h.below, h.frozen⟩

theorem RelZ.event (h : RelZ F FR W stk Z z M ν K s S t C) (e : Event) (he : Supp.event (Present s) S.tab.length e) :
    RelZ F FR W stk Z z M ν K (s.setTrace (e :: s.trace)) S (t.setTrace (M.event e :: t.trace)) C :=
  ⟨h.rel.event e he, h.out, h.below, h.frozen⟩

/-- The target only depends on its heap at the frozen addresses (with `RelB.heapCongr`). -/
theorem RelZ.heapCongr {t' : St F.S} (h : RelZ F FR W stk Z z M ν K s S t C) (hh : ∀ y, t'.heap.get y = t.heap.get y)
    (hn : t'.next = t.next) (hc : t'.ctl = t.ctl) (hs : t'.stack = t.stack) (ha : t'.aux = t.aux) :
    RelZ F FR W stk Z z M ν K s S t' C :=
  ⟨h.rel.heapCongr hh hn hc hs ha, h.out, fun a hz => by rw [hn]; exact h.below a hz,
    h.frozen.congr fun a _ => hh a⟩

/-! ### Allocation and writes: target writes land at images, allocations at the counter -/

theorem RelZ.alloc (h : RelZ F FR W stk Z z M ν K s S t C) (o : HObj) (hn : s.next < Sim.bound)
    (ho : Supp.hobj (Present (s.alloc o).2) S.tab.length o) :
    (t.alloc (M.hobj o)).1 = M.a (s.alloc o).1 ∧
      RelZ F FR W stk Z z M ν K (s.alloc o).2 S (t.alloc (M.hobj o)).2 C := by
  obtain ⟨e, hr⟩ := h.rel.alloc o hn ho
  have htn : t.next < 2 ^ 62 := h.rel.tnext hn
  have hs64 : s.next < 2 ^ 64 := by have : Sim.bound = 2 ^ 61 := rfl; omega
  refine ⟨e, hr, fun a ha => ?_, fun a hz => ?_, h.frozen.alloc _ (by omega) h.below⟩
  · rcases Present.of_alloc hs64 ha with rfl | ha
    · have hat : M.a s.next = t.next := by simpa using h.rel.next 0
      rw [hat]
      exact fun hz => Nat.lt_irrefl _ (h.below _ hz)
    · exact h.out a ha
  · exact Nat.lt_succ_of_lt (h.below a hz)

theorem RelZ.allocObj (h : RelZ F FR W stk Z z M ν K s S t C) (k : Kind) (proto : Val) (props : Props)
    (hn : s.next < Sim.bound) (hk : Supp.kind (Present (s.allocObj k proto props).2) S.tab.length k)
    (hpr : Supp.val (Present (s.allocObj k proto props).2) S.tab.length proto)
    (hps : Supp.props (Present (s.allocObj k proto props).2) S.tab.length props) :
    (t.allocObj (M.kind k) (M.val proto) (M.props props)).1 = M.a (s.allocObj k proto props).1 ∧
      RelZ F FR W stk Z z M ν K (s.allocObj k proto props).2 S
        (t.allocObj (M.kind k) (M.val proto) (M.props props)).2 C :=
  h.alloc (.obj ⟨k, proto, props, [], true⟩) hn ⟨hk, hpr, hps, fun _ hx => nomatch hx⟩

/-- A write at a present address: the target write is at its image, outside the frozen entries. -/
theorem RelZ.write (h : RelZ F FR W stk Z z M ν K s S t C) {a : Nat} (o : HObj) (o' : HObj)
    (hn : s.next < Sim.bound) (ha : Present s a) (hslot : SlotW M K.fr W a o (some o'))
    (ho : Supp.hobj (Present s) S.tab.length o) :
    RelZ F FR W stk Z z M ν K { s with heap := s.heap.set a o } S { t with heap := t.heap.set (M.a a) o' } C := by
  have hr := h.rel.write o o' hn ha hslot ho
  have htn : t.next < 2 ^ 62 := h.rel.tnext hn
  have hat : M.a a < t.next := h.rel.bound a ha
  have hb : Sim.bound = 2 ^ 61 := rfl
  have ha64 : a < 2 ^ 64 := by have := h.rel.presentBound a ha; omega
  refine ⟨hr, fun b hb' => ?_, h.below, h.frozen.set _ (by omega) (h.out a ha)⟩
  rcases Present.of_set ha64 hb' with rfl | hb'
  · exact h.out _ ha
  · exact h.out b hb'

theorem RelZ.set (h : RelZ F FR W stk Z z M ν K s S t C) {a : Nat} (o : HObj) (hn : s.next < Sim.bound)
    (ha : Present s a) (hfr : K.fr a = none) (ho : Supp.hobj (Present s) S.tab.length o) :
    RelZ F FR W stk Z z M ν K { s with heap := s.heap.set a o } S
      { t with heap := t.heap.set (M.a a) (M.hobj o) } C :=
  h.write o (M.hobj o) hn ha ((SlotW.of_fr_none hfr).2 rfl) ho

theorem RelZ.setObj (h : RelZ F FR W stk Z z M ν K s S t C) {a : Nat} (o : Obj) (hn : s.next < Sim.bound)
    (ha : Present s a) (hfr : K.fr a = none) (ho : Supp.obj (Present s) S.tab.length o) :
    RelZ F FR W stk Z z M ν K (s.setObj a o) S (t.setObj (M.a a) (M.obj o)) C :=
  h.set (.obj o) hn ha hfr ho

theorem RelZ.setCell (h : RelZ F FR W stk Z z M ν K s S t C) {a : Nat} (v : Val) (hn : s.next < Sim.bound)
    (ha : Present s a) (hfr : K.fr a = none) (hv : Supp.val (Present s) S.tab.length v) :
    RelZ F FR W stk Z z M ν K (s.setCell a v) S (t.setCell (M.a a) (M.val v)) C :=
  h.set (.cell (some v)) hn ha hfr hv

/-- Appending to a framed array. -/
theorem RelZ.setFramed (h : RelZ F FR W stk Z z M ν K s S t C) {a : Nat} {pre pre' xs ys : List Val}
    {o o' : Obj} (hn : s.next < Sim.bound) (hfr : K.fr a = some (pre, pre')) (hw : W a = none) (ho : s.obj? a = some o)
    (hfo : FramedObj M pre pre' o o') (hk : o.kind = .array (pre ++ xs))
    (hys : Supp.vals (Present s) S.tab.length ys) :
    RelZ F FR W stk Z z M ν K (s.setObj a { o with kind := .array (pre ++ xs ++ ys) }) S
      (t.setObj (M.a a) { o' with kind := .array (pre' ++ M.vals (xs ++ ys)) }) C := by
  have hr := h.rel.setFramed hn hfr hw ho hfo hk hys
  have ha : Present s a := Present.of_get (obj?_iff.1 ho)
  have htn : t.next < 2 ^ 62 := h.rel.tnext hn
  have hat : M.a a < t.next := h.rel.bound a ha
  have hb : Sim.bound = 2 ^ 61 := rfl
  have ha64 : a < 2 ^ 64 := by have := h.rel.presentBound a ha; omega
  refine ⟨hr, fun b hb' => ?_, h.below, h.frozen.set _ (by omega) (h.out a ha)⟩
  rcases Present.of_set ha64 hb' with rfl | hb'
  · exact h.out _ ha
  · exact h.out b hb'

end

/-! ## The frozen one-step obligation -/

/-- `RelXB` with frozen caller entries. -/
structure RelXZ (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame)
    (Z : Nat → Prop) (z : Nat → Option HObj) (M : Map) (ν : Nat → F64) (K : Ctx) (s : St F.S) (S : SSrv)
    (t : St F.S) (C : CSrv) : Prop where
  rel : RelXB F FR W stk M ν K s S t C
  out : ∀ a, Present s a → ¬ Z (M.a a)
  below : ∀ a, Z a → a < t.next
  frozen : FrozenT Z z t

theorem RelZ.toX {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame}
    {Z : Nat → Prop} {z : Nat → Option HObj} {M : Map} {ν : Nat → F64} {K : Ctx} {s : St F.S} {S : SSrv}
    {t : St F.S} {C : CSrv} (h : RelZ F FR W stk Z z M ν K s S t C) : RelXZ F FR W stk Z z M ν K s S t C :=
  ⟨.inl h.rel, h.out, h.below, h.frozen⟩

/-- **The frozen one-step obligation**: `Disp.StepSimXLB` for `RelXZ`, for every frozen set. -/
def StepSimZB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop)
    (W : Nat → Option WFrame) (stk : List Frame) (VBOk : (Nat → F64) → Prop) : Prop :=
  ∀ (Z : Nat → Prop) (z : Nat → Option HObj) M ν K s S t C s1 S1, Kp K → VBOk ν → RelXZ F FR W stk Z z M ν K s S t C →
    isHalt s.ctl = false → (stk = [] ∨ Disp.localB s = true) → ok s S = true → interpS (step F s).run S = some (s1, S1) →
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      RelXZ F FR W stk Z z M' ν K s1 S1 t1 C1

/-- **Projection**: the frozen obligation gives the base one (no frozen entries). -/
theorem StepSimZB.toXLB {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ok : St F.S → SSrv → Bool}
    {Kp : Ctx → Prop} {W : Nat → Option WFrame} {stk : List Frame} {VBOk : (Nat → F64) → Prop}
    (h : StepSimZB F FR ok Kp W stk VBOk) : Disp.StepSimXLB F FR ok Kp W stk VBOk := by
  intro M ν K s S t C s1 S1 hK hν hr hh hl hok hs
  obtain ⟨M', t1, C1, ht, he, hr'⟩ := h (fun _ => False) (fun _ => none) M ν K s S t C s1 S1 hK hν
    ⟨hr, fun _ _ hz => hz, fun _ hz => hz.elim, fun _ hz => hz.elim⟩ hh hl hok hs
  exact ⟨M', t1, C1, ht, he, hr'.rel⟩

/-- A checked run under the frozen obligation keeps the frozen entries. -/
theorem runOk_simZB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Kp : Ctx → Prop) (W : Nat → Option WFrame) (stk : List Frame) (VBOk : (Nat → F64) → Prop)
    (hsim : StepSimZB F FR ok Kp W stk VBOk) (hloc : ∀ s S, ok s S = true → stk = [] ∨ Disp.localB s = true)
    (Z : Nat → Prop) (z : Nat → Option HObj) (ν : Nat → F64) (K : Ctx) (hK : Kp K) (hν : VBOk ν) :
    ∀ n M s S t C s' S', RelXZ F FR W stk Z z M ν K s S t C → ok s S = true → runOk F ok n s S = some (s', S') →
      ∃ M' t' C', runC F n t C = some (t', C') ∧ Ext M M' S.tab.length ∧
        RelXZ F FR W stk Z z M' ν K s' S' t' C' := by
  intro n
  induction n with
  | zero =>
    intro M s S t C s' S' hr _ h
    simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨M, t, C, rfl, Ext.refl _ _, hr⟩
  | succ n ih =>
    intro M s S t C s' S' hr hok h
    rw [runOk_succ] at h
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs] at h
        cases hk : ok s1 S1
        · simp [hk] at h
        · simp only [hk, Bool.cond_true, St.rebuild_eq] at h
          obtain ⟨M1, t1, C1, ht, he1, hr1⟩ := hsim Z z M ν K s S t C s1 S1 hK hν hr hh (hloc s S hok) hok hs
          obtain ⟨M', t', C', ht', he', hr'⟩ := ih M1 s1 S1 t1 C1 s' S' hr1 hk h
          refine ⟨M', t', C', ?_, he1.trans he' (interpS_len _ _ _ _ hs), hr'⟩
          simp only [runC, runWith_succ, hr.rel.isHalt, hh, Bool.cond_false, ht, St.rebuild_eq]
          exact ht'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine ⟨M, t, C, ?_, Ext.refl _ _, hr⟩
      simp only [runC, runWith_succ, hr.rel.isHalt, hh, Bool.cond_true]

/-! ## The frozen contract of a stage template -/

/-- **The frozen contract** of a stage template: from every isolated call state related to the
template's start and under every caller frames `r`, the run of `T.n + 1` steps reaches the isolated
return state related to the template's end under an extension of the map; the concrete table only
grows; every caller-only target entry (below the call's counter, at no image of the template's
present addresses) is unchanged; and the native state moves by `NK` (a world's frame of the
caller-only native entries, stated against the call's map and the template's native start). -/
def _root_.Host.Ts.Sim.Stage.StageTpl.HoldsZ {F : Ffi} {ok : St F.S → SSrv → Bool} (T : StageTpl F ok) (FR : Map → Nat → F.S → F.S → Prop)
    (W : Nat → Option WFrame) (Kp : Ctx → Prop) (VBOk : (Nat → F64) → Prop)
    (NK : Map → F.S → F.S → F.S → Prop) : Prop :=
  ∀ M ν K t C (r : List Frame), Kp K → VBOk ν → RelF F FR W M ν K T.s0 T.S0 t C →
    ∃ M' t' C', runC F (T.n + 1) (under t r) C = some (under t' r, C') ∧ Ext M M' T.S0.tab.length ∧
      RelF F FR W M' ν K T.s2 T.S2 t' C' ∧ CSrv.Le C C' ∧
      (∀ a, CallerOnly M T.s0 t a → t'.heap.get a = t.heap.get a) ∧ NK M T.s0.ffi t.ffi t'.ffi

/-- The frozen contract gives the base contract's `HoldsU`. -/
theorem _root_.Host.Ts.Sim.Stage.StageTpl.HoldsZ.holdsU {F : Ffi} {ok : St F.S → SSrv → Bool} {T : StageTpl F ok}
    {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {Kp : Ctx → Prop} {VBOk : (Nat → F64) → Prop}
    {NK : Map → F.S → F.S → F.S → Prop} (h : T.HoldsZ FR W Kp VBOk NK) : (T.contract FR W Kp VBOk).HoldsU := by
  rintro ⟨⟩ t C ⟨M, ν, K, hK, hν, hr⟩ r
  obtain ⟨M', t', C', hrun, he, hr', -, -, -⟩ := h M ν K t C r hK hν hr
  exact ⟨T.n + 1, t', C', ⟨M, M', ν, K, hK, hr, he, hr'⟩, hrun⟩

/-- **A frozen one-step simulation gives the frozen contract** (the caller-only native frame `NK`
supplied by the world for the template's runs). -/
theorem _root_.Host.Ts.Sim.Stage.StageTpl.holdsZ {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {ok : St F.S → SSrv → Bool}
    {Kp : Ctx → Prop} {W : Nat → Option WFrame} {VBOk : (Nat → F64) → Prop} {NK : Map → F.S → F.S → F.S → Prop}
    (T : StageTpl F ok) (hsim : ∀ r, StepSimZB F FR ok Kp W r VBOk)
    (hloc : ∀ s S, ok s S = true → Disp.localB s = true)
    (hNK : ∀ M ν K t C r M' t' C', Kp K → VBOk ν → RelF F FR W M ν K T.s0 T.S0 t C →
      runC F (T.n + 1) (under t r) C = some (under t' r, C') → RelF F FR W M' ν K T.s2 T.S2 t' C' →
      NK M T.s0.ffi t.ffi t'.ffi) :
    T.HoldsZ FR W Kp VBOk NK := by
  intro M ν K t C r hK hν h
  have hrb : RelB F FR W r M ν K T.s0 T.S0 (under t r) C := RelB.ofUnder h r
  have hz0 : RelXZ F FR W r (CallerOnly M T.s0 t) (fun a => t.heap.get a) M ν K T.s0 T.S0 (under t r) C :=
    ⟨.inl hrb, fun a ha hz => hz.2 a ha rfl, fun _ hz => hz.1, fun _ _ => rfl⟩
  obtain ⟨M1, t1, C1, hr1, he1, hx1⟩ := runOk_simZB F FR ok Kp W r VBOk (hsim r) (fun s S hs => .inr (hloc s S hs))
    _ _ ν K hK hν T.n M T.s0 T.S0 (under t r) C T.s1 T.S1 hz0 T.ok0 T.run
  obtain ⟨M2, t2, C2, ht2, he2, hx2⟩ :=
    hsim r _ _ M1 ν K T.s1 T.S1 t1 C1 T.s2 T.S2 hK hν hx1 T.halt (.inr (hloc _ _ T.ok1)) T.ok1 T.last
  have h2 := RelXB.rel_frame' hx2.rel T.top
  obtain ⟨e, h2'⟩ := RelB.strip h2
  have hth : isHalt t1.ctl = false := by rw [hx1.rel.isHalt, T.halt]
  have hrun : runC F (T.n + 1) (under t r) C = some (t2, C2) := runC_trans hr1 (runC_one hth ht2)
  have hrun' : runC F (T.n + 1) (under t r) C = some (under { t2 with stack := T.s2.stack.map M2.frame } r, C2) := by
    rw [← e]; exact hrun
  refine ⟨M2, { t2 with stack := T.s2.stack.map M2.frame }, C2, hrun',
    he1.trans he2 (interpS_runOk_len T.run), h2', runC_le _ _ _ _ _ hrun, fun a ha => ?_,
    hNK M ν K t C r M2 _ C2 hK hν h hrun' h2'⟩
  have hf := hx2.frozen a ha
  show t2.heap.get a = t.heap.get a
  exact hf

end Host.Ts.Sim.Conv
