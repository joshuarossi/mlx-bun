import host.load.RuntimeNamespacedDecodePlan1331

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000

namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned.Parametric

host_derive_source_cuts P.F, Region1331.s31 using Region1331.S31 steps 9 as From1371
host_derive_source_cuts P.F, From1371.s9 using From1371.S9 steps 4 as From1375

end Host.Load.Run.Full.Ordinary.NamespacedDecode
