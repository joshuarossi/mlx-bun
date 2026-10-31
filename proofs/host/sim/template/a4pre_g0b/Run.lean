import host.sim.template.a4pre_g0b.K0
import host.sim.template.a4pre_g0b.K1
import host.sim.template.a4pre_g0b.K2
import host.sim.template.ChainRange
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range PRE_g0b PRE_g0b.okB0 0 1 runSeg0
sim_chain_range PRE_g0b PRE_g0b.okB1 3 4 runSeg1
sim_chain_range PRE_g0b PRE_g0b.okB2 6 7 runSeg2
sim_chain_range PRE_g0b PRE_g0b.okB3 9 10 runSeg3
end Host.Load.Run.Tpl
