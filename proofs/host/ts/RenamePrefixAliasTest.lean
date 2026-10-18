import host.load.tests.readtail.Frame
import host.ts.RenamePrefix
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Tests.ReadTail.Alias
open Host.Ts
noncomputable def F := P.F
def ks := P.ks
noncomputable def s0 := P.s0
noncomputable def s1 := P.s1
noncomputable def s2 := P.s2
noncomputable def S0 := P.S0
noncomputable def S1 := P.S1
noncomputable def S2 := P.S2
end Host.Load.Tests.ReadTail.Alias
namespace Host.Load.Tests.ReadTail
host_read_tail Alias 0, 2 keep 1
host_prefix_frames Alias 0, 2 arrays [initialPair.1]
host_chunk_prefix_frames Alias 0
host_chunk_prefix_frames Alias 1
host_chain_prefix_frames Alias 0, 2
end Host.Load.Tests.ReadTail
