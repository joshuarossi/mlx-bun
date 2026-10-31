import host.sim.template.a4pre_first_tail_x15_r0_body.H41
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
boot_rfl PRE_first_tail_x15_r0_body.k1310 from PRE_first_tail_x15_r0_body.s1310 to PRE_first_tail_x15_r0_body.s1311 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB387 ((nth? PRE_first_tail_x15_r0_body.ks 1310).getD 0) PRE_first_tail_x15_r0_body.s1310 PRE_first_tail_x15_r0_body.S1310 = some (PRE_first_tail_x15_r0_body.s1311, PRE_first_tail_x15_r0_body.S1311)
boot_rfl PRE_first_tail_x15_r0_body.stepA388 from PRE_first_tail_x15_r0_body.s1311 to PRE_first_tail_x15_r0_body.s1312 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1311).run PRE_first_tail_x15_r0_body.S1311 = some (PRE_first_tail_x15_r0_body.s1312, PRE_first_tail_x15_r0_body.S1312)
end Host.Load.Run.Tpl
