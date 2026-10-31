import host.sim.compose.a4b.GraphClearFillData
import host.simgraph.ChunkCheck
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Ts.Sim.Compose.DECGraph.ClearFill
open _root_.Host.Mlx.SimGraph

simgraph_check_range second : Gs, Tpl.Fill.graph, choice.cert, insT
  from 1994 to 3988 choosing Tpl.Fill.graph

end Host.Ts.Sim.Compose.DECGraph.ClearFill
