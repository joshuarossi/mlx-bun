import host.load.RuntimeOracleSliceOutputPlan
import host.load.RuntimeSliceTypedLength

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts.Owned.Annotated

host_source_plan_subst P.F, P.RestStream.micro0 from 1048 plan_steps 38
  substitute LoopVariables.oracleVariables as SliceCallTail

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
