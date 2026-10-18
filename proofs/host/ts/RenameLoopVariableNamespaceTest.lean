import host.ts.RenameLoopVariableNamespace

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.LoopVariables.Test
open Host.Ts

def futureExpression (oracleIndex : Nat) : SymE := .bin .add (.var oracleIndex) (.lit (F64.ofNat 1))
def futureServer (oracleIndex : Nat) : SSrv :=
  ⟨[.var oracleIndex],[⟨.lt,futureExpression oracleIndex,.lit (F64.ofNat 1000),true⟩]⟩
def futureRequest : Free Bool :=
  .bin .add (.ref 0) (.lit (F64.ofNat 1)) fun index =>
    .test .lt (.ref index) (.lit (F64.ofNat 1000)) .pure
def futureNext (oracleIndex : Nat) : SSrv := ⟨[.var oracleIndex,futureExpression oracleIndex],[]⟩

theorem source_future (oracleIndex : Nat) :
    interpS futureRequest (futureServer oracleIndex) = some (true,futureNext oracleIndex) := by
  simp [futureRequest,futureServer,futureNext,futureExpression,interpS_bin,interpS_test,interpS_pure,SSrv.val,SSrv.answer,nth?]

theorem embedded_future (oracleIndex : Nat) :
    interpS futureRequest ((futureServer oracleIndex).substitute oracleVariables) =
      some (true,(futureNext oracleIndex).substitute oracleVariables) :=
  interpS_substitute oracleVariables futureRequest _ _ _ (source_future oracleIndex)

theorem future_reference_index (oracleIndex : Nat) :
    ((futureNext oracleIndex).substitute oracleVariables).val (.ref 1) =
      some ((futureExpression oracleIndex).subst oracleVariables) := rfl

theorem future_token_three (oracle : Nat → F64) (prompt index limit size : Nat) :
    ((SymE.var 3).subst oracleVariables).eval (valuation oracle (loopValuation prompt index limit size)) = oracle 3 :=
  oracle_expression oracle _ (.var 3)

theorem capacity_is_separate (oracle : Nat → F64) (prompt index limit size : Nat) :
    capacity.eval (valuation oracle (loopValuation prompt index limit size)) = F64.ofNat size :=
  capacity_eval oracle prompt index limit size

theorem token_three_ignores_growth (oracle : Nat → F64) (prompt index limit size : Nat) :
    ((SymE.var 3).subst oracleVariables).eval (valuation oracle (loopValuation prompt index limit (size+256))) =
      ((SymE.var 3).subst oracleVariables).eval (valuation oracle (loopValuation prompt index limit size)) := by
  rw [oracle_expression,oracle_expression]

end Host.Ts.Owned.Annotated.LoopVariables.Test
