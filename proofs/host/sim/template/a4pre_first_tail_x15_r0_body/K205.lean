import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.stepA243 from PRE_first_tail_x15_r0_body.s820 to PRE_first_tail_x15_r0_body.s821 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s820).run PRE_first_tail_x15_r0_body.S820 = some (PRE_first_tail_x15_r0_body.s821, PRE_first_tail_x15_r0_body.S821)
boot_rfl PRE_first_tail_x15_r0_body.patchB243 from PRE_first_tail_x15_r0_body.s821 to PRE_first_tail_x15_r0_body.s822 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s821).run PRE_first_tail_x15_r0_body.S821 = some (PRE_first_tail_x15_r0_body.s822, PRE_first_tail_x15_r0_body.S822)
boot_rfl PRE_first_tail_x15_r0_body.k822 from PRE_first_tail_x15_r0_body.s822 to PRE_first_tail_x15_r0_body.s823 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB243 ((nth? PRE_first_tail_x15_r0_body.ks 822).getD 0) PRE_first_tail_x15_r0_body.s822 PRE_first_tail_x15_r0_body.S822 = some (PRE_first_tail_x15_r0_body.s823, PRE_first_tail_x15_r0_body.S823)
boot_rfl PRE_first_tail_x15_r0_body.stepA244 from PRE_first_tail_x15_r0_body.s823 to PRE_first_tail_x15_r0_body.s824 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s823).run PRE_first_tail_x15_r0_body.S823 = some (PRE_first_tail_x15_r0_body.s824, PRE_first_tail_x15_r0_body.S824)
end Host.Load.Run.Tpl
