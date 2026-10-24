import host.load.nat.M5
namespace Host.Ts.FfiNat
open Host.Ts

/-! # Machine runs of simulating worlds

`runS_sim`, `runC_sim`: if the second world simulates the first (`FfiSim`)
on related native states, every run of the first world is a run of the
second from the state with the related native state, with the same number
server, the same JavaScript side at the end, and related final native
states. The machine is a function of its world; this is proved once for
every definition of the interpreter (`rel_step`: one transition). -/

section
variable {F1 F2 : Ffi} [FfiRel F1 F2] [FfiSim F1 F2]

theorem step_tr (s : St F1.S) (x : F2.S) (hx : FfiRel.R s.ffi x) :
    TR (StRel FfiRel.R) (step F1 s).run (step F2 (s.reFfi x)).run :=
  (rel_step s x hx).run_rel

theorem runS_sim : ∀ (n : Nat) (s : St F1.S) (x : F2.S), FfiRel.R s.ffi x → ∀ (S : SSrv) (t : St F1.S) (S' : SSrv),
    runS F1 n s S = some (t, S') → ∃ y, runS F2 n (s.reFfi x) S = some (t.reFfi y, S') ∧ FfiRel.R t.ffi y
  | 0, s, x, hx, S, t, S', h => by
    simp only [runS, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨x, rfl, hx⟩
  | n + 1, s, x, hx, S, t, S', h => by
    unfold runS at h ⊢
    rw [runWith_succ] at h ⊢
    have hc : isHalt (s.reFfi x).ctl = isHalt s.ctl := rfl
    rw [hc]
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h ⊢
      cases hst : interpS (step F1 s).run S with
      | none => rw [hst] at h; cases h
      | some p =>
        obtain ⟨s1, S1⟩ := p
        rw [hst] at h
        simp only [St.rebuild_eq] at h
        obtain ⟨v2, hv2, y1, rfl, hy1⟩ := (step_tr s x hx).s _ _ _ hst
        rw [hv2]
        simp only [St.rebuild_eq]
        exact runS_sim n s1 y1 hy1 S1 t S' h
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h ⊢
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨x, ⟨rfl, rfl⟩, hx⟩

theorem runC_sim : ∀ (n : Nat) (s : St F1.S) (x : F2.S), FfiRel.R s.ffi x → ∀ (C : CSrv) (t : St F1.S) (C' : CSrv),
    runC F1 n s C = some (t, C') → ∃ y, runC F2 n (s.reFfi x) C = some (t.reFfi y, C') ∧ FfiRel.R t.ffi y
  | 0, s, x, hx, C, t, C', h => by
    simp only [runC, runWith_zero, Option.some.injEq, Prod.mk.injEq] at h
    obtain ⟨rfl, rfl⟩ := h
    exact ⟨x, rfl, hx⟩
  | n + 1, s, x, hx, C, t, C', h => by
    unfold runC at h ⊢
    rw [runWith_succ] at h ⊢
    have hc : isHalt (s.reFfi x).ctl = isHalt s.ctl := rfl
    rw [hc]
    cases hh : isHalt s.ctl
    · simp only [hh, Bool.cond_false] at h ⊢
      cases hst : interpC (step F1 s).run C with
      | none => rw [hst] at h; cases h
      | some p =>
        obtain ⟨s1, C1⟩ := p
        rw [hst] at h
        simp only [St.rebuild_eq] at h
        obtain ⟨v2, hv2, y1, rfl, hy1⟩ := (step_tr s x hx).c _ _ _ hst
        rw [hv2]
        simp only [St.rebuild_eq]
        exact runC_sim n s1 y1 hy1 C1 t C' h
    · simp only [hh, Bool.cond_true, Option.some.injEq, Prod.mk.injEq] at h ⊢
      obtain ⟨rfl, rfl⟩ := h
      exact ⟨x, ⟨rfl, rfl⟩, hx⟩

end

end Host.Ts.FfiNat
