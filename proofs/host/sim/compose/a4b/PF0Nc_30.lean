import host.sim.compose.a4b.PF0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF0.nprims_7 : (((((((((fullKeysF PF0.P0 PF0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PF0.x1.nodes.get (PFW0.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((((((((fullKeysF PF0.P0 PF0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PF0.x0.nodes.get i).map fun nd => PFW0.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
