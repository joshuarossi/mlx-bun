import host.load.RuntimeConcatEntryFacts
import host.load.RuntimeVectorOracleCompatibility

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.OracleConcatCases

host_retained_concat P.F, P.RestStream.micro0.micro3.s36
  using (P.RestStream.micro0.micro3.S36.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to P.RestStream.micro0.micro3.s37
  using (P.RestStream.micro0.micro3.S37.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Source336

end Host.Load.Run.Full.Ordinary.OracleConcatCases
