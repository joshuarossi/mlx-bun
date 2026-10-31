import host.sim.template.a4dec_clearFill.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearFill.nhandles_7 : (((((((((handlesOfA DEC_clearFill.X0).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).drop 2000).take 2000).all (handleOK DEC_clearFill.σ DEC_clearFill.PE.lo DEC_clearFill.X0 DEC_clearFill.X1) = true
end Host.Load.Run.Tpl
