import host.load.RuntimeNamespacedDecodePlan1438
import host.mlx.OrdinarySliceDynamic
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_retained_sliceDynamic P.F, Region1438.s111 using
  (Region1438.S111.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to DynamicSlice.output using
  (P.RestStream.micro0.micro15.S2.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Slice1549

theorem dynamic_call_source_endpoint : Region1438.s111 = DynamicSlice.input := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.NamespacedDecode
