import host.sim.template.a4pre_first_tail_x15_r0_body.H40
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
boot_rfl PRE_first_tail_x15_r0_body.k1276 from PRE_first_tail_x15_r0_body.s1276 to PRE_first_tail_x15_r0_body.s1277 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB377 ((nth? PRE_first_tail_x15_r0_body.ks 1276).getD 0) PRE_first_tail_x15_r0_body.s1276 PRE_first_tail_x15_r0_body.S1276 = some (PRE_first_tail_x15_r0_body.s1277, PRE_first_tail_x15_r0_body.S1277)
boot_rfl PRE_first_tail_x15_r0_body.stepA378 from PRE_first_tail_x15_r0_body.s1277 to PRE_first_tail_x15_r0_body.s1278 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1277).run PRE_first_tail_x15_r0_body.S1277 = some (PRE_first_tail_x15_r0_body.s1278, PRE_first_tail_x15_r0_body.S1278)
boot_rfl PRE_first_tail_x15_r0_body.patchB378 from PRE_first_tail_x15_r0_body.s1278 to PRE_first_tail_x15_r0_body.s1279 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1278).run PRE_first_tail_x15_r0_body.S1278 = some (PRE_first_tail_x15_r0_body.s1279, PRE_first_tail_x15_r0_body.S1279)
boot_rfl PRE_first_tail_x15_r0_body.k1279 from PRE_first_tail_x15_r0_body.s1279 to PRE_first_tail_x15_r0_body.s1280 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB378 ((nth? PRE_first_tail_x15_r0_body.ks 1279).getD 0) PRE_first_tail_x15_r0_body.s1279 PRE_first_tail_x15_r0_body.S1279 = some (PRE_first_tail_x15_r0_body.s1280, PRE_first_tail_x15_r0_body.S1280)
end Host.Load.Run.Tpl
