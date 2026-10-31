import host.sim.template.a4pre_first_tail_x15_r0_body.H38
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
boot_rfl PRE_first_tail_x15_r0_body.k1232 from PRE_first_tail_x15_r0_body.s1232 to PRE_first_tail_x15_r0_body.s1233 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB364 ((nth? PRE_first_tail_x15_r0_body.ks 1232).getD 0) PRE_first_tail_x15_r0_body.s1232 PRE_first_tail_x15_r0_body.S1232 = some (PRE_first_tail_x15_r0_body.s1233, PRE_first_tail_x15_r0_body.S1233)
boot_rfl PRE_first_tail_x15_r0_body.stepA365 from PRE_first_tail_x15_r0_body.s1233 to PRE_first_tail_x15_r0_body.s1234 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1233).run PRE_first_tail_x15_r0_body.S1233 = some (PRE_first_tail_x15_r0_body.s1234, PRE_first_tail_x15_r0_body.S1234)
end Host.Load.Run.Tpl
