import host.sim.template.a4pre_first_tail_x15_r0_body.H46
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
boot_rfl PRE_first_tail_x15_r0_body.k1480 from PRE_first_tail_x15_r0_body.s1480 to PRE_first_tail_x15_r0_body.s1481 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB399 ((nth? PRE_first_tail_x15_r0_body.ks 1480).getD 0) PRE_first_tail_x15_r0_body.s1480 PRE_first_tail_x15_r0_body.S1480 = some (PRE_first_tail_x15_r0_body.s1481, PRE_first_tail_x15_r0_body.S1481)
boot_rfl PRE_first_tail_x15_r0_body.stepA400 from PRE_first_tail_x15_r0_body.s1481 to PRE_first_tail_x15_r0_body.s1482 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1481).run PRE_first_tail_x15_r0_body.S1481 = some (PRE_first_tail_x15_r0_body.s1482, PRE_first_tail_x15_r0_body.S1482)
end Host.Load.Run.Tpl
