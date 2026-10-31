import host.sim.template.a4pre_setup_h2_chunk.K0
import host.sim.template.ChainRange
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range PRE_setup_h2_chunk PRE_setup_h2_chunk.okB1 2 3 runSeg1
end Host.Load.Run.Tpl
