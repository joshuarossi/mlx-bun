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
boot_rfl PRE_first_tail_x15_r0_body.k1657 from PRE_first_tail_x15_r0_body.s1657 to PRE_first_tail_x15_r0_body.s1658 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB447 ((nth? PRE_first_tail_x15_r0_body.ks 1657).getD 0) PRE_first_tail_x15_r0_body.s1657 PRE_first_tail_x15_r0_body.S1657 = some (PRE_first_tail_x15_r0_body.s1658, PRE_first_tail_x15_r0_body.S1658)
boot_rfl PRE_first_tail_x15_r0_body.stepA448 from PRE_first_tail_x15_r0_body.s1658 to PRE_first_tail_x15_r0_body.s1659 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1658).run PRE_first_tail_x15_r0_body.S1658 = some (PRE_first_tail_x15_r0_body.s1659, PRE_first_tail_x15_r0_body.S1659)
boot_rfl PRE_first_tail_x15_r0_body.patchB448 from PRE_first_tail_x15_r0_body.s1659 to PRE_first_tail_x15_r0_body.s1660 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1659).run PRE_first_tail_x15_r0_body.S1659 = some (PRE_first_tail_x15_r0_body.s1660, PRE_first_tail_x15_r0_body.S1660)
end Host.Load.Run.Tpl
