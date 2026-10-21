import host.sim.Free
namespace Host.Ts.Sim
open Host.Ts

/-! # Oracle prefixes

A symbolic run consumes its oracle from the front. A run that leaves a common
suffix `O2` of its oracle unconsumed runs the same without it: the answers it
uses are exactly the consumed prefix. -/

theorem SSrv.val_with (S : SSrv) (O : List Ans) : ({ S with oracle := O } : SSrv).val = S.val := rfl

theorem SSrv.answer_some {c c' : SSrv} {op : NTest} {x y : SymE} {r : Bool} (h : c.answer op x y = some (r, c')) :
    ∃ q o, c.oracle = q :: o ∧ q.op = op ∧ q.a = x ∧ q.b = y ∧ r = q.r ∧ c' = { c with oracle := o } := by
  unfold SSrv.answer at h
  split at h
  · rename_i q o ho
    cases hd : decide (q.op = op ∧ q.a = x ∧ q.b = y)
    · simp [hd] at h
    · simp only [hd, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨q, o, ho, (of_decide_eq_true hd).1, (of_decide_eq_true hd).2.1, (of_decide_eq_true hd).2.2, rfl, rfl⟩
  · cases h

/-- The oracle left by `interpS` is a suffix of the one it started with. -/
theorem interpS_oracle_suffix {α : Type} : ∀ (u : Free α) (S : SSrv) (a : α) (S' : SSrv),
    interpS u S = some (a, S') → ∃ U, S.oracle = U ++ S'.oracle := by
  intro u
  induction u with
  | pure a =>
    intro S b S' h
    simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨_, rfl⟩ := h
    exact ⟨[], rfl⟩
  | fail m => intro S b S' h; simp [interpS_fail] at h
  | bin op x y k ih =>
    intro S b S' h
    rw [interpS_bin] at h
    split at h
    · have hih := ih _ _ _ _ h; exact hih
    · cases h
  | un op x k ih =>
    intro S b S' h
    rw [interpS_un] at h
    split at h
    · have hih := ih _ _ _ _ h; exact hih
    · cases h
  | test op x y k ih =>
    intro S b S' h
    rw [interpS_test] at h
    split at h
    · split at h
      · rename_i r S1 hans
        obtain ⟨q, o, ho, -, -, -, -, rfl⟩ := SSrv.answer_some hans
        obtain ⟨U, hU⟩ := ih _ _ _ _ h
        exact ⟨q :: U, by rw [ho, List.cons_append, ← hU]⟩
      · cases h
    · cases h
  | conc x k ih =>
    intro S b S' h
    rw [interpS_conc] at h
    split at h
    · have hih := ih _ _ _ _ h; exact hih
    · cases h

/-- **Dropping an unconsumed suffix** of the oracle from one `interpS`. -/
theorem interpS_drop_suffix {α : Type} : ∀ (u : Free α) (S : SSrv) (a : α) (S' : SSrv),
    interpS u S = some (a, S') → ∀ O' O2 R', S.oracle = O' ++ O2 → S'.oracle = R' ++ O2 →
      interpS u { S with oracle := O' } = some (a, { S' with oracle := R' }) := by
  intro u
  induction u with
  | pure a =>
    intro S b S' h O' O2 R' hS hS'
    simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    rw [hS] at hS'
    have := List.append_cancel_right hS'
    subst this
    exact interpS_pure _ _
  | fail m => intro S b S' h; simp [interpS_fail] at h
  | bin op x y k ih =>
    intro S b S' h O' O2 R' hS hS'
    rw [interpS_bin] at h ⊢
    simp only [SSrv.val_with]
    cases hx : S.val x <;> cases hy : S.val y <;> simp only [hx, hy, reduceCtorEq] at h ⊢
    have hih := ih _ _ _ _ h O' O2 R' hS hS'; exact hih
  | un op x k ih =>
    intro S b S' h O' O2 R' hS hS'
    rw [interpS_un] at h ⊢
    simp only [SSrv.val_with]
    cases hx : S.val x <;> simp only [hx, reduceCtorEq] at h ⊢
    have hih := ih _ _ _ _ h O' O2 R' hS hS'; exact hih
  | test op x y k ih =>
    intro S b S' h O' O2 R' hS hS'
    rw [interpS_test] at h ⊢
    simp only [SSrv.val_with]
    cases hx : S.val x <;> cases hy : S.val y <;> simp only [hx, hy, reduceCtorEq] at h ⊢
    rename_i ex ey
    split at h
    · rename_i r S1 hans
      obtain ⟨q, o, ho, hop, ha, hb, rfl, rfl⟩ := SSrv.answer_some hans
      obtain ⟨U, hU⟩ := interpS_oracle_suffix _ _ _ _ h
      cases O' with
      | nil =>
        exfalso
        rw [List.nil_append, ho] at hS
        change o = U ++ S'.oracle at hU
        rw [hS', ← hS] at hU
        have := congrArg List.length hU
        simp only [List.length_append, List.length_cons] at this
        omega
      | cons q' O'' =>
        rw [ho, List.cons_append] at hS
        obtain ⟨rfl, ho'⟩ := List.cons.inj hS
        have hans' : ({ S with oracle := q :: O'' } : SSrv).answer op ex ey =
            some (q.r, { S with oracle := O'' }) := by
          unfold SSrv.answer
          simp [hop, ha, hb]
        rw [hans']
        exact ih _ _ _ _ h O'' O2 R' ho' hS'
    · cases h
  | conc x k ih =>
    intro S b S' h O' O2 R' hS hS'
    rw [interpS_conc] at h ⊢
    simp only [SSrv.val_with]
    cases hx : S.val x with
    | none => simp [hx] at h
    | some e =>
      cases e <;> simp only [hx] at h ⊢ <;> first | (have hih := ih _ _ _ _ h O' O2 R' hS hS'; exact hih) | cases h

/-- The oracle left by a symbolic run is a suffix of the one it started with. -/
theorem runS_oracle_suffix {F : Ffi} : ∀ {n : Nat} {s s' : St F.S} {S S' : SSrv},
    runS F n s S = some (s', S') → ∃ U, S.oracle = U ++ S'.oracle
  | 0, s, s', S, S', h => by
    simp only [runS, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨_, rfl⟩ := h
    exact ⟨[], rfl⟩
  | n + 1, s, s', S, S', h => by
    simp only [runS, runWith_succ] at h
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs, St.rebuild_eq] at h
        obtain ⟨U1, h1⟩ := interpS_oracle_suffix _ _ _ _ hs
        obtain ⟨U2, h2⟩ := runS_oracle_suffix (n := n) h
        exact ⟨U1 ++ U2, by rw [h1, h2, List.append_assoc]⟩
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨_, rfl⟩ := h
      exact ⟨[], rfl⟩

/-- **Dropping an unconsumed suffix** of the oracle from a symbolic run. -/
theorem runS_drop_suffix {F : Ffi} : ∀ {n : Nat} {s s' : St F.S} {S S' : SSrv},
    runS F n s S = some (s', S') → ∀ O' O2 R', S.oracle = O' ++ O2 → S'.oracle = R' ++ O2 →
      runS F n s { S with oracle := O' } = some (s', { S' with oracle := R' })
  | 0, s, s', S, S', h, O', O2, R', hS, hS' => by
    simp only [runS, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h ⊢
    obtain ⟨rfl, rfl⟩ := h
    rw [hS] at hS'
    exact ⟨rfl, by rw [List.append_cancel_right hS']⟩
  | n + 1, s, s', S, S', h, O', O2, R', hS, hS' => by
    simp only [runS, runWith_succ] at h ⊢
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h ⊢
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs, St.rebuild_eq] at h
        obtain ⟨U2, h2⟩ := runS_oracle_suffix (n := n) h
        have h1 : S1.oracle = (U2 ++ R') ++ O2 := by rw [h2, hS', List.append_assoc]
        rw [interpS_drop_suffix _ _ _ _ hs O' O2 (U2 ++ R') hS h1]
        simp only [St.rebuild_eq]
        exact runS_drop_suffix (n := n) h (U2 ++ R') O2 R' h1 hS'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h ⊢
      obtain ⟨rfl, rfl⟩ := h
      rw [hS] at hS'
      exact ⟨rfl, by rw [List.append_cancel_right hS']⟩

end Host.Ts.Sim
