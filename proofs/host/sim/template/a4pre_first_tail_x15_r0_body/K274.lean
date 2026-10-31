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
boot_rfl PRE_first_tail_x15_r0_body.k1096 from PRE_first_tail_x15_r0_body.s1096 to PRE_first_tail_x15_r0_body.s1097 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB324 ((nth? PRE_first_tail_x15_r0_body.ks 1096).getD 0) PRE_first_tail_x15_r0_body.s1096 PRE_first_tail_x15_r0_body.S1096 = some (PRE_first_tail_x15_r0_body.s1097, PRE_first_tail_x15_r0_body.S1097)
boot_rfl PRE_first_tail_x15_r0_body.stepA325 from PRE_first_tail_x15_r0_body.s1097 to PRE_first_tail_x15_r0_body.s1098 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1097).run PRE_first_tail_x15_r0_body.S1097 = some (PRE_first_tail_x15_r0_body.s1098, PRE_first_tail_x15_r0_body.S1098)
end Host.Load.Run.Tpl
