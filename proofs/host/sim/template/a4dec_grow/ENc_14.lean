import host.sim.template.a4dec_grow.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_grow.nnodes_5 : (((((((PTrie.keysA DEC_grow.X0.nodes).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (nodeOKF DEC_grow.σ DEC_grow.PE DEC_grow.X0 DEC_grow.X1) = true
end Host.Load.Run.Tpl
