import host.sim.template.a4pre_first_tail_x15_r0_body.H35
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
boot_rfl PRE_first_tail_x15_r0_body.k1128 from PRE_first_tail_x15_r0_body.s1128 to PRE_first_tail_x15_r0_body.s1129 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB304 ((nth? PRE_first_tail_x15_r0_body.ks 1128).getD 0) PRE_first_tail_x15_r0_body.s1128 PRE_first_tail_x15_r0_body.S1128 = some (PRE_first_tail_x15_r0_body.s1129, PRE_first_tail_x15_r0_body.S1129)
boot_rfl PRE_first_tail_x15_r0_body.stepA305 from PRE_first_tail_x15_r0_body.s1129 to PRE_first_tail_x15_r0_body.s1130 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1129).run PRE_first_tail_x15_r0_body.S1129 = some (PRE_first_tail_x15_r0_body.s1130, PRE_first_tail_x15_r0_body.S1130)
boot_rfl PRE_first_tail_x15_r0_body.patchB305 from PRE_first_tail_x15_r0_body.s1130 to PRE_first_tail_x15_r0_body.s1131 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1130).run PRE_first_tail_x15_r0_body.S1130 = some (PRE_first_tail_x15_r0_body.s1131, PRE_first_tail_x15_r0_body.S1131)
boot_rfl PRE_first_tail_x15_r0_body.k1131 from PRE_first_tail_x15_r0_body.s1131 to PRE_first_tail_x15_r0_body.s1132 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB305 ((nth? PRE_first_tail_x15_r0_body.ks 1131).getD 0) PRE_first_tail_x15_r0_body.s1131 PRE_first_tail_x15_r0_body.S1131 = some (PRE_first_tail_x15_r0_body.s1132, PRE_first_tail_x15_r0_body.S1132)
end Host.Load.Run.Tpl
