import host.sim.template.a4dec_clear.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clear.fp1_0 : (((DEC_clear.cln1.filter (fullB DEC_clear.P1))).take 600).map (fun i => (DEC_clear.cx1_1.mlx.nodes.get (DEC_clear.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((DEC_clear.cln1.filter (fullB DEC_clear.P1))).take 600).map (fun i => (DEC_clear.cx0_1.mlx.nodes.get i).map fun nd => DEC_clear.kappa1.prim nd.prim)
end Host.Load.Run.Tpl
