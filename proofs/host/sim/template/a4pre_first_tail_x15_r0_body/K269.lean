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
boot_rfl PRE_first_tail_x15_r0_body.stepA291 from PRE_first_tail_x15_r0_body.s1076 to PRE_first_tail_x15_r0_body.s1077 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1076).run PRE_first_tail_x15_r0_body.S1076 = some (PRE_first_tail_x15_r0_body.s1077, PRE_first_tail_x15_r0_body.S1077)
boot_rfl PRE_first_tail_x15_r0_body.patchB291 from PRE_first_tail_x15_r0_body.s1077 to PRE_first_tail_x15_r0_body.s1078 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1077).run PRE_first_tail_x15_r0_body.S1077 = some (PRE_first_tail_x15_r0_body.s1078, PRE_first_tail_x15_r0_body.S1078)
boot_rfl PRE_first_tail_x15_r0_body.k1078 from PRE_first_tail_x15_r0_body.s1078 to PRE_first_tail_x15_r0_body.s1079 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB291 ((nth? PRE_first_tail_x15_r0_body.ks 1078).getD 0) PRE_first_tail_x15_r0_body.s1078 PRE_first_tail_x15_r0_body.S1078 = some (PRE_first_tail_x15_r0_body.s1079, PRE_first_tail_x15_r0_body.S1079)
boot_rfl PRE_first_tail_x15_r0_body.stepA292 from PRE_first_tail_x15_r0_body.s1079 to PRE_first_tail_x15_r0_body.s1080 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1079).run PRE_first_tail_x15_r0_body.S1079 = some (PRE_first_tail_x15_r0_body.s1080, PRE_first_tail_x15_r0_body.S1080)
end Host.Load.Run.Tpl
