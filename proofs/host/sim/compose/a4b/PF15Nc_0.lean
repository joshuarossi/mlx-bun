import host.sim.compose.a4b.PF15Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF15.nobjs : (PTrie.keysA PF15.x0.objs).map (fun h => PF15.x1.objs.get (PFW15.R.data.map.handle h)) =
  (PTrie.keysA PF15.x0.objs).map (fun h => (PF15.x0.objs.get h).map PFW15.R.data.map.nobj)
kernel_rfl PF15.nobjok : (PTrie.keysA PF15.x0.objs).all (objOK PFW15.R.data.map PF15.P0.NL PF15.x0) = true

end Host.Load.Run.Tpl
