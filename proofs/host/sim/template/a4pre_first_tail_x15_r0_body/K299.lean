import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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
boot_rfl PRE_first_tail_x15_r0_body.k1197 from PRE_first_tail_x15_r0_body.s1197 to PRE_first_tail_x15_r0_body.s1198 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB323 ((nth? PRE_first_tail_x15_r0_body.ks 1197).getD 0) PRE_first_tail_x15_r0_body.s1197 PRE_first_tail_x15_r0_body.S1197 = some (PRE_first_tail_x15_r0_body.s1198, PRE_first_tail_x15_r0_body.S1198)
boot_rfl PRE_first_tail_x15_r0_body.stepA324 from PRE_first_tail_x15_r0_body.s1198 to PRE_first_tail_x15_r0_body.s1199 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1198).run PRE_first_tail_x15_r0_body.S1198 = some (PRE_first_tail_x15_r0_body.s1199, PRE_first_tail_x15_r0_body.S1199)
boot_rfl PRE_first_tail_x15_r0_body.patchB324 from PRE_first_tail_x15_r0_body.s1199 to PRE_first_tail_x15_r0_body.s1200 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1199).run PRE_first_tail_x15_r0_body.S1199 = some (PRE_first_tail_x15_r0_body.s1200, PRE_first_tail_x15_r0_body.S1200)
end Host.Load.Run.Tpl
