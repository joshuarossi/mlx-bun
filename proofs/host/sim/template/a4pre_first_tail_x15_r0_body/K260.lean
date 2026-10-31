import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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
boot_rfl PRE_first_tail_x15_r0_body.k1040 from PRE_first_tail_x15_r0_body.s1040 to PRE_first_tail_x15_r0_body.s1041 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB280 ((nth? PRE_first_tail_x15_r0_body.ks 1040).getD 0) PRE_first_tail_x15_r0_body.s1040 PRE_first_tail_x15_r0_body.S1040 = some (PRE_first_tail_x15_r0_body.s1041, PRE_first_tail_x15_r0_body.S1041)
boot_rfl PRE_first_tail_x15_r0_body.stepA281 from PRE_first_tail_x15_r0_body.s1041 to PRE_first_tail_x15_r0_body.s1042 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1041).run PRE_first_tail_x15_r0_body.S1041 = some (PRE_first_tail_x15_r0_body.s1042, PRE_first_tail_x15_r0_body.S1042)
boot_rfl PRE_first_tail_x15_r0_body.patchB281 from PRE_first_tail_x15_r0_body.s1042 to PRE_first_tail_x15_r0_body.s1043 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1042).run PRE_first_tail_x15_r0_body.S1042 = some (PRE_first_tail_x15_r0_body.s1043, PRE_first_tail_x15_r0_body.S1043)
boot_rfl PRE_first_tail_x15_r0_body.k1043 from PRE_first_tail_x15_r0_body.s1043 to PRE_first_tail_x15_r0_body.s1044 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB281 ((nth? PRE_first_tail_x15_r0_body.ks 1043).getD 0) PRE_first_tail_x15_r0_body.s1043 PRE_first_tail_x15_r0_body.S1043 = some (PRE_first_tail_x15_r0_body.s1044, PRE_first_tail_x15_r0_body.S1044)
end Host.Load.Run.Tpl
