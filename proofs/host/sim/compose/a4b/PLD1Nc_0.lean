import host.sim.compose.a4b.PLD1Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.nobjs : (PTrie.keysA PLD1.x0.objs).map (fun h => PLD1.x1.objs.get (PLWalkD1.R.data.map.handle h)) =
  (PTrie.keysA PLD1.x0.objs).map (fun h => (PLD1.x0.objs.get h).map PLWalkD1.R.data.map.nobj)
kernel_rfl PLD1.nobjok : (PTrie.keysA PLD1.x0.objs).all (objOK PLWalkD1.R.data.map PLD1.P0.NL PLD1.x0) = true

end Host.Load.Run.Tpl
