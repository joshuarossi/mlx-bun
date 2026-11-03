import host.sim.compose.a4b.PLTVNa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.nobjs : (PTrie.keysA PLTV.x0.objs).map (fun h => PLTV.x1.objs.get (PLTVW.R.data.map.handle h)) =
  (PTrie.keysA PLTV.x0.objs).map (fun h => (PLTV.x0.objs.get h).map PLTVW.R.data.map.nobj)
kernel_rfl PLTV.nobjok : (PTrie.keysA PLTV.x0.objs).all (objOK PLTVW.R.data.map PLTV.P0.NL PLTV.x0) = true

end Host.Load.Run.Tpl
