import host.sim.compose.a4b.PF8Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF8.nprims_0 : ((fullKeysF PF8.P0 PF8.x0).take 2000).map (fun i => (PF8.x1.nodes.get (PFW8.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((fullKeysF PF8.P0 PF8.x0).take 2000).map (fun i => (PF8.x0.nodes.get i).map fun nd => PFW8.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
