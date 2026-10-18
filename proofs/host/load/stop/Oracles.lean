import host.load.stop.OneResult
import host.load.stop.OneEosResult
import host.load.stop.TwoResult
import host.load.stop.TwoEosResult
import host.load.stop.FinalEosResult
import host.load.stop.first_eos.Result
import host.load.stop.EosResult
import host.load.stop.Clear512Result
import host.load.stop.BudgetEnd
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

theorem OneEos.oracle_iff (ρ : Nat → F64) :
    Good ρ OneEos.srv.oracle ↔
      F64.test .lt (.fin false 1 0) (ρ 0) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 1) = true := by
  change Good ρ OneEos.O ↔ _
  simp only [Good, OneEos.O, List.forall_mem_cons, SymE.eval, and_self_left]
  constructor
  · intro h
    exact ⟨h.1, h.2.1⟩
  · intro h
    exact ⟨h.1, h.2, by intro q hq; cases hq⟩

theorem OneEos.good_one_eos (ρ : Nat → F64) (budget : ρ 0 = .fin false 1 0)
    (eos : ρ 1 = .fin false 248044 0) : Good ρ OneEos.srv.oracle := by
  apply (OneEos.oracle_iff ρ).2
  constructor
  · rw [budget]
    decide
  · rw [eos]
    decide

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

theorem OneEos.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = OneEos.srv.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 1 0)
    (eos : ρ 1 = .fin false 248044 0) :
    ∃ C', runC Host.Load.ffi 2952 P.s2973 C = some (OneEos.s6, C') ∧ Inst ρ OneEos.S6 C' :=
  run_sim Host.Load.ffi ρ 2952 P.s2973 OneEos.s6 OneEos.srv OneEos.S6 C
    ⟨table, OneEos.good_one_eos ρ budget eos⟩ OneEos.execution

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

