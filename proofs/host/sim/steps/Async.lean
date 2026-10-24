import host.sim.steps.Props
namespace Host.Ts.Sim

/-! # Async functions, generators, promises and jobs

Promise, generator and AsyncLocalStorage helpers commute with the map on
present addresses: reads of promise and generator objects never meet framed
arrays (their kinds differ), writes go to present unframed addresses, and
allocations are lockstep. `Upd` collects what a helper keeps: the relation of
the results, growing presence and a bound on the addresses allocated. -/

/-- Control, stack and stores unchanged (heap, counter and jobs may change). -/
def CtlKeeps {S : Type} (s s' : St S) : Prop := s'.ctl = s.ctl ∧ s'.stack = s.stack ∧ s'.stores = s.stores

private theorem CtlKeeps.refl {S : Type} (s : St S) : CtlKeeps s s := ⟨rfl, rfl, rfl⟩

private theorem CtlKeeps.trans {S : Type} {s s1 s2 : St S} (h1 : CtlKeeps s s1) (h2 : CtlKeeps s1 s2) : CtlKeeps s s2 :=
  ⟨h2.1.trans h1.1, h2.2.1.trans h1.2.1, h2.2.2.trans h1.2.2⟩

def Map.queue (M : Map) (q : List (Nat × Comp)) : List (Nat × Comp) := q.map fun (p, c) => (M.a p, M.comp c)

private theorem Map.queue_cons (M : Map) (x : Nat × Comp) (q : List (Nat × Comp)) :
    M.queue (x :: q) = (M.a x.1, M.comp x.2) :: M.queue q := rfl

private theorem Map.obj_with_kind (M : Map) (o : Obj) (k : Kind) :
    M.obj { o with kind := k } = { M.obj o with kind := M.kind k } := by
  cases o; rfl

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {S : SSrv} {C : CSrv}

/-- What a state update keeps: the relation of the results, presence, and at most `k` allocations. -/
structure Upd (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame) (M : Map) (ν : Nat → F64) (K : Ctx)
    (S : SSrv) (C : CSrv) (s s' t' : St F.S) (k : Nat) : Prop where
  rel : RelB F FR W stk M ν K s' S t' C
  pres : ∀ a, Present s a → Present s' a
  next : s'.next ≤ s.next + k

theorem Upd.refl {s t : St F.S} (h : RelB F FR W stk M ν K s S t C) : Upd F FR W stk M ν K S C s s t 0 :=
  ⟨h, fun _ hp => hp, Nat.le_refl _⟩

theorem Upd.trans {s s1 s2 t1 t2 : St F.S} {k1 k2 : Nat} (h1 : Upd F FR W stk M ν K S C s s1 t1 k1)
    (h2 : Upd F FR W stk M ν K S C s1 s2 t2 k2) : Upd F FR W stk M ν K S C s s2 t2 (k1 + k2) :=
  ⟨h2.rel, fun a hp => h2.pres a (h1.pres a hp), by have := h1.next; have := h2.next; omega⟩

theorem Upd.weaken {s s' t' : St F.S} {k k' : Nat} (h : Upd F FR W stk M ν K S C s s' t' k) (hk : k ≤ k') :
    Upd F FR W stk M ν K S C s s' t' k' :=
  ⟨h.rel, h.pres, by have := h.next; omega⟩

theorem Upd.bound {s s' t' : St F.S} {k j : Nat} (h : Upd F FR W stk M ν K S C s s' t' k)
    (hn : s.next + (k + j) < Sim.bound) : s'.next + j < Sim.bound := by
  have := h.next; omega

/-! ## Heap reads at present addresses -/

private theorem St.obj?_none_of_cell {S' : Type} {s : St S'} {a : Nat} {v : Option Val}
    (hg : s.heap.get a = some (.cell v)) : s.obj? a = none := by
  unfold St.obj?; rw [hg]

private theorem RelB.objCases {s t : St F.S} (h : RelB F FR W stk M ν K s S t C) {a : Nat} (hp : Present s a) :
    (s.obj? a = none ∧ t.obj? (M.a a) = none) ∨
    (∃ o, s.obj? a = some o ∧ K.fr a = none ∧ t.obj? (M.a a) = some (M.obj o)) ∨
    (∃ o o' xs ys, s.obj? a = some o ∧ t.obj? (M.a a) = some o' ∧ o.kind = .array xs ∧
      o'.kind = .array ys) ∨
    (∃ o o', s.obj? a = some o ∧ t.obj? (M.a a) = some o' ∧ Wideable o.kind ∧ WTarget o'.kind ∧ W a ≠ none) := by
  obtain ⟨ho, hg⟩ := hp.get
  cases ho with
  | cell v =>
    obtain ⟨v', hv'⟩ := h.cell_target hg
    exact .inl ⟨St.obj?_none_of_cell hg, St.obj?_none_of_cell hv'⟩
  | obj o =>
    cases hfr : K.fr a with
    | none => exact .inr (.inl ⟨o, obj?_iff.2 hg, rfl, h.obj? (obj?_iff.2 hg) hfr⟩)
    | some p =>
      cases hw : W a with
      | none =>
        obtain ⟨pre, pre'⟩ := p
        obtain ⟨o', ht, xs, hk, rfl⟩ := h.obj?_framed (obj?_iff.2 hg) hfr hw
        exact .inr (.inr (.inl ⟨o, _, _, _, obj?_iff.2 hg, ht, hk, rfl⟩))
      | some w =>
        obtain ⟨o', ht, hk, hk'⟩ := h.wide_obj hg hfr hw
        exact .inr (.inr (.inr ⟨o, o', obj?_iff.2 hg, obj?_iff.2 ht, hk, hk', by simp⟩))

/-- Objects of non-array kinds no frame admits are never framed. -/
private theorem RelB.fr_of_kind {s t : St F.S} (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ es, o.kind ≠ .array es) (hw : ¬ Wideable o.kind) : K.fr a = none :=
  h.fr_none ho hk hw

/-- A non-array object where no frame of `W` matters is not framed. -/
private theorem RelB.fr_of_or {s t : St F.S} (h : RelB F FR W stk M ν K s S t C) {a : Nat} {o : Obj}
    (ho : s.obj? a = some o) (hk : ∀ es, o.kind ≠ .array es) (hw : W a = none ∨ K.fr a = none) : K.fr a = none := by
  cases hfr : K.fr a with
  | none => rfl
  | some p =>
    obtain ⟨pre, pre'⟩ := p
    obtain ⟨_, _, xs, hk', _⟩ := h.obj?_framed ho hfr (h.w_none (.of_or hw) hfr)
    exact absurd hk' (hk _)

private theorem Wideable.not_promise {k : Kind} (hk : Wideable k) (st : PState) : k ≠ .promise st := by
  intro he; rw [he] at hk; exact hk

private theorem WTarget.not_promise {k : Kind} (hk : WTarget k) (st : PState) : k ≠ .promise st := by
  rcases hk with hk | ⟨bs, rfl⟩ | ⟨kk, b, off, n, rfl⟩
  · exact Wideable.not_promise hk st
  · intro he; cases he
  · intro he; cases he

private theorem Wideable.not_gen {k : Kind} (hk : Wideable k) (st : GenState) (b : Bool) (q : List (Nat × Comp)) :
    k ≠ .gen st b q := by
  intro he; rw [he] at hk; exact hk

private theorem WTarget.not_gen {k : Kind} (hk : WTarget k) (st : GenState) (b : Bool) (q : List (Nat × Comp)) :
    k ≠ .gen st b q := by
  rcases hk with hk | ⟨bs, rfl⟩ | ⟨kk, b', off, n, rfl⟩
  · exact Wideable.not_gen hk st b q
  · intro he; cases he
  · intro he; cases he

private theorem promiseOf_none_of {S' : Type} {s : St S'} {p : Nat} {o : Obj} (h1 : s.obj? p = some o)
    (hk : ∀ st, o.kind ≠ .promise st) : promiseOf s p = none := by
  unfold promiseOf; rw [h1]
  cases hko : o.kind <;> simp_all

private theorem genOf_none_of {S' : Type} {s : St S'} {g : Nat} {o : Obj} (h1 : s.obj? g = some o)
    (hk : ∀ st b q, o.kind ≠ .gen st b q) : genOf s g = none := by
  unfold genOf; rw [h1]
  cases hko : o.kind <;> simp_all

private theorem agenQueue_nil_of {S' : Type} {s : St S'} {g : Nat} {o : Obj} (h1 : s.obj? g = some o)
    (hk : ∀ st b q, o.kind ≠ .gen st b q) : agenQueue s g = [] := by
  unfold agenQueue; rw [h1]
  cases hko : o.kind <;> simp_all

private theorem setGen_of {S' : Type} {s : St S'} {g : Nat} {o : Obj} (h1 : s.obj? g = some o)
    (hk : ∀ st b q, o.kind ≠ .gen st b q) (st : GenState) : setGen s g st = s := by
  unfold setGen; rw [h1]
  cases hko : o.kind <;> simp_all

private theorem setQueue_of {S' : Type} {s : St S'} {g : Nat} {o : Obj} (h1 : s.obj? g = some o)
    (hk : ∀ st b q, o.kind ≠ .gen st b q) (q : List (Nat × Comp)) : setQueue s g q = s := by
  unfold setQueue; rw [h1]
  cases hko : o.kind <;> simp_all

private theorem promiseOf_some {S' : Type} {s : St S'} {p : Nat} {o : Obj} {st : PState}
    (h : promiseOf s p = some (o, st)) : s.obj? p = some o ∧ o.kind = .promise st := by
  unfold promiseOf at h
  split at h
  · rename_i o' ho
    split at h
    · rename_i st' hk
      cases h
      exact ⟨ho, hk⟩
    · cases h
  · cases h

private theorem genOf_some {S' : Type} {s : St S'} {g : Nat} {st : GenState} {a : Bool}
    (h : genOf s g = some (st, a)) : ∃ o q, s.obj? g = some o ∧ o.kind = .gen st a q := by
  unfold genOf at h
  split at h
  · rename_i o ho
    split at h
    · rename_i st' a' q hk
      cases h
      exact ⟨o, q, ho, hk⟩
    · cases h
  · cases h

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

private theorem RelB.promiseOf_map {p : Nat} (hp : Present s p) :
    promiseOf t (M.a p) = (promiseOf s p).map fun x => (M.obj x.1, M.pstate x.2) := by
  rcases h.objCases hp with ⟨h1, h2⟩ | ⟨o, h1, -, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
    ⟨o, o', h1, h2, w1, w2, -⟩
  · simp only [Host.Ts.promiseOf, h1, h2, Option.map_none]
  · simp only [Host.Ts.promiseOf, h1, h2]
    cases hk : o.kind <;> simp [Map.obj, Map.kind, hk]
  · simp only [Host.Ts.promiseOf, h1, h2, k1, k2, Option.map_none]
  · rw [promiseOf_none_of h1 w1.not_promise, promiseOf_none_of h2 w2.not_promise]; rfl

private theorem RelB.isPromise_map {v : Val} (hv : Supp.val (Present s) S.tab.length v) :
    isPromise t (M.val v) = (isPromise s v).map M.a := by
  cases v with
  | obj a =>
    have hp : Present s a := hv
    simp only [Map.val, Host.Ts.isPromise, h.promiseOf_map hp]
    cases promiseOf s a <;> rfl
  | _ => rfl

private theorem RelB.genOf_map {g : Nat} (hp : Present s g) :
    genOf t (M.a g) = (genOf s g).map fun x => (M.gen x.1, x.2) := by
  rcases h.objCases hp with ⟨h1, h2⟩ | ⟨o, h1, -, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
    ⟨o, o', h1, h2, w1, w2, -⟩
  · simp only [Host.Ts.genOf, h1, h2, Option.map_none]
  · simp only [Host.Ts.genOf, h1, h2]
    cases hk : o.kind <;> simp [Map.obj, Map.kind, hk]
  · simp only [Host.Ts.genOf, h1, h2, k1, k2, Option.map_none]
  · rw [genOf_none_of h1 w1.not_gen, genOf_none_of h2 w2.not_gen]; rfl

private theorem RelB.agenQueue_map {g : Nat} (hp : Present s g) :
    agenQueue t (M.a g) = M.queue (agenQueue s g) := by
  rcases h.objCases hp with ⟨h1, h2⟩ | ⟨o, h1, -, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
    ⟨o, o', h1, h2, w1, w2, -⟩
  · simp only [Host.Ts.agenQueue, h1, h2]; rfl
  · simp only [Host.Ts.agenQueue, h1, h2]
    cases hk : o.kind <;> simp [Map.obj, Map.kind, hk, Map.queue]
  · simp only [Host.Ts.agenQueue, h1, h2, k1, k2]; rfl
  · rw [agenQueue_nil_of h1 w1.not_gen, agenQueue_nil_of h2 w2.not_gen]; rfl

private theorem RelB.promiseOf_supp {p : Nat} {o : Obj} {st : PState} (hpo : promiseOf s p = some (o, st)) :
    Supp.obj (Present s) S.tab.length o ∧ Supp.pstate (Present s) S.tab.length st := by
  obtain ⟨ho, hk⟩ := promiseOf_some hpo
  have hs := h.obj?_supp ho
  have hk' := hs.1
  rw [hk] at hk'
  exact ⟨hs, hk'⟩

private theorem RelB.genOf_supp {g : Nat} {st : GenState} {a : Bool} (hgo : genOf s g = some (st, a)) :
    Supp.gen (Present s) S.tab.length st := by
  obtain ⟨o, q, ho, hk⟩ := genOf_some hgo
  have hk' := (h.obj?_supp ho).1
  rw [hk] at hk'
  exact hk'.1

private theorem RelB.agenQueue_supp (g : Nat) :
    ∀ x ∈ agenQueue s g, Present s x.1 ∧ Supp.comp (Present s) S.tab.length x.2 := by
  intro x hx
  unfold Host.Ts.agenQueue at hx
  split at hx
  · rename_i o ho
    split at hx
    · rename_i st a q hk
      have hk' := (h.obj?_supp ho).1
      rw [hk] at hk'
      exact hk'.2 x hx
    · cases hx
  · cases hx

private theorem RelB.present_lt {a : Nat} (hp : Present s a) (hn : s.next < Sim.bound) : a < 2 ^ 64 := by
  have := h.presentBound a hp
  have hb : Sim.bound = 2 ^ 61 := rfl
  rw [hb] at hn
  omega

/-- Injectivity on present addresses, for address comparisons. -/
private theorem RelB.beq {a b : Nat} (ha : Present s a) (hb : Present s b) :
    Nat.beq (M.a a) (M.a b) = Nat.beq a b := by
  cases hab : Nat.beq a b with
  | true => rw [Nat.eq_of_beq_eq_true hab]; exact Nat.beq_refl _
  | false =>
    cases he : Nat.beq (M.a a) (M.a b) with
    | false => rfl
    | true =>
      have := h.inj a b ha hb (Nat.eq_of_beq_eq_true he)
      subst this
      rw [Nat.beq_refl] at hab
      cases hab

end

/-! ## Primitive updates -/

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

theorem upd_setObj {a : Nat} {o : Obj} (hn : s.next < Sim.bound) (ha : Present s a) (hfr : K.fr a = none)
    (ho : Supp.obj (Present s) S.tab.length o) :
    Upd F FR W stk M ν K S C s (s.setObj a o) (t.setObj (M.a a) (M.obj o)) 0 :=
  ⟨h.setObj o hn ha hfr ho, fun _ hp => Present.set _ (h.present_lt ha hn) hp, Nat.le_refl _⟩

theorem upd_setCell {a : Nat} {v : Val} (hn : s.next < Sim.bound) (ha : Present s a) (hfr : K.fr a = none)
    (hv : Supp.val (Present s) S.tab.length v) :
    Upd F FR W stk M ν K S C s (s.setCell a v) (t.setCell (M.a a) (M.val v)) 0 :=
  ⟨h.setCell v hn ha hfr hv, fun _ hp => Present.set _ (h.present_lt ha hn) hp, Nat.le_refl _⟩

theorem upd_allocObj {k : Kind} {proto : Val} {props : Props} (hn : s.next < Sim.bound)
    (hk : Supp.kind (Present s) S.tab.length k) (hpr : Supp.val (Present s) S.tab.length proto)
    (hps : Supp.props (Present s) S.tab.length props) :
    (t.allocObj (M.kind k) (M.val proto) (M.props props)).1 = M.a (s.allocObj k proto props).1 ∧
      (s.allocObj k proto props).1 = s.next ∧
      Present (s.allocObj k proto props).2 s.next ∧
      Upd F FR W stk M ν K S C s (s.allocObj k proto props).2 (t.allocObj (M.kind k) (M.val proto) (M.props props)).2 1 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  have hs64 : s.next < 2 ^ 64 := by rw [hb] at hn; omega
  have hP : ∀ a, Present s a → Present (s.allocObj k proto props).2 a := fun _ hp => Present.alloc _ hs64 hp
  obtain ⟨e, hr⟩ := h.allocObj k proto props hn (Supp.kind_mono hP (Nat.le_refl _) hk)
    (Supp.val_mono hP (Nat.le_refl _) hpr) (Supp.props_mono hP (Nat.le_refl _) hps)
  exact ⟨e, rfl, Present.alloc_next s _ hs64, hr, hP, Nat.le_refl _⟩

theorem upd_alloc {o : HObj} (hn : s.next < Sim.bound) (ho : Supp.hobj (Present s) S.tab.length o) :
    (t.alloc (M.hobj o)).1 = M.a (s.alloc o).1 ∧ (s.alloc o).1 = s.next ∧ Present (s.alloc o).2 s.next ∧
      Upd F FR W stk M ν K S C s (s.alloc o).2 (t.alloc (M.hobj o)).2 1 := by
  have hb : Sim.bound = 2 ^ 61 := rfl
  have hs64 : s.next < 2 ^ 64 := by rw [hb] at hn; omega
  have hP : ∀ a, Present s a → Present (s.alloc o).2 a := fun _ hp => Present.alloc _ hs64 hp
  obtain ⟨e, hr⟩ := h.alloc o hn (Supp.hobj_mono hP (Nat.le_refl _) ho)
  exact ⟨e, rfl, Present.alloc_next s _ hs64, hr, hP, Nat.le_refl _⟩

theorem upd_setJobs (js : List Job) (hjs : ∀ j ∈ js, Supp.job (Present s) S.tab.length j) :
    Upd F FR W stk M ν K S C s (s.setJobs js) (t.setJobs (js.map M.job)) 0 :=
  ⟨h.setJobs js hjs, fun _ hp => hp, Nat.le_refl _⟩

theorem upd_enqueue (j : Job) (hj : Supp.job (Present s) S.tab.length j) :
    Upd F FR W stk M ν K S C s (enqueue s j) (enqueue t (M.job j)) 0 := by
  have e : enqueue t (M.job j) = t.setJobs ((s.jobs ++ [j]).map M.job) := by
    simp only [enqueue, List.map_append, List.map_cons, List.map_nil, ← h.jobs]
  rw [e]
  refine upd_setJobs h _ fun j' hj' => ?_
  rcases List.mem_append.1 hj' with hj' | hj'
  · exact h.jobsSupp j' hj'
  · rw [List.mem_singleton.1 hj']; exact hj

end

theorem upd_enqueueAll (th : Bool) {v : Val} :
    ∀ (rs : List Reaction) {s t : St F.S}, RelB F FR W stk M ν K s S t C →
      (∀ r ∈ rs, Supp.reaction (Present s) S.tab.length r) → Supp.val (Present s) S.tab.length v →
      Upd F FR W stk M ν K S C s (enqueueAll s th v rs) (enqueueAll t th (M.val v) (rs.map M.reaction)) 0
  | [], _, _, h, _, _ => Upd.refl h
  | r :: rs, s, t, h, hrs, hv => by
    have u1 := upd_enqueue h ⟨r, th, v⟩ ⟨hrs r (List.mem_cons_self ..), hv⟩
    have u2 := upd_enqueueAll th rs u1.rel (fun r' hr' => hrs r' (List.mem_cons_of_mem _ hr')) hv
    exact u1.trans u2

private theorem enqueueAll_keeps {S' : Type} (th : Bool) (v : Val) :
    ∀ (rs : List Reaction) (s : St S'), CtlKeeps s (enqueueAll s th v rs)
  | [], s => CtlKeeps.refl s
  | r :: rs, s => (CtlKeeps.refl s).trans (enqueueAll_keeps th v rs (enqueue s ⟨r, th, v⟩))

/-! ## Promises -/

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

theorem upd_settle (hn : s.next < Sim.bound) {p : Nat} (hp : Present s p) (th : Bool) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) :
    Upd F FR W stk M ν K S C s (settle s p th v) (settle t (M.a p) th (M.val v)) 0 := by
  unfold settle
  rw [h.promiseOf_map hp]
  cases hpo : promiseOf s p with
  | none => exact Upd.refl h
  | some x =>
    obtain ⟨o, st⟩ := x
    obtain ⟨ho, hk⟩ := promiseOf_some hpo
    obtain ⟨hso, hst⟩ := h.promiseOf_supp hpo
    cases st with
    | pending rs =>
      have hfr : K.fr p = none := h.fr_of_kind ho (by intro es he; rw [hk] at he; cases he) (by rw [hk]; exact id)
      have e : ({ M.obj o with kind := .promise (bif th then .rejected (M.val v) else .fulfilled (M.val v)) } : Obj) =
          M.obj { o with kind := .promise (bif th then .rejected v else .fulfilled v) } := by
        rw [Map.obj_with_kind]; cases th <;> rfl
      simp only [Option.map, Map.pstate]
      rw [e]
      have hnew : Supp.obj (Present s) S.tab.length { o with kind := .promise (bif th then .rejected v else .fulfilled v) } :=
        ⟨by cases th <;> exact hv, hso.2.1, hso.2.2.1, hso.2.2.2⟩
      have u1 := upd_setObj h hn hp hfr hnew
      have u2 := upd_enqueueAll th rs u1.rel (fun r hr => Supp.reaction_mono u1.pres (Nat.le_refl _) (hst r hr))
        (Supp.val_mono u1.pres (Nat.le_refl _) hv)
      exact u1.trans u2
    | fulfilled _ => exact Upd.refl h
    | rejected _ => exact Upd.refl h

theorem upd_react (hn : s.next < Sim.bound) {p : Nat} (hp : Present s p) {r : Reaction}
    (hr : Supp.reaction (Present s) S.tab.length r) :
    Upd F FR W stk M ν K S C s (react s p r) (react t (M.a p) (M.reaction r)) 0 := by
  unfold react
  rw [h.promiseOf_map hp]
  cases hpo : promiseOf s p with
  | none => exact Upd.refl h
  | some x =>
    obtain ⟨o, st⟩ := x
    obtain ⟨ho, hk⟩ := promiseOf_some hpo
    obtain ⟨hso, hst⟩ := h.promiseOf_supp hpo
    cases st with
    | pending rs =>
      have hfr : K.fr p = none := h.fr_of_kind ho (by intro es he; rw [hk] at he; cases he) (by rw [hk]; exact id)
      have e : ({ M.obj o with kind := .promise (.pending (rs.map M.reaction ++ [M.reaction r])) } : Obj) =
          M.obj { o with kind := .promise (.pending (rs ++ [r])) } := by
        cases o; simp only [Map.obj, Map.kind, Map.pstate, List.map_append, List.map_cons, List.map_nil]
      simp only [Option.map, Map.pstate]
      rw [e]
      refine upd_setObj h hn hp hfr ⟨fun r' hr' => ?_, hso.2.1, hso.2.2.1, hso.2.2.2⟩
      rcases List.mem_append.1 hr' with hr' | hr'
      · exact hst r' hr'
      · rw [List.mem_singleton.1 hr']; exact hr
    | fulfilled v => exact upd_enqueue h ⟨r, false, v⟩ ⟨hr, hst⟩
    | rejected v => exact upd_enqueue h ⟨r, true, v⟩ ⟨hr, hst⟩

theorem upd_resolveP (hn : s.next < Sim.bound) {p : Nat} (hp : Present s p) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) :
    Upd F FR W stk M ν K S C s (resolveP s p v) (resolveP t (M.a p) (M.val v)) 0 := by
  unfold resolveP
  rw [h.isPromise_map hv]
  cases hip : isPromise s v with
  | none => exact upd_settle h hn hp false hv
  | some q =>
    have hq : Present s q := by
      cases v with
      | obj a =>
        simp only [Host.Ts.isPromise] at hip
        cases hpo : promiseOf s a <;> rw [hpo] at hip <;> cases hip
        exact hv
      | _ => cases hip
    simp only [Option.map]
    rw [h.beq hp hq]
    cases Nat.beq p q
    · exact upd_enqueue h ⟨.adopt p, false, v⟩ ⟨hp, hv⟩
    · exact Upd.refl h

theorem upd_newPromise (hpp : Present s aPromiseProto)
    (hn : s.next < Sim.bound) :
    (newPromise t).1 = M.a (newPromise s).1 ∧ (newPromise s).1 = s.next ∧
      Present (newPromise s).2 (newPromise s).1 ∧
      Upd F FR W stk M ν K S C s (newPromise s).2 (newPromise t).2 1 := by
  obtain ⟨e1, e2, hp, u⟩ := upd_allocObj h (k := .promise (.pending [])) (proto := .obj aPromiseProto)
    (props := []) hn (fun _ hr => nomatch hr) hpp (fun _ hx => nomatch hx)
  have e : M.val (.obj aPromiseProto) = .obj aPromiseProto := by
    show Val.obj (M.a aPromiseProto) = _; rw [h.intr _ (by decide)]
  rw [e] at e1 u
  exact ⟨e1, e2, e2 ▸ hp, u⟩

omit h in
private theorem isPromise_eq {S' : Type} {s : St S'} {v : Val} {q : Nat} (hip : isPromise s v = some q) :
    v = .obj q := by
  cases v with
  | obj a =>
    simp only [Host.Ts.isPromise] at hip
    cases hpo : promiseOf s a <;> rw [hpo] at hip <;> cases hip
    rfl
  | _ => cases hip

theorem upd_promiseFor (hpp : Present s aPromiseProto)
    (hn : s.next + 1 < Sim.bound) {v : Val} (hv : Supp.val (Present s) S.tab.length v) :
    (promiseFor t (M.val v)).1 = M.a (promiseFor s v).1 ∧ Present (promiseFor s v).2 (promiseFor s v).1 ∧
      Upd F FR W stk M ν K S C s (promiseFor s v).2 (promiseFor t (M.val v)).2 1 := by
  unfold promiseFor
  rw [h.isPromise_map hv]
  cases hip : isPromise s v with
  | some q =>
    have hq : Present s q := by rw [isPromise_eq hip] at hv; exact hv
    exact ⟨rfl, hq, (Upd.refl h).weaken (Nat.zero_le _)⟩
  | none =>
    obtain ⟨e1, -, hp, u⟩ := upd_newPromise h hpp (by omega)
    have hn1 : (newPromise s).2.next < Sim.bound := u.bound (j := 0) (by omega)
    have u2 := upd_settle u.rel hn1 hp false (Supp.val_mono u.pres (Nat.le_refl _) hv)
    have et : newPromise t = (M.a (newPromise s).1, (newPromise t).2) := by rw [← e1]
    simp only [Option.map]
    rw [et]
    exact ⟨rfl, u2.pres _ hp, u.trans u2⟩

theorem upd_iterResult (hpo : Present s aObjectProto)
    (hn : s.next < Sim.bound) {v : Val} (hv : Supp.val (Present s) S.tab.length v) (done : Bool) :
    (iterResult t (M.val v) done).1 = M.a (iterResult s v done).1 ∧
      Present (iterResult s v done).2 (iterResult s v done).1 ∧
      Upd F FR W stk M ν K S C s (iterResult s v done).2 (iterResult t (M.val v) done).2 1 := by
  have hps : Supp.props (Present s) S.tab.length
      [(.str ['v','a','l','u','e'], .data v true true), (.str ['d','o','n','e'], .data (.bool done) true true)] := by
    intro x hx
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hx
    rcases hx with rfl | rfl
    · exact ⟨trivial, hv⟩
    · exact ⟨trivial, trivial⟩
  obtain ⟨e1, e2, hp, u⟩ := upd_allocObj h (k := .ordinary) (proto := .obj aObjectProto) hn trivial hpo hps
  have e : M.val (.obj aObjectProto) = .obj aObjectProto := by
    show Val.obj (M.a aObjectProto) = _; rw [h.intr _ (by decide)]
  rw [e] at e1 u
  exact ⟨e1, e2 ▸ hp, u⟩

theorem upd_setGen (hn : s.next < Sim.bound) {g : Nat} (hg : Present s g) {st : GenState}
    (hst : Supp.gen (Present s) S.tab.length st) :
    Upd F FR W stk M ν K S C s (setGen s g st) (setGen t (M.a g) (M.gen st)) 0 := by
  rcases h.objCases hg with ⟨h1, h2⟩ | ⟨o, h1, hfr, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
    ⟨o, o', h1, h2, w1, w2, -⟩
  rotate_left 3
  · rw [setGen_of h1 w1.not_gen, setGen_of h2 w2.not_gen]; exact Upd.refl h
  · simp only [setGen, h1, h2]; exact Upd.refl h
  · have hso := h.obj?_supp h1
    cases hk : o.kind with
    | gen st0 a q =>
      have hk' : (M.obj o).kind = .gen (M.gen st0) a (M.queue q) := by
        simp only [Map.obj, hk]; rfl
      simp only [setGen, h1, h2, hk, hk']
      have e : ({ M.obj o with kind := .gen (M.gen st) a (M.queue q) } : Obj) =
          M.obj { o with kind := .gen st a q } := by rw [Map.obj_with_kind]; rfl
      rw [e]
      have hk2 := hso.1
      rw [hk] at hk2
      exact upd_setObj h hn hg hfr ⟨⟨hst, hk2.2⟩, hso.2.1, hso.2.2.1, hso.2.2.2⟩
    | _ => simp only [setGen, h1, h2, hk, Map.obj, Map.kind]; exact Upd.refl h
  · simp only [setGen, h1, h2, k1, k2]; exact Upd.refl h

theorem upd_setQueue (hn : s.next < Sim.bound) {g : Nat} (hg : Present s g) {q : List (Nat × Comp)}
    (hq : ∀ x ∈ q, Present s x.1 ∧ Supp.comp (Present s) S.tab.length x.2) :
    Upd F FR W stk M ν K S C s (setQueue s g q) (setQueue t (M.a g) (M.queue q)) 0 := by
  rcases h.objCases hg with ⟨h1, h2⟩ | ⟨o, h1, hfr, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
    ⟨o, o', h1, h2, w1, w2, -⟩
  rotate_left 3
  · rw [setQueue_of h1 w1.not_gen, setQueue_of h2 w2.not_gen]; exact Upd.refl h
  · simp only [setQueue, h1, h2]; exact Upd.refl h
  · have hso := h.obj?_supp h1
    cases hk : o.kind with
    | gen st0 a q0 =>
      have hk' : (M.obj o).kind = .gen (M.gen st0) a (M.queue q0) := by
        simp only [Map.obj, hk]; rfl
      simp only [setQueue, h1, h2, hk, hk']
      have e : ({ M.obj o with kind := .gen (M.gen st0) a (M.queue q) } : Obj) =
          M.obj { o with kind := .gen st0 a q } := by rw [Map.obj_with_kind]; rfl
      rw [e]
      have hk2 := hso.1
      rw [hk] at hk2
      exact upd_setObj h hn hg hfr ⟨⟨hk2.1, hq⟩, hso.2.1, hso.2.2.1, hso.2.2.2⟩
    | _ => simp only [setQueue, h1, h2, hk, Map.obj, Map.kind]; exact Upd.refl h
  · simp only [setQueue, h1, h2, k1, k2]; exact Upd.refl h

end

/-! ## What helpers keep -/

section
variable {S' : Type}

private theorem setObj_keeps (s : St S') (a : Nat) (o : Obj) : CtlKeeps s (s.setObj a o) := ⟨rfl, rfl, rfl⟩
private theorem alloc_keeps (s : St S') (o : HObj) : CtlKeeps s (s.alloc o).2 := ⟨rfl, rfl, rfl⟩
private theorem setCell_keeps (s : St S') (a : Nat) (v : Val) : CtlKeeps s (s.setCell a v) := ⟨rfl, rfl, rfl⟩
private theorem enqueue_keeps (s : St S') (j : Job) : CtlKeeps s (enqueue s j) := ⟨rfl, rfl, rfl⟩

private theorem settle_keeps (s : St S') (p : Nat) (th : Bool) (v : Val) : CtlKeeps s (settle s p th v) := by
  unfold settle
  split
  · exact (setObj_keeps s _ _).trans (enqueueAll_keeps th v _ _)
  · exact CtlKeeps.refl s

private theorem resolveP_keeps (s : St S') (p : Nat) (v : Val) : CtlKeeps s (resolveP s p v) := by
  unfold resolveP
  split
  · cases Nat.beq p _
    · exact enqueue_keeps s _
    · exact CtlKeeps.refl s
  · exact settle_keeps s p false v

private theorem react_keeps (s : St S') (p : Nat) (r : Reaction) : CtlKeeps s (react s p r) := by
  unfold react
  split
  · exact setObj_keeps s _ _
  · exact enqueue_keeps s _
  · exact enqueue_keeps s _
  · exact CtlKeeps.refl s

private theorem newPromise_keeps (s : St S') : CtlKeeps s (newPromise s).2 := ⟨rfl, rfl, rfl⟩

private theorem promiseFor_keeps (s : St S') (v : Val) : CtlKeeps s (promiseFor s v).2 := by
  unfold promiseFor
  split
  · exact CtlKeeps.refl s
  · exact (newPromise_keeps s).trans (settle_keeps _ _ _ _)

private theorem iterResult_keeps (s : St S') (v : Val) (d : Bool) : CtlKeeps s (iterResult s v d).2 := ⟨rfl, rfl, rfl⟩

private theorem setGen_keeps (s : St S') (g : Nat) (st : GenState) : CtlKeeps s (setGen s g st) := by
  unfold setGen
  split
  · split
    · exact setObj_keeps s _ _
    · exact CtlKeeps.refl s
  · exact CtlKeeps.refl s

private theorem setQueue_keeps (s : St S') (g : Nat) (q : List (Nat × Comp)) : CtlKeeps s (setQueue s g q) := by
  unfold setQueue
  split
  · split
    · exact setObj_keeps s _ _
    · exact CtlKeeps.refl s
  · exact CtlKeeps.refl s

end

/-! ## Suspension -/

private theorem isSuspBoundary_map (M : Map) (f : Frame) : isSuspBoundary (M.frame f) = isSuspBoundary f := by
  cases f with
  | k f =>
    cases f with
    | fn b => cases b <;> rfl
    | _ => rfl
  | _ => rfl

private theorem isSuspBoundary_eq {f : Frame} (hf : isSuspBoundary f = true) :
    (∃ q, f = .k (.fn (.async q))) ∨ (∃ g, f = .k (.fn (.gen g))) := by
  cases f with
  | k f =>
    cases f with
    | fn b =>
      cases b with
      | async q => exact .inl ⟨q, rfl⟩
      | gen g => exact .inr ⟨g, rfl⟩
      | _ => cases hf
    | _ => cases hf
  | _ => cases hf

private theorem splitSusp_map (M : Map) : ∀ (fs acc : List Frame),
    splitSusp (acc.map M.frame) (fs.map M.frame) =
      (splitSusp acc fs).map fun x => (x.1.map M.frame, M.frame x.2.1, x.2.2.map M.frame)
  | [], _ => rfl
  | f :: fs, acc => by
    simp only [List.map_cons, splitSusp, isSuspBoundary_map]
    cases isSuspBoundary f
    · simp only [Bool.cond_false]
      rw [← List.map_cons, splitSusp_map M fs (f :: acc)]
    · simp only [Bool.cond_true, Option.map, List.map_reverse, List.map_cons]

private theorem splitSusp_map_nil (M : Map) (fs : List Frame) :
    splitSusp [] (fs.map M.frame) =
      (splitSusp [] fs).map fun x => (x.1.map M.frame, M.frame x.2.1, x.2.2.map M.frame) :=
  splitSusp_map M fs []

private theorem splitSusp_mem : ∀ (fs acc : List Frame) {a : List Frame} {b : Frame} {c : List Frame},
    splitSusp acc fs = some (a, b, c) →
      (∀ x ∈ a, x ∈ acc ∨ x ∈ fs) ∧ b ∈ fs ∧ (∀ x ∈ c, x ∈ fs) ∧ isSuspBoundary b = true
  | [], _, _, _, _, hs => by cases hs
  | f :: fs, acc, a, b, c, hs => by
    simp only [splitSusp] at hs
    cases hb : isSuspBoundary f
    · rw [hb] at hs
      simp only [Bool.cond_false] at hs
      obtain ⟨ha, hb', hc, hbd⟩ := splitSusp_mem fs (f :: acc) hs
      refine ⟨fun x hx => ?_, List.mem_cons_of_mem _ hb', fun x hx => List.mem_cons_of_mem _ (hc x hx), hbd⟩
      rcases ha x hx with hx | hx
      · rcases List.mem_cons.1 hx with rfl | hx
        · exact .inr (List.mem_cons_self ..)
        · exact .inl hx
      · exact .inr (List.mem_cons_of_mem _ hx)
    · rw [hb] at hs
      simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at hs
      obtain ⟨rfl, rfl, rfl⟩ := hs
      refine ⟨fun x hx => ?_, List.mem_cons_self .., fun x hx => List.mem_cons_of_mem _ hx, hb⟩
      rw [List.mem_reverse] at hx
      rcases List.mem_cons.1 hx with rfl | hx
      · exact .inr (List.mem_cons_self ..)
      · exact .inl hx

private theorem nearestGen_map (M : Map) : ∀ fs : List Frame,
    nearestGen (fs.map M.frame) = (nearestGen fs).map fun x => (M.a x.1, x.2)
  | [] => rfl
  | f :: fs => by
    cases f with
    | k f =>
      cases f with
      | fn b => cases b <;> rfl
      | _ => simp only [List.map_cons, Map.frame, Map.fnF, nearestGen]; exact nearestGen_map M fs
    | _ => simp only [List.map_cons, Map.frame, nearestGen]; exact nearestGen_map M fs

private theorem nearestGen_append (stk : List Frame) : ∀ {xs : List Frame} {x : Nat × Bool},
    nearestGen xs = some x → nearestGen (xs ++ stk) = some x
  | [], _, h => by cases h
  | f :: xs, x, h => by
    cases f with
    | k f =>
      cases f with
      | fn bd => cases bd <;> first | exact h | simp [nearestGen] at h
      | _ => exact nearestGen_append stk (xs := xs) (by simpa [nearestGen] using h)
    | _ => exact nearestGen_append stk (xs := xs) (by simpa [nearestGen] using h)

private theorem splitSusp_append (stk : List Frame) : ∀ {xs acc a : List Frame} {b : Frame} {c : List Frame},
    splitSusp acc xs = some (a, b, c) → splitSusp acc (xs ++ stk) = some (a, b, c ++ stk)
  | [], _, _, _, _, h => by cases h
  | f :: xs, acc, a, b, c, h => by
    simp only [splitSusp, List.cons_append] at h ⊢
    cases hb : isSuspBoundary f
    · rw [hb] at h
      simp only [Bool.cond_false] at h ⊢
      exact splitSusp_append stk h
    · rw [hb] at h
      simp only [Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h ⊢
      obtain ⟨rfl, rfl, rfl⟩ := h
      exact ⟨rfl, rfl, rfl⟩

/-- A function boundary frame. -/
def isFnF : Frame → Bool
  | .k (.fn _) => true
  | _ => false

/-- Some frame of the list is a function boundary. -/
def fnB (fs : List Frame) : Bool := fs.any isFnF

theorem fnB_map (M : Map) (fs : List Frame) : fnB (fs.map M.frame) = fnB fs := by
  unfold fnB
  rw [List.any_map]
  congr 1
  funext f
  cases f with
  | k g => cases g <;> rfl
  | _ => rfl

/-- `nearestGen` stops at the first function boundary. -/
theorem nearestGen_append_fn (stk : List Frame) : ∀ {xs : List Frame}, fnB xs = true →
    nearestGen (xs ++ stk) = nearestGen xs
  | [], h => by cases h
  | f :: xs, h => by
    cases f with
    | k g =>
      cases g with
      | fn bd => cases bd <;> rfl
      | _ => exact nearestGen_append_fn stk (xs := xs) (by simpa [fnB, isFnF] using h)
    | _ => exact nearestGen_append_fn stk (xs := xs) (by simpa [fnB, isFnF] using h)

private theorem nearestGen_mem : ∀ {fs : List Frame} {g : Nat} {b : Bool},
    nearestGen fs = some (g, b) → Frame.k (.fn (.gen g)) ∈ fs
  | [], _, _, h => by cases h
  | f :: fs, g, b, h => by
    cases f with
    | k f =>
      cases f with
      | fn bd =>
        cases bd with
        | gen g' =>
          simp only [nearestGen, Option.some.injEq, Prod.mk.injEq] at h
          rw [h.1]; exact List.mem_cons_self ..
        | _ => cases h
      | _ => exact List.mem_cons_of_mem _ (nearestGen_mem (fs := fs) (by simpa [nearestGen] using h))
    | _ => exact List.mem_cons_of_mem _ (nearestGen_mem (fs := fs) (by simpa [nearestGen] using h))

/-! ## Control and stack updates as `Upd` -/

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

theorem upd_push (f : Frame) (hf : Supp.frame (Present s) S.tab.length f) :
    Upd F FR W stk M ν K S C s (s.push f) (t.push (M.frame f)) 0 :=
  ⟨h.push f hf, fun _ hp => hp, Nat.le_refl _⟩

theorem upd_ret (v : Val) (hv : Supp.val (Present s) S.tab.length v) :
    Upd F FR W stk M ν K S C s (s.ret v) (t.ret (M.val v)) 0 :=
  ⟨h.ret v hv, fun _ hp => hp, Nat.le_refl _⟩

theorem upd_go (c : Ctl) (hc : Supp.ctl (Present s) S.tab.length c) :
    Upd F FR W stk M ν K S C s (s.go c) (t.go (M.ctl c)) 0 :=
  ⟨h.go c hc, fun _ hp => hp, Nat.le_refl _⟩

theorem upd_restack (fs : List Frame) (hfs : ∀ f ∈ fs, Supp.frame (Present s) S.tab.length f) :
    Upd F FR W stk M ν K S C s { s with stack := fs } { t with stack := fs.map M.frame ++ stk } 0 :=
  ⟨h.restack fs hfs, fun _ hp => hp, Nat.le_refl _⟩

theorem upd_setStores (ss : List (Nat × Val)) (hss : Supp.stores (Present s) S.tab.length ss) :
    Upd F FR W stk M ν K S C s (s.setStores ss) (t.setStores (M.stores ss)) 0 :=
  ⟨h.setStores ss hss, fun _ hp => hp, Nat.le_refl _⟩

/-- Fresh addresses are never framed. -/
private theorem RelB.fr_above {a : Nat} (ha : s.next ≤ a) : K.fr a = none := by
  cases hf : K.fr a with
  | none => rfl
  | some p => exact absurd (h.presentBound _ (h.framedPresent _ _ hf)) (by omega)

end

/-! ## Block entry -/

private theorem pair_eta {α β : Type} (p : α × β) : p = (p.1, p.2) := rfl

private theorem keeps_allocCells {S' : Type} : ∀ (ns : List Name) (s : St S') (env : Env),
    CtlKeeps s (allocCells s ns env).2
  | [], s, _ => CtlKeeps.refl s
  | _ :: ns, s, _ => (alloc_keeps s _).trans (keeps_allocCells ns _ _)

theorem upd_allocCells : ∀ (ns : List Name) {s t : St F.S} {env : Env}, RelB F FR W stk M ν K s S t C →
    s.next + ns.length < Sim.bound → Supp.env (Present s) S.tab.length env →
    (∀ x ∈ env, K.fr x.2 = none) →
    (allocCells t ns (M.env env)).1 = M.env (allocCells s ns env).1 ∧
      Supp.env (Present (allocCells s ns env).2) S.tab.length (allocCells s ns env).1 ∧
      (∀ x ∈ (allocCells s ns env).1, K.fr x.2 = none) ∧
      Upd F FR W stk M ν K S C s (allocCells s ns env).2 (allocCells t ns (M.env env)).2 ns.length
  | [], _, _, _, h, _, he, hf => ⟨rfl, he, hf, Upd.refl h⟩
  | n :: ns, s, t, env, h, hn, he, hf => by
    obtain ⟨e1, e2, hp, u⟩ := upd_alloc h (o := .cell none) (by simp only [List.length_cons] at hn; omega) trivial
    have e0 : M.hobj (.cell none) = .cell none := rfl
    rw [e0] at e1 u
    have hfr0 : K.fr s.next = none := h.fr_above (Nat.le_refl _)
    have he' : Supp.env (Present (s.alloc (.cell none)).2) S.tab.length ((n, (s.alloc (.cell none)).1) :: env) := by
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · rw [e2]; exact hp
      · exact u.pres _ (he x hx)
    have hf' : ∀ x ∈ ((n, (s.alloc (.cell none)).1) :: env), K.fr x.2 = none := by
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx
      · rw [e2]; exact hfr0
      · exact hf x hx
    have hn' : (s.alloc (.cell none)).2.next + ns.length < Sim.bound := by
      have := u.next; simp only [List.length_cons] at hn; omega
    obtain ⟨r1, r2, r3, u2⟩ := upd_allocCells ns u.rel hn' he' hf'
    have es : allocCells s (n :: ns) env =
        allocCells (s.alloc (.cell none)).2 ns ((n, (s.alloc (.cell none)).1) :: env) := rfl
    have et : allocCells t (n :: ns) (M.env env) =
        allocCells (t.alloc (.cell none)).2 ns (M.env ((n, (s.alloc (.cell none)).1) :: env)) := by
      show allocCells (t.alloc (.cell none)).2 ns ((n, (t.alloc (.cell none)).1) :: M.env env) = _
      rw [e1]; rfl
    rw [es, et]
    exact ⟨r1, r2, r3, (u.trans u2).weaken (by simp only [List.length_cons]; omega)⟩

/-- `initFuncs` by its equations (its definition recurses through the AST's `brecOn`). -/
private theorem initFuncs_cases {S' : Type} (s : St S') (env : Env) (st : Stmt) (ss : List Stmt) :
    (∃ n ps r body as gn props, st = .func (.mk (some n) ps r body as gn props) ∧
      initFuncs s env (st :: ss) = match lookupEnv n env with
        | some c => initFuncs ((closureObj s (.mk (some n) ps r body as gn props) env false .undef).2.setCell c
            (.obj (closureObj s (.mk (some n) ps r body as gn props) env false .undef).1)) env ss
        | none => initFuncs s env ss) ∨
    initFuncs s env (st :: ss) = initFuncs s env ss := by
  by_cases hst : ∃ n ps r body as gn props, st = .func (.mk (some n) ps r body as gn props)
  · obtain ⟨n, ps, r, body, as, gn, props, rfl⟩ := hst
    refine .inl ⟨n, ps, r, body, as, gn, props, rfl, ?_⟩
    rw [initFuncs.eq_2]
    rfl
  · exact .inr (initFuncs.eq_3 _ _ _ _ fun n ps r body as gn props he =>
      hst ⟨n, ps, r, body, as, gn, props, he⟩)

private theorem keeps_initFuncs {S' : Type} (env : Env) : ∀ (ss : List Stmt) (s : St S'),
    CtlKeeps s (initFuncs s env ss)
  | [], s => by rw [initFuncs.eq_1]; exact CtlKeeps.refl s
  | st :: ss, s => by
    rcases initFuncs_cases s env st ss with ⟨n, ps, r, body, as, gn, props, -, e⟩ | e
    · rw [e]
      split
      · rename_i c _
        exact (alloc_keeps s _).trans ((setCell_keeps _ c _).trans (keeps_initFuncs env ss _))
      · exact keeps_initFuncs env ss s
    · rw [e]; exact keeps_initFuncs env ss s

private theorem lookupEnv_some_mem {n : Name} {c : Nat} : ∀ {env : Env}, lookupEnv n env = some c → ∃ x ∈ env, x.2 = c
  | [], hl => by cases hl
  | (m, a) :: env, hl => by
    change brec (Nat.beq (pack n) (pack m)) (some a) (lookupEnv n env) = some c at hl
    cases hb : Nat.beq (pack n) (pack m)
    · rw [hb] at hl
      obtain ⟨x, hx, hx2⟩ := lookupEnv_some_mem hl
      exact ⟨x, List.mem_cons_of_mem _ hx, hx2⟩
    · rw [hb] at hl
      exact ⟨(m, a), List.mem_cons_self .., Option.some.inj hl⟩

theorem upd_initFuncs {env : Env} (hfr : ∀ x ∈ env, K.fr x.2 = none) :
    ∀ (ss : List Stmt) {s t : St F.S}, RelB F FR W stk M ν K s S t C → Present s aFunctionProto →
      s.next + ss.length < Sim.bound → Supp.env (Present s) S.tab.length env →
      Upd F FR W stk M ν K S C s (initFuncs s env ss) (initFuncs t (M.env env) ss) ss.length
  | [], s, t, h, _, _, _ => by rw [initFuncs.eq_1, initFuncs.eq_1]; exact Upd.refl h
  | st :: ss, s, t, h, hfp, hn, he => by
    simp only [List.length_cons] at hn
    by_cases hst : ∃ n ps r body as gn props, st = .func (.mk (some n) ps r body as gn props)
    · obtain ⟨n, ps, r, body, as, gn, props, rfl⟩ := hst
      rw [initFuncs.eq_2, initFuncs.eq_2, lookupEnv_map]
      cases hl : lookupEnv n env with
      | none =>
        simp only [Option.map]
        exact (upd_initFuncs hfr ss h hfp (by omega) he).weaken (by simp)
      | some c =>
        simp only [Option.map]
        obtain ⟨x, hx, hx2⟩ := lookupEnv_some_mem hl
        have hc : Present s c := hx2 ▸ he x hx
        have hfc : K.fr c = none := hx2 ▸ hfr x hx
        let f : Func := .mk (some n) ps r body as gn props
        obtain ⟨e1, e2, hp, u⟩ := upd_allocObj h (k := .fn (.closure f env false .undef))
          (proto := .obj aFunctionProto) (props := []) (by omega) ⟨he, trivial⟩ hfp (fun _ hx => nomatch hx)
        have ep : M.val (.obj aFunctionProto) = .obj aFunctionProto := by
          show Val.obj (M.a aFunctionProto) = _; rw [h.intr _ (by decide)]
        rw [ep] at e1 u
        have e1' : (closureObj t f (M.env env) false .undef).1 = M.a (closureObj s f env false .undef).1 := e1
        have u : Upd F FR W stk M ν K S C s (closureObj s f env false .undef).2
            (closureObj t f (M.env env) false .undef).2 1 := u
        have hp : Present (closureObj s f env false .undef).2 (closureObj s f env false .undef).1 := hp
        have ec : closureObj t f (M.env env) false .undef =
            (M.a (closureObj s f env false .undef).1, (closureObj t f (M.env env) false .undef).2) := by
          rw [← e1']
        rw [pair_eta (closureObj s f env false .undef), ec]
        have hn1 : (closureObj s f env false .undef).2.next < Sim.bound := u.bound (j := 0) (by omega)
        have u2 := upd_setCell u.rel hn1 (u.pres _ hc) hfc (v := .obj (closureObj s f env false .undef).1)
          hp
        have hn2 : ((closureObj s f env false .undef).2.setCell c (.obj (closureObj s f env false .undef).1)).next
            + ss.length < Sim.bound := by
          have := u.next; have := u2.next; omega
        have u3 := upd_initFuncs hfr ss u2.rel (u2.pres _ (u.pres _ hfp)) hn2
          (Supp.env_mono (fun a ha => u2.pres a (u.pres a ha)) (Nat.le_refl _) he)
        exact ((u.trans u2).trans u3).weaken (by simp; omega)
    · have hne : ∀ n ps r body as gn props, st = .func (.mk (some n) ps r body as gn props) → False :=
        fun n ps r body as gn props he => hst ⟨n, ps, r, body, as, gn, props, he⟩
      rw [initFuncs.eq_3 _ _ _ _ hne, initFuncs.eq_3 _ _ _ _ hne]
      exact (upd_initFuncs hfr ss h hfp (by omega) he).weaken (by simp)

theorem upd_hoist {ss : List Stmt} {env : Env}
    (hfr : ∀ x ∈ env, K.fr x.2 = none) {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
    (hfp : Present s aFunctionProto) (hn : s.next + ((blockNames ss).length + ss.length) < Sim.bound)
    (he : Supp.env (Present s) S.tab.length env) :
    (hoist t ss (M.env env)).1 = M.env (hoist s ss env).1 ∧
      Supp.env (Present (hoist s ss env).2) S.tab.length (hoist s ss env).1 ∧
      Upd F FR W stk M ν K S C s (hoist s ss env).2 (hoist t ss (M.env env)).2 ((blockNames ss).length + ss.length) := by
  unfold hoist
  cases hb : blockNames ss with
  | nil => exact ⟨rfl, he, (Upd.refl h).weaken (Nat.zero_le _)⟩
  | cons n ns =>
    rw [hb] at hn
    obtain ⟨r1, r2, r3, u⟩ := upd_allocCells (n :: ns) h (by omega) he hfr
    dsimp only
    rw [pair_eta (allocCells s (n :: ns) env), pair_eta (allocCells t (n :: ns) (M.env env)), r1]
    have hn1 : (allocCells s (n :: ns) env).2.next + ss.length < Sim.bound := by have := u.next; omega
    have u2 := upd_initFuncs r3 ss u.rel (u.pres _ hfp) hn1 r2
    exact ⟨rfl, Supp.env_mono u2.pres (Nat.le_refl _) r2, u.trans u2⟩

theorem upd_enterBlock {ss : List Stmt} {env : Env}
    (hfr : ∀ x ∈ env, K.fr x.2 = none) {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
    (hfp : Present s aFunctionProto) (hn : s.next + ((blockNames ss).length + ss.length) < Sim.bound)
    (he : Supp.env (Present s) S.tab.length env) :
    Upd F FR W stk M ν K S C s (enterBlock s ss env) (enterBlock t ss (M.env env))
      ((blockNames ss).length + ss.length) := by
  obtain ⟨r1, r2, u⟩ := upd_hoist hfr h hfp hn he
  unfold enterBlock
  rw [pair_eta (hoist s ss env), pair_eta (hoist t ss (M.env env)), r1]
  have u1 := upd_push u.rel (.s (.scope [])) (fun _ hx => nomatch hx)
  have u2 := upd_push u1.rel (.s (.block ss (hoist s ss env).1)) r2
  have u3 := upd_ret u2.rel .undef trivial
  exact ((u.trans u1).trans (u2.trans u3)).weaken (by omega)

/-! ## Async generators -/

/-- What `agenDrain` needs of a generator about to start its body: few hoisted
names and function declarations (allocations), and an unframed environment. -/
def StartOK (K : Ctx) (body : List Stmt) (env : Env) : Prop :=
  (blockNames body).length + body.length ≤ 2 ^ 20 ∧ ∀ x ∈ env, K.fr x.2 = none

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- `iterResult` then `resolveP` of the result into `p`, then `ret undefined` (a settled request). -/
theorem upd_resolveIter (hpo : Present s aObjectProto)
    (hn : s.next + 1 < Sim.bound) {p : Nat} (hp : Present s p) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) (d : Bool) :
    Upd F FR W stk M ν K S C s ((resolveP (iterResult s v d).2 p (.obj (iterResult s v d).1)).ret .undef)
      ((resolveP (iterResult t (M.val v) d).2 (M.a p) (.obj (iterResult t (M.val v) d).1)).ret .undef) 1 := by
  obtain ⟨e1, hr, u1⟩ := upd_iterResult h hpo (by omega) hv d
  have u2 := upd_resolveP u1.rel (u1.bound (j := 0) (by omega)) (u1.pres _ hp) (v := .obj (iterResult s v d).1) hr
  have u3 := upd_ret u2.rel .undef trivial
  rw [e1]
  exact (u1.trans (u2.trans u3)).weaken (by omega)

theorem upd_agenDrain (hpo : Present s aObjectProto)
    (hfp : Present s aFunctionProto) (hn : s.next + 2 ^ 21 < Sim.bound) {g : Nat} (hg : Present s g)
    (hstart : ∀ body env, genOf s g = some (.start body env, true) → StartOK K body env) :
    Upd F FR W stk M ν K S C s (agenDrain s g) (agenDrain t (M.a g)) (2 ^ 21) := by
  have hs : s.next < Sim.bound := by omega
  have hdef : Upd F FR W stk M ν K S C s (s.ret .undef) (t.ret .undef) (2 ^ 21) :=
    (upd_ret h .undef trivial).weaken (Nat.zero_le _)
  have hqs := h.agenQueue_supp g
  unfold agenDrain
  rw [h.genOf_map hg, h.agenQueue_map hg]
  cases hgo : genOf s g with
  | none => exact hdef
  | some x =>
    obtain ⟨st, a⟩ := x
    have hst := h.genOf_supp hgo
    cases hq : agenQueue s g with
    | nil => cases st <;> cases a <;> exact hdef
    | cons x q =>
      obtain ⟨p, c⟩ := x
      rw [hq] at hqs
      have hp : Present s p := (hqs _ (List.mem_cons_self ..)).1
      have hc : Supp.comp (Present s) S.tab.length c := (hqs _ (List.mem_cons_self ..)).2
      have hq' : ∀ x ∈ q, Present s x.1 ∧ Supp.comp (Present s) S.tab.length x.2 :=
        fun x hx => hqs x (List.mem_cons_of_mem _ hx)
      cases a with
      | false => cases st <;> exact hdef
      | true =>
        cases st with
        | start body env =>
          cases c with
          | normal v =>
            obtain ⟨hcount, hfr⟩ := hstart body env hgo
            have he : Supp.env (Present s) S.tab.length env := hst
            have u1 : Upd F FR W stk M ν K S C s (setGen s g .running) (setGen t (M.a g) .running) 0 :=
              upd_setGen h hs hg (st := .running) trivial
            have u2 : Upd F FR W stk M ν K S C (setGen s g .running) ((setGen s g .running).push (.k (.fn (.gen g))))
                ((setGen t (M.a g) .running).push (.k (.fn (.gen (M.a g))))) 0 :=
              upd_push u1.rel (.k (.fn (.gen g))) (u1.pres _ hg)
            have u3 := upd_enterBlock (ss := body) hfr u2.rel (u2.pres _ (u1.pres _ hfp))
              (by have := u1.next; have := u2.next; omega)
              (Supp.env_mono (fun a ha => u2.pres a (u1.pres a ha)) (Nat.le_refl _) he)
            exact ((u1.trans u2).trans u3).weaken (by omega)
          | abrupt ab =>
            cases ab with
            | ret v =>
              have u1 : Upd F FR W stk M ν K S C s (setGen s g .done) (setGen t (M.a g) .done) 0 :=
                upd_setGen h hs hg (st := .done) trivial
              have u2 : Upd F FR W stk M ν K S C (setGen s g .done) (setQueue (setGen s g .done) g q)
                  (setQueue (setGen t (M.a g) .done) (M.a g) (M.queue q)) 0 :=
                upd_setQueue u1.rel (u1.bound (j := 0) (by omega)) (u1.pres _ hg)
                  (fun x hx => ⟨u1.pres _ (hq' x hx).1, Supp.comp_mono u1.pres (Nat.le_refl _) (hq' x hx).2⟩)
              have u3 := upd_resolveIter u2.rel (u2.pres _ (u1.pres _ hpo))
                (by have := u1.next; have := u2.next; omega) (u2.pres _ (u1.pres _ hp))
                (Supp.val_mono (fun a ha => u2.pres a (u1.pres a ha)) (Nat.le_refl _) hc) true
              exact ((u1.trans u2).trans u3).weaken (by omega)
            | throw v =>
              have u1 : Upd F FR W stk M ν K S C s (setGen s g .done) (setGen t (M.a g) .done) 0 :=
                upd_setGen h hs hg (st := .done) trivial
              have u2 : Upd F FR W stk M ν K S C (setGen s g .done) (setQueue (setGen s g .done) g q)
                  (setQueue (setGen t (M.a g) .done) (M.a g) (M.queue q)) 0 :=
                upd_setQueue u1.rel (u1.bound (j := 0) (by omega)) (u1.pres _ hg)
                  (fun x hx => ⟨u1.pres _ (hq' x hx).1, Supp.comp_mono u1.pres (Nat.le_refl _) (hq' x hx).2⟩)
              have u3 := upd_settle u2.rel (by have := u1.next; have := u2.next; omega) (u2.pres _ (u1.pres _ hp)) true
                (Supp.val_mono (fun a ha => u2.pres a (u1.pres a ha)) (Nat.le_refl _) hc)
              have u4 := upd_ret u3.rel .undef trivial
              exact ((u1.trans u2).trans (u3.trans u4)).weaken (by omega)
            | brk l => exact hdef
            | cont l => exact hdef
        | suspended su =>
          have hsu : Supp.susp (Present s) S.tab.length su := hst
          have u1 : Upd F FR W stk M ν K S C s (setGen s g .running) (setGen t (M.a g) .running) 0 :=
            upd_setGen h hs hg (st := .running) trivial
          have e : (M.susp su).frames ++ t.stack = (su.frames ++ s.stack).map M.frame ++ stk := by
            rw [List.map_append, h.stack, List.append_assoc]; rfl
          have u2 : Upd F FR W stk M ν K S C (setGen s g .running) { setGen s g .running with stack := su.frames ++ s.stack }
              { setGen t (M.a g) .running with stack := (M.susp su).frames ++ t.stack } 0 := by
            rw [e]
            exact upd_restack u1.rel (su.frames ++ s.stack) fun f hf => by
              rcases List.mem_append.1 hf with hf | hf
              · exact Supp.frame_mono u1.pres (Nat.le_refl _) (hsu.1 f hf)
              · exact Supp.frame_mono u1.pres (Nat.le_refl _) (h.stackSupp f hf)
          have u3 := upd_setStores u2.rel su.stores
            (Supp.stores_mono (fun a ha => u2.pres a (u1.pres a ha)) (Nat.le_refl _) hsu.2)
          have hc' := Supp.comp_mono (fun a ha => u3.pres a (u2.pres a (u1.pres a ha))) (Nat.le_refl _) hc
          cases c with
          | normal v =>
            have u4 := upd_go u3.rel (.ret v) hc'
            exact ((u1.trans u2).trans (u3.trans u4)).weaken (by omega)
          | abrupt ab =>
            have u4 := upd_go u3.rel (.abr ab) hc'
            exact ((u1.trans u2).trans (u3.trans u4)).weaken (by omega)
        | running => exact hdef
        | done =>
          have u1 : Upd F FR W stk M ν K S C s (setQueue s g q) (setQueue t (M.a g) (M.queue q)) 0 :=
            upd_setQueue h hs hg hq'
          have hc' := Supp.comp_mono u1.pres (Nat.le_refl _) hc
          cases c with
          | normal v =>
            have u2 := upd_resolveIter u1.rel (u1.pres _ hpo) (by have := u1.next; omega) (u1.pres _ hp)
              (v := .undef) trivial true
            exact (u1.trans u2).weaken (by omega)
          | abrupt ab =>
            cases ab with
            | throw v =>
              have u2 := upd_settle u1.rel (u1.bound (j := 0) (by omega)) (u1.pres _ hp) true hc'
              have u3 := upd_ret u2.rel .undef trivial
              exact (u1.trans (u2.trans u3)).weaken (by omega)
            | ret v =>
              have u2 := upd_resolveIter u1.rel (u1.pres _ hpo) (by have := u1.next; omega) (u1.pres _ hp)
                hc' true
              exact (u1.trans u2).weaken (by omega)
            | brk l =>
              have u2 := upd_resolveIter u1.rel (u1.pres _ hpo) (by have := u1.next; omega) (u1.pres _ hp)
                (v := .undef) trivial true
              exact (u1.trans u2).weaken (by omega)
            | cont l =>
              have u2 := upd_resolveIter u1.rel (u1.pres _ hpo) (by have := u1.next; omega) (u1.pres _ hp)
                (v := .undef) trivial true
              exact (u1.trans u2).weaken (by omega)

end

private theorem genOf_setGen {S' : Type} (s : St S') (g : Nat) (st : GenState) (hg : g < 2 ^ 64) :
    genOf (setGen s g st) g = (genOf s g).map fun x => (st, x.2) := by
  unfold setGen genOf
  cases ho : s.obj? g with
  | none => simp only [ho, Option.map]
  | some o =>
    cases hk : o.kind with
    | gen st0 a q =>
      have e : (s.setObj g { o with kind := .gen st a q }).obj? g = some { o with kind := .gen st a q } := by
        unfold St.obj? St.setObj
        rw [PTrie.get_set_u64 _ _ _ hg, ite_eq_left rfl]
      simp only [hk, e, Option.map]
    | _ => simp only [ho, hk, Option.map]

/-! ## Suspension at `await` and `yield` -/

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

theorem sim_awaitVal (hpp : Present s aPromiseProto)
    (hn : s.next + 1 < Sim.bound) {v : Val} (hv : Supp.val (Present s) S.tab.length v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (awaitVal F s v) (awaitVal F t (M.val v)) := by
  obtain ⟨e1, hp, u⟩ := upd_promiseFor h hpp hn hv
  have ks := promiseFor_keeps s v
  have kt := promiseFor_keeps t (M.val v)
  have hst : (promiseFor t (M.val v)).2.stores = M.stores (promiseFor s v).2.stores := u.rel.stores
  unfold awaitVal
  rw [pair_eta (promiseFor s v), pair_eta (promiseFor t (M.val v)), e1]
  dsimp only
  rw [ks.2.1, kt.2.1, h.stack, hst]
  cases hsp : splitSusp [] s.stack with
  | none => exact MSim.fail _ _
  | some x =>
    obtain ⟨frames, b, rest⟩ := x
    rw [splitSusp_append stk (by rw [splitSusp_map_nil, hsp]; rfl)]
    obtain ⟨hfr, hb, hrest, hbd⟩ := splitSusp_mem _ _ hsp
    have hsupp : ∀ f ∈ s.stack, Supp.frame (Present (promiseFor s v).2) S.tab.length f :=
      fun f hf => Supp.frame_mono u.pres (Nat.le_refl _) (h.stackSupp f hf)
    have r0 := u.rel.restack rest fun f hf => hsupp f (hrest f hf)
    have hr : Supp.reaction (Present (promiseFor s v).2) S.tab.length
        (.resume ⟨frames, (promiseFor s v).2.stores⟩) :=
      ⟨fun f hf => by
        rcases hfr f hf with hf | hf
        · cases hf
        · exact hsupp f hf, u.rel.storesSupp⟩
    have u2 := upd_react r0 (u.bound (j := 0) (by omega)) hp hr
    rcases isSuspBoundary_eq hbd with ⟨q, rfl⟩ | ⟨g, rfl⟩
    · have hq : Present s q := h.stackSupp _ hb
      exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret (.obj q) (u2.pres _ (u.pres _ hq))⟩
    · exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret .undef trivial⟩

theorem sim_yieldResult (hn : s.next < Sim.bound) {r : Val} (hr : Supp.val (Present s) S.tab.length r) :
    MSim (StepPostB F FR W stk M ν K S C) S C (yieldResult F s r) (yieldResult F t (M.val r)) := by
  unfold yieldResult
  rw [h.stack, h.stores]
  cases hsp : splitSusp [] s.stack with
  | none => exact MSim.fail _ _
  | some x =>
    obtain ⟨frames, b, rest⟩ := x
    rw [splitSusp_append stk (by rw [splitSusp_map_nil, hsp]; rfl)]
    obtain ⟨hfr, hb, hrest, hbd⟩ := splitSusp_mem _ _ hsp
    rcases isSuspBoundary_eq hbd with ⟨q, rfl⟩ | ⟨g, rfl⟩
    · exact MSim.fail _ _
    · have hg : Present s g := h.stackSupp _ hb
      have u1 := upd_setGen h hn hg (st := .suspended ⟨frames, s.stores⟩)
        ⟨fun f hf => by
          rcases hfr f hf with hf | hf
          · cases hf
          · exact h.stackSupp f hf, h.storesSupp⟩
      have r1 := u1.rel.restack rest fun f hf =>
        Supp.frame_mono u1.pres (Nat.le_refl _) (h.stackSupp f (hrest f hf))
      exact MSim.pure ⟨Grow.refl h.srv, r1.ret r (Supp.val_mono u1.pres (Nat.le_refl _) hr)⟩

theorem sim_yieldVal (hpo : Present s aObjectProto)
    (hn : s.next + 1 < Sim.bound) {v : Val} (hv : Supp.val (Present s) S.tab.length v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (yieldVal F s v) (yieldVal F t (M.val v)) := by
  obtain ⟨e1, hr, u⟩ := upd_iterResult h hpo (by omega) hv false
  unfold yieldVal
  rw [pair_eta (iterResult s v false), pair_eta (iterResult t (M.val v) false), e1]
  have := sim_yieldResult u.rel (u.bound (j := 0) (by omega)) (r := .obj (iterResult s v false).1) hr
  exact this.mono fun M' S' C' a b ⟨hg, hr⟩ => ⟨hg, hr⟩

theorem sim_agenYield (hpo : Present s aObjectProto)
    (hfp : Present s aFunctionProto) (hn : s.next + (1 + 2 ^ 21) < Sim.bound) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) :
    MSim (StepPostB F FR W stk M ν K S C) S C (agenYield F s v) (agenYield F t (M.val v)) := by
  unfold agenYield
  rw [h.stack]
  cases hsp : splitSusp [] s.stack with
  | none => exact MSim.fail _ _
  | some x =>
    obtain ⟨frames, b, rest⟩ := x
    rw [splitSusp_append stk (by rw [splitSusp_map_nil, hsp]; rfl)]
    obtain ⟨hfr, hb, hrest, hbd⟩ := splitSusp_mem _ _ hsp
    rcases isSuspBoundary_eq hbd with ⟨q, rfl⟩ | ⟨g, rfl⟩
    · exact MSim.fail _ _
    · have hg : Present s g := h.stackSupp _ hb
      have hs : s.next < Sim.bound := by omega
      dsimp only [Option.map, Map.frame, Map.fnF, Map.bnd]
      rw [h.agenQueue_map hg]
      have hqs := h.agenQueue_supp g
      cases hq : agenQueue s g with
      | nil => exact MSim.fail _ _
      | cons x q =>
        obtain ⟨p, c⟩ := x
        rw [hq] at hqs
        have hp : Present s p := (hqs _ (List.mem_cons_self ..)).1
        obtain ⟨e1, hr, u1⟩ := upd_iterResult h hpo hs hv false
        rw [pair_eta (iterResult s v false), pair_eta (iterResult t (M.val v) false), e1]
        have u2 := upd_setQueue u1.rel (u1.bound (j := 0) (by omega)) (u1.pres _ hg) (q := q)
          (fun x hx => ⟨u1.pres _ (hqs x (List.mem_cons_of_mem _ hx)).1,
            Supp.comp_mono u1.pres (Nat.le_refl _) (hqs x (List.mem_cons_of_mem _ hx)).2⟩)
        have u3 := upd_resolveP u2.rel (by have := u1.next; have := u2.next; omega)
          (u2.pres _ (u1.pres _ hp)) (v := .obj (iterResult s v false).1) (Supp.val_mono u2.pres (Nat.le_refl _) hr)
        have hn3' : (resolveP (setQueue (iterResult s v false).2 g q) p (.obj (iterResult s v false).1)).next
            ≤ s.next + 1 := by
          have := u1.next; have := u2.next; have := u3.next; omega
        obtain ⟨s3, hs3⟩ : ∃ x, resolveP (setQueue (iterResult s v false).2 g q) p (.obj (iterResult s v false).1) = x :=
          ⟨_, rfl⟩
        obtain ⟨t3, ht3⟩ : ∃ x, resolveP (setQueue (iterResult t (M.val v) false).2 (M.a g) (M.queue q)) (M.a p)
            (.obj (M.a (iterResult s v false).1)) = x := ⟨_, rfl⟩
        rw [show M.val (.obj (iterResult s v false).1) = .obj (M.a (iterResult s v false).1) from rfl] at u3
        rw [hs3] at hn3' u3
        rw [ht3] at u3
        rw [Map.queue_cons]
        dsimp only
        rw [hs3, ht3]
        have hst : t3.stores = M.stores s3.stores := u3.rel.stores
        have hP3 : ∀ a, Present s a → Present s3 a := fun a ha => u3.pres a (u2.pres a (u1.pres a ha))
        have r4 := u3.rel.restack rest fun f hf => Supp.frame_mono hP3 (Nat.le_refl _) (h.stackSupp f (hrest f hf))
        have u5 := upd_setGen r4 (by show s3.next < Sim.bound; omega)
          (hP3 _ hg) (st := .suspended ⟨frames, s3.stores⟩)
          ⟨fun f hf => by
            rcases hfr f hf with hf | hf
            · cases hf
            · exact Supp.frame_mono hP3 (Nat.le_refl _) (h.stackSupp f hf), u3.rel.storesSupp⟩
        have e : M.gen (.suspended ⟨frames, s3.stores⟩) = .suspended ⟨frames.map M.frame, t3.stores⟩ := by
          rw [hst]; rfl
        rw [e] at u5
        have hg64 : g < 2 ^ 64 := h.present_lt hg hs
        have u6 := upd_agenDrain u5.rel (u5.pres _ (hP3 _ hpo)) (u5.pres _ (hP3 _ hfp))
          (by
            have h5 : (setGen { s3 with stack := rest } g (.suspended ⟨frames, s3.stores⟩)).next ≤ s3.next := u5.next
            omega)
          (u5.pres _ (hP3 _ hg)) (fun body env hgo => by
            rw [genOf_setGen _ _ _ hg64] at hgo
            cases hg0 : genOf { s3 with stack := rest } g <;> rw [hg0] at hgo <;> cases hgo)
        exact MSim.pure ⟨Grow.refl h.srv, u6.rel⟩

end

/-! ## Steps: a value returning to an async frame -/

private theorem RelB.topRet {s t : St F.S} (h : RelB F FR W stk M ν K s S t C) {v : Val} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = f :: fs) :
    step F s = retStep F { s with stack := fs } f v ∧
    step F t = retStep F { t with stack := fs.map M.frame ++ stk } (M.frame f) (M.val v) ∧
    RelB F FR W stk M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C ∧
    Supp.val (Present s) S.tab.length v ∧ Supp.frame (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  refine ⟨by simp only [step, hc, stepRet, hs], by simp only [step, htc, stepRet, hts], hr, ?_,
    h.stackSupp f (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

private theorem margin_take {n : Nat} (hn : n + margin < Sim.bound) (k : Nat) (hk : k ≤ 2 ^ 29) : n + k < Sim.bound := by
  unfold margin at hn; omega

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- `await`: suspend to the nearest async boundary (both kinds of boundary, both promise cases). -/
theorem step_ret_await (hpp : Present s aPromiseProto)
    {v : Val} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k .await :: fs)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  exact sim_awaitVal h1 hpp (margin_take hn 1 (by decide)) hv

/-- Async `yield*`: resumed with a value for the inner `next`. -/
theorem step_ret_ystarAResume {v it nx : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.ystarAResume it nx) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  have u1 := upd_push h1 (.k (.ystarAResult it nx)) hf
  have u2 := upd_push u1.rel (.k .await) trivial
  exact MSim.pure ⟨Grow.refl h.srv, u2.rel.go (.call nx it [v]) ⟨hf.2, hf.1, fun x hx => by
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hx; rw [hx]; exact hv⟩⟩

/-- Sync `yield*`: resumed with a value for the inner `next`. -/
theorem step_ret_ystarResume {v it nx : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.ystarResume it nx) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  have u1 := upd_push h1 (.k (.ystarNext it nx)) hf
  exact MSim.pure ⟨Grow.refl h.srv, u1.rel.go (.call nx it [v]) ⟨hf.2, hf.1, fun x hx => by
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at hx; rw [hx]; exact hv⟩⟩

/-- Async `yield*` returning: the awaited return value. -/
theorem step_ret_ystarAReturn {v : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k .ystarAReturn :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.ret v)) hv⟩

/-- A derived promise's callback returned: resolve it. -/
theorem step_ret_promiseThen {v : Val} {p : Nat} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.promiseThen p) :: fs) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  have u := upd_resolveP h1 (margin_take hn 0 (by decide)) hf hv
  exact MSim.pure ⟨Grow.refl h.srv, u.rel.ret .undef trivial⟩

/-- Non-delegating `yield` in an async generator: await the operand first. -/
theorem step_ret_yield_async (hpp : Present s aPromiseProto)
    {v : Val} {fs : List Frame} {g : Nat} {b : Bool} {st : GenState}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.yield false) :: fs)
    (hng : nearestGen fs = some (g, b)) (hgo : genOf s g = some (st, true))
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  have hg : Present s g := h1.stackSupp _ (nearestGen_mem hng)
  have hng' : nearestGen (fs.map M.frame ++ stk) = some (M.a g, b) :=
    nearestGen_append stk (by rw [nearestGen_map, hng]; rfl)
  have hgo' : genOf { t with stack := fs.map M.frame ++ stk } (M.a g) = some (M.gen st, true) := by
    rw [h1.genOf_map hg]; exact congrArg (Option.map _) hgo
  show MSim _ S C (retK F { s with stack := fs } (.yield false) v) (retK F { t with stack := fs.map M.frame ++ stk } (.yield false) (M.val v))
  have hgo1 : genOf { s with stack := fs } g = some (st, true) := hgo
  simp only [retK, Bool.cond_false, hng, hng', hgo1, hgo']
  exact sim_awaitVal (h1.push (.k .ystarIt) trivial) hpp (margin_take hn 1 (by decide)) hv

/-- Non-delegating `yield` in a sync generator. -/
theorem step_ret_yield_sync (hpo : Present s aObjectProto)
    {v : Val} {fs : List Frame} {g : Nat} {b : Bool}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.yield false) :: fs)
    (hng : nearestGen fs = some (g, b)) (hgo : ∀ st, genOf s g ≠ some (st, true))
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  have hg : Present s g := h1.stackSupp _ (nearestGen_mem hng)
  have hng' : nearestGen (fs.map M.frame ++ stk) = some (M.a g, b) :=
    nearestGen_append stk (by rw [nearestGen_map, hng]; rfl)
  show MSim _ S C (retK F { s with stack := fs } (.yield false) v) (retK F { t with stack := fs.map M.frame ++ stk } (.yield false) (M.val v))
  simp only [retK, Bool.cond_false, hng, hng']
  rw [h1.genOf_map hg]
  have hy := sim_yieldVal h1 hpo (margin_take hn 1 (by decide)) hv
  cases hg0 : genOf { s with stack := fs } g with
  | none => exact hy
  | some x =>
    obtain ⟨st, a⟩ := x
    cases a with
    | true => exact absurd hg0 (hgo st)
    | false => exact hy

/-- `yield*` in an async generator: the iterator's results are awaited; here the awaited
operand of the delegated `yield` arrives and is yielded. -/
theorem step_ret_ystarIt_async (hpo : Present s aObjectProto)
    (hfp : Present s aFunctionProto) {v : Val} {fs : List Frame} {g : Nat} {b : Bool} {st : GenState}
    (hc : s.ctl = .ret v) (hs : s.stack = .k .ystarIt :: fs)
    (hng : nearestGen fs = some (g, b)) (hgo : genOf s g = some (st, true))
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  have hg : Present s g := h1.stackSupp _ (nearestGen_mem hng)
  have hng' : nearestGen (fs.map M.frame ++ stk) = some (M.a g, b) :=
    nearestGen_append stk (by rw [nearestGen_map, hng]; rfl)
  have hgo' : genOf { t with stack := fs.map M.frame ++ stk } (M.a g) = some (M.gen st, true) := by
    rw [h1.genOf_map hg]; exact congrArg (Option.map _) hgo
  show MSim _ S C (retK F { s with stack := fs } .ystarIt v) (retK F { t with stack := fs.map M.frame ++ stk } .ystarIt (M.val v))
  have hgo1 : genOf { s with stack := fs } g = some (st, true) := hgo
  simp only [retK, hng, hng', hgo1, hgo']
  exact sim_agenYield h1 hpo hfp (margin_take hn _ (by decide)) hv

end

/-! ## Jobs -/

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

theorem sim_runJob (hstk : stk = []) (hn : s.next < Sim.bound) {j : Job} (hj : Supp.job (Present s) S.tab.length j) :
    MSim (StepPostB F FR W stk M ν K S C) S C (runJob F s j) (runJob F t (M.job j)) := by
  subst hstk
  obtain ⟨r, th, v⟩ := j
  obtain ⟨hr, hv⟩ := hj
  cases r with
  | resume su =>
    have hsu : Supp.susp (Present s) S.tab.length su := hr
    have r1 := (h.restack su.frames hsu.1).setStores su.stores hsu.2
    simp only [List.append_nil] at r1
    cases th
    · exact MSim.pure ⟨Grow.refl h.srv, r1.go (.ret v) hv⟩
    · exact MSim.pure ⟨Grow.refl h.srv, r1.go (.abr (.throw v)) hv⟩
  | then_ onF onR d st =>
    obtain ⟨hF, hR, hd, hst⟩ := hr
    have key : ∀ f : Val, Supp.val (Present s) S.tab.length f →
        MSim (StepPostB F FR W [] M ν K S C) S C
          (match f with
            | .obj _ => .pure (({ s with stack := [.k (.promiseThen d)] }.setStores st).go (.call f .undef [v]))
            | _ => retS F (bif th then settle s d true v else resolveP s d v) .undef)
          (match M.val f with
            | .obj _ => .pure (({ t with stack := [.k (.promiseThen (M.a d))] }.setStores (M.stores st)).go
                (.call (M.val f) .undef [M.val v]))
            | _ => retS F (bif th then settle t (M.a d) true (M.val v) else resolveP t (M.a d) (M.val v)) .undef) := by
      intro f hf
      by_cases ho : ∃ a, f = .obj a
      · obtain ⟨a, rfl⟩ := ho
        have r1 := (h.restack [.k (.promiseThen d)] fun x hx => by
          rw [List.mem_singleton.1 hx]; exact hd).setStores st hst
        simp only [List.map_cons, List.map_nil, List.cons_append, List.nil_append] at r1
        exact MSim.pure ⟨Grow.refl h.srv, r1.go (.call (.obj a) .undef [v]) ⟨hf, trivial, fun x hx => by
          rw [List.mem_singleton.1 hx]; exact hv⟩⟩
      · have hrest : MSim (StepPostB F FR W [] M ν K S C) S C
            (retS F (bif th then settle s d true v else resolveP s d v) .undef)
            (retS F (bif th then settle t (M.a d) true (M.val v) else resolveP t (M.a d) (M.val v)) .undef) := by
          cases th
          · exact MSim.pure ⟨Grow.refl h.srv, (upd_resolveP h hn hd hv).rel.ret .undef trivial⟩
          · exact MSim.pure ⟨Grow.refl h.srv, (upd_settle h hn hd true hv).rel.ret .undef trivial⟩
        cases f with
        | obj a => exact absurd ⟨a, rfl⟩ ho
        | _ => exact hrest
    cases th
    · exact key onF hF
    · exact key onR hR
  | adopt p =>
    have hp : Present s p := hr
    show MSim _ S C (match isPromise s v with
        | some q => retS F (react s q (.forward p)) .undef
        | none => retS F (settle s p false v) .undef)
      (match isPromise t (M.val v) with
        | some q => retS F (react t q (.forward (M.a p))) .undef
        | none => retS F (settle t (M.a p) false (M.val v)) .undef)
    rw [h.isPromise_map hv]
    cases hip : isPromise s v with
    | some q =>
      have hq : Present s q := by rw [isPromise_eq hip] at hv; exact hv
      exact MSim.pure ⟨Grow.refl h.srv, (upd_react h hn hq (r := .forward p) hp).rel.ret .undef trivial⟩
    | none => exact MSim.pure ⟨Grow.refl h.srv, (upd_settle h hn hp false hv).rel.ret .undef trivial⟩
  | forward p =>
    have hp : Present s p := hr
    cases th
    · exact MSim.pure ⟨Grow.refl h.srv, (upd_resolveP h hn hp hv).rel.ret .undef trivial⟩
    · exact MSim.pure ⟨Grow.refl h.srv, (upd_settle h hn hp true hv).rel.ret .undef trivial⟩

omit h in
/-- The map keeps the `setImmediate` marker (`symMacro` is below the renamed symbols). -/
theorem isMacro_map (M : Map) (j : Job) : (M.job j).isMacro = j.isMacro := by
  obtain ⟨r, th, v⟩ := j
  cases r with
  | then_ f r' d st =>
    cases r' with
    | sym i =>
      show Nat.beq (bif Nat.blt i 16 then i else M.a (i - 16) + 16) symMacro = Nat.beq i symMacro
      cases hi : Nat.blt i 16
      · have hi' : ¬ i < 16 := fun hlt => by rw [Nat.blt_eq.mpr hlt] at hi; cases hi
        have h1 : Nat.beq (M.a (i - 16) + 16) symMacro = false := by
          cases e : Nat.beq (M.a (i - 16) + 16) symMacro
          · rfl
          · have := Nat.eq_of_beq_eq_true e; simp [symMacro] at this
        have h2 : Nat.beq i symMacro = false := by
          cases e : Nat.beq i symMacro
          · rfl
          · have := Nat.eq_of_beq_eq_true e; simp [symMacro] at this; omega
        rw [Bool.cond_false, h1, h2]
      · rfl
    | _ => rfl
  | _ => rfl

omit h in
theorem takeMicro_map (M : Map) : ∀ js : List Job,
    takeMicro (js.map M.job) = (takeMicro js).map fun p => (M.job p.1, p.2.map M.job)
  | [] => rfl
  | j :: js => by
    have ih := takeMicro_map M js
    show (bif (M.job j).isMacro then (takeMicro (js.map M.job)).map (fun p => (p.1, M.job j :: p.2))
        else some (M.job j, js.map M.job)) =
      (bif j.isMacro then (takeMicro js).map (fun p => (p.1, j :: p.2)) else some (j, js)).map
        fun p => (M.job p.1, p.2.map M.job)
    rw [isMacro_map, ih]
    cases j.isMacro
    · rfl
    · cases takeMicro js <;> rfl

omit h in
theorem nextJob_map (M : Map) (js : List Job) :
    nextJob (js.map M.job) = (nextJob js).map fun p => (M.job p.1, p.2.map M.job) := by
  unfold nextJob
  rw [takeMicro_map]
  cases takeMicro js with
  | some p => rfl
  | none => cases js <;> rfl

omit h in
theorem takeMicro_mem : ∀ {js : List Job} {j : Job} {r : List Job}, takeMicro js = some (j, r) →
    j ∈ js ∧ ∀ x ∈ r, x ∈ js
  | [], _, _, h => by cases h
  | k :: ks, j, r, h => by
    simp only [takeMicro] at h
    cases hk : k.isMacro
    · rw [hk, Bool.cond_false, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨List.mem_cons_self .., fun x hx => List.mem_cons_of_mem _ hx⟩
    · rw [hk, Bool.cond_true] at h
      cases ht : takeMicro ks with
      | none => rw [ht] at h; cases h
      | some p =>
        rw [ht] at h
        simp only [Option.map_some, Option.some.injEq, Prod.mk.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        obtain ⟨h1, h2⟩ := takeMicro_mem ht
        refine ⟨List.mem_cons_of_mem _ h1, fun x hx => ?_⟩
        rcases List.mem_cons.1 hx with rfl | hx
        · exact List.mem_cons_self ..
        · exact List.mem_cons_of_mem _ (h2 x hx)

omit h in
theorem nextJob_mem {js : List Job} {j : Job} {r : List Job} (h : nextJob js = some (j, r)) :
    j ∈ js ∧ ∀ x ∈ r, x ∈ js := by
  unfold nextJob at h
  cases ht : takeMicro js with
  | some p => rw [ht] at h; cases h; exact takeMicro_mem ht
  | none =>
    rw [ht] at h
    cases js with
    | nil => cases h
    | cons k ks =>
      simp only [Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨List.mem_cons_self .., fun x hx => List.mem_cons_of_mem _ hx⟩

/-- A value returning to an empty stack: run the next job, or halt. -/
theorem step_ret_empty (hstk : stk = []) {v : Val} (hc : s.ctl = .ret v) (hs : s.stack = [])
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  subst hstk
  have htc : t.ctl = .ret (M.val v) := by rw [h.ctl, hc]; rfl
  have hts : t.stack = [] := by rw [h.stack, hs]; rfl
  have hv : Supp.val (Present s) S.tab.length v := by have := h.ctlSupp; rw [hc] at this; exact this
  have e1 : step F s = stepJobs F s v := by simp only [step, hc, stepRet, hs]
  have e2 : step F t = stepJobs F t (M.val v) := by simp only [step, htc, stepRet, hts]
  rw [e1, e2]
  unfold stepJobs
  rw [h.jobs, nextJob_map]
  cases hj : nextJob s.jobs with
  | none => exact MSim.pure ⟨Grow.refl h.srv, h.go (.halt (.normal v)) hv⟩
  | some p =>
    obtain ⟨j, js⟩ := p
    obtain ⟨hjm, hjs⟩ := nextJob_mem hj
    have r1 := h.setJobs js fun j' hj' => h.jobsSupp j' (hjs j' hj')
    exact sim_runJob r1 rfl (margin_take hn 0 (by decide)) (h.jobsSupp j hjm)

/-- An abrupt completion reaching an empty stack halts. -/
theorem step_abr_empty (hstk : stk = []) {a : Abrupt} (hc : s.ctl = .abr a) (hs : s.stack = []) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  subst hstk
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  have hts : t.stack = [] := by rw [h.stack, hs]; rfl
  have ha : Supp.abr (Present s) S.tab.length a := by have := h.ctlSupp; rw [hc] at this; exact this
  have e1 : step F s = .pure (s.go (.halt (.abrupt a))) := by simp only [step, hc, stepAbr, hs]
  have e2 : step F t = .pure (t.go (.halt (.abrupt (M.abr a)))) := by simp only [step, htc, stepAbr, hts]
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h.go (.halt (.abrupt a)) ha⟩

end

/-! ## Builtin calls: promises, async generators, AsyncLocalStorage -/

private theorem nthD_map {α β : Type} (f : α → β) (d : α) : ∀ (l : List α) (i : Nat),
    nthD (f d) (l.map f) i = f (nthD d l i)
  | [], _ => rfl
  | _ :: _, 0 => rfl
  | _ :: l, i + 1 => nthD_map f d l i

private theorem arg_map (M : Map) (args : List Val) (i : Nat) : arg (M.vals args) i = M.val (arg args i) :=
  nthD_map M.val .undef args i

private theorem Supp.vals_arg {A : Nat → Prop} {n : Nat} {args : List Val} (h : Supp.vals A n args) (i : Nat) :
    Supp.val A n (Host.Ts.arg args i) := by
  unfold Host.Ts.arg
  induction args generalizing i with
  | nil => exact trivial
  | cons a l ih =>
    cases i with
    | zero => exact h a (List.mem_cons_self ..)
    | succ i => exact ih (fun x hx => h x (List.mem_cons_of_mem _ hx)) i

private theorem genOf_alloc {S' : Type} (s : St S') (o : HObj) {g : Nat} (hg : g < s.next) (hn : s.next < 2 ^ 64) :
    genOf (s.alloc o).2 g = genOf s g := by
  have e : (s.alloc o).2.obj? g = s.obj? g := by
    unfold St.obj?
    rw [alloc_get s o hn, ite_eq_right (Nat.ne_of_lt hg)]
  unfold genOf; rw [e]

private theorem genOf_setQueue {S' : Type} (s : St S') (g : Nat) (q : List (Nat × Comp)) (hg : g < 2 ^ 64) :
    genOf (setQueue s g q) g = genOf s g := by
  unfold setQueue genOf
  cases ho : s.obj? g with
  | none => simp only [ho]
  | some o =>
    cases hk : o.kind with
    | gen st0 a q0 =>
      have e : (s.setObj g { o with kind := .gen st0 a q }).obj? g = some { o with kind := .gen st0 a q } := by
        unfold St.obj? St.setObj
        rw [PTrie.get_set_u64 _ _ _ hg, ite_eq_left rfl]
      simp only [hk, e]
    | _ => simp only [ho, hk]

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- A builtin called on both sides: the callee is a native function object (never framed). -/
private theorem RelB.topCall {a : Nat} {this : Val} {args : List Val} {o : Obj} {n : Native} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o) (hk : o.kind = .fn (.native n data)) :
    step F s = callNative F s n data this args ∧
    step F t = callNative F t n (M.vals data) (M.val this) (M.vals args) ∧
    Supp.val (Present s) S.tab.length this ∧ Supp.vals (Present s) S.tab.length args ∧
    Supp.vals (Present s) S.tab.length data := by
  have htc : t.ctl = .call (.obj (M.a a)) (M.val this) (M.vals args) := by rw [h.ctl, hc]; rfl
  have hfr : K.fr a = none := h.fr_of_kind ho (by intro es he; rw [hk] at he; cases he) (by rw [hk]; exact id)
  have ho' : t.obj? (M.a a) = some (M.obj o) := h.obj? ho hfr
  have hk' : (M.obj o).kind = .fn (.native n (M.vals data)) := by
    show M.kind o.kind = _; rw [hk]; rfl
  have hsc := h.ctlSupp
  rw [hc] at hsc
  have hso := (h.obj?_supp ho).1
  rw [hk] at hso
  exact ⟨by simp only [step, hc, callStep, ho, hk], by simp only [step, htc, callStep, ho', hk'], hsc.2.1, hsc.2.2,
    hso⟩

theorem sim_agen (hpp : Present s aPromiseProto)
    (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto) (htp : Present s aTypeErrorProto)
    (hn : s.next + (1 + 2 ^ 21) < Sim.bound) {this : Val} (hthis : Supp.val (Present s) S.tab.length this)
    {c : Comp} (hc : Supp.comp (Present s) S.tab.length c)
    (hstart : ∀ g body env, this = .obj g → genOf s g = some (.start body env, true) → StartOK K body env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (ctlN.agen F s this c) (ctlN.agen F t (M.val this) (M.comp c)) := by
  have hs : s.next < Sim.bound := by omega
  cases this with
  | obj g =>
    have hg : Present s g := hthis
    unfold ctlN.agen
    rw [show M.val (.obj g) = .obj (M.a g) from rfl]
    dsimp only
    rw [h.genOf_map hg]
    cases hgo : genOf s g with
    | none => exact typeErr_sim h h.intr hs htp _
    | some x =>
      obtain ⟨st, a⟩ := x
      cases a with
      | false => exact typeErr_sim h h.intr hs htp _
      | true =>
        obtain ⟨e1, e2, hp, u⟩ := upd_newPromise h hpp hs
        dsimp only [Option.map]
        rw [pair_eta (newPromise s), pair_eta (newPromise t), e1]
        dsimp only
        rw [u.rel.agenQueue_map (u.pres _ hg)]
        rw [show M.queue (agenQueue (newPromise s).2 g) ++ [(M.a (newPromise s).1, M.comp c)] =
            M.queue (agenQueue (newPromise s).2 g ++ [((newPromise s).1, c)]) by
          simp only [Map.queue, List.map_append, List.map_cons, List.map_nil]]
        have hn1 : (newPromise s).2.next < Sim.bound := u.bound (j := 0) (by omega)
        have u2 := upd_setQueue u.rel hn1 (u.pres _ hg) (q := agenQueue (newPromise s).2 g ++ [((newPromise s).1, c)])
          (fun x hx => by
            rcases List.mem_append.1 hx with hx | hx
            · exact u.rel.agenQueue_supp g x hx
            · rw [List.mem_singleton.1 hx]; exact ⟨hp, Supp.comp_mono u.pres (Nat.le_refl _) hc⟩)
        have hg64 : g < 2 ^ 64 := h.present_lt hg hs
        have hgs : g < s.next := h.presentBound g hg
        have hgo2 : ∀ x : St F.S, x.heap = (setQueue (newPromise s).2 g (agenQueue (newPromise s).2 g ++ [((newPromise s).1, c)])).heap →
            genOf x g = genOf s g := by
          intro x hx
          have e : genOf x g = genOf (setQueue (newPromise s).2 g (agenQueue (newPromise s).2 g ++ [((newPromise s).1, c)])) g := by
            unfold genOf St.obj?; rw [hx]
          rw [e, genOf_setQueue _ _ _ hg64]
          exact genOf_alloc s _ hgs (by have hb : Sim.bound = 2 ^ 61 := rfl; rw [hb] at hs; omega)
        cases st with
        | running =>
          exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret (.obj _) (u2.pres _ hp)⟩
        | _ =>
          first
          | (have u3 := upd_push u2.rel (.e (.const (.obj (newPromise s).1))) (u2.pres _ hp)
             have u4 := upd_agenDrain u3.rel (u3.pres _ (u2.pres _ (u.pres _ hpo)))
               (u3.pres _ (u2.pres _ (u.pres _ hfp))) (by have := u.next; have := u2.next; have := u3.next; omega)
               (u3.pres _ (u2.pres _ (u.pres _ hg))) (fun body env hgo' => by
                 have hgo3 : genOf ((setQueue (newPromise s).2 g (agenQueue (newPromise s).2 g ++
                     [((newPromise s).1, c)])).push (.e (.const (.obj (newPromise s).1)))) g = genOf s g :=
                   hgo2 _ rfl
                 rw [hgo3, hgo] at hgo'
                 exact hstart g body env rfl (by rw [hgo]; exact hgo'))
             exact MSim.pure ⟨Grow.refl h.srv, u4.rel⟩)
  | _ => exact typeErr_sim h h.intr hs htp _

end

/-! ## Builtin calls: the step lemmas -/

private theorem storeFind_map (M : Map) {A : Nat → Prop} (hinj : ∀ a b, A a → A b → M.a a = M.a b → a = b) {a : Nat}
    (ha : A a) : ∀ (ss : List (Nat × Val)), (∀ x ∈ ss, A x.1) →
    ((M.stores ss).find? fun (b, _) => Nat.beq (M.a a) b).elim .undef Prod.snd =
      M.val ((ss.find? fun (b, _) => Nat.beq a b).elim .undef Prod.snd)
  | [], _ => rfl
  | (i, v) :: ss, hss => by
    have hi : A i := hss (i, v) (List.mem_cons_self ..)
    have e : Nat.beq (M.a a) (M.a i) = Nat.beq a i := beq_map hinj ha hi
    simp only [Map.stores, List.map_cons, List.find?_cons, e]
    cases Nat.beq a i
    · exact storeFind_map M hinj ha ss fun x hx => hss x (List.mem_cons_of_mem _ hx)
    · rfl

private theorem Map.stores_tail (M : Map) (ss : List (Nat × Val)) : (M.stores ss).tail = M.stores ss.tail := by
  cases ss <;> rfl

private theorem dataOf_own (F : Ffi) {s : St F.S} {a : Nat} {o : Obj} {k : PKey} {dv : Val} {w e : Bool}
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary) (hp : findProp k o.props = some (.data dv w e)) :
    dataOf F s (.obj a) k = Host.Ts.M.pure (some dv) := by
  unfold dataOf lookup
  rw [show (16 : Nat) = 15 + 1 from rfl]
  simp only [getChain, ho, ownGet, hk, hp]
  rfl

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- `next`/`return`/`throw` of an async generator: queue the request, start an idle generator. -/
theorem step_call_agen (hpp : Present s aPromiseProto)
    (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto) (htp : Present s aTypeErrorProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {f : CtlN} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o) (hk : o.kind = .fn (.native (.ctl f) data))
    (hf : f = .agenNext ∨ f = .agenReturn ∨ f = .agenThrow)
    (hstart : ∀ g body env, this = .obj g → genOf s g = some (.start body env, true) → StartOK K body env)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  have hn' := margin_take hn (1 + 2 ^ 21) (by decide)
  have ha0 := Supp.vals_arg hargs 0
  rcases hf with rfl | rfl | rfl
  · show MSim _ S C (ctlN.agen F s this (.normal (arg args 0)))
      (ctlN.agen F t (M.val this) (.normal (arg (M.vals args) 0)))
    rw [arg_map]
    exact sim_agen h hpp hpo hfp htp hn' hthis (c := .normal _) ha0 hstart
  · show MSim _ S C (ctlN.agen F s this (.abrupt (.ret (arg args 0))))
      (ctlN.agen F t (M.val this) (.abrupt (.ret (arg (M.vals args) 0))))
    rw [arg_map]
    exact sim_agen h hpp hpo hfp htp hn' hthis (c := .abrupt (.ret _)) ha0 hstart
  · show MSim _ S C (ctlN.agen F s this (.abrupt (.throw (arg args 0))))
      (ctlN.agen F t (M.val this) (.abrupt (.throw (arg (M.vals args) 0))))
    rw [arg_map]
    exact sim_agen h hpp hpo hfp htp hn' hthis (c := .abrupt (.throw _)) ha0 hstart

/-- `AsyncLocalStorage.prototype.getStore`. -/
theorem step_call_alsGetStore (htp : Present s aTypeErrorProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl .alsGetStore) data)) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, -, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  show MSim _ S C (ctlN F s this args data .alsGetStore) (ctlN F t (M.val this) (M.vals args) (M.vals data) .alsGetStore)
  cases this with
  | obj b =>
    have hb : Present s b := hthis
    show MSim _ S C (retS F s ((s.stores.find? fun (c, _) => Nat.beq b c).elim .undef Prod.snd))
      (retS F t ((t.stores.find? fun (c, _) => Nat.beq (M.a b) c).elim .undef Prod.snd))
    rw [h.stores, storeFind_map M h.inj hb s.stores fun x hx => (h.storesSupp x hx).1]
    refine MSim.pure ⟨Grow.refl h.srv, h.ret _ ?_⟩
    cases hf : s.stores.find? (fun (c, _) => Nat.beq b c) with
    | none => trivial
    | some x => exact (h.storesSupp x (List.mem_of_find?_eq_some hf)).2
  | _ => exact typeErr_sim h h.intr (margin_take hn 0 (by decide)) htp _

/-- `AsyncLocalStorage.prototype.run`: push the store, call the callback above a frame that pops it. -/
theorem step_call_alsRun (htp : Present s aTypeErrorProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl .alsRun) data)) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  show MSim _ S C (ctlN F s this args data .alsRun) (ctlN F t (M.val this) (M.vals args) (M.vals data) .alsRun)
  cases this with
  | obj b =>
    have hb : Present s b := hthis
    show MSim _ S C
      (Host.Ts.M.pure (((s.setStores ((b, arg args 0) :: s.stores)).push (.k (.native (.ctl .alsRun) []))).go
        (.call (arg args 1) .undef (args.drop 2))))
      (Host.Ts.M.pure (((t.setStores ((M.a b, arg (M.vals args) 0) :: t.stores)).push (.k (.native (.ctl .alsRun) []))).go
        (.call (arg (M.vals args) 1) .undef ((M.vals args).drop 2))))
    have e : ((M.a b, arg (M.vals args) 0) :: t.stores) = M.stores ((b, arg args 0) :: s.stores) := by
      rw [arg_map, h.stores]; rfl
    rw [e, arg_map, show (M.vals args).drop 2 = M.vals (args.drop 2) from (List.map_drop ..).symm]
    have r1 := h.setStores ((b, arg args 0) :: s.stores) fun x hx => by
      rcases List.mem_cons.1 hx with rfl | hx
      · exact ⟨hb, Supp.vals_arg hargs 0⟩
      · exact h.storesSupp x hx
    have r2 := r1.push (.k (.native (.ctl .alsRun) [])) (fun _ hx => nomatch hx)
    exact MSim.pure ⟨Grow.refl h.srv, r2.go (.call (arg args 1) .undef (args.drop 2))
      ⟨Supp.vals_arg hargs 1, trivial, fun x hx => hargs x (List.mem_of_mem_drop hx)⟩⟩
  | _ => exact typeErr_sim h h.intr (margin_take hn 0 (by decide)) htp _

/-- `Promise.resolve`. -/
theorem step_call_promiseResolve (hpp : Present s aPromiseProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl .promiseResolve) data)) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  obtain ⟨e, hp, u⟩ := upd_promiseFor h hpp (margin_take hn 1 (by decide)) (Supp.vals_arg hargs 0)
  show MSim _ S C (retS F (promiseFor s (arg args 0)).2 (.obj (promiseFor s (arg args 0)).1))
    (retS F (promiseFor t (arg (M.vals args) 0)).2 (.obj (promiseFor t (arg (M.vals args) 0)).1))
  rw [arg_map, e]
  exact MSim.pure ⟨Grow.refl h.srv, u.rel.ret (.obj _) hp⟩

/-- `Promise.reject`. -/
theorem step_call_promiseReject (hpp : Present s aPromiseProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl .promiseReject) data)) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  obtain ⟨e, -, hp, u⟩ := upd_newPromise h hpp (margin_take hn 0 (by decide))
  have u2 := upd_settle u.rel (u.bound (j := 0) (margin_take hn 1 (by decide))) hp true
    (Supp.val_mono u.pres (Nat.le_refl _) (Supp.vals_arg hargs 0))
  show MSim _ S C (retS F (settle (newPromise s).2 (newPromise s).1 true (arg args 0)) (.obj (newPromise s).1))
    (retS F (settle (newPromise t).2 (newPromise t).1 true (arg (M.vals args) 0)) (.obj (newPromise t).1))
  rw [arg_map, e]
  exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret (.obj _) (u2.pres _ hp)⟩

/-- `setImmediate(cb)`: a fresh promise and the macrotask `cb()` (a `then_` job marked by
`symMacro`), or a `TypeError` for a non-object callback. -/
theorem step_call_setImmediate (hpp : Present s aPromiseProto) (htp : Present s aTypeErrorProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl .setImmediate) data)) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  show MSim _ S C (ctlN F s this args data .setImmediate)
    (ctlN F t (M.val this) (M.vals args) (M.vals data) .setImmediate)
  have hs0 := Supp.vals_arg hargs 0
  have hn0 : s.next < Sim.bound := margin_take hn 0 (by decide)
  simp only [ctlN, arg_map]
  cases hv : arg args 0 with
  | obj b =>
    rw [hv] at hs0
    obtain ⟨e, -, hp, u⟩ := upd_newPromise h hpp hn0
    have hj : Supp.job (Present (newPromise s).2) S.tab.length
        ⟨.then_ (.obj b) (.sym symMacro) (newPromise s).1 (newPromise s).2.stores, false, .undef⟩ :=
      ⟨⟨u.pres _ hs0, fun h16 => absurd h16 (by decide), hp, u.rel.storesSupp⟩, trivial⟩
    have u2 := upd_enqueue u.rel _ hj
    have hJ : M.job ⟨.then_ (.obj b) (.sym symMacro) (newPromise s).1 (newPromise s).2.stores, false, .undef⟩ =
        ⟨.then_ (.obj (M.a b)) (.sym symMacro) (newPromise t).1 (newPromise t).2.stores, false, .undef⟩ := by
      show (⟨.then_ (M.val (.obj b)) (M.val (.sym symMacro)) (M.a (newPromise s).1)
        (M.stores (newPromise s).2.stores), false, M.val .undef⟩ : Job) = _
      rw [← e, ← u.rel.stores]
      rfl
    rw [hJ] at u2
    exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret .undef trivial⟩
  | _ => exact typeErr_sim h h.intr hn0 htp _

theorem sim_thenOn (hpp : Present s aPromiseProto)
    (hn : s.next + 1 < Sim.bound) {p : Nat} (hp : Present s p) {onF onR : Val}
    (hF : Supp.val (Present s) S.tab.length onF) (hR : Supp.val (Present s) S.tab.length onR) :
    MSim (StepPostB F FR W stk M ν K S C) S C (thenOn F s p onF onR) (thenOn F t (M.a p) (M.val onF) (M.val onR)) := by
  obtain ⟨e, -, hd, u⟩ := upd_newPromise h hpp (by omega)
  have hst : (newPromise t).2.stores = M.stores (newPromise s).2.stores := u.rel.stores
  have u2 := upd_react u.rel (u.bound (j := 0) (by omega)) (u.pres _ hp)
    (r := .then_ onF onR (newPromise s).1 (newPromise s).2.stores)
    ⟨Supp.val_mono u.pres (Nat.le_refl _) hF, Supp.val_mono u.pres (Nat.le_refl _) hR, hd, u.rel.storesSupp⟩
  show MSim _ S C
    (retS F (react (newPromise s).2 p (.then_ onF onR (newPromise s).1 (newPromise s).2.stores)) (.obj (newPromise s).1))
    (retS F (react (newPromise t).2 (M.a p) (.then_ (M.val onF) (M.val onR) (newPromise t).1 (newPromise t).2.stores))
      (.obj (newPromise t).1))
  rw [hst, e]
  exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret (.obj _) (u2.pres _ hd)⟩

/-- `Promise.prototype.then` and `catch`. -/
theorem step_call_promiseThen (hpp : Present s aPromiseProto)
    (htp : Present s aTypeErrorProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {f : CtlN} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl f) data)) (hf : f = .promiseThen ∨ f = .promiseCatch)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  have hs := margin_take hn 0 (by decide)
  have hn1 := margin_take hn 1 (by decide)
  rcases hf with rfl | rfl
  · show MSim _ S C
      (match isPromise s this with
        | some p => thenOn F s p (arg args 0) (arg args 1)
        | none => typeErr s (chars!"then on a non-promise"))
      (match isPromise t (M.val this) with
        | some p => thenOn F t p (arg (M.vals args) 0) (arg (M.vals args) 1)
        | none => typeErr t (chars!"then on a non-promise"))
    rw [h.isPromise_map hthis, arg_map, arg_map]
    cases hip : isPromise s this with
    | none => exact typeErr_sim h h.intr hs htp _
    | some p =>
      have hp : Present s p := by rw [isPromise_eq hip] at hthis; exact hthis
      exact sim_thenOn h hpp hn1 hp (Supp.vals_arg hargs 0) (Supp.vals_arg hargs 1)
  · show MSim _ S C
      (match isPromise s this with
        | some p => thenOn F s p .undef (arg args 0)
        | none => typeErr s (chars!"catch on a non-promise"))
      (match isPromise t (M.val this) with
        | some p => thenOn F t p .undef (arg (M.vals args) 0)
        | none => typeErr t (chars!"catch on a non-promise"))
    rw [h.isPromise_map hthis, arg_map]
    cases hip : isPromise s this with
    | none => exact typeErr_sim h h.intr hs htp _
    | some p =>
      have hp : Present s p := by rw [isPromise_eq hip] at hthis; exact hthis
      exact sim_thenOn h hpp hn1 hp (onF := .undef) trivial (Supp.vals_arg hargs 0)

/-- The resolving functions of `new Promise(executor)`. -/
theorem step_call_resolveFn {a : Nat} {this : Val} {args : List Val} {o : Obj} {f : CtlN} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o)
    (hk : o.kind = .fn (.native (.ctl f) data)) (hf : f = .resolveFn ∨ f = .rejectFn)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, hargs, hdata⟩ := h.topCall hc ho hk
  rw [e1, e2]
  have hs := margin_take hn 0 (by decide)
  have hv := Supp.vals_arg hargs 0
  rcases hf with rfl | rfl
  · show MSim _ S C (match data with
        | [.obj p] => retS F (resolveP s p (arg args 0)) .undef
        | _ => .fail "resolve function")
      (match M.vals data with
        | [.obj p] => retS F (resolveP t p (arg (M.vals args) 0)) .undef
        | _ => .fail "resolve function")
    rw [arg_map]
    match data, hdata with
    | [.obj p], hdata =>
      exact MSim.pure ⟨Grow.refl h.srv, (upd_resolveP h hs (hdata _ (List.mem_singleton_self _)) hv).rel.ret .undef trivial⟩
    | [], _ => exact MSim.fail _ _
    | [.undef], _ | [.null], _ | [.bool _], _ | [.num _], _ | [.big _], _ | [.str _], _ | [.sym _], _
    | [.ptr _ _], _ => exact MSim.fail _ _
    | x :: _ :: _, _ => cases x <;> exact MSim.fail _ _
  · show MSim _ S C (match data with
        | [.obj p] => retS F (settle s p true (arg args 0)) .undef
        | _ => .fail "reject function")
      (match M.vals data with
        | [.obj p] => retS F (settle t p true (arg (M.vals args) 0)) .undef
        | _ => .fail "reject function")
    rw [arg_map]
    match data, hdata with
    | [.obj p], hdata =>
      exact MSim.pure ⟨Grow.refl h.srv, (upd_settle h hs (hdata _ (List.mem_singleton_self _)) true hv).rel.ret .undef trivial⟩
    | [], _ => exact MSim.fail _ _
    | [.undef], _ | [.null], _ | [.bool _], _ | [.num _], _ | [.big _], _ | [.str _], _ | [.sym _], _
    | [.ptr _ _], _ => exact MSim.fail _ _
    | x :: _ :: _, _ => cases x <;> exact MSim.fail _ _

/-! ## Builtin frames -/

/-- `AsyncLocalStorage.run`'s callback returned: pop the store. -/
theorem step_ret_native_alsRun {v : Val} {data : List Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.native (.ctl .alsRun) data) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  show MSim _ S C (retS F ({ s with stack := fs }.setStores s.stores.tail) v)
    (retS F ({ t with stack := fs.map M.frame ++ stk }.setStores t.stores.tail) (M.val v))
  rw [h.stores, Map.stores_tail]
  have r1 := h1.setStores s.stores.tail fun x hx => h.storesSupp x (List.mem_of_mem_tail hx)
  exact MSim.pure ⟨Grow.refl h.srv, r1.ret v hv⟩

/-- `new Promise(executor)`'s executor returned: the promise is the result. -/
theorem step_ret_native_promiseCtor {v p : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.native (.ctl .promiseCtor) [p]) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, -, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  exact MSim.pure ⟨Grow.refl h.srv, h1.ret p (hf p (List.mem_singleton_self _))⟩

/-- An abrupt completion through `AsyncLocalStorage.run`: pop the store. -/
theorem step_abr_native_alsRun {a : Abrupt} {data : List Val} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.native (.ctl .alsRun) data) :: fs) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨hts, h1⟩ := h.pop hs
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  have ha : Supp.abr (Present s) S.tab.length a := by have := h.ctlSupp; rw [hc] at this; exact this
  have e1 : step F s = abrStep F { s with stack := fs } (.k (.native (.ctl .alsRun) data)) a := by
    simp only [step, hc, stepAbr, hs]
  have e2 : step F t = abrStep F { t with stack := fs.map M.frame ++ stk } (M.frame (.k (.native (.ctl .alsRun) data)))
      (M.abr a) := by
    simp only [step, htc, stepAbr, hts]
  rw [e1, e2]
  show MSim _ S C (Host.Ts.M.pure (({ s with stack := fs }.setStores s.stores.tail).go (.abr a)))
    (Host.Ts.M.pure (({ t with stack := fs.map M.frame ++ stk }.setStores t.stores.tail).go (.abr (M.abr a))))
  rw [h.stores, Map.stores_tail]
  have r1 := h1.setStores s.stores.tail fun x hx => h.storesSupp x (List.mem_of_mem_tail hx)
  exact MSim.pure ⟨Grow.refl h.srv, r1.go (.abr a) ha⟩

/-- A derived promise's callback threw: reject it (other completions pass through). -/
theorem step_abr_promiseThen {a : Abrupt} {p : Nat} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.promiseThen p) :: fs) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨hts, h1⟩ := h.pop hs
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  have ha : Supp.abr (Present s) S.tab.length a := by have := h.ctlSupp; rw [hc] at this; exact this
  have hp : Present s p := h.stackSupp (.k (.promiseThen p)) (by rw [hs]; exact List.mem_cons_self ..)
  have e1 : step F s = abrStep F { s with stack := fs } (.k (.promiseThen p)) a := by
    simp only [step, hc, stepAbr, hs]
  have e2 : step F t = abrStep F { t with stack := fs.map M.frame ++ stk } (M.frame (.k (.promiseThen p))) (M.abr a) := by
    simp only [step, htc, stepAbr, hts]
  rw [e1, e2]
  cases a with
  | throw e =>
    exact MSim.pure ⟨Grow.refl h.srv,
      (upd_settle h1 (margin_take hn 0 (by decide)) hp true ha).rel.ret .undef trivial⟩
  | ret v => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.ret v)) ha⟩
  | brk l => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.brk l)) ha⟩
  | cont l => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.cont l)) ha⟩

