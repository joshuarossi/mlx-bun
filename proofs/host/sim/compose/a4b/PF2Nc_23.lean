import host.sim.compose.a4b.PF2Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF2.nnodes_9 : (((((((((((PTrie.keysA PF2.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF PFW2.R.data.map PF2.P0 PF2.x0 PF2.x1) = true

end Host.Load.Run.Tpl
