import host.sim.template.a4pre_first_tail_x15_r0_body.H49
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
boot_rfl PRE_first_tail_x15_r0_body.stepA424 from PRE_first_tail_x15_r0_body.s1568 to PRE_first_tail_x15_r0_body.s1569 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1568).run PRE_first_tail_x15_r0_body.S1568 = some (PRE_first_tail_x15_r0_body.s1569, PRE_first_tail_x15_r0_body.S1569)
boot_rfl PRE_first_tail_x15_r0_body.k1571 from PRE_first_tail_x15_r0_body.s1571 to PRE_first_tail_x15_r0_body.s1572 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB424 ((nth? PRE_first_tail_x15_r0_body.ks 1571).getD 0) PRE_first_tail_x15_r0_body.s1571 PRE_first_tail_x15_r0_body.S1571 = some (PRE_first_tail_x15_r0_body.s1572, PRE_first_tail_x15_r0_body.S1572)
end Host.Load.Run.Tpl
