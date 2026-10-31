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
boot_rfl PRE_first_tail_x15_r0_body.stepA204 from PRE_first_tail_x15_r0_body.s688 to PRE_first_tail_x15_r0_body.s689 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s688).run PRE_first_tail_x15_r0_body.S688 = some (PRE_first_tail_x15_r0_body.s689, PRE_first_tail_x15_r0_body.S689)
boot_rfl PRE_first_tail_x15_r0_body.patchB204 from PRE_first_tail_x15_r0_body.s689 to PRE_first_tail_x15_r0_body.s690 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s689).run PRE_first_tail_x15_r0_body.S689 = some (PRE_first_tail_x15_r0_body.s690, PRE_first_tail_x15_r0_body.S690)
boot_rfl PRE_first_tail_x15_r0_body.k690 from PRE_first_tail_x15_r0_body.s690 to PRE_first_tail_x15_r0_body.s691 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB204 ((nth? PRE_first_tail_x15_r0_body.ks 690).getD 0) PRE_first_tail_x15_r0_body.s690 PRE_first_tail_x15_r0_body.S690 = some (PRE_first_tail_x15_r0_body.s691, PRE_first_tail_x15_r0_body.S691)
boot_rfl PRE_first_tail_x15_r0_body.stepA205 from PRE_first_tail_x15_r0_body.s691 to PRE_first_tail_x15_r0_body.s692 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s691).run PRE_first_tail_x15_r0_body.S691 = some (PRE_first_tail_x15_r0_body.s692, PRE_first_tail_x15_r0_body.S692)
end Host.Load.Run.Tpl
