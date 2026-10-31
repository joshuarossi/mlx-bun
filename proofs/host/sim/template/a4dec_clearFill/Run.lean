import host.sim.template.a4dec_clearFill.K0
import host.sim.template.a4dec_clearFill.K1
import host.sim.template.a4dec_clearFill.K2
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range DEC_clearFill DEC_clearFill.okB1 2 3 runSeg1
sim_chain_range DEC_clearFill DEC_clearFill.okB2 6 7 runSeg2
sim_chain_range DEC_clearFill DEC_clearFill.okB3 10 11 runSeg3
end Host.Load.Run.Tpl
