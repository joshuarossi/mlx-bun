import host.sim.compose.a4b.GraphColdData
import host.simgraph.ChunkCheck
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx.SimGraph
simgraph_check_range range1 : Gs, fullExpected.1, choice.cert, insT from 512 to 1024 choosing fullExpected.1
end Host.Ts.Sim.Compose.ColdGraph
