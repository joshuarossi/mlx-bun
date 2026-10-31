import host.sim.template.a4dec_clearFill.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clearFill.fnd1_1 : (((DEC_clearFill.cln1).drop 600).take 600).all (nodeOKF DEC_clearFill.kappa1 DEC_clearFill.P1 DEC_clearFill.cx0_1.mlx DEC_clearFill.cx1_1.mlx) = true
end Host.Load.Run.Tpl
