import host.load.RuntimeOracleConcatCases

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch

open Host.Ts.Owned.Annotated
host_source_plan_subst P.F, P.RestStream.micro0 from 337 plan_steps 35 substitute LoopVariables.oracleVariables as Plan

end Host.Load.Run.Full.Ordinary.RetainedOracleConcatReturnBatch
