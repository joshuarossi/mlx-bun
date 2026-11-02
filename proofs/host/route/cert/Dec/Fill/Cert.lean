import host.route.cert.Dec.Fill.Range0
import host.route.cert.Dec.Fill.Range1
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false

namespace Host.Route.Cert.Dec.Fill
open Host.Mlx.SimGraph

kernel_rfl graph_length : Tpl.Fill.graph.length = 3988

/-- Both adjacent ranges cover every node and input condition. -/
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

theorem cert_length : Tpl.Fill.graph.length ≤ choice.cert.length := by decide

end Host.Route.Cert.Dec.Fill
