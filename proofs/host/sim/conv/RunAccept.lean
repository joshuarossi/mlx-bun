import host.sim.StageRel
namespace Host.Ts.Sim
open Host.Ts

/-- Checked runs transfer whenever the new acceptance includes the old one. -/
theorem runOk_mono {F : Ffi} {ok ok' : St F.S → SSrv → Bool}
    (hok : ∀ s S, ok s S = true → ok' s S = true)
    {n : Nat} {s s1 : St F.S} {S S1 : SSrv}
    (h : runOk F ok n s S = some (s1, S1)) : runOk F ok' n s S = some (s1, S1) := by
  induction n generalizing s S with
  | zero => exact h
  | succ n ih =>
    rw [runOk_succ] at h ⊢
    cases hh : isHalt s.ctl with
    | true => simpa only [hh, Bool.cond_true] using h
    | false =>
      simp only [hh, Bool.cond_false] at h ⊢
      cases hs : interpS (step F s).run S with
      | none => simp only [hs] at h; cases h
      | some pair =>
        rcases pair with ⟨s2, S2⟩
        simp only [hs] at h ⊢
        cases hb : ok s2 S2 with
        | false => simp only [hb, Bool.cond_false] at h; cases h
        | true =>
          have hb' := hok s2 S2 hb
          simp only [hb, hb', Bool.cond_true, St.rebuild_eq] at h ⊢
          exact ih h

/-- Transfer a template while retaining its states, servers and checked length. -/
def Stage.StageTpl.mapOk {F : Ffi} {ok ok' : St F.S → SSrv → Bool}
    (T : Stage.StageTpl F ok) (hok : ∀ s S, ok s S = true → ok' s S = true) :
    Stage.StageTpl F ok' :=
  { T with ok0 := hok _ _ T.ok0, run := runOk_mono hok T.run, ok1 := hok _ _ T.ok1 }

/-- The source allocation counter is nondecreasing on each successful step. -/
def SourceNextMono (F : Ffi) : Prop :=
  ∀ (s : St F.S) (S : SSrv) (s1 : St F.S) (S1 : SSrv),
    interpS (step F s).run S = some (s1, S1) → s.next ≤ s1.next

theorem runOk_next_mono {F : Ffi} (hnext : SourceNextMono F)
    {ok : St F.S → SSrv → Bool} {n : Nat} {s s1 : St F.S} {S S1 : SSrv}
    (h : runOk F ok n s S = some (s1, S1)) : s.next ≤ s1.next := by
  induction n generalizing s S with
  | zero => cases Option.some.inj h; exact Nat.le_refl _
  | succ n ih =>
    rw [runOk_succ] at h
    cases hh : isHalt s.ctl with
    | true => simp only [hh, Bool.cond_true] at h; cases Option.some.inj h; exact Nat.le_refl _
    | false =>
      simp only [hh, Bool.cond_false] at h
      cases hs : interpS (step F s).run S with
      | none => simp only [hs] at h; cases h
      | some pair =>
        rcases pair with ⟨s2, S2⟩
        simp only [hs] at h
        cases hb : ok s2 S2 with
        | false => simp only [hb, Bool.cond_false] at h; cases h
        | true =>
          simp only [hb, Bool.cond_true, St.rebuild_eq] at h
          exact Nat.le_trans (hnext s S s2 S2 hs) (ih h)

/-- An endpoint bounds every intermediate allocator counter when steps are monotone. -/
theorem runOk_mono_bounded_next {F : Ffi} (hnext : SourceNextMono F)
    {ok ok' : St F.S → SSrv → Bool} {n : Nat} {s s1 : St F.S} {S S1 : SSrv}
    (hok : ∀ u U, u.next ≤ s1.next → ok u U = true → ok' u U = true)
    (h : runOk F ok n s S = some (s1, S1)) : runOk F ok' n s S = some (s1, S1) := by
  induction n generalizing s S with
  | zero => exact h
  | succ n ih =>
    rw [runOk_succ] at h ⊢
    cases hh : isHalt s.ctl with
    | true => simpa only [hh, Bool.cond_true] using h
    | false =>
      simp only [hh, Bool.cond_false] at h ⊢
      cases hs : interpS (step F s).run S with
      | none => simp only [hs] at h; cases h
      | some pair =>
        rcases pair with ⟨s2, S2⟩
        simp only [hs] at h ⊢
        cases hb : ok s2 S2 with
        | false => simp only [hb, Bool.cond_false] at h; cases h
        | true =>
          simp only [hb, Bool.cond_true, St.rebuild_eq] at h
          have hb' := hok s2 S2 (runOk_next_mono hnext h) hb
          simp only [hb', Bool.cond_true, St.rebuild_eq]
          exact ih h

def Stage.StageTpl.mapOk_bounded_next {F : Ffi} (hnext : SourceNextMono F)
    {ok ok' : St F.S → SSrv → Bool} (T : Stage.StageTpl F ok)
    (hok : ∀ s S, s.next ≤ T.s1.next → ok s S = true → ok' s S = true) :
    Stage.StageTpl F ok' :=
  { T with ok0 := hok _ _ (runOk_next_mono hnext T.run) T.ok0, run := runOk_mono_bounded_next hnext hok T.run, ok1 := hok _ _ (Nat.le_refl _) T.ok1 }

end Host.Ts.Sim
