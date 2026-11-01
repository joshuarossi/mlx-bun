import host.sim.compose.a4b.PLTNa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.nnodes_8 : ((((((((((PTrie.keysA PLT.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF PLTail.R.data.map PLT.P0 PLT.x0 PLT.x1) = true

end Host.Load.Run.Tpl
