import host.route.cert.Fin.X4L8.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Fin.X4L8
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The X4L8 class's final forward: every node of the ordinary step's forward part, at its carrier -/

simgraph_check_template check : Gs, Eh, choice.cert, insT choosing Eh

end Host.Route.Cert.Fin.X4L8
