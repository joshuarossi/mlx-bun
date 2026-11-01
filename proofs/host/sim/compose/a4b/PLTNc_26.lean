import host.sim.compose.a4b.PLTNa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLT.nprims_2 : ((((fullKeysF PLT.P0 PLT.x0).drop 2000).drop 2000).take 2000).map (fun i => (PLT.x1.nodes.get (PLTP.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((((fullKeysF PLT.P0 PLT.x0).drop 2000).drop 2000).take 2000).map (fun i => (PLT.x0.nodes.get i).map fun nd => PLTP.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
