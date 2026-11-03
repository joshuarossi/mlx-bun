import host.sim.compose.a4b.PL0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PL0.nprims_0 : ((fullKeysF PL0.P0 PL0.x0).take 2000).map (fun i => (PL0.x1.nodes.get (PLW0.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((fullKeysF PL0.P0 PL0.x0).take 2000).map (fun i => (PL0.x0.nodes.get i).map fun nd => PLW0.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
