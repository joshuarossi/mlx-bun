import host.route.cert.One.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.One
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl Host.Load.Run.Full
open Host.Ts.Sim.Compose.ColdGraph (fullExpected choice.cert)

/-! # The one-token prompt's sampled cut: every node of the first step's graph at its carrier -/

simgraph_check_nodes check : nodeOkD Gs choice.cert, fullExpected.1 choosing Ecn

end Host.Route.Cert.One
