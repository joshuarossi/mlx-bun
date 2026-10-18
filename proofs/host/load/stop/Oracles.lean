import host.load.stop.OneResult
import host.load.stop.EosResult
import host.load.stop.Clear512Result
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full
open Host.Ts Host.Load

/-- Exact remaining branch conditions of the budget-one fragment. -/
theorem OneToken.oracle_iff (ρ : Nat → F64) :
    Good ρ OneToken.srv.oracle ↔
      F64.test .lt (.fin false 1 0) (ρ 0) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 1) = false := by
  change Good ρ OneToken.O ↔ _
  simp only [Good, OneToken.O, List.forall_mem_cons, SymE.eval, and_self_left]
  constructor
  · intro h
    exact ⟨h.1, h.2.1⟩
  · intro h
    exact ⟨h.1, h.2, by intro q hq; cases hq⟩

theorem OneToken.good_one (ρ : Nat → F64) (budget : ρ 0 = .fin false 1 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    Good ρ OneToken.srv.oracle := by
  apply (OneToken.oracle_iff ρ).2
  exact ⟨by rw [budget]; decide, notEos⟩

/-- The ordinary EOS fragment has no token-budget or future-read premise. -/
theorem EosToken.oracle_iff (ρ : Nat → F64) :
    Good ρ EosToken.srv.oracle ↔
      F64.test .eq (.fin false 248044 0) (ρ 2) = true := by
  change Good ρ EosToken.O ↔ _
  simp only [Good, EosToken.O, List.forall_mem_cons, SymE.eval]
  constructor
  · intro h
    exact h.1
  · intro h
    exact ⟨h, by intro q hq; cases hq⟩

theorem EosToken.good_eos (ρ : Nat → F64) (eos : ρ 2 = .fin false 248044 0) :
    Good ρ EosToken.srv.oracle := by
  apply (EosToken.oracle_iff ρ).2
  rw [eos]
  decide

theorem Clear256.good (ρ : Nat → F64) : Good ρ Clear256.srv.oracle := by
  change Good ρ []
  intro q h
  cases h

theorem Clear512.good (ρ : Nat → F64) : Good ρ Clear512.srv.oracle := by
  change Good ρ []
  intro q h
  cases h

theorem OneToken.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = OneToken.srv.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 1 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    ∃ C', runC Host.Load.ffi 3144 P.s2973 C = some (OneToken.s7, C') ∧ Inst ρ OneToken.S7 C' :=
  run_sim Host.Load.ffi ρ 3144 P.s2973 OneToken.s7 OneToken.srv OneToken.S7 C
    ⟨table, OneToken.good_one ρ budget notEos⟩ OneToken.execution

theorem EosToken.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = EosToken.srv.tab.map (SymE.eval ρ))
    (eos : ρ 2 = .fin false 248044 0) :
    ∃ C', runC Host.Load.ffi 825 P.s3272 C = some (EosToken.s2, C') ∧ Inst ρ EosToken.S2 C' :=
  run_sim Host.Load.ffi ρ 825 P.s3272 EosToken.s2 EosToken.srv EosToken.S2 C
    ⟨table, EosToken.good_eos ρ eos⟩ EosToken.execution

theorem Clear256.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = Clear256.srv.tab.map (SymE.eval ρ)) :
    ∃ C', runC Host.Load.ffi 32 Clear256.entry C = some (Clear256.s1, C') ∧ Inst ρ Clear256.S1 C' :=
  run_sim Host.Load.ffi ρ 32 Clear256.entry Clear256.s1 Clear256.srv Clear256.S1 C
    ⟨table, Clear256.good ρ⟩ Clear256.execution

theorem Clear512.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = Clear512.srv.tab.map (SymE.eval ρ)) :
    ∃ C', runC Host.Load.ffi 32 Clear512.entry C = some (Clear512.s1, C') ∧ Inst ρ Clear512.S1 C' :=
  run_sim Host.Load.ffi ρ 32 Clear512.entry Clear512.s1 Clear512.srv Clear512.S1 C
    ⟨table, Clear512.good ρ⟩ Clear512.execution

end Host.Load.Run.Full
