import host.load.RuntimeNamespacedDecodePlan1770
import host.mlx.OrdinaryConvRetained
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_retained_conv1d P.F, Region1770.s86 using
  (Region1770.S86.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to ConvCall.output using
  (P.RestStream.micro0.micro18.S57.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Conv1856

theorem convolution_call_source_endpoint : Region1770.s86 = ConvCall.input := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.NamespacedDecode
