import host.sim.template.a4pre_setup_h4_chunk.st0.K0
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range PRE_setup_h4_chunk.st0 PRE_setup_h4_chunk.st0.okL 0 3 run
end Host.Load.Run.Tpl
