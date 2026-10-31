import host.sim.template.a4dec_clearGrow.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearGrow.fp1_4 : (((((((DEC_clearGrow.cln1.filter (fullB DEC_clearGrow.P1))).drop 600).drop 600).drop 600).drop 600).take 600).map (fun i => (DEC_clearGrow.cx1_1.mlx.nodes.get (DEC_clearGrow.kappa1.node i)).map Host.Mlx.Ffi.Node.prim) =
  (((((((DEC_clearGrow.cln1.filter (fullB DEC_clearGrow.P1))).drop 600).drop 600).drop 600).drop 600).take 600).map (fun i => (DEC_clearGrow.cx0_1.mlx.nodes.get i).map fun nd => DEC_clearGrow.kappa1.prim nd.prim)
end Host.Load.Run.Tpl
