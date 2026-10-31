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
boot_rfl PRE_first_tail_x15_r0_body.stepA301 from PRE_first_tail_x15_r0_body.s1112 to PRE_first_tail_x15_r0_body.s1113 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1112).run PRE_first_tail_x15_r0_body.S1112 = some (PRE_first_tail_x15_r0_body.s1113, PRE_first_tail_x15_r0_body.S1113)
boot_rfl PRE_first_tail_x15_r0_body.patchB301 from PRE_first_tail_x15_r0_body.s1113 to PRE_first_tail_x15_r0_body.s1114 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1113).run PRE_first_tail_x15_r0_body.S1113 = some (PRE_first_tail_x15_r0_body.s1114, PRE_first_tail_x15_r0_body.S1114)
boot_rfl PRE_first_tail_x15_r0_body.k1114 from PRE_first_tail_x15_r0_body.s1114 to PRE_first_tail_x15_r0_body.s1115 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB301 ((nth? PRE_first_tail_x15_r0_body.ks 1114).getD 0) PRE_first_tail_x15_r0_body.s1114 PRE_first_tail_x15_r0_body.S1114 = some (PRE_first_tail_x15_r0_body.s1115, PRE_first_tail_x15_r0_body.S1115)
boot_rfl PRE_first_tail_x15_r0_body.k1115 from PRE_first_tail_x15_r0_body.s1115 to PRE_first_tail_x15_r0_body.s1116 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB301 ((nth? PRE_first_tail_x15_r0_body.ks 1115).getD 0) PRE_first_tail_x15_r0_body.s1115 PRE_first_tail_x15_r0_body.S1115 = some (PRE_first_tail_x15_r0_body.s1116, PRE_first_tail_x15_r0_body.S1116)
end Host.Load.Run.Tpl
