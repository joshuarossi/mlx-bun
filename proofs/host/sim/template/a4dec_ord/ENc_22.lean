import host.sim.template.a4dec_ord.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_ord.nprims_5 : (((((((fullKeysF DEC_ord.PE DEC_ord.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (DEC_ord.X1.nodes.get (DEC_ord.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((((((fullKeysF DEC_ord.PE DEC_ord.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (DEC_ord.X0.nodes.get i).map fun nd => DEC_ord.σ.prim nd.prim)
end Host.Load.Run.Tpl
