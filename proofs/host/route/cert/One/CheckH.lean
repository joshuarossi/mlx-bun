import host.route.cert.One.DataH
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.One
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl Host.Load.Run.Full
open Host.Ts.Sim.Compose.ColdGraph (fullExpected)

/-! # The one-token prompt's sampled cut: the head and sampler's nodes at their carriers -/

kernel_rfl downH : (List.range nativeH.nnext).all (downB (exactTplDom 15235 15235 [5554869888] nativeH) nativeH) = true

simgraph_check_nodes checkH : tailOk 4010 GsH choice.cert, fullExpected.1 choosing Ecn

kernel_rfl node_counter : nativeH.nnext = 17777

end Host.Route.Cert.One
