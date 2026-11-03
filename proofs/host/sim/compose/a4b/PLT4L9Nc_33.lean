import host.sim.compose.a4b.PLT4L9Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L9.nedges_0 : ((PTrie.keysA PLT4L9.x0.nodes).take 2000).all (edgeOK PLTW4L9.R.data.map PLT4L9.x0) = true

end Host.Load.Run.Tpl
