import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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
boot_rfl PRE_first_tail_x15_r0_body.stepA158 from PRE_first_tail_x15_r0_body.s584 to PRE_first_tail_x15_r0_body.s585 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s584).run PRE_first_tail_x15_r0_body.S584 = some (PRE_first_tail_x15_r0_body.s585, PRE_first_tail_x15_r0_body.S585)
boot_rfl PRE_first_tail_x15_r0_body.patchB158 from PRE_first_tail_x15_r0_body.s585 to PRE_first_tail_x15_r0_body.s586 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s585).run PRE_first_tail_x15_r0_body.S585 = some (PRE_first_tail_x15_r0_body.s586, PRE_first_tail_x15_r0_body.S586)
boot_rfl PRE_first_tail_x15_r0_body.k586 from PRE_first_tail_x15_r0_body.s586 to PRE_first_tail_x15_r0_body.s587 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB158 ((nth? PRE_first_tail_x15_r0_body.ks 586).getD 0) PRE_first_tail_x15_r0_body.s586 PRE_first_tail_x15_r0_body.S586 = some (PRE_first_tail_x15_r0_body.s587, PRE_first_tail_x15_r0_body.S587)
boot_rfl PRE_first_tail_x15_r0_body.stepA159 from PRE_first_tail_x15_r0_body.s587 to PRE_first_tail_x15_r0_body.s588 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s587).run PRE_first_tail_x15_r0_body.S587 = some (PRE_first_tail_x15_r0_body.s588, PRE_first_tail_x15_r0_body.S588)
end Host.Load.Run.Tpl
