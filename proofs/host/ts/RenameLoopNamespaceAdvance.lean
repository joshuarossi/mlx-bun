import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.LoopVariables
open Host.Ts

/-- Advance loop counters in the odd namespace. Oracle expressions keep
their even variable IDs, including future readback expressions. -/
def advance (growth : Bool) (i : Nat) : SymE :=
  if i % 2 = 0 then .var i else (advanceRoles growth (i/2)).subst loopVariables

theorem advance_oracle (growth : Bool) (i : Nat) :
    advance growth (2*i) = .var (2*i) := by
  have even : (2*i)%2 = 0 := by omega
  simp only [advance,even,ite_true]

theorem advance_loop (growth : Bool) (i : Nat) :
    advance growth (2*i+1) = (advanceRoles growth i).subst loopVariables := by
  have odd : ¬ (2*i+1)%2 = 0 := by omega
  have half : (2*i+1)/2 = i := by omega
  simp only [advance,ite_eq_right odd,half]

theorem advance_valuation (oracle : Nat → F64) (prompt index limit capacity : Nat) (growth : Bool)
    (indexBound : index+1 < 2^53) (capacityBound : capacity+256 < 2^53) :
    nextValuation (advance growth) (valuation oracle (loopValuation prompt index limit capacity)) =
      valuation oracle (loopValuation prompt (index+1) limit (if growth then capacity+256 else capacity)) := by
  funext i
  by_cases even : i%2 = 0
  · simp only [nextValuation,advance,ite_true,SymE.eval,valuation,even,ite_true]
  · simp only [nextValuation,advance,ite_eq_right even]
    rw [loop_expression]
    simp only [valuation,ite_eq_right even]
    exact congrFun (advanceRoles_eval prompt index limit capacity growth indexBound capacityBound) (i/2)

theorem oracle_unchanged (oracle : Nat → F64) (loop : Nat → F64) (growth : Bool) (expression : SymE) :
    (expression.subst oracleVariables).eval (nextValuation (advance growth) (valuation oracle loop)) =
      expression.eval oracle := by
  rw [SymE.eval_subst]
  have same : nextValuation oracleVariables (nextValuation (advance growth) (valuation oracle loop)) = oracle := by
    funext i
    change (advance growth (2*i)).eval (valuation oracle loop) = oracle i
    rw [advance_oracle]
    exact congrFun (oracle_projection oracle loop) i
  exact congrArg (expression.eval) same

end Host.Ts.Owned.Annotated.LoopVariables
