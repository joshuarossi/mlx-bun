import host.load.RuntimeSliceLiteralI32Cases
import host.load.RuntimeDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.SliceLiteralI32Selection
open Host.Ts.Owned.Annotated

host_source_step P.F, P.RestStream.micro0.micro7.s53
  using (P.RestStream.micro0.micro7.S53.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro7.s54 using (P.RestStream.micro0.micro7.S54.substitute LoopVariables.oracleVariables)
  as Start
host_source_step P.F, P.RestStream.micro0.micro7.s64
  using (P.RestStream.micro0.micro7.S64.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro7.s65 using (P.RestStream.micro0.micro7.S65.substitute LoopVariables.oracleVariables)
  as Stop
host_source_step P.F, P.RestStream.micro0.micro9.s36
  using (P.RestStream.micro0.micro9.S36.substitute LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro9.s37 using (P.RestStream.micro0.micro9.S37.substitute LoopVariables.oracleVariables)
  as Strides

end Host.Load.Run.Full.Ordinary.SliceLiteralI32Selection
