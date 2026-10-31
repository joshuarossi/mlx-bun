import host.sim.template.a4dec_clear.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_clear.fnd1_3 : (((((DEC_clear.cln1).drop 600).drop 600).drop 600).take 600).all (nodeOKF DEC_clear.kappa1 DEC_clear.P1 DEC_clear.cx0_1.mlx DEC_clear.cx1_1.mlx) = true
end Host.Load.Run.Tpl
