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
boot_rfl PRE_first_tail_x15_r0_body.k1116 from PRE_first_tail_x15_r0_body.s1116 to PRE_first_tail_x15_r0_body.s1117 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB330 ((nth? PRE_first_tail_x15_r0_body.ks 1116).getD 0) PRE_first_tail_x15_r0_body.s1116 PRE_first_tail_x15_r0_body.S1116 = some (PRE_first_tail_x15_r0_body.s1117, PRE_first_tail_x15_r0_body.S1117)
boot_rfl PRE_first_tail_x15_r0_body.stepA331 from PRE_first_tail_x15_r0_body.s1117 to PRE_first_tail_x15_r0_body.s1118 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1117).run PRE_first_tail_x15_r0_body.S1117 = some (PRE_first_tail_x15_r0_body.s1118, PRE_first_tail_x15_r0_body.S1118)
end Host.Load.Run.Tpl
