import host.route.cert.VW8.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.VW8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl
open Host.Mlx.SimGraph.Tpl.Fam

/-! # The x8 forward's certificate: every node of the family's graph at its carrier -/

simgraph_check_segment check : Gs, kindOf choice.kind, Ec, .promptIds, 0, 5018, choice.cert, ins choosing Ecn

end Host.Route.Cert.VW8
