import host.sim.compose.a4b.PLT4L9Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT4L9.nobjs : (PTrie.keysA PLT4L9.x0.objs).map (fun h => PLT4L9.x1.objs.get (PLTW4L9.R.data.map.handle h)) =
  (PTrie.keysA PLT4L9.x0.objs).map (fun h => (PLT4L9.x0.objs.get h).map PLTW4L9.R.data.map.nobj)
kernel_rfl PLT4L9.nobjok : (PTrie.keysA PLT4L9.x0.objs).all (objOK PLTW4L9.R.data.map PLT4L9.P0.NL PLT4L9.x0) = true

end Host.Load.Run.Tpl
