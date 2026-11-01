import host.sim.compose.a4b.PF3Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF3.nobjs : (PTrie.keysA PF3.x0.objs).map (fun h => PF3.x1.objs.get (PFW3.R.data.map.handle h)) =
  (PTrie.keysA PF3.x0.objs).map (fun h => (PF3.x0.objs.get h).map PFW3.R.data.map.nobj)
kernel_rfl PF3.nobjok : (PTrie.keysA PF3.x0.objs).all (objOK PFW3.R.data.map PF3.P0.NL PF3.x0) = true

end Host.Load.Run.Tpl
