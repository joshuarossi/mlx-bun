import host.sim.OraclePrefix
import host.sim.Run
namespace Host.Ts.Sim.Compose
open Host.Ts Host.Ts.Sim

/-! # A checked run with only the answers it consumes

A chain's boundary servers hold the whole remaining oracle, which reads variables of later pieces.
A stretch needs only the prefix it consumes: `runOk_drop_suffix` is `runS_drop_suffix` under an
acceptance that does not read the oracle. -/

variable {F : Ffi} {ok : St F.S → SSrv → Bool}

theorem runOk_oracle_suffix : ∀ {n : Nat} {s s' : St F.S} {S S' : SSrv},
    runOk F ok n s S = some (s', S') → ∃ U, S.oracle = U ++ S'.oracle
  | 0, s, s', S, S', h => by
    simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨_, rfl⟩ := h
    exact ⟨[], rfl⟩
  | n + 1, s, s', S, S', h => by
    rw [runOk_succ] at h
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs] at h
        cases hb : ok s1 S1
        · simp [hb] at h
        · simp only [hb, Bool.cond_true, St.rebuild_eq] at h
          obtain ⟨U1, h1⟩ := interpS_oracle_suffix _ _ _ _ hs
          obtain ⟨U2, h2⟩ := runOk_oracle_suffix (n := n) h
          exact ⟨U1 ++ U2, by rw [h1, h2, List.append_assoc]⟩
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h
      obtain ⟨_, rfl⟩ := h
      exact ⟨[], rfl⟩

theorem runOk_drop_suffix (hok : ∀ (s : St F.S) (S : SSrv) (O : List Ans), ok s { S with oracle := O } = ok s S) :
    ∀ {n : Nat} {s s' : St F.S} {S S' : SSrv}, runOk F ok n s S = some (s', S') →
      ∀ O' O2 R', S.oracle = O' ++ O2 → S'.oracle = R' ++ O2 →
        runOk F ok n s { S with oracle := O' } = some (s', { S' with oracle := R' })
  | 0, s, s', S, S', h, O', O2, R', hS, hS' => by
    simp only [runOk_zero, Option.some.injEq, Prod.mk.injEq] at h ⊢
    obtain ⟨rfl, rfl⟩ := h
    rw [hS] at hS'
    exact ⟨rfl, by rw [List.append_cancel_right hS']⟩
  | n + 1, s, s', S, S', h, O', O2, R', hS, hS' => by
    rw [runOk_succ] at h ⊢
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h ⊢
      cases hs : interpS (step F s).run S with
      | none => simp [hs] at h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        simp only [hs] at h
        cases hb : ok s1 S1
        · simp [hb] at h
        · simp only [hb, Bool.cond_true, St.rebuild_eq] at h
          obtain ⟨U2, h2⟩ := runOk_oracle_suffix (n := n) h
          have h1 : S1.oracle = (U2 ++ R') ++ O2 := by rw [h2, hS', List.append_assoc]
          rw [interpS_drop_suffix _ _ _ _ hs O' O2 (U2 ++ R') hS h1]
          simp only [hok, hb, Bool.cond_true, St.rebuild_eq]
          exact runOk_drop_suffix hok (n := n) h (U2 ++ R') O2 R' h1 hS'
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h ⊢
      obtain ⟨rfl, rfl⟩ := h
      rw [hS] at hS'
      exact ⟨rfl, by rw [List.append_cancel_right hS']⟩

/-- The prefix a stretch consumes, from the boundary oracles. -/
theorem oracle_take {O U O2 : List Ans} (h : O = U ++ O2) : U = O.take (O.length - O2.length) := by
  subst h
  simp

end Host.Ts.Sim.Compose
