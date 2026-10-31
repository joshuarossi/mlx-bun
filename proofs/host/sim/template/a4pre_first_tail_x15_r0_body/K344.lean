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
boot_rfl PRE_first_tail_x15_r0_body.k1377 from PRE_first_tail_x15_r0_body.s1377 to PRE_first_tail_x15_r0_body.s1378 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB371 ((nth? PRE_first_tail_x15_r0_body.ks 1377).getD 0) PRE_first_tail_x15_r0_body.s1377 PRE_first_tail_x15_r0_body.S1377 = some (PRE_first_tail_x15_r0_body.s1378, PRE_first_tail_x15_r0_body.S1378)
boot_rfl PRE_first_tail_x15_r0_body.stepA372 from PRE_first_tail_x15_r0_body.s1378 to PRE_first_tail_x15_r0_body.s1379 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1378).run PRE_first_tail_x15_r0_body.S1378 = some (PRE_first_tail_x15_r0_body.s1379, PRE_first_tail_x15_r0_body.S1379)
end Host.Load.Run.Tpl
