import host.sim.compose.a4b.GraphClearGrowRange0
import host.sim.compose.a4b.GraphClearGrowRange1
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Ts.Sim.Compose.DECGraph.ClearGrow
open _root_.Host.Mlx.SimGraph

kernel_rfl graph_length : Tpl.Growth.graph.length = 4084

/-- Both adjacent absolute ranges cover every original node and input condition. -/
theorem completeRange : GraphRangeD Gs Tpl.Growth.graph choice.cert insT
    0 Tpl.Growth.graph.length := by
  rw [graph_length]
  exact first.checked.append second.checked

namespace check

theorem «matches» : MatchesD Gs Tpl.Growth.graph choice.cert = true :=
  completeRange.matchesD

theorem inputs : inputCarriersMatchD Tpl.Growth.graph choice.cert insT = true :=
  completeRange.inputCarriersMatchD

end check
end Host.Ts.Sim.Compose.DECGraph.ClearGrow
