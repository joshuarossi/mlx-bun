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
boot_rfl PRE_first_tail_x15_r0_body.stepA309 from PRE_first_tail_x15_r0_body.s1144 to PRE_first_tail_x15_r0_body.s1145 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1144).run PRE_first_tail_x15_r0_body.S1144 = some (PRE_first_tail_x15_r0_body.s1145, PRE_first_tail_x15_r0_body.S1145)
boot_rfl PRE_first_tail_x15_r0_body.k1147 from PRE_first_tail_x15_r0_body.s1147 to PRE_first_tail_x15_r0_body.s1148 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB309 ((nth? PRE_first_tail_x15_r0_body.ks 1147).getD 0) PRE_first_tail_x15_r0_body.s1147 PRE_first_tail_x15_r0_body.S1147 = some (PRE_first_tail_x15_r0_body.s1148, PRE_first_tail_x15_r0_body.S1148)
end Host.Load.Run.Tpl
