import host.load.RuntimeOracleConstructorBatch

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch

open Host.Ts.Owned.Annotated
host_source_plan_subst P.F, P.RestStream.micro0 from 409 plan_steps 75 substitute LoopVariables.oracleVariables as Cleanup
noncomputable def Cleanup13.rules := Cleanup.rules.take 13
noncomputable def WeightGuard.rules := (Cleanup.rules.drop 13).take 23
noncomputable def WeightGetter.rules := (Cleanup.rules.drop 36).take 21
noncomputable def CleanupEnd.rules := Cleanup.rules.drop (Cleanup.rules.length-2)

end Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
