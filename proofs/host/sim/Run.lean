import host.sim.Rel
namespace Host.Ts.Sim

/-! # Checked source runs

`runOk F ok n s S` is the symbolic run `runS F n s S` that additionally
requires `ok` of every state it steps from. The kernel evaluates it on the
template; `runOk_sim` turns a checked run into the corresponding target run
for every related target, given the one-step simulation `StepSim` for the
states `ok` accepts. -/

def runOkStep (F : Ffi) (ok : St F.S → SSrv → Bool) (ih : St F.S → SSrv → Option (St F.S × SSrv))
    (s : St F.S) (c : SSrv) : Option (St F.S × SSrv) :=
  bif isHalt s.ctl then some (s, c) else
    match interpS (step F s).run c with
    | some (s', c') => bif ok s' c' then s'.rebuild fun s' => ih s' c' else none
    | none => none

def runOk (F : Ffi) (ok : St F.S → SSrv → Bool) (n : Nat) : St F.S → SSrv → Option (St F.S × SSrv) :=
  Nat.rec (motive := fun _ => St F.S → SSrv → Option (St F.S × SSrv)) (fun s c => some (s, c))
    (fun _ ih => runOkStep F ok ih) n

section
variable (F : Ffi) (ok : St F.S → SSrv → Bool)
theorem runOk_zero (s : St F.S) (c : SSrv) : runOk F ok 0 s c = some (s, c) := rfl
theorem runOk_succ (n : Nat) (s : St F.S) (c : SSrv) :
    runOk F ok (n + 1) s c = bif isHalt s.ctl then some (s, c) else
      match interpS (step F s).run c with
      | some (s', c') => bif ok s' c' then s'.rebuild fun s' => runOk F ok n s' c' else none
      | none => none := rfl

theorem runOk_trans (m n : Nat) (s s' s'' : St F.S) (c c' c'' : SSrv)
    (h1 : runOk F ok m s c = some (s', c')) (h2 : runOk F ok n s' c' = some (s'', c'')) :
    runOk F ok (m + n) s c = some (s'', c'') := by
  induction m generalizing s c with
  | zero =>
    simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h1
    obtain ⟨rfl, rfl⟩ := h1
    simpa using h2
  | succ m ih =>
    rw [Nat.succ_add, runOk_succ]
    rw [runOk_succ] at h1
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h1 ⊢
      cases hs : interpS (step F s).run c with
      | none => simp [hs] at h1
      | some p =>
        obtain ⟨s1, c1⟩ := p
        simp only [hs] at h1 ⊢
        cases hk : ok s1 c1
        · simp [hk] at h1
        · simp only [hk, Bool.cond_true, St.rebuild_eq] at h1 ⊢
          exact ih s1 c1 h1
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h1 ⊢
      obtain ⟨rfl, rfl⟩ := h1
      cases n with
      | zero =>
        simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h2
        exact h2
      | succ n =>
        rw [runOk_succ, hh] at h2
        simpa using h2
end

/-- The one-step obligation: from related states, every non-halted source
step between accepted states has a related target step under an extension
of the map. -/
def StepSim (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop) : Prop :=
  ∀ M ν K s S t C s1 S1, Kp K → Rel F FR M ν K s S t C →
    isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) → ok s1 S1 = true →
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      Rel F FR M' ν K s1 S1 t1 C1

/-- Halting is preserved by the relation. -/
theorem RelB.isHalt {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s : St F.S} {S : SSrv}
    {t : St F.S} {C : CSrv} (h : RelB F FR W stk M ν K s S t C) : isHalt t.ctl = isHalt s.ctl := by
  rw [h.ctl]
  cases s.ctl <;> rfl

theorem runOk_sim (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Kp : Ctx → Prop) (hsim : StepSim F FR ok Kp) (ν : Nat → F64) (K : Ctx) (hK : Kp K) :
    ∀ n M s S t C s' S', Rel F FR M ν K s S t C → ok s S = true → runOk F ok n s S = some (s', S') →
      ∃ M' t' C', runC F n t C = some (t', C') ∧ Ext M M' S.tab.length ∧
        Rel F FR M' ν K s' S' t' C' := by
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
          obtain ⟨M1, t1, C1, ht, he1, hr1⟩ := hsim M ν K s S t C s1 S1 hK hr hh hok hs hk
          obtain ⟨M', t', C', ht', he', hr'⟩ := ih M1 s1 S1 t1 C1 s' S' hr1 hk h
          refine ⟨M', t', C', ?_, he1.trans he' (interpS_len _ _ _ _ hs), hr'⟩
          simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_false, ht, St.rebuild_eq]
          exact ht'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine ⟨M, t, C, ?_, Ext.refl _ _, hr⟩
      simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_true]

end Host.Ts.Sim

namespace Host.Ts.Sim

/-! ## Values a statement list discards

Appending to a framed array returns the array's length, which differs between
iterations (the two sides keep their own prefixes). The statement-list frame that
receives it discards it. `RelD` relates such a pair: the target agrees with a
related state except in the returned value, and the source's top frame is a
statement-list frame. `RelX` is either relation; a checked run keeps it. -/

