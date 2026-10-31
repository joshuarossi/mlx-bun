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
boot_rfl PRE_first_tail_x15_r0_body.patchB451 from PRE_first_tail_x15_r0_body.s1672 to PRE_first_tail_x15_r0_body.s1673 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1672).run PRE_first_tail_x15_r0_body.S1672 = some (PRE_first_tail_x15_r0_body.s1673, PRE_first_tail_x15_r0_body.S1673)
boot_rfl PRE_first_tail_x15_r0_body.k1673 from PRE_first_tail_x15_r0_body.s1673 to PRE_first_tail_x15_r0_body.s1674 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB451 ((nth? PRE_first_tail_x15_r0_body.ks 1673).getD 0) PRE_first_tail_x15_r0_body.s1673 PRE_first_tail_x15_r0_body.S1673 = some (PRE_first_tail_x15_r0_body.s1674, PRE_first_tail_x15_r0_body.S1674)
boot_rfl PRE_first_tail_x15_r0_body.stepA452 from PRE_first_tail_x15_r0_body.s1674 to PRE_first_tail_x15_r0_body.s1675 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1674).run PRE_first_tail_x15_r0_body.S1674 = some (PRE_first_tail_x15_r0_body.s1675, PRE_first_tail_x15_r0_body.S1675)
boot_rfl PRE_first_tail_x15_r0_body.patchB452 from PRE_first_tail_x15_r0_body.s1675 to PRE_first_tail_x15_r0_body.s1676 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1675).run PRE_first_tail_x15_r0_body.S1675 = some (PRE_first_tail_x15_r0_body.s1676, PRE_first_tail_x15_r0_body.S1676)
end Host.Load.Run.Tpl
