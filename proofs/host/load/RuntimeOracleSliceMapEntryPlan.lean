import host.load.RuntimeSliceLiteralI32Cases

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts.Owned.Annotated

host_source_plan_subst P.F, P.RestStream.micro0 from 736 plan_steps 17
  substitute LoopVariables.oracleVariables as SliceMapBeforeStart
host_source_plan_subst P.F, P.RestStream.micro0 from 754 plan_steps 10
  substitute LoopVariables.oracleVariables as SliceMapBeforeStop
host_source_plan_subst P.F, P.RestStream.micro0 from 765 plan_steps 14
  substitute LoopVariables.oracleVariables as SliceMapAfterStop

noncomputable def SliceMapEntry.rules := SliceMapBeforeStart.rules ++ [``StartI32.retained_transport] ++
  SliceMapBeforeStop.rules ++ [``StopI32.retained_transport] ++ SliceMapAfterStop.rules

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
