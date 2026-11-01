import host.sim.compose.a4b.PF6Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF6.nobjs : (PTrie.keysA PF6.x0.objs).map (fun h => PF6.x1.objs.get (PFW6.R.data.map.handle h)) =
  (PTrie.keysA PF6.x0.objs).map (fun h => (PF6.x0.objs.get h).map PFW6.R.data.map.nobj)
kernel_rfl PF6.nobjok : (PTrie.keysA PF6.x0.objs).all (objOK PFW6.R.data.map PF6.P0.NL PF6.x0) = true

end Host.Load.Run.Tpl
