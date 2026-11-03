import host.sim.compose.a4b.PLT0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT0.nedges_7 : (((((((((PTrie.keysA PLT0.x0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (edgeOK PLTW0.R.data.map PLT0.x0) = true

end Host.Load.Run.Tpl
