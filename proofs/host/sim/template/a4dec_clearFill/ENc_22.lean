import host.sim.template.a4dec_clearFill.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearFill.nprims_5 : (((((((fullKeysF DEC_clearFill.PE DEC_clearFill.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (DEC_clearFill.X1.nodes.get (DEC_clearFill.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((((((fullKeysF DEC_clearFill.PE DEC_clearFill.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).map (fun i => (DEC_clearFill.X0.nodes.get i).map fun nd => DEC_clearFill.σ.prim nd.prim)
end Host.Load.Run.Tpl
