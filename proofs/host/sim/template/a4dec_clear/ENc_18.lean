import host.sim.template.a4dec_clear.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clear.nprims_1 : (((fullKeysF DEC_clear.PE DEC_clear.X0).drop 2000).take 2000).map (fun i => (DEC_clear.X1.nodes.get (DEC_clear.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((fullKeysF DEC_clear.PE DEC_clear.X0).drop 2000).take 2000).map (fun i => (DEC_clear.X0.nodes.get i).map fun nd => DEC_clear.σ.prim nd.prim)
end Host.Load.Run.Tpl
