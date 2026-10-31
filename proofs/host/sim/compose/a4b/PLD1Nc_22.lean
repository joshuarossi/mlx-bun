import host.sim.compose.a4b.PLD1Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.nnodes_8 : ((((((((((PTrie.keysA PLD1.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF PLWalkD1.R.data.map PLD1.P0 PLD1.x0 PLD1.x1) = true

end Host.Load.Run.Tpl
