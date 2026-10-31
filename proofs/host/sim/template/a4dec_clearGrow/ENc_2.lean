import host.sim.template.a4dec_clearGrow.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_clearGrow.nhandles_1 : (((handlesOfA DEC_clearGrow.X0).drop 2000).take 2000).all (handleOK DEC_clearGrow.σ DEC_clearGrow.PE.lo DEC_clearGrow.X0 DEC_clearGrow.X1) = true
end Host.Load.Run.Tpl
