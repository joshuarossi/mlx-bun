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
boot_rfl PRE_first_tail_x15_r0_body.k1104 from PRE_first_tail_x15_r0_body.s1104 to PRE_first_tail_x15_r0_body.s1105 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB298 ((nth? PRE_first_tail_x15_r0_body.ks 1104).getD 0) PRE_first_tail_x15_r0_body.s1104 PRE_first_tail_x15_r0_body.S1104 = some (PRE_first_tail_x15_r0_body.s1105, PRE_first_tail_x15_r0_body.S1105)
boot_rfl PRE_first_tail_x15_r0_body.stepA299 from PRE_first_tail_x15_r0_body.s1105 to PRE_first_tail_x15_r0_body.s1106 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1105).run PRE_first_tail_x15_r0_body.S1105 = some (PRE_first_tail_x15_r0_body.s1106, PRE_first_tail_x15_r0_body.S1106)
boot_rfl PRE_first_tail_x15_r0_body.patchB299 from PRE_first_tail_x15_r0_body.s1106 to PRE_first_tail_x15_r0_body.s1107 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1106).run PRE_first_tail_x15_r0_body.S1106 = some (PRE_first_tail_x15_r0_body.s1107, PRE_first_tail_x15_r0_body.S1107)
boot_rfl PRE_first_tail_x15_r0_body.k1107 from PRE_first_tail_x15_r0_body.s1107 to PRE_first_tail_x15_r0_body.s1108 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB299 ((nth? PRE_first_tail_x15_r0_body.ks 1107).getD 0) PRE_first_tail_x15_r0_body.s1107 PRE_first_tail_x15_r0_body.S1107 = some (PRE_first_tail_x15_r0_body.s1108, PRE_first_tail_x15_r0_body.S1108)
end Host.Load.Run.Tpl
