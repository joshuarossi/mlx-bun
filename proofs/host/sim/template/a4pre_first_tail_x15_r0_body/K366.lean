import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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
boot_rfl PRE_first_tail_x15_r0_body.k1464 from PRE_first_tail_x15_r0_body.s1464 to PRE_first_tail_x15_r0_body.s1465 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB395 ((nth? PRE_first_tail_x15_r0_body.ks 1464).getD 0) PRE_first_tail_x15_r0_body.s1464 PRE_first_tail_x15_r0_body.S1464 = some (PRE_first_tail_x15_r0_body.s1465, PRE_first_tail_x15_r0_body.S1465)
boot_rfl PRE_first_tail_x15_r0_body.stepA396 from PRE_first_tail_x15_r0_body.s1465 to PRE_first_tail_x15_r0_body.s1466 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1465).run PRE_first_tail_x15_r0_body.S1465 = some (PRE_first_tail_x15_r0_body.s1466, PRE_first_tail_x15_r0_body.S1466)
end Host.Load.Run.Tpl
