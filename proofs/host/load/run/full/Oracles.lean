import host.load.run.full.States
set_option Elab.async false
namespace Host.Load.Run.Full
open Host.Ts

/-- The exact branch conditions of the original five-token source trace. -/
theorem P.oracle_iff (ρ : Nat → F64) :
    Good ρ P.srv.oracle ↔
      F64.test .lt (.fin false 1 0) (ρ 0) = true ∧
      F64.test .lt (.fin false 2 0) (ρ 0) = true ∧
      F64.test .lt (.fin false 3 0) (ρ 0) = true ∧
      F64.test .lt (.fin false 4 0) (ρ 0) = true ∧
      F64.test .lt (.fin false 5 0) (ρ 0) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 1) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 2) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 3) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 4) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 5) = false := by
  change Good ρ P.O ↔ _
  simp only [Good, P.O, List.forall_mem_cons, SymE.eval]
  constructor
  · rintro ⟨h1, t1, _, _, h2, t2, h3, t3, h4, t4, h5, t5, _⟩
    exact ⟨h1, h2, h3, h4, h5, t1, t2, t3, t4, t5⟩
  · rintro ⟨h1, h2, h3, h4, h5, t1, t2, t3, t4, t5⟩
    exact ⟨h1, t1, h1, t1, h2, t2, h3, t3, h4, t4, h5, t5,
      by intro q hq; cases hq⟩

theorem P.good_five (ρ : Nat → F64) (budget : ρ 0 = .fin false 5 0)
    (notEos : ∀ i ∈ [1, 2, 3, 4, 5],
      F64.test .eq (.fin false 248044 0) (ρ i) = false) : Good ρ P.srv.oracle := by
  apply (P.oracle_iff ρ).2
  refine ⟨?_, ?_, ?_, ?_, ?_, notEos 1 (by decide), notEos 2 (by decide),
    notEos 3 (by decide), notEos 4 (by decide), notEos 5 (by decide)⟩ <;>
    rw [budget] <;> decide

end Host.Load.Run.Full
