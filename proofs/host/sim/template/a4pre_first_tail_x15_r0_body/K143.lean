import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.stepA170 from PRE_first_tail_x15_r0_body.s572 to PRE_first_tail_x15_r0_body.s573 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s572).run PRE_first_tail_x15_r0_body.S572 = some (PRE_first_tail_x15_r0_body.s573, PRE_first_tail_x15_r0_body.S573)
boot_rfl PRE_first_tail_x15_r0_body.k575 from PRE_first_tail_x15_r0_body.s575 to PRE_first_tail_x15_r0_body.s576 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB170 ((nth? PRE_first_tail_x15_r0_body.ks 575).getD 0) PRE_first_tail_x15_r0_body.s575 PRE_first_tail_x15_r0_body.S575 = some (PRE_first_tail_x15_r0_body.s576, PRE_first_tail_x15_r0_body.S576)
end Host.Load.Run.Tpl
