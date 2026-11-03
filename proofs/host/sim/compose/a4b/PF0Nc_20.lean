import host.sim.compose.a4b.PF0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF0.nnodes_6 : ((((((((PTrie.keysA PF0.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF PFW0.R.data.map PF0.P0 PF0.x0 PF0.x1) = true

end Host.Load.Run.Tpl
