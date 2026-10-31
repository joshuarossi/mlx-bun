import host.sim.template.a4dec_ord.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_ord.nnodes_6 : ((((((((PTrie.keysA DEC_ord.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF DEC_ord.σ DEC_ord.PE DEC_ord.X0 DEC_ord.X1) = true
end Host.Load.Run.Tpl
