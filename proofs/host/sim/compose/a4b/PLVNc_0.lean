import host.sim.compose.a4b.PLVNa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLV.nobjs : (PTrie.keysA PLV.x0.objs).map (fun h => PLV.x1.objs.get (PLVW.R.data.map.handle h)) =
  (PTrie.keysA PLV.x0.objs).map (fun h => (PLV.x0.objs.get h).map PLVW.R.data.map.nobj)
kernel_rfl PLV.nobjok : (PTrie.keysA PLV.x0.objs).all (objOK PLVW.R.data.map PLV.P0.NL PLV.x0) = true

end Host.Load.Run.Tpl
