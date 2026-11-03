import host.sim.compose.a4b.PLT0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT0.nobjs : (PTrie.keysA PLT0.x0.objs).map (fun h => PLT0.x1.objs.get (PLTW0.R.data.map.handle h)) =
  (PTrie.keysA PLT0.x0.objs).map (fun h => (PLT0.x0.objs.get h).map PLTW0.R.data.map.nobj)
kernel_rfl PLT0.nobjok : (PTrie.keysA PLT0.x0.objs).all (objOK PLTW0.R.data.map PLT0.P0.NL PLT0.x0) = true

end Host.Load.Run.Tpl
