import host.sim.Restart
import host.sim.template.Sigma

/-! # The JavaScript parts of the shift and of the base relation

`ShiftJS` is `Shift` without its native field `ffi` (the native relation `FS`
is stated separately); `RelJS` is `Rel` without `ffi`. -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim

structure ShiftJS (F : Ffi) (σ : Map) (θ : Nat → SymE) (K : Ctx)
    (s0 : St F.S) (S0 : SSrv) (s1 : St F.S) (S1 : SSrv) : Prop where
  num : ∀ i e, nth? S0.tab i = some e → S1.val (σ.num i) = some (e.subst θ)
  heap : ∀ a h, s0.heap.get a = some h → K.fr a = none → s1.heap.get (σ.a a) = some (σ.hobj h)
  framed : ∀ a pre pre', K.fr a = some (pre, pre') → σ.a a = a ∧
    ∃ o xs, s0.heap.get a = some (.obj o) ∧ o.kind = .array pre ∧
      s1.heap.get a = some (.obj { σ.obj o with kind := .array (pre ++ xs) })
  next : ∀ k, σ.a (s0.next + k) = s1.next + k
  grows : s0.next ≤ s1.next
  present : ∀ a, Present s0 a → Present s1 (σ.a a)
  inj : ∀ a b, Present s0 a → Present s0 b → σ.a a = σ.a b → a = b
  presentBound : ∀ a, Present s0 a → a < s0.next
  framedPresent : ∀ a p, K.fr a = some p → Present s0 a
  ctl : s1.ctl = σ.ctl s0.ctl
  stack : s1.stack = s0.stack.map σ.frame
  jobs : s1.jobs = s0.jobs.map σ.job
  stores : s1.stores = σ.stores s0.stores
  heapSupp : ∀ a h, s0.heap.get a = some h → Supp.hobj (Present s0) S0.tab.length h
  ctlSupp : Supp.ctl (Present s0) S0.tab.length s0.ctl
  stackSupp : ∀ f ∈ s0.stack, Supp.frame (Present s0) S0.tab.length f
  jobsSupp : ∀ j ∈ s0.jobs, Supp.job (Present s0) S0.tab.length j
  storesSupp : Supp.stores (Present s0) S0.tab.length s0.stores
  bigFixed : ∀ i, BigFixed K.lo K.hi i → σ.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → σ.big (ptrInt (.ext r) off) = ptrInt (.ext (σ.region r)) off
  intr : ∀ a, a < aFirst → σ.a a = a

theorem ShiftJS.toShift {F : Ffi} {FS : Map → F.S → F.S → Prop} {σ : Map} {θ : Nat → SymE} {K : Ctx}
    {s0 : St F.S} {S0 : SSrv} {s1 : St F.S} {S1 : SSrv} (h : ShiftJS F σ θ K s0 S0 s1 S1)
    (hffi : FS σ s0.ffi s1.ffi) : Shift F FS σ θ K s0 S0 s1 S1 :=
  ⟨h.num, h.heap, h.framed, h.next, h.grows, h.present, h.inj, h.presentBound, h.framedPresent, h.ctl,
    h.stack, h.jobs, h.stores, hffi, h.heapSupp, h.ctlSupp, h.stackSupp, h.jobsSupp, h.storesSupp,
    h.bigFixed, h.bigExt, h.intr⟩

structure RelJS (F : Ffi) (M : Map) (ν : Nat → F64) (K : Ctx) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop where
  srv : Srv M ν S C
  heap : ∀ a h, s.heap.get a = some h → SlotOK M K.fr a h (t.heap.get (M.a a))
  next : ∀ k, M.a (s.next + k) = t.next + k
  offset : t.next = s.next + K.D
  room : K.D < bound
  bigFixed : ∀ i, BigFixed K.lo K.hi i → M.big i = i
  bigExt : ∀ r off, off < 2 ^ 24 → M.big (ptrInt (.ext r) off) = ptrInt (.ext (M.region r)) off
  band : K.hi ≤ 2 ^ 56
  intr : ∀ a, a < aFirst → M.a a = a
  bound : ∀ a, Present s a → M.a a < t.next
  inj : ∀ a b, Present s a → Present s b → M.a a = M.a b → a = b
  presentBound : ∀ a, Present s a → a < s.next
  framedPresent : ∀ a p, K.fr a = some p → Present s a
  ctl : t.ctl = M.ctl s.ctl
  stack : t.stack = s.stack.map M.frame
  jobs : t.jobs = s.jobs.map M.job
  stores : t.stores = M.stores s.stores
  trace : ∃ fresh, s.trace = fresh ++ K.base ∧ t.trace = fresh.map M.event ++ K.base'
  heapSupp : ∀ a h, s.heap.get a = some h → Supp.hobj (Present s) S.tab.length h
  ctlSupp : Supp.ctl (Present s) S.tab.length s.ctl
  stackSupp : ∀ f ∈ s.stack, Supp.frame (Present s) S.tab.length f
  jobsSupp : ∀ j ∈ s.jobs, Supp.job (Present s) S.tab.length j
  storesSupp : Supp.stores (Present s) S.tab.length s.stores
  traceSupp : ∃ fresh, s.trace = fresh ++ K.base ∧ ∀ e ∈ fresh, Supp.event (Present s) S.tab.length e

