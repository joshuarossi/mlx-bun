import host.sim.template.a4dec_fill.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_fill.fnd1_3 : (((((DEC_fill.cln1).drop 600).drop 600).drop 600).take 600).all (nodeOKF DEC_fill.kappa1 DEC_fill.P1 DEC_fill.cx0_1.mlx DEC_fill.cx1_1.mlx) = true
end Host.Load.Run.Tpl
