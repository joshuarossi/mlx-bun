import host.load.RuntimeOracleConvolutionSliceCallEntry
import host.ts.RenameRuntimeDriverLiteralI32Array

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_retained_literalI32Typed P.F, P.RestStream.micro0.micro7.s53
  using (P.RestStream.micro0.micro7.S53.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro7.s54 using (P.RestStream.micro0.micro7.S54.substitute LoopVariables.oracleVariables)
  as StartI32

host_retained_literalI32Typed P.F, P.RestStream.micro0.micro7.s64
  using (P.RestStream.micro0.micro7.S64.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro7.s65 using (P.RestStream.micro0.micro7.S65.substitute LoopVariables.oracleVariables)
  as StopI32

host_retained_literalI32Typed P.F, P.RestStream.micro0.micro9.s36
  using (P.RestStream.micro0.micro9.S36.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro9.s37 using (P.RestStream.micro0.micro9.S37.substitute LoopVariables.oracleVariables)
  as StridesI32

end Host.Load.Run.Full.Ordinary.RetainedOracleConvolutionBatch
