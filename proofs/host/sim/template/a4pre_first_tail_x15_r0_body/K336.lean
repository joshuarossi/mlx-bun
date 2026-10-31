import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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
boot_rfl PRE_first_tail_x15_r0_body.k1344 from PRE_first_tail_x15_r0_body.s1344 to PRE_first_tail_x15_r0_body.s1345 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB363 ((nth? PRE_first_tail_x15_r0_body.ks 1344).getD 0) PRE_first_tail_x15_r0_body.s1344 PRE_first_tail_x15_r0_body.S1344 = some (PRE_first_tail_x15_r0_body.s1345, PRE_first_tail_x15_r0_body.S1345)
boot_rfl PRE_first_tail_x15_r0_body.k1345 from PRE_first_tail_x15_r0_body.s1345 to PRE_first_tail_x15_r0_body.s1346 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB363 ((nth? PRE_first_tail_x15_r0_body.ks 1345).getD 0) PRE_first_tail_x15_r0_body.s1345 PRE_first_tail_x15_r0_body.S1345 = some (PRE_first_tail_x15_r0_body.s1346, PRE_first_tail_x15_r0_body.S1346)
boot_rfl PRE_first_tail_x15_r0_body.stepA364 from PRE_first_tail_x15_r0_body.s1346 to PRE_first_tail_x15_r0_body.s1347 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1346).run PRE_first_tail_x15_r0_body.S1346 = some (PRE_first_tail_x15_r0_body.s1347, PRE_first_tail_x15_r0_body.S1347)
end Host.Load.Run.Tpl
