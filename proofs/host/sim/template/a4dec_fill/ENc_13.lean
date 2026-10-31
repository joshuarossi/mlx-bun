import host.sim.template.a4dec_fill.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_fill.nnodes_4 : ((((((PTrie.keysA DEC_fill.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF DEC_fill.σ DEC_fill.PE DEC_fill.X0 DEC_fill.X1) = true
end Host.Load.Run.Tpl
