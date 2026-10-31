import host.sim.template.a4dec_fill.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_fill.fp1_0 : (((DEC_fill.cln1.filter (fullB DEC_fill.P1))).take 600).map (fun i => (DEC_fill.cx1_1.mlx.nodes.get (DEC_fill.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((DEC_fill.cln1.filter (fullB DEC_fill.P1))).take 600).map (fun i => (DEC_fill.cx0_1.mlx.nodes.get i).map fun nd => DEC_fill.kappa1.prim nd.prim)
end Host.Load.Run.Tpl
