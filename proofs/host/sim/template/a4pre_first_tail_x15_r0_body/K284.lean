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
boot_rfl PRE_first_tail_x15_r0_body.stepA307 from PRE_first_tail_x15_r0_body.s1136 to PRE_first_tail_x15_r0_body.s1137 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1136).run PRE_first_tail_x15_r0_body.S1136 = some (PRE_first_tail_x15_r0_body.s1137, PRE_first_tail_x15_r0_body.S1137)
boot_rfl PRE_first_tail_x15_r0_body.k1139 from PRE_first_tail_x15_r0_body.s1139 to PRE_first_tail_x15_r0_body.s1140 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB307 ((nth? PRE_first_tail_x15_r0_body.ks 1139).getD 0) PRE_first_tail_x15_r0_body.s1139 PRE_first_tail_x15_r0_body.S1139 = some (PRE_first_tail_x15_r0_body.s1140, PRE_first_tail_x15_r0_body.S1140)
end Host.Load.Run.Tpl
