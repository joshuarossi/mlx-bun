import host.route.cert.One.Choice
import host.route.cert.Seg
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.One
open Host.Ts Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Ts.Sim.Compose.ColdGraph (fullExpected)

/-! # The one-token prompt's first step: each input at its carrier -/

simgraph_check_nodes checkI : inputNodeOkD choice.cert insT, fullExpected.1 choosing Ecn

end Host.Route.Cert.One
