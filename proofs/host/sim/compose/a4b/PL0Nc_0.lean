import host.sim.compose.a4b.PL0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.nobjs : (PTrie.keysA PL0.x0.objs).map (fun h => PL0.x1.objs.get (PLW0.R.data.map.handle h)) =
  (PTrie.keysA PL0.x0.objs).map (fun h => (PL0.x0.objs.get h).map PLW0.R.data.map.nobj)
kernel_rfl PL0.nobjok : (PTrie.keysA PL0.x0.objs).all (objOK PLW0.R.data.map PL0.P0.NL PL0.x0) = true

end Host.Load.Run.Tpl
