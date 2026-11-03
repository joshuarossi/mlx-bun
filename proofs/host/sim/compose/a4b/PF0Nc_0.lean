import host.sim.compose.a4b.PF0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF0.nobjs : (PTrie.keysA PF0.x0.objs).map (fun h => PF0.x1.objs.get (PFW0.R.data.map.handle h)) =
  (PTrie.keysA PF0.x0.objs).map (fun h => (PF0.x0.objs.get h).map PFW0.R.data.map.nobj)
kernel_rfl PF0.nobjok : (PTrie.keysA PF0.x0.objs).all (objOK PFW0.R.data.map PF0.P0.NL PF0.x0) = true

end Host.Load.Run.Tpl
