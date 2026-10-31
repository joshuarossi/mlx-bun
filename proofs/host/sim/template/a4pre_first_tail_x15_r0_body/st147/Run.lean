import host.sim.template.a4pre_first_tail_x15_r0_body.st147.K0
import host.sim.template.a4pre_first_tail_x15_r0_body.st147.K1
import host.sim.template.ChainRange
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts.Sim Host.Ts.Sim.Template
sim_chain_range PRE_first_tail_x15_r0_body.st147 PRE_first_tail_x15_r0_body.st147.okL 0 4 run
end Host.Load.Run.Tpl
