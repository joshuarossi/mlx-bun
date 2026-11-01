import host.sim.compose.a4b.PF2Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF2.nobjs : (PTrie.keysA PF2.x0.objs).map (fun h => PF2.x1.objs.get (PFW2.R.data.map.handle h)) =
  (PTrie.keysA PF2.x0.objs).map (fun h => (PF2.x0.objs.get h).map PFW2.R.data.map.nobj)
kernel_rfl PF2.nobjok : (PTrie.keysA PF2.x0.objs).all (objOK PFW2.R.data.map PF2.P0.NL PF2.x0) = true

end Host.Load.Run.Tpl
