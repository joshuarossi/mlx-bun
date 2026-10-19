import host.mlx.OrdinaryArrayFreeFrontend
import host.load.RuntimeNamespacedDecodePlan1770

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_retained_arrayFree P.F, ArrayFreeCall.input using
  (P.RestStream.micro0.micro19.S78.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to ArrayFreeCall.output using
  (P.RestStream.micro0.micro19.S79.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Free1978

theorem free1978_selected : Free1978.handle = 29372 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.NamespacedDecode
