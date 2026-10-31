import host.sim.template.a4pre_first_tail_x15_r0_body.H51
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
boot_rfl PRE_first_tail_x15_r0_body.k1628 from PRE_first_tail_x15_r0_body.s1628 to PRE_first_tail_x15_r0_body.s1629 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB439 ((nth? PRE_first_tail_x15_r0_body.ks 1628).getD 0) PRE_first_tail_x15_r0_body.s1628 PRE_first_tail_x15_r0_body.S1628 = some (PRE_first_tail_x15_r0_body.s1629, PRE_first_tail_x15_r0_body.S1629)
boot_rfl PRE_first_tail_x15_r0_body.stepA440 from PRE_first_tail_x15_r0_body.s1629 to PRE_first_tail_x15_r0_body.s1630 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1629).run PRE_first_tail_x15_r0_body.S1629 = some (PRE_first_tail_x15_r0_body.s1630, PRE_first_tail_x15_r0_body.S1630)
boot_rfl PRE_first_tail_x15_r0_body.patchB440 from PRE_first_tail_x15_r0_body.s1630 to PRE_first_tail_x15_r0_body.s1631 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1630).run PRE_first_tail_x15_r0_body.S1630 = some (PRE_first_tail_x15_r0_body.s1631, PRE_first_tail_x15_r0_body.S1631)
boot_rfl PRE_first_tail_x15_r0_body.k1631 from PRE_first_tail_x15_r0_body.s1631 to PRE_first_tail_x15_r0_body.s1632 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB440 ((nth? PRE_first_tail_x15_r0_body.ks 1631).getD 0) PRE_first_tail_x15_r0_body.s1631 PRE_first_tail_x15_r0_body.S1631 = some (PRE_first_tail_x15_r0_body.s1632, PRE_first_tail_x15_r0_body.S1632)
end Host.Load.Run.Tpl
