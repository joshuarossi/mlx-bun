import host.sim.template.a4dec_grow.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_grow.fp1_1 : ((((DEC_grow.cln1.filter (fullB DEC_grow.P1))).drop 600).take 600).map (fun i => (DEC_grow.cx1_1.mlx.nodes.get (DEC_grow.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  ((((DEC_grow.cln1.filter (fullB DEC_grow.P1))).drop 600).take 600).map (fun i => (DEC_grow.cx0_1.mlx.nodes.get i).map fun nd => DEC_grow.kappa1.prim nd.prim)
end Host.Load.Run.Tpl
