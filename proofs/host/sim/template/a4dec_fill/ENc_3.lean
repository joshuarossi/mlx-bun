import host.sim.template.a4dec_fill.ENa
set_option Elab.async false
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Template
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

kernel_rfl DEC_fill.nhandles_2 : ((((handlesOfA DEC_fill.X0).drop 2000).drop 2000).take 2000).all (handleOK DEC_fill.σ DEC_fill.PE.lo DEC_fill.X0 DEC_fill.X1) = true
end Host.Load.Run.Tpl
