import host.sim.compose.a4b.GraphClearGrowData
import host.simgraph.ChunkCheck
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Ts.Sim.Compose.DECGraph.ClearGrow
open _root_.Host.Mlx.SimGraph

simgraph_check_range first : Gs, Tpl.Growth.graph, choice.cert, insT
  from 0 to 2042 choosing Tpl.Growth.graph

end Host.Ts.Sim.Compose.DECGraph.ClearGrow
