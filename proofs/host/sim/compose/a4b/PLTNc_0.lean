import host.sim.compose.a4b.PLTNa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.nobjs : (PTrie.keysA PLT.x0.objs).map (fun h => PLT.x1.objs.get (PLTP.R.data.map.handle h)) =
  (PTrie.keysA PLT.x0.objs).map (fun h => (PLT.x0.objs.get h).map PLTP.R.data.map.nobj)
kernel_rfl PLT.nobjok : (PTrie.keysA PLT.x0.objs).all (objOK PLTP.R.data.map PLT.P0.NL PLT.x0) = true

end Host.Load.Run.Tpl
