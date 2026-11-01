import host.sim.compose.a4b.PF2Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PF2.nprims_5 : (((((((fullKeysF PF2.P0 PF2.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PF2.x1.nodes.get (PFW2.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((((((fullKeysF PF2.P0 PF2.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PF2.x0.nodes.get i).map fun nd => PFW2.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
