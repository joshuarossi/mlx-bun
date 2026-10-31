import host.sim.compose.a4b.GraphClearFillRange0
import host.sim.compose.a4b.GraphClearFillRange1
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Ts.Sim.Compose.DECGraph.ClearFill
open _root_.Host.Mlx.SimGraph

kernel_rfl graph_length : Tpl.Fill.graph.length = 3988

/-- Both adjacent absolute ranges cover every original node and input condition. -/
theorem completeRange : GraphRangeD Gs Tpl.Fill.graph choice.cert insT
    0 Tpl.Fill.graph.length := by
  rw [graph_length]
  exact first.checked.append second.checked

namespace check

theorem «matches» : MatchesD Gs Tpl.Fill.graph choice.cert = true :=
  completeRange.matchesD

theorem inputs : inputCarriersMatchD Tpl.Fill.graph choice.cert insT = true :=
  completeRange.inputCarriersMatchD

end check
end Host.Ts.Sim.Compose.DECGraph.ClearFill
