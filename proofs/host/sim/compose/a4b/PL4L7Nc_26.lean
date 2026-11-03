import host.sim.compose.a4b.PL4L7Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL4L7.nnodes_10 : ((((((((((((PTrie.keysA PL4L7.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF PLW4L7.R.data.map PL4L7.P0 PL4L7.x0 PL4L7.x1) = true

end Host.Load.Run.Tpl
