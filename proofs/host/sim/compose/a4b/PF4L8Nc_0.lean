import host.sim.compose.a4b.PF4L8Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L8.nobjs : (PTrie.keysA PF4L8.x0.objs).map (fun h => PF4L8.x1.objs.get (PFW4L8.R.data.map.handle h)) =
  (PTrie.keysA PF4L8.x0.objs).map (fun h => (PF4L8.x0.objs.get h).map PFW4L8.R.data.map.nobj)
kernel_rfl PF4L8.nobjok : (PTrie.keysA PF4L8.x0.objs).all (objOK PFW4L8.R.data.map PF4L8.P0.NL PF4L8.x0) = true

end Host.Load.Run.Tpl
