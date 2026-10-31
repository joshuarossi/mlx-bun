import host.sim.template.a4dec_grow.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_grow.nprims_7 : (((((((((fullKeysF DEC_grow.PE DEC_grow.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (DEC_grow.X1.nodes.get (DEC_grow.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((((((((fullKeysF DEC_grow.PE DEC_grow.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (DEC_grow.X0.nodes.get i).map fun nd => DEC_grow.σ.prim nd.prim)
end Host.Load.Run.Tpl
