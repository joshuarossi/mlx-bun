import host.sim.template.a4dec_grow.SiteSa1
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template

kernel_rfl DEC_grow.fnd1_4 : ((((((DEC_grow.cln1).drop 600).drop 600).drop 600).drop 600).take 600).all (nodeOKF DEC_grow.kappa1 DEC_grow.P1 DEC_grow.cx0_1.mlx DEC_grow.cx1_1.mlx) = true
end Host.Load.Run.Tpl