open Lean Elab Command Meta in
run_elab do
  let lhs ← Term.elabTermAndSynthesize (← `(P.S3573.oracle)) none
  let rhs ← Term.elabTermAndSynthesize
    (← `(([⟨.lt, .lit (.fin false 5 0), .var 0, false⟩,
      ⟨.eq, .lit (.fin false 248044 0), .var 5, false⟩] : List Ans))) (some (← inferType lhs))
  let type ← mkEq lhs rhs
  let value ← mkEqRefl lhs
  addDecl (.thmDecl { name := `Host.Load.Run.Full.BudgetEnd.oracle_tail, levelParams := [], type, value })

theorem BudgetEnd.oracle_iff (ρ : Nat → F64) :
    Good ρ P.S3573.oracle ↔
      F64.test .lt (.fin false 5 0) (ρ 0) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 5) = false := by
  rw [BudgetEnd.oracle_tail]
  simp only [Good, List.forall_mem_cons, SymE.eval]
  constructor
  · intro h
    exact ⟨h.1, h.2.1⟩
  · intro h
    exact ⟨h.1, h.2, by intro q hq; cases hq⟩

theorem BudgetEnd.good_budget (ρ : Nat → F64) (budget : ρ 0 = .fin false 5 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 5) = false) : Good ρ P.S3573.oracle := by
  apply (BudgetEnd.oracle_iff ρ).2
  exact ⟨by rw [budget]; decide, notEos⟩

theorem BudgetEnd.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = P.S3573.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 5) = false) :
    ∃ C', runC P.F 1310 P.s3573 C = some (P.s3575, C') ∧ Inst ρ P.S3575 C' :=
  run_sim P.F ρ 1310 P.s3573 P.s3575 P.S3573 P.S3575 C
    ⟨table, BudgetEnd.good_budget ρ budget notEos⟩ BudgetEnd.execution

theorem FinalEos.oracle_iff (ρ : Nat → F64) :
    Good ρ FinalEos.srv.oracle ↔
      F64.test .lt (.fin false 5 0) (ρ 0) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 5) = true := by
  change Good ρ FinalEos.O ↔ _
  simp only [Good, FinalEos.O, List.forall_mem_cons, SymE.eval]
  constructor
  · intro h
    exact ⟨h.1, h.2.1⟩
  · intro h
    exact ⟨h.1, h.2, by intro q hq; cases hq⟩

theorem FinalEos.good_eos (ρ : Nat → F64) (budget : ρ 0 = .fin false 5 0)
    (eos : ρ 5 = .fin false 248044 0) : Good ρ FinalEos.srv.oracle := by
  apply (FinalEos.oracle_iff ρ).2
  constructor
  · rw [budget]
    decide
  · rw [eos]
    decide

theorem FinalEos.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = FinalEos.srv.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 5 0)
    (eos : ρ 5 = .fin false 248044 0) :
    ∃ C', runC Host.Load.ffi 1134 P.s3573 C = some (FinalEos.s3, C') ∧ Inst ρ FinalEos.S3 C' :=
  run_sim Host.Load.ffi ρ 1134 P.s3573 FinalEos.s3 FinalEos.srv FinalEos.S3 C
    ⟨table, FinalEos.good_eos ρ budget eos⟩ FinalEos.execution

theorem FirstEos.oracle_iff (ρ : Nat → F64) :
    Good ρ FirstEos.srv.oracle ↔
      F64.test .lt (.fin false 1 0) (ρ 0) = true ∧
      F64.test .eq (.fin false 248044 0) (ρ 1) = true := by
  change Good ρ FirstEos.O ↔ _
  simp only [Good, FirstEos.O, List.forall_mem_cons, SymE.eval]
  constructor
  · rintro ⟨budget, eos, _, _, _⟩
    exact ⟨budget, eos⟩
  · rintro ⟨budget, eos⟩
    exact ⟨budget, eos, budget, eos, by intro q hq; cases hq⟩

theorem FirstEos.good_eos (ρ : Nat → F64)
    (budget : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (eos : ρ 1 = .fin false 248044 0) : Good ρ FirstEos.srv.oracle := by
  apply (FirstEos.oracle_iff ρ).2
  exact ⟨budget, by rw [eos]; decide⟩

theorem FirstEos.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = FirstEos.srv.tab.map (SymE.eval ρ))
    (budget : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (eos : ρ 1 = .fin false 248044 0) :
    ∃ C', runC Host.Load.ffi 1495111 P.s2973 C = some (FirstEos.s150, C') ∧ Inst ρ FirstEos.S150 C' :=
  run_sim Host.Load.ffi ρ 1495111 P.s2973 FirstEos.s150 FirstEos.srv FirstEos.S150 C
    ⟨table, FirstEos.good_eos ρ budget eos⟩ FirstEos.execution

theorem TwoToken.oracle_iff (ρ : Nat → F64) :
    Good ρ TwoToken.srv.oracle ↔
      F64.test .eq (.fin false 248044 0) (ρ 1) = false ∧
      F64.test .lt (.fin false 2 0) (ρ 0) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 2) = false := by
  change Good ρ TwoToken.O ↔ _
  simp only [Good, TwoToken.O, List.forall_mem_cons, SymE.eval]
  constructor
  · rintro ⟨a, b, c, _⟩
    exact ⟨a, b, c⟩
  · rintro ⟨a, b, c⟩
    exact ⟨a, b, c, by intro q hq; cases hq⟩

theorem TwoToken.good_budget (ρ : Nat → F64) (budget : ρ 0 = .fin false 2 0)
    (first : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (last : F64.test .eq (.fin false 248044 0) (ρ 2) = false) :
    Good ρ TwoToken.srv.oracle :=
  (TwoToken.oracle_iff ρ).2 ⟨first, by rw [budget]; decide, last⟩

theorem TwoToken.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = TwoToken.srv.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 2 0)
    (first : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (last : F64.test .eq (.fin false 248044 0) (ρ 2) = false) :
    ∃ C', runC Host.Load.ffi 1430 P.s3123 C = some (TwoToken.s3, C') ∧ Inst ρ TwoToken.S3 C' :=
  run_sim Host.Load.ffi ρ 1430 P.s3123 TwoToken.s3 TwoToken.srv TwoToken.S3 C
    ⟨table, TwoToken.good_budget ρ budget first last⟩ TwoToken.execution

theorem TwoEos.oracle_iff (ρ : Nat → F64) :
    Good ρ TwoEos.srv.oracle ↔
      F64.test .eq (.fin false 248044 0) (ρ 1) = false ∧
      F64.test .lt (.fin false 2 0) (ρ 0) = false ∧
      F64.test .eq (.fin false 248044 0) (ρ 2) = true := by
  change Good ρ TwoEos.O ↔ _
  simp only [Good, TwoEos.O, List.forall_mem_cons, SymE.eval]
  constructor
  · rintro ⟨a, b, c, _⟩
    exact ⟨a, b, c⟩
  · rintro ⟨a, b, c⟩
    exact ⟨a, b, c, by intro q hq; cases hq⟩

theorem TwoEos.good_eos (ρ : Nat → F64) (budget : ρ 0 = .fin false 2 0)
    (first : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (eos : ρ 2 = .fin false 248044 0) : Good ρ TwoEos.srv.oracle :=
  (TwoEos.oracle_iff ρ).2 ⟨first, by rw [budget]; decide, by rw [eos]; decide⟩

theorem TwoEos.concrete_run (ρ : Nat → F64) (C : CSrv)
    (table : C.tab = TwoEos.srv.tab.map (SymE.eval ρ))
    (budget : ρ 0 = .fin false 2 0)
    (first : F64.test .eq (.fin false 248044 0) (ρ 1) = false)
    (eos : ρ 2 = .fin false 248044 0) :
    ∃ C', runC Host.Load.ffi 1254 P.s3123 C = some (TwoEos.s3, C') ∧ Inst ρ TwoEos.S3 C' :=
  run_sim Host.Load.ffi ρ 1254 P.s3123 TwoEos.s3 TwoEos.srv TwoEos.S3 C
    ⟨table, TwoEos.good_eos ρ budget first eos⟩ TwoEos.execution

end Host.Load.Run.Full
