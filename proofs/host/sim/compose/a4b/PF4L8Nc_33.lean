import host.sim.compose.a4b.PF4L8Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF4L8.nprims_8 : ((((((((((fullKeysF PF4L8.P0 PF4L8.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PF4L8.x1.nodes.get (PFW4L8.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((((((((((fullKeysF PF4L8.P0 PF4L8.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PF4L8.x0.nodes.get i).map fun nd => PFW4L8.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