def RelDB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame) (M : Map)
    (ν : Nat → F64) (K : Ctx) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  ∃ v v' r env fs, s.ctl = .ret v ∧ t.ctl = .ret v' ∧ s.stack = .s (.block r env) :: fs ∧
    RelB F FR W stk M ν K s S { t with ctl := M.ctl s.ctl } C

def RelXB (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (stk : List Frame) (M : Map)
    (ν : Nat → F64) (K : Ctx) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelB F FR W stk M ν K s S t C ∨ RelDB F FR W stk M ν K s S t C

/-- `RelDB` and `RelXB` without a stack base. -/
abbrev RelDF (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (M : Map) (ν : Nat → F64)
    (K : Ctx) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelDB F FR W [] M ν K s S t C

abbrev RelXF (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (W : Nat → Option WFrame) (M : Map) (ν : Nat → F64)
    (K : Ctx) (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelXB F FR W [] M ν K s S t C

/-- `RelDF` and `RelXF` without frames. -/
abbrev RelD (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (ν : Nat → F64) (K : Ctx)
    (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelDF F FR noFrames M ν K s S t C

abbrev RelX (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (ν : Nat → F64) (K : Ctx)
    (s : St F.S) (S : SSrv) (t : St F.S) (C : CSrv) : Prop :=
  RelXF F FR noFrames M ν K s S t C

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64}
  {K : Ctx} {s t : St F.S} {S : SSrv} {C : CSrv}

/-- A statement-list frame ignores the value it receives. -/
theorem step_block_value (t : St F.S) (v v' : Val) (r : List Stmt) (env : Env) (fs : List Frame)
    (hs : t.stack = .s (.block r env) :: fs) :
    step F { t with ctl := .ret v } = step F { t with ctl := .ret v' } := by
  obtain ⟨heap, nx, c, st, aux⟩ := t
  simp only at hs
  subst hs
  cases r <;> rfl

/-- Under `RelD` the target steps exactly as the related state. -/
theorem RelDB.step_eq (h : RelDB F FR W stk M ν K s S t C) :
    step F t = step F { t with ctl := M.ctl s.ctl } := by
  obtain ⟨v, v', r, env, fs, hc, htc, hs, hr⟩ := h
  have hts : t.stack = .s (.block r (M.env env)) :: (fs.map M.frame ++ stk) := by
    have := hr.stack
    simp only at this
    rw [this, hs]
    rfl
  have e1 : t = { t with ctl := .ret v' } := by cases t; simp only at htc; rw [htc]
  rw [hc]
  conv => lhs; rw [e1]
  exact step_block_value t v' (M.val v) r (M.env env) (fs.map M.frame ++ stk) hts

theorem RelXB.isHalt (h : RelXB F FR W stk M ν K s S t C) : isHalt t.ctl = isHalt s.ctl := by
  rcases h with h | ⟨v, v', r, env, fs, hc, htc, _, _⟩
  · exact h.isHalt
  · rw [hc, htc]; rfl

/-- At a state that is not returning a value, `RelX` is `Rel`. -/
theorem RelXB.rel (h : RelXB F FR W stk M ν K s S t C) (hc : ∀ v, s.ctl ≠ .ret v) : RelB F FR W stk M ν K s S t C := by
  rcases h with h | ⟨v, _, _, _, _, hv, _⟩
  · exact h
  · exact absurd hv (hc v)
end

/-- The one-step obligation for `RelX`. -/
def StepSimX (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool) (Kp : Ctx → Prop) : Prop :=
  ∀ M ν K s S t C s1 S1, Kp K → RelX F FR M ν K s S t C →
    isHalt s.ctl = false → ok s S = true → interpS (step F s).run S = some (s1, S1) → ok s1 S1 = true →
    ∃ M' t1 C1, interpC (step F t).run C = some (t1, C1) ∧ Ext M M' S.tab.length ∧
      RelX F FR M' ν K s1 S1 t1 C1

theorem runOk_simX (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (ok : St F.S → SSrv → Bool)
    (Kp : Ctx → Prop) (hsim : StepSimX F FR ok Kp) (ν : Nat → F64) (K : Ctx) (hK : Kp K) :
    ∀ n M s S t C s' S', RelX F FR M ν K s S t C → ok s S = true → runOk F ok n s S = some (s', S') →
      ∃ M' t' C', runC F n t C = some (t', C') ∧ Ext M M' S.tab.length ∧
        RelX F FR M' ν K s' S' t' C' := by
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
          obtain ⟨M1, t1, C1, ht, he1, hr1⟩ := hsim M ν K s S t C s1 S1 hK hr hh hok hs hk
          obtain ⟨M', t', C', ht', he', hr'⟩ := ih M1 s1 S1 t1 C1 s' S' hr1 hk h
          refine ⟨M', t', C', ?_, he1.trans he' (interpS_len _ _ _ _ hs), hr'⟩
          simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_false, ht, St.rebuild_eq]
          exact ht'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine ⟨M, t, C, ?_, Ext.refl _ _, hr⟩
      simp only [runC, runWith_succ, hr.isHalt, hh, Bool.cond_true]

end Host.Ts.Sim
