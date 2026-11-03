import host.sim.compose.a4b.PLTVNa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.nedges_3 : (((((PTrie.keysA PLTV.x0.nodes).drop 2000).drop 2000).drop 2000).take 2000).all (edgeOK PLTVW.R.data.map PLTV.x0) = true

end Host.Load.Run.Tpl
