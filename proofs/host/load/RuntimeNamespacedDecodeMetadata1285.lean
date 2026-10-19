import host.load.RuntimeNamespacedDecodePlan1220
import host.mlx.NativeMetadataSourceCut
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_derive_metadata_cut P.F, Region1220.s65 using Region1220.S65 as At1285
host_retained_metadata P.F, At1285.s0 using
  (At1285.S0.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to At1285.s1 using
  (At1285.S1.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Meta1285
end Host.Load.Run.Full.Ordinary.NamespacedDecode
