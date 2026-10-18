import host.ts.Loop
set_option Elab.async false
namespace Host.Load.OraclePrefix
open Host.Ts

private theorem answer_parts (S : SSrv) {op : NTest} {x y : SymE} {b : Bool} {S' : SSrv}
    (h : S.answer op x y = some (b, S')) :
    ∃ q tail, S.oracle = q :: tail ∧ (q.op = op ∧ q.a = x ∧ q.b = y) ∧
      b = q.r ∧ S' = { S with oracle := tail } := by
  unfold SSrv.answer at h
  cases ho : S.oracle with
  | nil => simp [ho] at h
  | cons q tail =>
    by_cases hq : q.op = op ∧ q.a = x ∧ q.b = y
    · simp only [ho, hq, and_self, decide_true, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      exact ⟨q, tail, rfl, hq, h.1.symm, h.2.symm⟩
    · simp [ho, hq] at h

/-- A successful symbolic computation needs only the answers it consumed.
The remaining suffix is recovered from its checked final server. -/
theorem interpS_consumed {α : Type} (t : Free α) :
    ∀ (S : SSrv) (a : α) (S' : SSrv), interpS t S = some (a, S') →
      ∃ front, S.oracle = front ++ S'.oracle ∧
        interpS t { S with oracle := front } = some (a, { S' with oracle := [] }) := by
  induction t with
  | pure x =>
    intro S a S' h
    simp only [interpS_pure, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨[], rfl, rfl⟩
  | fail m => intro S a S' h; simp [interpS_fail] at h
  | bin op x y k ih =>
    intro S a S' h
    match hx : S.val x, hy : S.val y with
    | some ex, some ey =>
      simp only [interpS_bin, hx, hy] at h
      obtain ⟨front, hp, hr⟩ := ih _ _ _ _ h
      refine ⟨front, hp, ?_⟩
      have hx' : ({ S with oracle := front } : SSrv).val x = some ex := by simpa [SSrv.val] using hx
      have hy' : ({ S with oracle := front } : SSrv).val y = some ey := by simpa [SSrv.val] using hy
      simp only [interpS_bin, hx', hy']
      exact hr
    | none, _ => simp [interpS_bin, hx] at h
    | some _, none => simp [interpS_bin, hx, hy] at h
  | un op x k ih =>
    intro S a S' h
    cases hx : S.val x with
    | none => simp [interpS_un, hx] at h
    | some ex =>
      simp only [interpS_un, hx] at h
      obtain ⟨front, hp, hr⟩ := ih _ _ _ _ h
      refine ⟨front, hp, ?_⟩
      have hx' : ({ S with oracle := front } : SSrv).val x = some ex := by simpa [SSrv.val] using hx
      simp only [interpS_un, hx']
      exact hr
  | test op x y k ih =>
    intro S a S' h
    match hx : S.val x, hy : S.val y with
    | none, _ => simp [interpS_test, hx] at h
    | some _, none => simp [interpS_test, hx, hy] at h
    | some ex, some ey =>
      simp only [interpS_test, hx, hy] at h
      match ha : S.answer op ex ey with
      | none => simp [ha] at h
      | some (b, S1) =>
        simp only [ha] at h
        obtain ⟨q, tail, ho, hq, hb, hS1⟩ := answer_parts S ha
        subst b
        subst S1
        obtain ⟨front, hp, hr⟩ := ih _ _ _ _ h
        refine ⟨q :: front, ?_, ?_⟩
        · rw [ho]
          exact congrArg (List.cons q) hp
        · have hx' : ({ S with oracle := q :: front } : SSrv).val x = some ex := by simpa [SSrv.val] using hx
          have hy' : ({ S with oracle := q :: front } : SSrv).val y = some ey := by simpa [SSrv.val] using hy
          have ha' : ({ S with oracle := q :: front } : SSrv).answer op ex ey =
              some (q.r, { S with oracle := front }) := by simp [SSrv.answer, hq]
          simp only [interpS_test, hx', hy', ha']
          exact hr
  | conc x k ih =>
    intro S a S' h
    cases hx : S.val x with
    | none => simp [interpS_conc, hx] at h
    | some e =>
      cases e with
      | lit v =>
        simp only [interpS_conc, hx] at h
        obtain ⟨front, hp, hr⟩ := ih _ _ _ _ h
        refine ⟨front, hp, ?_⟩
        have hx' : ({ S with oracle := front } : SSrv).val x = some (.lit v) := by simpa [SSrv.val] using hx
        simp only [interpS_conc, hx']
        exact hr
      | _ => simp [interpS_conc, hx] at h

theorem interpS_strip {α : Type} (t : Free α) {S S' : SSrv} {a : α} {front : List Ans}
    (execution : interpS t S = some (a, S'))
    (shape : S.oracle = front ++ S'.oracle) :
    interpS t { S with oracle := front } = some (a, { S' with oracle := [] }) := by
  obtain ⟨used, hu, hr⟩ := interpS_consumed t S a S' execution
  have same : used = front := List.append_cancel_right (hu.symm.trans shape)
  subst used
  exact hr

theorem runS_consumed (F : Ffi) :
    ∀ (n : Nat) (s s' : St F.S) (S S' : SSrv), runS F n s S = some (s', S') →
      ∃ front, S.oracle = front ++ S'.oracle ∧
        runS F n s { S with oracle := front } = some (s', { S' with oracle := [] }) := by
  intro n
  induction n with
  | zero =>
    intro s s' S S' h
    simp only [runS, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨[], rfl, rfl⟩
  | succ n ih =>
    intro s s' S S' h
    cases hh : isHalt s.ctl
    · simp only [runS, runWith_succ, hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs, St.rebuild_eq] at h
        obtain ⟨first, hf, hfirst⟩ := interpS_consumed (step F s).run S s1 S1 hs
        obtain ⟨rest, hr, hrest⟩ := ih s1 s' S1 S' h
        have hstep : interpS (step F s).run { S with oracle := first ++ rest } =
            some (s1, { S1 with oracle := rest }) := by
          simpa only [List.nil_append] using interpS_append rest (step F s).run _ _ _ hfirst
        refine ⟨first ++ rest, ?_, ?_⟩
        · rw [hf, hr, List.append_assoc]
        · simp only [runS, runWith_succ, hh, Bool.cond_false, hstep, St.rebuild_eq]
          exact hrest
    · simp only [runS, runWith_succ, hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      refine ⟨[], rfl, ?_⟩
      simp [runS, runWith_succ, hh]

theorem runS_strip (F : Ffi) {n : Nat} {s s' : St F.S} {S S' : SSrv} {front : List Ans}
    (execution : runS F n s S = some (s', S'))
    (shape : S.oracle = front ++ S'.oracle) :
    runS F n s { S with oracle := front } = some (s', { S' with oracle := [] }) := by
  obtain ⟨used, hu, hr⟩ := runS_consumed F n s s' S S' execution
  have same : used = front := List.append_cancel_right (hu.symm.trans shape)
  subst used
  exact hr

theorem runS_replace_tail (F : Ffi) {n : Nat} {s s' : St F.S} {S S' : SSrv} {front : List Ans}
    (execution : runS F n s S = some (s', S'))
    (shape : S.oracle = front ++ S'.oracle) (tail : List Ans) :
    runS F n s { S with oracle := front ++ tail } = some (s', { S' with oracle := tail }) := by
  simpa only [List.nil_append] using runS_append F tail n s s' _ _ (runS_strip F execution shape)

end Host.Load.OraclePrefix
