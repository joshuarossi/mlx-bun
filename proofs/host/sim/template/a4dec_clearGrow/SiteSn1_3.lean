import host.sim.template.a4dec_clearGrow.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearGrow.fnd1_3 : (((((DEC_clearGrow.cln1).drop 600).drop 600).drop 600).take 600).all (nodeOKF DEC_clearGrow.kappa1 DEC_clearGrow.P1 DEC_clearGrow.cx0_1.mlx DEC_clearGrow.cx1_1.mlx) = true
end Host.Load.Run.Tpl
