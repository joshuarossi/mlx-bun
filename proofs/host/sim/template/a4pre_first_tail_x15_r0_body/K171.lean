import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.k684 from PRE_first_tail_x15_r0_body.s684 to PRE_first_tail_x15_r0_body.s685 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB202 ((nth? PRE_first_tail_x15_r0_body.ks 684).getD 0) PRE_first_tail_x15_r0_body.s684 PRE_first_tail_x15_r0_body.S684 = some (PRE_first_tail_x15_r0_body.s685, PRE_first_tail_x15_r0_body.S685)
boot_rfl PRE_first_tail_x15_r0_body.stepA203 from PRE_first_tail_x15_r0_body.s685 to PRE_first_tail_x15_r0_body.s686 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s685).run PRE_first_tail_x15_r0_body.S685 = some (PRE_first_tail_x15_r0_body.s686, PRE_first_tail_x15_r0_body.S686)
boot_rfl PRE_first_tail_x15_r0_body.patchB203 from PRE_first_tail_x15_r0_body.s686 to PRE_first_tail_x15_r0_body.s687 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s686).run PRE_first_tail_x15_r0_body.S686 = some (PRE_first_tail_x15_r0_body.s687, PRE_first_tail_x15_r0_body.S687)
boot_rfl PRE_first_tail_x15_r0_body.k687 from PRE_first_tail_x15_r0_body.s687 to PRE_first_tail_x15_r0_body.s688 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB203 ((nth? PRE_first_tail_x15_r0_body.ks 687).getD 0) PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.S687 = some (PRE_first_tail_x15_r0_body.s688, PRE_first_tail_x15_r0_body.S688)
end Host.Load.Run.Tpl
