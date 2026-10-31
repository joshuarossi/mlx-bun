import host.sim.template.a4dec_fill.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_fill.nprims_0 : ((fullKeysF DEC_fill.PE DEC_fill.X0).take 2000).map (fun i => (DEC_fill.X1.nodes.get (DEC_fill.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((fullKeysF DEC_fill.PE DEC_fill.X0).take 2000).map (fun i => (DEC_fill.X0.nodes.get i).map fun nd => DEC_fill.σ.prim nd.prim)
end Host.Load.Run.Tpl
