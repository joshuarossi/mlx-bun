import host.route.cert.One.DataF
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
set_option autoImplicit false
namespace Host.Route.Cert.One
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Load.Run.Tpl Host.Load.Run.Full
open Host.Ts.Sim.Compose.ColdGraph (fullExpected)

/-! # The one-token prompt's final forward: every node up to the hidden state at its carrier -/

simgraph_check_nodes checkF : headOk 4010 GsF choice.cert, fullExpected.1 choosing Ecn

kernel_rfl downF : (List.range nativeF.nnext).all (downB (exactTplDom 15235 15235 [5554869888] nativeF) nativeF) = true

kernel_rfl head_below : (choice.cert.take 4010).all (fun c => Nat.blt c 17764) = true
kernel_rfl hidden_carrier : certAt choice.cert 4009 = 17763

end Host.Route.Cert.One
