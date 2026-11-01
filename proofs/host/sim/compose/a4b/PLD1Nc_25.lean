import host.sim.compose.a4b.PLD1Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLD1.nprims_2 : ((((fullKeysF PLD1.P0 PLD1.x0).drop 2000).drop 2000).take 2000).map (fun i => (PLD1.x1.nodes.get (PLWalkD1.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((((fullKeysF PLD1.P0 PLD1.x0).drop 2000).drop 2000).take 2000).map (fun i => (PLD1.x0.nodes.get i).map fun nd => PLWalkD1.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
