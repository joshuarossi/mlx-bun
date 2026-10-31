import host.sim.template.a4pre_first_tail_x15_r0_body.H47
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
boot_rfl PRE_first_tail_x15_r0_body.k1525 from PRE_first_tail_x15_r0_body.s1525 to PRE_first_tail_x15_r0_body.s1526 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB411 ((nth? PRE_first_tail_x15_r0_body.ks 1525).getD 0) PRE_first_tail_x15_r0_body.s1525 PRE_first_tail_x15_r0_body.S1525 = some (PRE_first_tail_x15_r0_body.s1526, PRE_first_tail_x15_r0_body.S1526)
boot_rfl PRE_first_tail_x15_r0_body.k1526 from PRE_first_tail_x15_r0_body.s1526 to PRE_first_tail_x15_r0_body.s1527 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB411 ((nth? PRE_first_tail_x15_r0_body.ks 1526).getD 0) PRE_first_tail_x15_r0_body.s1526 PRE_first_tail_x15_r0_body.S1526 = some (PRE_first_tail_x15_r0_body.s1527, PRE_first_tail_x15_r0_body.S1527)
boot_rfl PRE_first_tail_x15_r0_body.stepA412 from PRE_first_tail_x15_r0_body.s1527 to PRE_first_tail_x15_r0_body.s1528 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1527).run PRE_first_tail_x15_r0_body.S1527 = some (PRE_first_tail_x15_r0_body.s1528, PRE_first_tail_x15_r0_body.S1528)
end Host.Load.Run.Tpl
