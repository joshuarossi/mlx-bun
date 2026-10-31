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
boot_rfl PRE_first_tail_x15_r0_body.k1353 from PRE_first_tail_x15_r0_body.s1353 to PRE_first_tail_x15_r0_body.s1354 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB365 ((nth? PRE_first_tail_x15_r0_body.ks 1353).getD 0) PRE_first_tail_x15_r0_body.s1353 PRE_first_tail_x15_r0_body.S1353 = some (PRE_first_tail_x15_r0_body.s1354, PRE_first_tail_x15_r0_body.S1354)
boot_rfl PRE_first_tail_x15_r0_body.k1354 from PRE_first_tail_x15_r0_body.s1354 to PRE_first_tail_x15_r0_body.s1355 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB365 ((nth? PRE_first_tail_x15_r0_body.ks 1354).getD 0) PRE_first_tail_x15_r0_body.s1354 PRE_first_tail_x15_r0_body.S1354 = some (PRE_first_tail_x15_r0_body.s1355, PRE_first_tail_x15_r0_body.S1355)
boot_rfl PRE_first_tail_x15_r0_body.stepA366 from PRE_first_tail_x15_r0_body.s1355 to PRE_first_tail_x15_r0_body.s1356 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1355).run PRE_first_tail_x15_r0_body.S1355 = some (PRE_first_tail_x15_r0_body.s1356, PRE_first_tail_x15_r0_body.S1356)
end Host.Load.Run.Tpl