end

/-! ## Async `yield*` results and `super()` returns -/

private theorem thisEnv_eq (F : Ffi) (s : St F.S) (v : Val) (env : Env) :
    thisEnv F s v env = ((nThis, (s.alloc (.cell (some v))).1) :: env, (s.alloc (.cell (some v))).2) := rfl

private theorem sim_truthy {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C) (v : Val)
    (hb : ∀ i, v = .big i → M.big i = i) :
    MSim (fun M' S' C' r r' => r' = r ∧ Grow M ν S C M' S' C') S C (truthy v) (truthy (M.val v)) := by
  cases v with
  | num x => exact numTest_sim hs .truthy x zeroN
  | big i =>
    show MSim _ S C (Host.Ts.M.pure _) (Host.Ts.M.pure _)
    rw [hb i rfl]
    exact MSim.pure ⟨rfl, Grow.refl hs⟩
  | _ => exact MSim.pure ⟨rfl, Grow.refl hs⟩

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- Async `yield*`: the awaited inner result arrives. Its `done` is an own data property of an
ordinary object (an iterator result), not a renamed bigint; `value` is any lookup. -/
theorem step_ret_ystarAResult {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto)
    {a : Nat} {o : Obj} {dv it nx : Val} {w e : Bool} {fs : List Frame}
    (hc : s.ctl = .ret (.obj a)) (hs : s.stack = .k (.ystarAResult it nx) :: fs)
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary) (hd : findProp kDone o.props = some (.data dv w e))
    (hbig : ∀ i, dv = .big i → BigFixed K.lo K.hi i) (hn : s.next + margin < Sim.bound) (hW : ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  have hfr : K.fr a = none := h.fr_of_or ho (by intro es he; rw [hk] at he; cases he) (.inl (hW a))
  have ho' : t.obj? (M.a a) = some (M.obj o) := h.obj? ho hfr
  have hso := h.obj?_supp ho
  have hd' : findProp kDone (M.obj o).props = some (.data (M.val dv) w e) := by
    show findProp (M.key kDone) (M.props o.props) = _
    rw [findProp_map (k := kDone) h.inj (show Supp.key (Present s) S.tab.length kDone from trivial) hso.2.2.1, hd]
    rfl
  have hdv : Supp.val (Present s) S.tab.length dv := findProp_supp hso.2.2.1 hd
  have hk' : (M.obj o).kind = .ordinary := by show M.kind o.kind = _; rw [hk]; rfl
  show MSim _ S C (retK F { s with stack := fs } (.ystarAResult it nx) (.obj a))
    (retK F { t with stack := fs.map M.frame ++ stk } (.ystarAResult (M.val it) (M.val nx)) (.obj (M.a a)))
  simp only [retK]
  rw [dataOf_own F (s := { s with stack := fs }) ho hk hd, dataOf_own F (s := { t with stack := fs.map M.frame ++ stk }) ho' hk' hd']
  show MSim _ S C (Host.Ts.M.bind (truthy dv) _) (Host.Ts.M.bind (truthy (M.val dv)) _)
  refine MSim.bind (sim_truthy h.srv dv fun i hi => h.bigFixed i (hbig i hi)) ?_
  rintro M' S' C' r r' ⟨rfl, hg⟩
  have h2 := h1.grow hFR hg
  have hI' : ∀ a, a < aFirst → M'.a a = a := h2.intr
  have hva : Val.obj (M.a a) = M'.val (.obj a) := by show _ = Val.obj (M'.a a); rw [hg.ext.a]
  rw [hva]
  refine MSim.bind (dataOf_sim h2 hF hI' (recv := .obj a) (k := kValue) hv trivial
    (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
  rintro M'' S'' C'' x x' ⟨-, hS, hC, hxx, hx⟩
  rw [hS, hC, hxx]
  have hit : M'.val it = M.val it := Map.val_agree hg.ext.agree' hf.1
  have hnx : M'.val nx = M.val nx := Map.val_agree hg.ext.agree' hf.2
  rw [← hit, ← hnx]
  cases x with
  | none => exact MSim.fail _ _
  | some x =>
    have hxs : Supp.val (Present s) S'.tab.length x := hx x rfl
    cases r'
    · have hy := sim_agenYield (h2.push (.k (.ystarAResume it nx)) (Supp.frame_mono (fun _ h => h) hg.len hf))
        hpo hfp (margin_take hn _ (by decide)) hxs
      exact StepPost.after hg hy
    · exact StepPost.after hg (MSim.pure ⟨Grow.refl h2.srv, h2.ret x hxs⟩)

/-- A derived constructor's `super(...)` returned the parent's object: bind `this`, then run
parameter properties and fields. -/
theorem step_ret_superRet (hre : Present s aReferenceErrorProto)
    {v : Val} {tc cls : Nat} {env : Env} {fs : List Frame} {x : Option Val}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.superRet tc cls env) :: fs) (hcell : s.cell? tc = some x)
    (hn : s.next + margin < Sim.bound) (htw : W tc = none ∨ K.fr tc = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  obtain ⟨htc, hcls, henv⟩ := hf
  have hs0 := margin_take hn 0 (by decide)
  have hcell' : t.cell? (M.a tc) = some (x.map M.val) := h.cell? hcell (.of_or htw)
  have hfr : K.fr tc = none := h.fr_cell (cell?_iff.1 hcell) (.of_or htw)
  show MSim _ S C (retK F { s with stack := fs } (.superRet tc cls env) v)
    (retK F { t with stack := fs.map M.frame ++ stk } (.superRet (M.a tc) (M.a cls) (M.env env)) (M.val v))
  have hcell1 : ({ s with stack := fs } : St F.S).cell? tc = some x := hcell
  have hcell1' : ({ t with stack := fs.map M.frame ++ stk } : St F.S).cell? (M.a tc) = some (x.map M.val) := hcell'
  simp only [retK, hcell1, hcell1']
  cases x with
  | some y => exact refErr_sim h1 h1.intr hs0 hre _
  | none =>
    simp only [Option.map]
    have u1 := upd_setCell h1 hs0 htc hfr hv
    have hcls1 : Present ({ s with stack := fs }.setCell tc v) cls := u1.pres _ hcls
    cases v with
    | obj ob =>
      rcases u1.rel.objCases hcls1 with ⟨k1, k2⟩ | ⟨co, k1, -, k2⟩ | ⟨co, co', xs, ys, k1, k2, k3, k4⟩ |
        ⟨co, co', k1, k2, k3, -, -⟩
      rotate_left 3
      · obtain ⟨kind, proto, props, priv, ext⟩ := co
        cases kind <;> first | exact k3.elim | (simp only [k1]; exact MSim.fail _ _)
      · simp only [k1, k2]; exact MSim.fail _ _
      · obtain ⟨kind, proto, props, priv, ext⟩ := co
        have hco := u1.rel.obj?_supp k1
        cases kind with
        | fn cd =>
          cases cd with
          | klass ctor cenv par inst =>
            have k2' : ({ t with stack := fs.map M.frame ++ stk }.setCell (M.a tc) (.obj (M.a ob))).obj? (M.a cls) =
                some (M.obj ⟨.fn (.klass ctor cenv par inst), proto, props, priv, ext⟩) := k2
            simp only [k1, k2', Map.obj, Map.kind, Map.code, Map.val, thisEnv_eq]
            obtain ⟨hcenv, hpar, hinst⟩ := hco.1
            obtain ⟨ea, -, hp, u2⟩ := upd_alloc u1.rel (o := .cell (some (.obj ob)))
              (by have := u1.next; exact margin_take (by omega) 0 (by decide))
              (Supp.val_mono u1.pres (Nat.le_refl _) hv)
            have ea' : (({ t with stack := fs.map M.frame ++ stk }.setCell (M.a tc) (.obj (M.a ob))).alloc
                (.cell (some (.obj (M.a ob))))).1 =
                M.a (({ s with stack := fs }.setCell tc (.obj ob)).alloc (.cell (some (.obj ob)))).1 := ea
            rw [ea']
            have hP : ∀ a, Present s a → Present (({ s with stack := fs }.setCell tc (.obj ob)).alloc
                (.cell (some (.obj ob)))).2 a := fun a ha => u2.pres a (u1.pres a ha)
            have r3 := ((u2.rel.push (.e (.const (.obj ob))) (hP _ hv)).push
              (.k (.paramProps (.obj ob) ((ctor.map fnProps).getD []) env))
                ⟨hP _ hv, Supp.env_mono hP (Nat.le_refl _) henv⟩).push
              (.k (.fields ob inst ((nThis, (({ s with stack := fs }.setCell tc (.obj ob)).alloc
                (.cell (some (.obj ob)))).1) :: cenv)))
              ⟨hP _ hv, Supp.insts_mono u2.pres (Nat.le_refl _) hinst, fun y hy => by
                rcases List.mem_cons.1 hy with rfl | hy
                · exact hp
                · exact u2.pres _ (hcenv y hy)⟩
            exact MSim.pure ⟨Grow.refl h.srv, r3.ret .undef trivial⟩
          | _ => simp only [k1]; exact MSim.fail _ _
        | _ => simp only [k1]; exact MSim.fail _ _
      · obtain ⟨kind, proto, props, priv, ext⟩ := co
        cases k3
        simp only [k1]; exact MSim.fail _ _
    | _ => exact MSim.fail _ _

end

/-! ## `yield*`: iterator protocol frames -/

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- An iterator result's own `done` read on both sides (an ordinary object's own data property). -/
private theorem RelB.ownDone {s0 t0 : St F.S} (hheap : s0.heap = s.heap) (hheap' : t0.heap = t.heap)
    {a : Nat} {o : Obj} {dv : Val} {w e : Bool}
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary) (hd : findProp kDone o.props = some (.data dv w e))
    (hW : ∀ a, W a = none) :
    dataOf F s0 (.obj a) kDone = Host.Ts.M.pure (some dv) ∧
      dataOf F t0 (.obj (M.a a)) kDone = Host.Ts.M.pure (some (M.val dv)) ∧
      Supp.val (Present s) S.tab.length dv := by
  have hfr : K.fr a = none := h.fr_of_or ho (by intro es he; rw [hk] at he; cases he) (.inl (hW a))
  have ho' : t.obj? (M.a a) = some (M.obj o) := h.obj? ho hfr
  have hso := h.obj?_supp ho
  have hd' : findProp kDone (M.obj o).props = some (.data (M.val dv) w e) := by
    show findProp (M.key kDone) (M.props o.props) = _
    rw [findProp_map (k := kDone) h.inj (show Supp.key (Present s) S.tab.length kDone from trivial) hso.2.2.1, hd]
    rfl
  have hk' : (M.obj o).kind = .ordinary := by show M.kind o.kind = _; rw [hk]; rfl
  have ho0 : s0.obj? a = some o := by unfold St.obj?; rw [hheap]; exact ho
  have ho0' : t0.obj? (M.a a) = some (M.obj o) := by unfold St.obj?; rw [hheap']; exact ho'
  exact ⟨dataOf_own F ho0 hk hd, dataOf_own F ho0' hk' hd', findProp_supp hso.2.2.1 hd⟩

/-- Sync `yield*`: the iterator arrived; call its `next`. -/
theorem step_ret_ystarIt_sync {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) {v : Val} {fs : List Frame} {g : Nat} {b : Bool}
    (hc : s.ctl = .ret v) (hs : s.stack = .k .ystarIt :: fs)
    (hng : nearestGen fs = some (g, b)) (hgo : ∀ st, genOf s g ≠ some (st, true)) (hW : ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  have hg : Present s g := h1.stackSupp _ (nearestGen_mem hng)
  have hng' : nearestGen (fs.map M.frame ++ stk) = some (M.a g, b) :=
    nearestGen_append stk (by rw [nearestGen_map, hng]; rfl)
  show MSim _ S C (retK F { s with stack := fs } .ystarIt v) (retK F { t with stack := fs.map M.frame ++ stk } .ystarIt (M.val v))
  simp only [retK, hng, hng']
  rw [h1.genOf_map hg]
  have sync : MSim (StepPostB F FR W stk M ν K S C) S C
      (Host.Ts.M.bind (dataOf F { s with stack := fs } v kNext) fun
        | some next => Host.Ts.M.pure (({ s with stack := fs }.push (.k (.ystarNext v next))).go (.call next v [.undef]))
        | none => Host.Ts.M.fail "iterator next accessor")
      (Host.Ts.M.bind (dataOf F { t with stack := fs.map M.frame ++ stk } (M.val v) kNext) fun
        | some next => Host.Ts.M.pure (({ t with stack := fs.map M.frame ++ stk }.push (.k (.ystarNext (M.val v) next))).go
            (.call next (M.val v) [.undef]))
        | none => Host.Ts.M.fail "iterator next accessor") := by
    refine MSim.bind (dataOf_sim h1 hF h1.intr hv (k := kNext) trivial (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
    rintro M' S' C' x x' ⟨-, hS, hC, hxx, hx⟩
    rw [hS, hC, hxx]
    cases x with
    | none => exact MSim.fail _ _
    | some nx =>
      exact MSim.pure ⟨Grow.refl h.srv, (h1.push (.k (.ystarNext v nx)) ⟨hv, hx nx rfl⟩).go (.call nx v [.undef])
        ⟨hx nx rfl, hv, fun y hy => by rw [List.mem_singleton.1 hy]; trivial⟩⟩
  cases hg0 : genOf { s with stack := fs } g with
  | none => exact sync
  | some x =>
    obtain ⟨st, a⟩ := x
    cases a with
    | true => exact absurd hg0 (hgo st)
    | false => exact sync

/-- Async `yield*`: the async iterator arrived; call its `next` and await the result. -/
theorem step_ret_ystarAIt {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) {v : Val} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k .ystarAIt :: fs) (hW : ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  show MSim _ S C (retK F { s with stack := fs } .ystarAIt v) (retK F { t with stack := fs.map M.frame ++ stk } .ystarAIt (M.val v))
  simp only [retK]
  refine MSim.bind (dataOf_sim h1 hF h1.intr hv (k := kNext) trivial (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
  rintro M' S' C' x x' ⟨-, hS, hC, hxx, hx⟩
  rw [hS, hC, hxx]
  cases x with
  | none => exact MSim.fail _ _
  | some nx =>
    exact MSim.pure ⟨Grow.refl h.srv, ((h1.push (.k (.ystarAResult v nx)) ⟨hv, hx nx rfl⟩).push (.k .await) trivial).go
      (.call nx v [.undef]) ⟨hx nx rfl, hv, fun y hy => by rw [List.mem_singleton.1 hy]; trivial⟩⟩

/-- Sync `yield*`: the inner `next()` result arrived (its `done` an own data property). -/
theorem step_ret_ystarNext {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    {a : Nat} {o : Obj} {dv it nx : Val} {w e : Bool} {fs : List Frame}
    (hc : s.ctl = .ret (.obj a)) (hs : s.stack = .k (.ystarNext it nx) :: fs)
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary) (hd : findProp kDone o.props = some (.data dv w e))
    (hbig : ∀ i, dv = .big i → BigFixed K.lo K.hi i) (hn : s.next + margin < Sim.bound) (hW : ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  obtain ⟨d1, d2, hdv⟩ := h.ownDone (s0 := { s with stack := fs }) (t0 := { t with stack := fs.map M.frame ++ stk })
    rfl rfl ho hk hd hW
  show MSim _ S C (retK F { s with stack := fs } (.ystarNext it nx) (.obj a))
    (retK F { t with stack := fs.map M.frame ++ stk } (.ystarNext (M.val it) (M.val nx)) (.obj (M.a a)))
  simp only [retK]
  rw [d1, d2]
  show MSim _ S C (Host.Ts.M.bind (truthy dv) _) (Host.Ts.M.bind (truthy (M.val dv)) _)
  refine MSim.bind (sim_truthy h.srv dv fun i hi => h.bigFixed i (hbig i hi)) ?_
  rintro M' S' C' r r' ⟨rfl, hg⟩
  have h2 := h1.grow hFR hg
  have hva : Val.obj (M.a a) = M'.val (.obj a) := by show _ = Val.obj (M'.a a); rw [hg.ext.a]
  have hit : M'.val it = M.val it := Map.val_agree hg.ext.agree' hf.1
  have hnx : M'.val nx = M.val nx := Map.val_agree hg.ext.agree' hf.2
  rw [hva, ← hit, ← hnx]
  cases r'
  · have hy := sim_yieldResult (h2.push (.k (.ystarResume it nx)) (Supp.frame_mono (fun _ h => h) hg.len hf))
      (margin_take hn 0 (by decide)) (r := .obj a) hv
    exact StepPost.after hg hy
  · show MSim _ S' C' (Host.Ts.M.bind (dataOf F { s with stack := fs } (.obj a) kValue) _)
      (Host.Ts.M.bind (dataOf F { t with stack := fs.map M.frame ++ stk } (M'.val (.obj a)) kValue) _)
    refine MSim.bind (dataOf_sim h2 hF h2.intr (recv := .obj a) (k := kValue) hv trivial
      (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
    rintro M'' S'' C'' x x' ⟨-, hS, hC, hxx, hx⟩
    rw [hS, hC, hxx]
    cases x with
    | none => exact MSim.fail _ _
    | some x => exact StepPost.after hg (MSim.pure ⟨Grow.refl h2.srv, h2.ret x (hx x rfl)⟩)

/-- Async `yield*`: the awaited result of the inner `return()` arrived. -/
theorem step_ret_ystarAReturned {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) (hFR : FRLaws FR)
    (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto)
    {a : Nat} {o : Obj} {dv it nx : Val} {w e : Bool} {fs : List Frame}
    (hc : s.ctl = .ret (.obj a)) (hs : s.stack = .k (.ystarAReturned it nx) :: fs)
    (ho : s.obj? a = some o) (hk : o.kind = .ordinary) (hd : findProp kDone o.props = some (.data dv w e))
    (hbig : ∀ i, dv = .big i → BigFixed K.lo K.hi i) (hn : s.next + margin < Sim.bound) (hW : ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, hf⟩ := h.topRet hc hs
  rw [e1, e2]
  obtain ⟨d1, d2, hdv⟩ := h.ownDone (s0 := { s with stack := fs }) (t0 := { t with stack := fs.map M.frame ++ stk })
    rfl rfl ho hk hd hW
  show MSim _ S C (retK F { s with stack := fs } (.ystarAReturned it nx) (.obj a))
    (retK F { t with stack := fs.map M.frame ++ stk } (.ystarAReturned (M.val it) (M.val nx)) (.obj (M.a a)))
  simp only [retK]
  rw [d1, d2]
  show MSim _ S C (Host.Ts.M.bind (truthy dv) _) (Host.Ts.M.bind (truthy (M.val dv)) _)
  refine MSim.bind (sim_truthy h.srv dv fun i hi => h.bigFixed i (hbig i hi)) ?_
  rintro M' S' C' r r' ⟨rfl, hg⟩
  have h2 := h1.grow hFR hg
  have hva : Val.obj (M.a a) = M'.val (.obj a) := by show _ = Val.obj (M'.a a); rw [hg.ext.a]
  rw [hva]
  refine MSim.bind (dataOf_sim h2 hF h2.intr (recv := .obj a) (k := kValue) hv trivial
    (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
  rintro M'' S'' C'' x x' ⟨-, hS, hC, hxx, hx⟩
  rw [hS, hC, hxx]
  have hit : M'.val it = M.val it := Map.val_agree hg.ext.agree' hf.1
  have hnx : M'.val nx = M.val nx := Map.val_agree hg.ext.agree' hf.2
  rw [← hit, ← hnx]
  cases x with
  | none => exact MSim.fail _ _
  | some x =>
    have hxs : Supp.val (Present s) S'.tab.length x := hx x rfl
    cases r'
    · have hy := sim_agenYield (h2.push (.k (.ystarAResume it nx)) (Supp.frame_mono (fun _ h => h) hg.len hf))
        hpo hfp (margin_take hn _ (by decide)) hxs
      exact StepPost.after hg hy
    · exact StepPost.after hg (MSim.pure ⟨Grow.refl h2.srv, h2.go (.abr (.ret x)) hxs⟩)

end

/-! ## `yield*` start and `return`/`throw` into a delegated iterator -/

private theorem isIndexable_map {s t : St F.S} (h : RelB F FR W stk M ν K s S t C) {v : Val}
    (hv : Supp.val (Present s) S.tab.length v) (hW : ∀ a, W a = none) : isIndexable F t (M.val v) = isIndexable F s v := by
  cases v with
  | obj a =>
    have hp : Present s a := hv
    rcases h.objCases hp with ⟨h1, h2⟩ | ⟨o, h1, -, h2⟩ | ⟨o, o', xs, ys, h1, h2, k1, k2⟩ |
      ⟨o, o', h1, h2, -, -, hwn⟩
    rotate_left 3
    · exact absurd (hW a) hwn
    · simp only [Map.val, isIndexable, h1, h2]
    · obtain ⟨k, pr, ps, pv, ex⟩ := o
      simp only [Map.val, isIndexable, h1, h2, Map.obj]
      cases k <;> rfl
    · obtain ⟨k, pr, ps, pv, ex⟩ := o
      obtain ⟨k', pr', ps', pv', ex'⟩ := o'
      cases k1; cases k2
      simp only [Map.val, isIndexable, h1, h2]
  | _ => rfl

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- `yield*` received its operand: get the (async) iterator. -/
theorem step_ret_yield_delegate {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) (htp : Present s aTypeErrorProto) (hai : Present s aArrayIterProto)
    {v : Val} {fs : List Frame} (hc : s.ctl = .ret v) (hs : s.stack = .k (.yield true) :: fs)
    (hn : s.next + margin < Sim.bound) (hW : ∀ a, W a = none) (hfn : stk = [] ∨ fnB fs = true) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, hv, -⟩ := h.topRet hc hs
  rw [e1, e2]
  have hs0 := margin_take hn 0 (by decide)
  show MSim _ S C (retK F { s with stack := fs } (.yield true) v) (retK F { t with stack := fs.map M.frame ++ stk } (.yield true) (M.val v))
  simp only [retK, Bool.cond_true]
  have hng : nearestGen (fs.map M.frame ++ stk) = nearestGen (fs.map M.frame) := by
    rcases hfn with rfl | hfn
    · rw [List.append_nil]
    · exact nearestGen_append_fn stk (by rw [fnB_map]; exact hfn)
  rw [hng, nearestGen_map]
  have sync : MSim (StepPostB F FR W stk M ν K S C) S C
      (bif isIndexable F { s with stack := fs } v then
        (Host.Ts.M.pure ((({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).2.push (.k .ystarIt)).ret
          (.obj ({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).1)))
       else startIter F ({ s with stack := fs }.push (.k .ystarIt)) v)
      (bif isIndexable F { t with stack := fs.map M.frame ++ stk } (M.val v) then
        (Host.Ts.M.pure ((({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0) (.obj aArrayIterProto) []).2.push
          (.k .ystarIt)).ret (.obj ({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0)
            (.obj aArrayIterProto) []).1)))
       else startIter F ({ t with stack := fs.map M.frame ++ stk }.push (.k .ystarIt)) (M.val v)) := by
    rw [isIndexable_map h1 hv hW]
    cases isIndexable F { s with stack := fs } v
    · exact getV_sim ((h1.push (.k .ystarIt) trivial).push (.c (.method v [] [] false)) ⟨hv, fun _ hx => nomatch hx⟩)
        hF h1.intr hs0 htp hv (k := .sym symIterator) (fun h => absurd h (by decide))
        (LookupOK.of_plain (by decide) (by decide) hW _)
    · obtain ⟨ea, -, hp, u⟩ := upd_allocObj h1 (k := .iter v 0 0) (proto := .obj aArrayIterProto) (props := [])
        hs0 hv hai (fun _ hx => nomatch hx)
      have ep : M.val (.obj aArrayIterProto) = .obj aArrayIterProto := by
        show Val.obj (M.a aArrayIterProto) = _; rw [h.intr _ (by decide)]
      rw [ep] at ea u
      have ea' : ({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0) (.obj aArrayIterProto) []).1 =
          M.a ({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).1 := ea
      have u' : Upd F FR W stk M ν K S C { s with stack := fs } ({ s with stack := fs }.allocObj (.iter v 0 0) (.obj aArrayIterProto) []).2
          ({ t with stack := fs.map M.frame ++ stk }.allocObj (.iter (M.val v) 0 0) (.obj aArrayIterProto) []).2 1 := u
      rw [ea']
      exact MSim.pure ⟨Grow.refl h.srv, (u'.rel.push (.k .ystarIt) trivial).ret (.obj _) hp⟩
  cases hng : nearestGen fs with
  | none => exact sync
  | some x =>
    obtain ⟨g, b⟩ := x
    have hg : Present s g := h1.stackSupp _ (nearestGen_mem hng)
    simp only [Option.map]
    rw [h1.genOf_map hg]
    cases hgo : genOf { s with stack := fs } g with
    | none => exact sync
    | some y =>
      obtain ⟨st, a⟩ := y
      cases a with
      | false => exact sync
      | true =>
        simp only [Option.map, Option.elim, Bool.cond_true]
        cases v with
        | obj o =>
          exact getV_sim ((h1.push (.k .ystarAIt) trivial).push (.c (.method (.obj o) [] [] false))
            ⟨hv, fun _ hx => nomatch hx⟩) hF h1.intr hs0 htp hv (k := .sym symAsyncIterator)
            (fun h => absurd h (by decide)) (LookupOK.of_plain (by decide) (by decide) hW _)
        | _ => exact typeErr_sim h1 h1.intr hs0 htp _

/-- `return`/`throw`/`break` reaching a sync `yield*`: close the inner iterator on `return`. -/
theorem step_abr_ystarResume {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) {a : Abrupt} {it nx : Val} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.ystarResume it nx) :: fs) (hW : ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨hts, h1⟩ := h.pop hs
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  have ha : Supp.abr (Present s) S.tab.length a := by have := h.ctlSupp; rw [hc] at this; exact this
  have hf : Supp.frame (Present s) S.tab.length (.k (.ystarResume it nx)) :=
    h.stackSupp _ (by rw [hs]; exact List.mem_cons_self ..)
  have e1 : step F s = abrStep F { s with stack := fs } (.k (.ystarResume it nx)) a := by
    simp only [step, hc, stepAbr, hs]
  have e2 : step F t = abrStep F { t with stack := fs.map M.frame ++ stk } (M.frame (.k (.ystarResume it nx))) (M.abr a) := by
    simp only [step, htc, stepAbr, hts]
  rw [e1, e2]
  cases a with
  | ret v =>
    show MSim _ S C (Host.Ts.M.bind (dataOf F { s with stack := fs } it kReturn) _)
      (Host.Ts.M.bind (dataOf F { t with stack := fs.map M.frame ++ stk } (M.val it) kReturn) _)
    refine MSim.bind (dataOf_sim h1 hF h1.intr hf.1 (k := kReturn) trivial
      (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
    rintro M' S' C' x x' ⟨-, hS, hC, hxx, hx⟩
    rw [hS, hC, hxx]
    cases x with
    | none => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.ret v)) ha⟩
    | some m =>
      cases m with
      | obj m =>
        exact MSim.pure ⟨Grow.refl h.srv, (h1.push (.lp (.close (.abrupt (.ret v)))) ha).go (.call (.obj m) it [])
          ⟨hx _ rfl, hf.1, fun _ hx => nomatch hx⟩⟩
      | _ => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.ret v)) ha⟩
  | throw e => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.throw e)) ha⟩
  | brk l => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.brk l)) ha⟩
  | cont l => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.cont l)) ha⟩

/-- `return`/`throw` reaching an async `yield*`: forward to the inner iterator's `return`/`throw`. -/
theorem step_abr_ystarAResume {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}
    (hF : FfiSim F FR okCall okBack) (hpp : Present s aPromiseProto)
    {a : Abrupt} {it nx : Val} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.ystarAResume it nx) :: fs) (hn : s.next + margin < Sim.bound)
    (hW : ∀ a, W a = none) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨hts, h1⟩ := h.pop hs
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  have ha : Supp.abr (Present s) S.tab.length a := by have := h.ctlSupp; rw [hc] at this; exact this
  have hf : Supp.frame (Present s) S.tab.length (.k (.ystarAResume it nx)) :=
    h.stackSupp _ (by rw [hs]; exact List.mem_cons_self ..)
  have e1 : step F s = abrStep F { s with stack := fs } (.k (.ystarAResume it nx)) a := by
    simp only [step, hc, stepAbr, hs]
  have e2 : step F t = abrStep F { t with stack := fs.map M.frame ++ stk } (M.frame (.k (.ystarAResume it nx))) (M.abr a) := by
    simp only [step, htc, stepAbr, hts]
  rw [e1, e2]
  cases a with
  | ret v =>
    show MSim _ S C (Host.Ts.M.bind (dataOf F { s with stack := fs } it kReturn) _)
      (Host.Ts.M.bind (dataOf F { t with stack := fs.map M.frame ++ stk } (M.val it) kReturn) _)
    refine MSim.bind (dataOf_sim h1 hF h1.intr hf.1 (k := kReturn) trivial
      (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
    rintro M' S' C' x x' ⟨-, hS, hC, hxx, hx⟩
    rw [hS, hC, hxx]
    have await : MSim (StepPostB F FR W stk M ν K S C) S C
        (awaitVal F ({ s with stack := fs }.push (.k .ystarAReturn)) v)
        (awaitVal F ({ t with stack := fs.map M.frame ++ stk }.push (.k .ystarAReturn)) (M.val v)) :=
      sim_awaitVal (h1.push (.k .ystarAReturn) trivial) hpp (margin_take hn 1 (by decide)) ha
    cases x with
    | none => exact await
    | some m =>
      cases m with
      | obj m =>
        exact MSim.pure ⟨Grow.refl h.srv, ((h1.push (.k (.ystarAReturned it nx)) hf).push (.k .await) trivial).go
          (.call (.obj m) it [v]) ⟨hx _ rfl, hf.1, fun y hy => by rw [List.mem_singleton.1 hy]; exact ha⟩⟩
      | _ => exact await
  | throw e =>
    show MSim _ S C (Host.Ts.M.bind (dataOf F { s with stack := fs } it (.str chars!"throw")) _)
      (Host.Ts.M.bind (dataOf F { t with stack := fs.map M.frame ++ stk } (M.val it) (.str chars!"throw")) _)
    refine MSim.bind (dataOf_sim h1 hF h1.intr hf.1 (k := .str chars!"throw") trivial
      (LookupOK.of_plain (by decide) (by decide) hW _)) ?_
    rintro M' S' C' x x' ⟨-, hS, hC, hxx, hx⟩
    rw [hS, hC, hxx]
    cases x with
    | none => exact MSim.fail _ _
    | some m =>
      cases m with
      | obj m =>
        exact MSim.pure ⟨Grow.refl h.srv, ((h1.push (.k (.ystarAResult it nx)) hf).push (.k .await) trivial).go
          (.call (.obj m) it [e]) ⟨hx _ rfl, hf.1, fun y hy => by rw [List.mem_singleton.1 hy]; exact ha⟩⟩
      | _ => exact MSim.fail _ _
  | brk l => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.brk l)) ha⟩
  | cont l => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.cont l)) ha⟩

end

/-! ## Generator and async function boundaries -/

/-- Generator `g` is not about to start its body (so draining it allocates little). -/
def NoStart {S' : Type} (s : St S') (g : Nat) : Prop := ∀ body env a, genOf s g ≠ some (.start body env, a)

section
variable {S' : Type}

private theorem NoStart.heap {s s' : St S'} {g : Nat} (h : NoStart s g) (he : s'.heap = s.heap) : NoStart s' g := by
  intro body env a hg
  have e : genOf s' g = genOf s g := by unfold genOf St.obj?; rw [he]
  exact h body env a (e ▸ hg)

private theorem enqueueAll_heap (th : Bool) (v : Val) : ∀ (rs : List Reaction) (s : St S'),
    (enqueueAll s th v rs).heap = s.heap
  | [], _ => rfl
  | r :: rs, s => enqueueAll_heap th v rs (enqueue s ⟨r, th, v⟩)

private theorem NoStart.setObj_promise {s : St S'} {g a : Nat} {o : Obj} {st : PState} (h : NoStart s g)
    (hk : o.kind = .promise st) (ha : a < 2 ^ 64) : NoStart (s.setObj a o) g := by
  intro body env b hg
  unfold genOf St.obj? St.setObj at hg
  rw [PTrie.get_set_u64 _ _ _ ha] at hg
  by_cases hga : g = a
  · rw [ite_eq_left hga] at hg
    simp only [hk] at hg
    cases hg
  · rw [ite_eq_right hga] at hg
    exact h body env b hg

private theorem NoStart.settle {s : St S'} {g p : Nat} (h : NoStart s g) (hp : p < 2 ^ 64) (th : Bool) (v : Val) :
    NoStart (settle s p th v) g := by
  unfold Host.Ts.settle
  split
  · rename_i o rs hpo
    exact (h.setObj_promise rfl hp).heap (enqueueAll_heap th v rs _)
  · exact h

private theorem NoStart.resolveP {s : St S'} {g p : Nat} (h : NoStart s g) (hp : p < 2 ^ 64) (v : Val) :
    NoStart (resolveP s p v) g := by
  unfold Host.Ts.resolveP
  split
  · cases Nat.beq p _
    · exact h.heap rfl
    · exact h
  · exact h.settle hp false v

private theorem NoStart.alloc {s : St S'} {g : Nat} (h : NoStart s g) (o : HObj) (hg : g < s.next) (hn : s.next < 2 ^ 64) :
    NoStart (s.alloc o).2 g := fun body env a hgo => h body env a (by rw [← genOf_alloc s o hg hn]; exact hgo)

end

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- Completing the head request of an async generator, then draining it. -/
theorem upd_agenComplete (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto)
    (hn : s.next + (1 + 2 ^ 21) < Sim.bound) {g : Nat} (hg : Present s g) {c : Comp}
    (hc : Supp.comp (Present s) S.tab.length c) :
    Upd F FR W stk M ν K S C s (agenComplete F s g c) (agenComplete F t (M.a g) (M.comp c)) (1 + 2 ^ 21) := by
  have hs : s.next < Sim.bound := by omega
  have hg64 : g < 2 ^ 64 := h.present_lt hg hs
  have hgs : g < s.next := h.presentBound g hg
  have hb : Sim.bound = 2 ^ 61 := rfl
  have u1 : Upd F FR W stk M ν K S C s (setGen s g .done) (setGen t (M.a g) .done) 0 := upd_setGen h hs hg (st := .done) trivial
  have ns1 : NoStart (setGen s g .done) g := fun body env a hgo => by
    rw [genOf_setGen _ _ _ hg64] at hgo
    cases hx : genOf s g <;> rw [hx] at hgo <;> cases hgo
  unfold agenComplete
  dsimp only
  rw [u1.rel.agenQueue_map (u1.pres _ hg)]
  have hqs := u1.rel.agenQueue_supp g
  cases hq : agenQueue (setGen s g .done) g with
  | nil => exact (u1.trans (upd_ret u1.rel .undef trivial)).weaken (by omega)
  | cons x q =>
    obtain ⟨p, c0⟩ := x
    rw [hq] at hqs
    have hp : Present (setGen s g .done) p := (hqs _ (List.mem_cons_self ..)).1
    rw [Map.queue_cons]
    dsimp only
    have u2 : Upd F FR W stk M ν K S C (setGen s g .done) (setQueue (setGen s g .done) g q)
        (setQueue (setGen t (M.a g) .done) (M.a g) (M.queue q)) 0 :=
      upd_setQueue u1.rel (u1.bound (j := 0) (by omega)) (u1.pres _ hg) fun x hx => hqs x (List.mem_cons_of_mem _ hx)
    have ns2 : NoStart (setQueue (setGen s g .done) g q) g := fun body env a hgo => by
      rw [genOf_setQueue _ _ _ hg64] at hgo; exact ns1 body env a hgo
    have hP2 : ∀ a, Present s a → Present (setQueue (setGen s g .done) g q) a := fun a ha => u2.pres a (u1.pres a ha)
    have hn2 : (setQueue (setGen s g .done) g q).next ≤ s.next := by have := u1.next; have := u2.next; omega
    have hp64 : p < 2 ^ 64 := u2.rel.present_lt (u2.pres _ hp) (by omega)
    have drain : ∀ {s3 t3 : St F.S}, Upd F FR W stk M ν K S C (setQueue (setGen s g .done) g q) s3 t3 1 → NoStart s3 g →
        Upd F FR W stk M ν K S C s (agenDrain s3 g) (agenDrain t3 (M.a g)) (1 + 2 ^ 21) := by
      intro s3 t3 u3 ns3
      have u4 := upd_agenDrain u3.rel (u3.pres _ (hP2 _ hpo)) (u3.pres _ (hP2 _ hfp))
        (by have := u3.next; omega) (u3.pres _ (hP2 _ hg)) (fun body env hgo => absurd hgo (ns3 body env true))
      exact ((u1.trans u2).trans (u3.trans u4)).weaken (by omega)
    have hc2 := Supp.comp_mono hP2 (Nat.le_refl _) hc
    have hsq : (setQueue (setGen s g .done) g q).next < 2 ^ 64 := by omega
    have iter : ∀ {v : Val}, Supp.val (Present (setQueue (setGen s g .done) g q)) S.tab.length v →
        Upd F FR W stk M ν K S C s
          (agenDrain (resolveP (iterResult (setQueue (setGen s g .done) g q) v true).2 p
            (.obj (iterResult (setQueue (setGen s g .done) g q) v true).1)) g)
          (agenDrain (resolveP (iterResult (setQueue (setGen t (M.a g) .done) (M.a g) (M.queue q)) (M.val v) true).2
            (M.a p) (.obj (iterResult (setQueue (setGen t (M.a g) .done) (M.a g) (M.queue q)) (M.val v) true).1)) (M.a g))
          (1 + 2 ^ 21) := by
      intro v hv
      obtain ⟨e1, hr, u3⟩ := upd_iterResult u2.rel (hP2 _ hpo) (by omega) hv true
      have u4 := upd_resolveP u3.rel (u3.bound (j := 0) (by omega)) (u3.pres _ (u2.pres _ hp))
        (v := .obj (iterResult (setQueue (setGen s g .done) g q) v true).1) hr
      rw [e1]
      refine drain ((u3.trans u4).weaken (by omega)) ?_
      exact (ns2.alloc _ (u2.rel.presentBound g (hP2 g hg)) hsq).resolveP hp64 _
    cases c with
    | normal v => exact iter (v := .undef) trivial
    | abrupt ab =>
      cases ab with
      | throw e =>
        have u3 := upd_settle u2.rel (by omega) (u2.pres _ hp) true hc2
        exact drain (u3.weaken (by omega)) (ns2.settle hp64 true e)
      | ret v => exact iter hc2
      | brk l => exact drain ((Upd.refl u2.rel).weaken (by omega)) ns2
      | cont l => exact drain ((Upd.refl u2.rel).weaken (by omega)) ns2

end

private theorem RelB.topAbr {s t : St F.S} (h : RelB F FR W stk M ν K s S t C) {a : Abrupt} {f : Frame} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = f :: fs) :
    step F s = abrStep F { s with stack := fs } f a ∧
    step F t = abrStep F { t with stack := fs.map M.frame ++ stk } (M.frame f) (M.abr a) ∧
    RelB F FR W stk M ν K { s with stack := fs } S { t with stack := fs.map M.frame ++ stk } C ∧
    Supp.abr (Present s) S.tab.length a ∧ Supp.frame (Present s) S.tab.length f := by
  obtain ⟨hts, hr⟩ := h.pop hs
  have htc : t.ctl = .abr (M.abr a) := by rw [h.ctl, hc]; rfl
  refine ⟨by simp only [step, hc, stepAbr, hs], by simp only [step, htc, stepAbr, hts], hr, ?_,
    h.stackSupp f (by rw [hs]; exact List.mem_cons_self ..)⟩
  have := h.ctlSupp
  rw [hc] at this
  exact this

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- An async function's body completed normally: resolve its promise with `undefined`. -/
theorem step_ret_fn_async {v : Val} {p : Nat} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.fn (.async p)) :: fs) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, -, hp⟩ := h.topRet hc hs
  have hp : Present s p := hp
  rw [e1, e2]
  have u := upd_resolveP h1 (margin_take hn 0 (by decide)) hp (v := .undef) trivial
  exact MSim.pure ⟨Grow.refl h.srv, u.rel.ret (.obj p) (u.pres _ hp)⟩

/-- A generator's body completed normally: finish (sync) or complete the head request (async). -/
theorem step_ret_fn_gen (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto)
    {v : Val} {g : Nat} {fs : List Frame}
    (hc : s.ctl = .ret v) (hs : s.stack = .k (.fn (.gen g)) :: fs) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, -, hg⟩ := h.topRet hc hs
  have hg : Present s g := hg
  rw [e1, e2]
  have hs0 := margin_take hn 0 (by decide)
  show MSim _ S C (boundaryRet F { s with stack := fs } (.gen g)) (boundaryRet F { t with stack := fs.map M.frame ++ stk } (.gen (M.a g)))
  unfold boundaryRet
  dsimp only
  rw [h1.genOf_map hg]
  have sync : MSim (StepPostB F FR W stk M ν K S C) S C
      (retS F (iterResult (setGen { s with stack := fs } g .done) .undef true).2
        (.obj (iterResult (setGen { s with stack := fs } g .done) .undef true).1))
      (retS F (iterResult (setGen { t with stack := fs.map M.frame ++ stk } (M.a g) .done) .undef true).2
        (.obj (iterResult (setGen { t with stack := fs.map M.frame ++ stk } (M.a g) .done) .undef true).1)) := by
    have u1 : Upd F FR W stk M ν K S C { s with stack := fs } (setGen { s with stack := fs } g .done)
        (setGen { t with stack := fs.map M.frame ++ stk } (M.a g) .done) 0 := upd_setGen h1 hs0 hg (st := .done) trivial
    obtain ⟨ea, hr, u2⟩ := upd_iterResult u1.rel (u1.pres _ hpo) (u1.bound (j := 0) (margin_take hn 0 (by decide)))
      (v := .undef) trivial true
    rw [show M.val .undef = .undef from rfl] at ea u2
    rw [ea]
    exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret (.obj _) hr⟩
  cases hgo : genOf { s with stack := fs } g with
  | none => exact sync
  | some x =>
    obtain ⟨st, a⟩ := x
    cases a with
    | false => exact sync
    | true =>
      exact MSim.pure ⟨Grow.refl h.srv, (upd_agenComplete h1 hpo hfp (margin_take hn _ (by decide)) hg
        (c := .normal .undef) trivial).rel⟩

/-- `return`/`throw` leaving an async function: settle its promise. -/
theorem step_abr_fn_async {a : Abrupt} {p : Nat} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.fn (.async p)) :: fs) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, ha, hp⟩ := h.topAbr hc hs
  have hp : Present s p := hp
  rw [e1, e2]
  have hs0 := margin_take hn 0 (by decide)
  cases a with
  | ret v =>
    have u := upd_resolveP h1 hs0 hp ha
    exact MSim.pure ⟨Grow.refl h.srv, u.rel.ret (.obj p) (u.pres _ hp)⟩
  | throw e =>
    have u := upd_settle h1 hs0 hp true ha
    exact MSim.pure ⟨Grow.refl h.srv, u.rel.ret (.obj p) (u.pres _ hp)⟩
  | brk l => exact MSim.fail _ _
  | cont l => exact MSim.fail _ _

/-- `return`/`throw` leaving a generator body. -/
theorem step_abr_fn_gen (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto)
    {a : Abrupt} {g : Nat} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.fn (.gen g)) :: fs) (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, ha, hg⟩ := h.topAbr hc hs
  have hg : Present s g := hg
  rw [e1, e2]
  have hs0 := margin_take hn 0 (by decide)
  have u1 : Upd F FR W stk M ν K S C { s with stack := fs } (setGen { s with stack := fs } g .done)
      (setGen { t with stack := fs.map M.frame ++ stk } (M.a g) .done) 0 := upd_setGen h1 hs0 hg (st := .done) trivial
  cases a with
  | ret v =>
    show MSim _ S C (boundaryAbr F { s with stack := fs } (.gen g) (.ret v))
      (boundaryAbr F { t with stack := fs.map M.frame ++ stk } (.gen (M.a g)) (.ret (M.val v)))
    unfold boundaryAbr
    dsimp only
    rw [h1.genOf_map hg]
    have sync : MSim (StepPostB F FR W stk M ν K S C) S C
        (retS F (iterResult (setGen { s with stack := fs } g .done) v true).2
          (.obj (iterResult (setGen { s with stack := fs } g .done) v true).1))
        (retS F (iterResult (setGen { t with stack := fs.map M.frame ++ stk } (M.a g) .done) (M.val v) true).2
          (.obj (iterResult (setGen { t with stack := fs.map M.frame ++ stk } (M.a g) .done) (M.val v) true).1)) := by
      obtain ⟨ea, hr, u2⟩ := upd_iterResult u1.rel (u1.pres _ hpo) (u1.bound (j := 0) (margin_take hn 0 (by decide)))
        (Supp.val_mono u1.pres (Nat.le_refl _) ha) true
      rw [ea]
      exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret (.obj _) hr⟩
    cases hgo : genOf { s with stack := fs } g with
    | none => exact sync
    | some x =>
      obtain ⟨st, b⟩ := x
      cases b with
      | false => exact sync
      | true =>
        exact MSim.pure ⟨Grow.refl h.srv, (upd_agenComplete h1 hpo hfp (margin_take hn _ (by decide)) hg
          (c := .abrupt (.ret v)) ha).rel⟩
  | throw e =>
    show MSim _ S C (boundaryAbr F { s with stack := fs } (.gen g) (.throw e))
      (boundaryAbr F { t with stack := fs.map M.frame ++ stk } (.gen (M.a g)) (.throw (M.val e)))
    unfold boundaryAbr
    dsimp only
    rw [h1.genOf_map hg]
    have sync : MSim (StepPostB F FR W stk M ν K S C) S C
        (Host.Ts.M.pure ((setGen { s with stack := fs } g .done).go (.abr (.throw e))))
        (Host.Ts.M.pure ((setGen { t with stack := fs.map M.frame ++ stk } (M.a g) .done).go (.abr (.throw (M.val e))))) :=
      MSim.pure ⟨Grow.refl h.srv, u1.rel.go (.abr (.throw e)) (Supp.val_mono u1.pres (Nat.le_refl _) ha)⟩
    cases hgo : genOf { s with stack := fs } g with
    | none => exact sync
    | some x =>
      obtain ⟨st, b⟩ := x
      cases b with
      | false => exact sync
      | true =>
        exact MSim.pure ⟨Grow.refl h.srv, (upd_agenComplete h1 hpo hfp (margin_take hn _ (by decide)) hg
          (c := .abrupt (.throw e)) ha).rel⟩
  | brk l => exact MSim.fail _ _
  | cont l => exact MSim.fail _ _

end

/-! ## Sync generators: `next`/`return`/`throw` -/

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

theorem sim_genResume (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto)
    (htp : Present s aTypeErrorProto) (hn : s.next + 2 ^ 21 < Sim.bound) {g : Nat} (hg : Present s g)
    {mode : Nat} (hmode : mode = 0 ∨ mode = 1 ∨ mode = 2) {v : Val} (hv : Supp.val (Present s) S.tab.length v)
    (hstart : ∀ body env, genOf s g = some (.start body env, false) → StartOK K body env) :
    MSim (StepPostB F FR W stk M ν K S C) S C (genResume s g mode v) (genResume t (M.a g) mode (M.val v)) := by
  have hs : s.next < Sim.bound := by omega
  have hst := fun {st : GenState} {a : Bool} (hgo : genOf s g = some (st, a)) => h.genOf_supp hgo
  unfold genResume
  rw [h.genOf_map hg]
  cases hgo : genOf s g with
  | none => exact typeErr_sim h h.intr hs htp _
  | some x =>
    obtain ⟨st, a⟩ := x
    have hsg := hst hgo
    cases st with
    | running => exact typeErr_sim h h.intr hs htp _
    | start body env =>
      cases a with
      | true => exact MSim.fail _ _
      | false =>
        have he : Supp.env (Present s) S.tab.length env := hsg
        rcases hmode with rfl | rfl | rfl
        · obtain ⟨hcount, hfr⟩ := hstart body env hgo
          have u1 : Upd F FR W stk M ν K S C s (setGen s g .running) (setGen t (M.a g) .running) 0 :=
            upd_setGen h hs hg (st := .running) trivial
          have u2 : Upd F FR W stk M ν K S C (setGen s g .running) ((setGen s g .running).push (.k (.fn (.gen g))))
              ((setGen t (M.a g) .running).push (.k (.fn (.gen (M.a g))))) 0 :=
            upd_push u1.rel (.k (.fn (.gen g))) (u1.pres _ hg)
          have u3 := upd_enterBlock (ss := body) hfr u2.rel (u2.pres _ (u1.pres _ hfp))
            (by have := u1.next; have := u2.next; omega)
            (Supp.env_mono (fun a ha => u2.pres a (u1.pres a ha)) (Nat.le_refl _) he)
          exact MSim.pure ⟨Grow.refl h.srv, u3.rel⟩
        · have u1 : Upd F FR W stk M ν K S C s (setGen s g .done) (setGen t (M.a g) .done) 0 :=
            upd_setGen h hs hg (st := .done) trivial
          obtain ⟨ea, hr, u2⟩ := upd_iterResult u1.rel (u1.pres _ hpo) (u1.bound (j := 0) (by omega))
            (Supp.val_mono u1.pres (Nat.le_refl _) hv) true
          dsimp only
          rw [pair_eta (iterResult (setGen s g .done) v true), pair_eta (iterResult (setGen t (M.a g) .done) (M.val v) true), ea]
          exact MSim.pure ⟨Grow.refl h.srv, u2.rel.ret (.obj _) hr⟩
        · have u1 : Upd F FR W stk M ν K S C s (setGen s g .done) (setGen t (M.a g) .done) 0 :=
            upd_setGen h hs hg (st := .done) trivial
          exact MSim.pure ⟨Grow.refl h.srv, u1.rel.go (.abr (.throw v)) (Supp.val_mono u1.pres (Nat.le_refl _) hv)⟩
    | suspended su =>
      cases a with
      | true => exact MSim.fail _ _
      | false =>
        have hsu : Supp.susp (Present s) S.tab.length su := hsg
        have u1 : Upd F FR W stk M ν K S C s (setGen s g .running) (setGen t (M.a g) .running) 0 :=
          upd_setGen h hs hg (st := .running) trivial
        have e : (M.susp su).frames ++ t.stack = (su.frames ++ s.stack).map M.frame ++ stk := by
          rw [List.map_append, h.stack, List.append_assoc]; rfl
        have u2 : Upd F FR W stk M ν K S C (setGen s g .running) { setGen s g .running with stack := su.frames ++ s.stack }
            { setGen t (M.a g) .running with stack := (M.susp su).frames ++ t.stack } 0 := by
          rw [e]
          exact upd_restack u1.rel (su.frames ++ s.stack) fun f hf => by
            rcases List.mem_append.1 hf with hf | hf
            · exact Supp.frame_mono u1.pres (Nat.le_refl _) (hsu.1 f hf)
            · exact Supp.frame_mono u1.pres (Nat.le_refl _) (h.stackSupp f hf)
        have hv2 := Supp.val_mono (fun a ha => u2.pres a (u1.pres a ha)) (Nat.le_refl _) hv
        dsimp only
        rcases hmode with rfl | rfl | rfl
        · exact MSim.pure ⟨Grow.refl h.srv, u2.rel.go (.ret v) hv2⟩
        · exact MSim.pure ⟨Grow.refl h.srv, u2.rel.go (.abr (.ret v)) hv2⟩
        · exact MSim.pure ⟨Grow.refl h.srv, u2.rel.go (.abr (.throw v)) hv2⟩
    | done =>
      cases a with
      | true => exact MSim.fail _ _
      | false =>
        rcases hmode with rfl | rfl | rfl
        · obtain ⟨ea, hr, u1⟩ := upd_iterResult h hpo hs (v := .undef) trivial true
          dsimp only
          rw [pair_eta (iterResult s .undef true), pair_eta (iterResult t .undef true)]
          rw [show M.val .undef = .undef from rfl] at ea u1
          rw [ea]
          exact MSim.pure ⟨Grow.refl h.srv, u1.rel.ret (.obj _) hr⟩
        · obtain ⟨ea, hr, u1⟩ := upd_iterResult h hpo hs hv true
          dsimp only
          rw [pair_eta (iterResult s v true), pair_eta (iterResult t (M.val v) true), ea]
          exact MSim.pure ⟨Grow.refl h.srv, u1.rel.ret (.obj _) hr⟩
        · exact MSim.pure ⟨Grow.refl h.srv, h.go (.abr (.throw v)) hv⟩

/-- `next`/`return`/`throw` of a sync generator. -/
theorem step_call_gen (hpo : Present s aObjectProto) (hfp : Present s aFunctionProto) (htp : Present s aTypeErrorProto)
    {a : Nat} {this : Val} {args : List Val} {o : Obj} {f : CtlN} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o) (hk : o.kind = .fn (.native (.ctl f) data))
    (hf : f = .genNext ∨ f = .genReturn ∨ f = .genThrow)
    (hstart : ∀ g body env, this = .obj g → genOf s g = some (.start body env, false) → StartOK K body env)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, hthis, hargs, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  have hn' := margin_take hn (2 ^ 21) (by decide)
  have hs := margin_take hn 0 (by decide)
  have key : ∀ mode, (mode = 0 ∨ mode = 1 ∨ mode = 2) →
      MSim (StepPostB F FR W stk M ν K S C) S C (ctlN.gen F s this args mode) (ctlN.gen F t (M.val this) (M.vals args) mode) := by
    intro mode hm
    unfold ctlN.gen
    cases this with
    | obj g =>
      rw [arg_map]
      exact sim_genResume h hpo hfp htp hn' hthis hm (Supp.vals_arg hargs 0) (hstart g · · rfl)
    | _ => exact typeErr_sim h h.intr hs htp _
  rcases hf with rfl | rfl | rfl
  · exact key 0 (.inl rfl)
  · exact key 1 (.inr (.inl rfl))
  · exact key 2 (.inr (.inr rfl))

end

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- An abrupt completion reaching `new Promise`'s executor frame: a throw rejects the promise. -/
theorem step_abr_native_promiseCtor {a : Abrupt} {p : Val} {fs : List Frame}
    (hc : s.ctl = .abr a) (hs : s.stack = .k (.native (.ctl .promiseCtor) [p]) :: fs)
    (hn : s.next + margin < Sim.bound) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, h1, ha, hf⟩ := h.topAbr hc hs
  rw [e1, e2]
  have hp : Supp.val (Present s) S.tab.length p := hf p (List.mem_singleton_self _)
  cases a with
  | throw e =>
    cases p with
    | obj q =>
      have u := upd_settle h1 (margin_take hn 0 (by decide)) hp true ha
      exact MSim.pure ⟨Grow.refl h.srv, u.rel.ret (.obj q) (u.pres _ hp)⟩
    | _ => exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.throw e)) ha⟩
  | ret v => cases p <;> exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.ret v)) ha⟩
  | brk l => cases p <;> exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.brk l)) ha⟩
  | cont l => cases p <;> exact MSim.pure ⟨Grow.refl h.srv, h1.go (.abr (.cont l)) ha⟩

end

section
variable {s t : St F.S} (h : RelB F FR W stk M ν K s S t C)
include h

/-- Calling `Promise` or `AsyncLocalStorage` without `new` is rejected by the model on both sides. -/
theorem step_call_ctl_ctor {a : Nat} {this : Val} {args : List Val} {o : Obj} {f : CtlN} {data : List Val}
    (hc : s.ctl = .call (.obj a) this args) (ho : s.obj? a = some o) (hk : o.kind = .fn (.native (.ctl f) data))
    (hf : f = .promiseCtor ∨ f = .alsCtor) :
    MSim (StepPostB F FR W stk M ν K S C) S C (step F s) (step F t) := by
  obtain ⟨e1, e2, -, -, -⟩ := h.topCall hc ho hk
  rw [e1, e2]
  rcases hf with rfl | rfl <;> exact MSim.fail _ _

end

end
end Host.Ts.Sim
