import host.sim.template.a4pre_first_tail_x15_r0_body.H34
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
boot_rfl PRE_first_tail_x15_r0_body.stepA321 from PRE_first_tail_x15_r0_body.s1084 to PRE_first_tail_x15_r0_body.s1085 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1084).run PRE_first_tail_x15_r0_body.S1084 = some (PRE_first_tail_x15_r0_body.s1085, PRE_first_tail_x15_r0_body.S1085)
boot_rfl PRE_first_tail_x15_r0_body.patchB321 from PRE_first_tail_x15_r0_body.s1085 to PRE_first_tail_x15_r0_body.s1086 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1085).run PRE_first_tail_x15_r0_body.S1085 = some (PRE_first_tail_x15_r0_body.s1086, PRE_first_tail_x15_r0_body.S1086)
boot_rfl PRE_first_tail_x15_r0_body.k1086 from PRE_first_tail_x15_r0_body.s1086 to PRE_first_tail_x15_r0_body.s1087 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB321 ((nth? PRE_first_tail_x15_r0_body.ks 1086).getD 0) PRE_first_tail_x15_r0_body.s1086 PRE_first_tail_x15_r0_body.S1086 = some (PRE_first_tail_x15_r0_body.s1087, PRE_first_tail_x15_r0_body.S1087)
boot_rfl PRE_first_tail_x15_r0_body.stepA322 from PRE_first_tail_x15_r0_body.s1087 to PRE_first_tail_x15_r0_body.s1088 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1087).run PRE_first_tail_x15_r0_body.S1087 = some (PRE_first_tail_x15_r0_body.s1088, PRE_first_tail_x15_r0_body.S1088)
end Host.Load.Run.Tpl
