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
boot_rfl PRE_first_tail_x15_r0_body.k1056 from PRE_first_tail_x15_r0_body.s1056 to PRE_first_tail_x15_r0_body.s1057 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB285 ((nth? PRE_first_tail_x15_r0_body.ks 1056).getD 0) PRE_first_tail_x15_r0_body.s1056 PRE_first_tail_x15_r0_body.S1056 = some (PRE_first_tail_x15_r0_body.s1057, PRE_first_tail_x15_r0_body.S1057)
boot_rfl PRE_first_tail_x15_r0_body.k1057 from PRE_first_tail_x15_r0_body.s1057 to PRE_first_tail_x15_r0_body.s1058 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB285 ((nth? PRE_first_tail_x15_r0_body.ks 1057).getD 0) PRE_first_tail_x15_r0_body.s1057 PRE_first_tail_x15_r0_body.S1057 = some (PRE_first_tail_x15_r0_body.s1058, PRE_first_tail_x15_r0_body.S1058)
boot_rfl PRE_first_tail_x15_r0_body.stepA286 from PRE_first_tail_x15_r0_body.s1058 to PRE_first_tail_x15_r0_body.s1059 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1058).run PRE_first_tail_x15_r0_body.S1058 = some (PRE_first_tail_x15_r0_body.s1059, PRE_first_tail_x15_r0_body.S1059)
end Host.Load.Run.Tpl
