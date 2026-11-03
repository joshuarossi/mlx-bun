import host.sim.compose.a4b.PLTVNa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template Host.Ts.Sim.Full Host.Ts.Sim.Compose Host.Route
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl PLTV.nprims_6 : ((((((((fullKeysF PLTV.P0 PLTV.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PLTV.x1.nodes.get (PLTVW.R.data.map.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((((((((fullKeysF PLTV.P0 PLTV.x0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (PLTV.x0.nodes.get i).map fun nd => PLTVW.R.data.map.prim nd.prim)

end Host.Load.Run.Tpl
