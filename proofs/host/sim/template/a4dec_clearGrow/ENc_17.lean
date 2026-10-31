import host.sim.template.a4dec_clearGrow.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearGrow.nprims_0 : ((fullKeysF DEC_clearGrow.PE DEC_clearGrow.X0).take 2000).map (fun i => (DEC_clearGrow.X1.nodes.get (DEC_clearGrow.σ.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((fullKeysF DEC_clearGrow.PE DEC_clearGrow.X0).take 2000).map (fun i => (DEC_clearGrow.X0.nodes.get i).map fun nd => DEC_clearGrow.σ.prim nd.prim)
end Host.Load.Run.Tpl
