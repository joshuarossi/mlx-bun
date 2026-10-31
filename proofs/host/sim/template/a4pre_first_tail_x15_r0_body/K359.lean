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
boot_rfl PRE_first_tail_x15_r0_body.stepA388 from PRE_first_tail_x15_r0_body.s1436 to PRE_first_tail_x15_r0_body.s1437 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1436).run PRE_first_tail_x15_r0_body.S1436 = some (PRE_first_tail_x15_r0_body.s1437, PRE_first_tail_x15_r0_body.S1437)
boot_rfl PRE_first_tail_x15_r0_body.k1439 from PRE_first_tail_x15_r0_body.s1439 to PRE_first_tail_x15_r0_body.s1440 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB388 ((nth? PRE_first_tail_x15_r0_body.ks 1439).getD 0) PRE_first_tail_x15_r0_body.s1439 PRE_first_tail_x15_r0_body.S1439 = some (PRE_first_tail_x15_r0_body.s1440, PRE_first_tail_x15_r0_body.S1440)
end Host.Load.Run.Tpl
