import host.load.stop.Oracles
import host.load.stop.FirstEosStates
import host.load.OraclePrefix
set_option Elab.async false
set_option maxRecDepth 1000000
namespace Host.Load.Run.Full.StopEntry
open Host.Ts

def firstYieldAnswers : List Ans :=
  [⟨.lt, .lit (.fin false 1 0), .var 0, true⟩,
   ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩]

def coldAnswers : List Ans := firstYieldAnswers ++
  [⟨.lt, .lit (.fin false 1 0), .var 0, true⟩]

def ordinaryAnswers : List Ans :=
  [⟨.lt, .lit (.fin false 1 0), .var 0, true⟩,
   ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩,
   ⟨.lt, .lit (.fin false 1 0), .var 0, true⟩,
   ⟨.eq, .lit (.fin false 248044 0), .var 1, false⟩,
   ⟨.lt, .lit (.fin false 2 0), .var 0, true⟩]

def finalAnswers : List Ans := ordinaryAnswers ++
  [⟨.eq, .lit (.fin false 248044 0), .var 2, false⟩,
   ⟨.lt, .lit (.fin false 3 0), .var 0, true⟩,
   ⟨.eq, .lit (.fin false 248044 0), .var 3, false⟩,
   ⟨.lt, .lit (.fin false 4 0), .var 0, true⟩,
   ⟨.eq, .lit (.fin false 248044 0), .var 4, false⟩]

kernel_rfl first_oracle : P.S0.oracle = [] ++ P.S2973.oracle
kernel_rfl first_yield_oracle : P.S0.oracle = firstYieldAnswers ++ P.S2974.oracle
kernel_rfl cold_oracle : P.S0.oracle = coldAnswers ++ P.S3123.oracle
kernel_rfl ordinary_oracle : P.S0.oracle = ordinaryAnswers ++ P.S3272.oracle
kernel_rfl final_oracle : P.S0.oracle = finalAnswers ++ P.S3573.oracle

kernel_rfl one_table : OneToken.srv.tab = P.S2973.tab
kernel_rfl one_eos_table : OneEos.srv.tab = P.S2973.tab
kernel_rfl first_eos_table : FirstEos.srv.tab = P.S2973.tab
kernel_rfl ordinary_eos_table : EosToken.srv.tab = P.S3272.tab
kernel_rfl final_eos_table : FinalEos.srv.tab = P.S3573.tab

theorem first_yield_good (ρ : Nat → F64)
    (budget : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    Good ρ firstYieldAnswers := by
  simp only [Good, firstYieldAnswers, List.forall_mem_cons, SymE.eval]
  exact ⟨budget, notEos, by intro q hq; cases hq⟩

theorem cold_good (ρ : Nat → F64)
    (budget : F64.test .lt (.fin false 1 0) (ρ 0) = true)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    Good ρ coldAnswers := by
  apply (good_append ρ _ _).2
  refine ⟨first_yield_good ρ budget notEos, ?_⟩
  simp only [Good, List.forall_mem_cons, SymE.eval]
  exact ⟨budget, by intro q hq; cases hq⟩

theorem ordinary_good (ρ : Nat → F64) (budget : ρ 0 = .fin false 5 0)
    (notEos : F64.test .eq (.fin false 248044 0) (ρ 1) = false) :
    Good ρ ordinaryAnswers := by
  simp only [Good, ordinaryAnswers, List.forall_mem_cons, SymE.eval]
  exact ⟨by rw [budget]; decide, notEos, by rw [budget]; decide, notEos,
    by rw [budget]; decide, by intro q hq; cases hq⟩

theorem final_good (ρ : Nat → F64) (budget : ρ 0 = .fin false 5 0)
    (notEos : ∀ i ∈ [1, 2, 3, 4], F64.test .eq (.fin false 248044 0) (ρ i) = false) :
    Good ρ finalAnswers := by
  apply (good_append ρ _ _).2
  refine ⟨ordinary_good ρ budget (notEos 1 (by decide)), ?_⟩
  simp only [Good, List.forall_mem_cons, SymE.eval]
  exact ⟨notEos 2 (by decide), by rw [budget]; decide, notEos 3 (by decide),
    by rw [budget]; decide, notEos 4 (by decide), by intro q hq; cases hq⟩

end Host.Load.Run.Full.StopEntry
