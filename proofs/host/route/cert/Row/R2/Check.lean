import host.route.cert.Row.R2.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Row.R2
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl

/-! # POST row `r2`: every node of the ordinary forward, at its carrier -/

simgraph_check_template check : Gs, Tpl.Ordinary.graph, choice.cert, insT choosing Tpl.Ordinary.graph

end Host.Route.Cert.Row.R2
