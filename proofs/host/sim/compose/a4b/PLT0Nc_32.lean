import host.sim.compose.a4b.PLT0Na
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT0.nprims_8 : ((((((((((fullKeysF PLT0.P0 PLT0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PLT0.x1.nodes.get (PLTW0.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((((((((((fullKeysF PLT0.P0 PLT0.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PLT0.x0.nodes.get i).map fun nd => PLTW0.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