theorem RelJS.toRel {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
    {s : St F.S} {S : SSrv} {t : St F.S} {C : CSrv} (h : RelJS F M ν K s S t C)
    (hffi : FR M S.tab.length s.ffi t.ffi) : Rel F FR M ν K s S t C :=
  ⟨h.srv, h.heap, h.next, h.offset, h.room, h.bigFixed, h.bigExt, h.band, h.intr, h.bound, h.inj,
    h.presentBound, h.framedPresent, h.ctl, by rw [List.append_nil]; exact h.stack, h.jobs, h.stores, hffi, h.trace, h.heapSupp,
    h.ctlSupp, h.stackSupp, h.jobsSupp, h.storesSupp, h.traceSupp⟩

/-! ## Checks for the oracle and the number correspondence of a base relation -/

def checkGood (ν : Nat → F64) (o : List Ans) : Bool :=
  o.all fun q => F64.test q.op (q.a.eval ν) (q.b.eval ν) == q.r

theorem checkGood_sound {ν : Nat → F64} {o : List Ans} (h : checkGood ν o = true) : Good ν o := by
  intro q hq
  simp only [checkGood, List.all_eq_true, beq_iff_eq] at h
  exact h q hq

def checkNumOK (M : Map) (ν : Nat → F64) (S : SSrv) (C : CSrv) : Bool :=
  (List.range S.tab.length).all fun i => match nth? S.tab i with
    | some e => decide (C.val (M.num i) = some (e.eval ν))
    | none => true

theorem checkNumOK_sound {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} (h : checkNumOK M ν S C = true) :
    NumOK M ν S C := by
  intro i e he
  simp only [checkNumOK, List.all_eq_true, List.mem_range] at h
  have := h i (nth?_lt S.tab i e he)
  rw [he] at this
  simpa using this

/-! ## The framed output arrays of the decode loop -/

/-- `forwarded` and `emitted`. -/
def framedList : List Nat := [2673447, 12502]

def arrOf {S : Type} (s : St S) (a : Nat) : List Val :=
  match s.heap.get a with
  | some (.obj o) => match o.kind with
    | .array es => es
    | _ => []
  | _ => []

def objOf {S : Type} (s : St S) (a : Nat) : Obj :=
  match s.heap.get a with
  | some (.obj o) => o
  | _ => ⟨.ordinary, .undef, [], [], true⟩

/-- The framed prefixes: the template's own arrays, and target prefixes `p1`, `p2`. -/
def frOf {S : Type} (s0 : St S) (p1 p2 : List Val) (a : Nat) : Option (List Val × List Val) :=
  bif Nat.beq a 2673447 then some (arrOf s0 2673447, p1)
  else bif Nat.beq a 12502 then some (arrOf s0 12502, p2) else none

theorem frOf_none {S : Type} {s0 : St S} {p1 p2 : List Val} {a : Nat} (h : frOf s0 p1 p2 a = none) :
    a ∉ framedList := by
  intro hm
  simp only [framedList, List.mem_cons, List.not_mem_nil, or_false] at hm
  rcases hm with rfl | rfl <;> simp [frOf] at h

theorem frOf_some {S : Type} {s0 : St S} {p1 p2 : List Val} {a : Nat} {p : List Val × List Val}
    (h : frOf s0 p1 p2 a = some p) : (a = 2673447 ∧ p = (arrOf s0 2673447, p1)) ∨ (a = 12502 ∧ p = (arrOf s0 12502, p2)) := by
  unfold frOf at h
  cases h1 : Nat.beq a 2673447
  · cases h2 : Nat.beq a 12502
    · simp [h1, h2] at h
    · simp only [h1, h2, Bool.cond_false, Bool.cond_true, Option.some.injEq] at h
      exact Or.inr ⟨Nat.eq_of_beq_eq_true h2, h.symm⟩
  · simp only [h1, Bool.cond_true, Option.some.injEq] at h
    exact Or.inl ⟨Nat.eq_of_beq_eq_true h1, h.symm⟩

/-! ## Fresh template variables -/

def symOcc (v : Nat) : SymE → Bool
  | .lit _ => false
  | .var i => Nat.beq i v
  | .bin _ a b => symOcc v a || symOcc v b
  | .un _ a => symOcc v a

/-- Variable `v` occurs in none of the end server's table and oracle and the template's table. -/
def freshVar (v : Nat) (S1 : SSrv) (tab0 : List SymE) : Bool :=
  !(S1.tab.any (symOcc v)) && !(S1.oracle.any fun q => symOcc v q.a || symOcc v q.b) && !(tab0.any (symOcc v))

/-! ## Valuation-generic number correspondence -/

/-- A symbolic number correspondence (`checkNum` against the target's symbolic server) gives
the concrete one at every valuation of the target's variables. -/
theorem numOK_of_subst {M : Map} {θ : Nat → SymE} {S T : SSrv}
    (h : ∀ i e, nth? S.tab i = some e → T.val (M.num i) = some (e.subst θ)) (ρ : Nat → F64) :
    NumOK M (fun j => (θ j).eval ρ) S ⟨T.tab.map (SymE.eval ρ)⟩ := by
  intro i e he
  rw [val_inst (S := T) (C := ⟨T.tab.map (SymE.eval ρ)⟩) rfl, h i e he]
  simp [SymE.eval_subst]

/-- The JavaScript part of a base relation does not see the target's native state. -/
theorem RelJS.setFfi {F : Ffi} {M : Map} {ν : Nat → F64} {K : Ctx} {s : St F.S} {S : SSrv} {t : St F.S}
    {C : CSrv} (h : RelJS F M ν K s S t C) (x : F.S) : RelJS F M ν K s S (t.setFfi x) C :=
  ⟨h.srv, h.heap, h.next, h.offset, h.room, h.bigFixed, h.bigExt, h.band, h.intr, h.bound, h.inj,
    h.presentBound, h.framedPresent, h.ctl, h.stack, h.jobs, h.stores, h.trace, h.heapSupp,
    h.ctlSupp, h.stackSupp, h.jobsSupp, h.storesSupp, h.traceSupp⟩

end Host.Ts.Sim.Template
