import host.sim.compose.a4b.PF1Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF1.nnodes_1 : (((PTrie.keysA PF1.x0.nodes).drop 2000).take 2000).all (nodeOKF PFW1.R.data.map PF1.P0 PF1.x0 PF1.x1) = true

end Host.Load.Run.Tpl
