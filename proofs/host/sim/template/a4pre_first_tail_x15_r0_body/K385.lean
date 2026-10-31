import host.sim.template.a4pre_first_tail_x15_r0_body.H48
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
boot_rfl PRE_first_tail_x15_r0_body.k1542 from PRE_first_tail_x15_r0_body.s1542 to PRE_first_tail_x15_r0_body.s1543 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB416 ((nth? PRE_first_tail_x15_r0_body.ks 1542).getD 0) PRE_first_tail_x15_r0_body.s1542 PRE_first_tail_x15_r0_body.S1542 = some (PRE_first_tail_x15_r0_body.s1543, PRE_first_tail_x15_r0_body.S1543)
boot_rfl PRE_first_tail_x15_r0_body.stepA417 from PRE_first_tail_x15_r0_body.s1543 to PRE_first_tail_x15_r0_body.s1544 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1543).run PRE_first_tail_x15_r0_body.S1543 = some (PRE_first_tail_x15_r0_body.s1544, PRE_first_tail_x15_r0_body.S1544)
end Host.Load.Run.Tpl
