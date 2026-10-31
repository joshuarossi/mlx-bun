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
boot_rfl PRE_first_tail_x15_r0_body.k1216 from PRE_first_tail_x15_r0_body.s1216 to PRE_first_tail_x15_r0_body.s1217 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB328 ((nth? PRE_first_tail_x15_r0_body.ks 1216).getD 0) PRE_first_tail_x15_r0_body.s1216 PRE_first_tail_x15_r0_body.S1216 = some (PRE_first_tail_x15_r0_body.s1217, PRE_first_tail_x15_r0_body.S1217)
boot_rfl PRE_first_tail_x15_r0_body.stepA329 from PRE_first_tail_x15_r0_body.s1217 to PRE_first_tail_x15_r0_body.s1218 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1217).run PRE_first_tail_x15_r0_body.S1217 = some (PRE_first_tail_x15_r0_body.s1218, PRE_first_tail_x15_r0_body.S1218)
boot_rfl PRE_first_tail_x15_r0_body.patchB329 from PRE_first_tail_x15_r0_body.s1218 to PRE_first_tail_x15_r0_body.s1219 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1218).run PRE_first_tail_x15_r0_body.S1218 = some (PRE_first_tail_x15_r0_body.s1219, PRE_first_tail_x15_r0_body.S1219)
boot_rfl PRE_first_tail_x15_r0_body.k1219 from PRE_first_tail_x15_r0_body.s1219 to PRE_first_tail_x15_r0_body.s1220 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB329 ((nth? PRE_first_tail_x15_r0_body.ks 1219).getD 0) PRE_first_tail_x15_r0_body.s1219 PRE_first_tail_x15_r0_body.S1219 = some (PRE_first_tail_x15_r0_body.s1220, PRE_first_tail_x15_r0_body.S1220)
end Host.Load.Run.Tpl
