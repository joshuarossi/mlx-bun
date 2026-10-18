import host.load.RuntimeNamespacedDecodeCuts1100
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Annotated
host_derive_source_cuts P.F, From1100.s25 using From1100.S25 steps 25 as From1125
end Host.Load.Run.Full.Ordinary.NamespacedDecode
