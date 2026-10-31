import host.sim.template.a4pre_first_tail_x15_r0_body.H46
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
boot_rfl PRE_first_tail_x15_r0_body.k1496 from PRE_first_tail_x15_r0_body.s1496 to PRE_first_tail_x15_r0_body.s1497 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB403 ((nth? PRE_first_tail_x15_r0_body.ks 1496).getD 0) PRE_first_tail_x15_r0_body.s1496 PRE_first_tail_x15_r0_body.S1496 = some (PRE_first_tail_x15_r0_body.s1497, PRE_first_tail_x15_r0_body.S1497)
boot_rfl PRE_first_tail_x15_r0_body.k1497 from PRE_first_tail_x15_r0_body.s1497 to PRE_first_tail_x15_r0_body.s1498 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB403 ((nth? PRE_first_tail_x15_r0_body.ks 1497).getD 0) PRE_first_tail_x15_r0_body.s1497 PRE_first_tail_x15_r0_body.S1497 = some (PRE_first_tail_x15_r0_body.s1498, PRE_first_tail_x15_r0_body.S1498)
boot_rfl PRE_first_tail_x15_r0_body.stepA404 from PRE_first_tail_x15_r0_body.s1498 to PRE_first_tail_x15_r0_body.s1499 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1498).run PRE_first_tail_x15_r0_body.S1498 = some (PRE_first_tail_x15_r0_body.s1499, PRE_first_tail_x15_r0_body.S1499)
boot_rfl PRE_first_tail_x15_r0_body.patchB404 from PRE_first_tail_x15_r0_body.s1499 to PRE_first_tail_x15_r0_body.s1500 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1499).run PRE_first_tail_x15_r0_body.S1499 = some (PRE_first_tail_x15_r0_body.s1500, PRE_first_tail_x15_r0_body.S1500)
end Host.Load.Run.Tpl
