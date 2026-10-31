import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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
boot_rfl PRE_first_tail_x15_r0_body.k1066 from PRE_first_tail_x15_r0_body.s1066 to PRE_first_tail_x15_r0_body.s1067 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB315 ((nth? PRE_first_tail_x15_r0_body.ks 1066).getD 0) PRE_first_tail_x15_r0_body.s1066 PRE_first_tail_x15_r0_body.S1066 = some (PRE_first_tail_x15_r0_body.s1067, PRE_first_tail_x15_r0_body.S1067)
boot_rfl PRE_first_tail_x15_r0_body.stepA316 from PRE_first_tail_x15_r0_body.s1067 to PRE_first_tail_x15_r0_body.s1068 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1067).run PRE_first_tail_x15_r0_body.S1067 = some (PRE_first_tail_x15_r0_body.s1068, PRE_first_tail_x15_r0_body.S1068)
end Host.Load.Run.Tpl
