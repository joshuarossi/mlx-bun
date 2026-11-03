import host.route.cert.Head.X4L7.Data
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.Head.X4L7
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load Host.Load.Extract Host.Load.Run.Tpl
open Host.Route.Cert.Fin

/-! # The X4L7 class's sampled cut: the head and sampler's nodes at their carriers -/

simgraph_check_nodes checkH : tailOk 4010 GsH choiceH.cert, Tpl.Ordinary.graph choosing Tpl.Ordinary.graph

end Host.Route.Cert.Head.X4L7
