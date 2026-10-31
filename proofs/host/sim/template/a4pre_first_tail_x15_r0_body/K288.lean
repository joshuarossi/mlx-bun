import host.sim.template.a4pre_first_tail_x15_r0_body.H36
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
boot_rfl PRE_first_tail_x15_r0_body.stepA341 from PRE_first_tail_x15_r0_body.s1152 to PRE_first_tail_x15_r0_body.s1153 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1152).run PRE_first_tail_x15_r0_body.S1152 = some (PRE_first_tail_x15_r0_body.s1153, PRE_first_tail_x15_r0_body.S1153)
boot_rfl PRE_first_tail_x15_r0_body.k1155 from PRE_first_tail_x15_r0_body.s1155 to PRE_first_tail_x15_r0_body.s1156 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB341 ((nth? PRE_first_tail_x15_r0_body.ks 1155).getD 0) PRE_first_tail_x15_r0_body.s1155 PRE_first_tail_x15_r0_body.S1155 = some (PRE_first_tail_x15_r0_body.s1156, PRE_first_tail_x15_r0_body.S1156)
end Host.Load.Run.Tpl
