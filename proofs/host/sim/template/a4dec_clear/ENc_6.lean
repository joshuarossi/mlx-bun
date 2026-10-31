import host.sim.template.a4dec_clear.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clear.nhandles_5 : (((((((handlesOfA DEC_clear.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (handleOK DEC_clear.σ DEC_clear.PE.lo DEC_clear.X0 DEC_clear.X1) = true
end Host.Load.Run.Tpl
