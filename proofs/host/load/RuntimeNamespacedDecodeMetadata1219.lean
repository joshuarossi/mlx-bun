import host.load.RuntimeNamespacedDecodeCuts1200
import host.mlx.NativeMetadataSourceCut
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
host_derive_metadata_cut P.F, From1200.s19 using From1200.S19 as At1219
host_retained_metadata P.F, At1219.s0 using
  (At1219.S0.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables)
  to At1219.s1 using
  (At1219.S1.substitute Host.Ts.Owned.Annotated.LoopVariables.oracleVariables) as Meta1219
end Host.Load.Run.Full.Ordinary.NamespacedDecode
