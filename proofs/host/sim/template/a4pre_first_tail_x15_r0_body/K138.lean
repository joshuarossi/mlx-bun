import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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
boot_rfl PRE_first_tail_x15_r0_body.k552 from PRE_first_tail_x15_r0_body.s552 to PRE_first_tail_x15_r0_body.s553 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB163 ((nth? PRE_first_tail_x15_r0_body.ks 552).getD 0) PRE_first_tail_x15_r0_body.s552 PRE_first_tail_x15_r0_body.S552 = some (PRE_first_tail_x15_r0_body.s553, PRE_first_tail_x15_r0_body.S553)
boot_rfl PRE_first_tail_x15_r0_body.stepA164 from PRE_first_tail_x15_r0_body.s553 to PRE_first_tail_x15_r0_body.s554 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s553).run PRE_first_tail_x15_r0_body.S553 = some (PRE_first_tail_x15_r0_body.s554, PRE_first_tail_x15_r0_body.S554)
boot_rfl PRE_first_tail_x15_r0_body.patchB164 from PRE_first_tail_x15_r0_body.s554 to PRE_first_tail_x15_r0_body.s555 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s554).run PRE_first_tail_x15_r0_body.S554 = some (PRE_first_tail_x15_r0_body.s555, PRE_first_tail_x15_r0_body.S555)
boot_rfl PRE_first_tail_x15_r0_body.k555 from PRE_first_tail_x15_r0_body.s555 to PRE_first_tail_x15_r0_body.s556 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB164 ((nth? PRE_first_tail_x15_r0_body.ks 555).getD 0) PRE_first_tail_x15_r0_body.s555 PRE_first_tail_x15_r0_body.S555 = some (PRE_first_tail_x15_r0_body.s556, PRE_first_tail_x15_r0_body.S556)
end Host.Load.Run.Tpl
