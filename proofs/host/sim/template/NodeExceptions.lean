import host.sim.template.Sigma
import host.sim.stage.Read
set_option Elab.async false
namespace Host.Ts.Sim.Template

theorem setAll_identity_getD (t : PTrie Nat) (es : List (Nat × Nat))
    (ht : ∀ i, (t.get i).getD i = i)
    (he : ∀ e ∈ es, e.2 = e.1)
    (hb : ∀ e ∈ es, e.1 / 4096 < 4 ^ 31) :
    ∀ i, ((Stage.setAll t es).get i).getD i = i := by
  induction es generalizing t with
  | nil => exact ht
  | cons e es ih =>
    obtain ⟨a, b⟩ := e
    have hba : b = a := he (a, b) (by simp)
    subst b
    apply ih
    · intro i
      by_cases hi : a = i
      · subst i
        rw [PTrie.get_set_self t a a (hb (a, a) (by simp))]
        rfl
      · rw [PTrie.get_set_ne t a a (hb (a, a) (by simp)) i (Ne.symm hi)]
        exact ht i
    · exact fun e h => he e (List.mem_cons_of_mem _ h)
    · exact fun e h => hb e (List.mem_cons_of_mem _ h)

end Host.Ts.Sim.Template
