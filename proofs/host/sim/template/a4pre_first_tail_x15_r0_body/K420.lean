import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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
boot_rfl PRE_first_tail_x15_r0_body.stepA454 from PRE_first_tail_x15_r0_body.s1680 to PRE_first_tail_x15_r0_body.s1681 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1680).run PRE_first_tail_x15_r0_body.S1680 = some (PRE_first_tail_x15_r0_body.s1681, PRE_first_tail_x15_r0_body.S1681)
boot_rfl PRE_first_tail_x15_r0_body.patchB454 from PRE_first_tail_x15_r0_body.s1681 to PRE_first_tail_x15_r0_body.s1682 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1681).run PRE_first_tail_x15_r0_body.S1681 = some (PRE_first_tail_x15_r0_body.s1682, PRE_first_tail_x15_r0_body.S1682)
boot_rfl PRE_first_tail_x15_r0_body.k1682 from PRE_first_tail_x15_r0_body.s1682 to PRE_first_tail_x15_r0_body.s1683 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB454 ((nth? PRE_first_tail_x15_r0_body.ks 1682).getD 0) PRE_first_tail_x15_r0_body.s1682 PRE_first_tail_x15_r0_body.S1682 = some (PRE_first_tail_x15_r0_body.s1683, PRE_first_tail_x15_r0_body.S1683)
boot_rfl PRE_first_tail_x15_r0_body.stepA455 from PRE_first_tail_x15_r0_body.s1683 to PRE_first_tail_x15_r0_body.s1684 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1683).run PRE_first_tail_x15_r0_body.S1683 = some (PRE_first_tail_x15_r0_body.s1684, PRE_first_tail_x15_r0_body.S1684)
end Host.Load.Run.Tpl
