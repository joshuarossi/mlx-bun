import host.load.RuntimeNamespacedDecodePlan1286
import host.mlx.NativeMetadataSourceCut
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_derive_metadata_cut P.F, Region1286.s44 using Region1286.S44 as At1330
host_retained_metadata P.F, At1330.s0 using
  (At1330.S0.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to At1330.s1 using
  (At1330.S1.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Meta1330
end Host.Load.Run.Full.Ordinary.NamespacedDecode
