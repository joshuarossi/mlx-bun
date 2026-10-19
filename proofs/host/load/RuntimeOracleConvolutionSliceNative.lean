import host.load.RuntimeOracleSliceCallTailPlan
import host.mlx.NativeClosedFixedSliceFrontend
import host.mlx.OrdinarySliceCut

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts.Owned.Annotated

host_retained_closedFixedSlice P.F, P.RestStream.micro0.micro10.s86
  using (P.RestStream.micro0.micro10.S86.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro10.s87 using (P.RestStream.micro0.micro10.S87.substitute LoopVariables.oracleVariables)
  as Slice1086

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
