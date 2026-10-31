import host.sim.compose.a4b.GraphColdRange0
import host.sim.compose.a4b.GraphColdRange1
import host.sim.compose.a4b.GraphColdRange2
import host.sim.compose.a4b.GraphColdRange3
import host.sim.compose.a4b.GraphColdRange4
import host.sim.compose.a4b.GraphColdRange5
import host.sim.compose.a4b.GraphColdRange6
import host.sim.compose.a4b.GraphColdRange7
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Ts.Sim.Compose.ColdGraph
open _root_.Host.Mlx.SimGraph
kernel_rfl graph_length : fullExpected.1.length = 4020
kernel_rfl cert_length_check : decide (fullExpected.1.length ≤ choice.cert.length) = true
theorem cert_length : fullExpected.1.length ≤ choice.cert.length := of_decide_eq_true cert_length_check
namespace check
theorem complete : GraphRangeD Gs fullExpected.1 choice.cert insT 0 fullExpected.1.length := by
  rw [graph_length]
  exact (((((((range0.checked.append range1.checked).append range2.checked).append range3.checked).append range4.checked).append range5.checked).append range6.checked).append range7.checked)
theorem «matches» : MatchesD Gs fullExpected.1 choice.cert = true := complete.matchesD
theorem inputs : inputCarriersMatchD fullExpected.1 choice.cert insT = true := complete.inputCarriersMatchD
end check
end Host.Ts.Sim.Compose.ColdGraph
