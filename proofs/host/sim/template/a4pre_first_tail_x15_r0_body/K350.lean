import host.sim.template.a4pre_first_tail_x15_r0_body.H43
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
boot_rfl PRE_first_tail_x15_r0_body.patchB378 from PRE_first_tail_x15_r0_body.s1400 to PRE_first_tail_x15_r0_body.s1401 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1400).run PRE_first_tail_x15_r0_body.S1400 = some (PRE_first_tail_x15_r0_body.s1401, PRE_first_tail_x15_r0_body.S1401)
boot_rfl PRE_first_tail_x15_r0_body.k1401 from PRE_first_tail_x15_r0_body.s1401 to PRE_first_tail_x15_r0_body.s1402 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB378 ((nth? PRE_first_tail_x15_r0_body.ks 1401).getD 0) PRE_first_tail_x15_r0_body.s1401 PRE_first_tail_x15_r0_body.S1401 = some (PRE_first_tail_x15_r0_body.s1402, PRE_first_tail_x15_r0_body.S1402)
boot_rfl PRE_first_tail_x15_r0_body.k1402 from PRE_first_tail_x15_r0_body.s1402 to PRE_first_tail_x15_r0_body.s1403 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB378 ((nth? PRE_first_tail_x15_r0_body.ks 1402).getD 0) PRE_first_tail_x15_r0_body.s1402 PRE_first_tail_x15_r0_body.S1402 = some (PRE_first_tail_x15_r0_body.s1403, PRE_first_tail_x15_r0_body.S1403)
boot_rfl PRE_first_tail_x15_r0_body.stepA379 from PRE_first_tail_x15_r0_body.s1403 to PRE_first_tail_x15_r0_body.s1404 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1403).run PRE_first_tail_x15_r0_body.S1403 = some (PRE_first_tail_x15_r0_body.s1404, PRE_first_tail_x15_r0_body.S1404)
end Host.Load.Run.Tpl
