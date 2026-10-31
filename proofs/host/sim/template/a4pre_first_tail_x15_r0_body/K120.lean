import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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
boot_rfl PRE_first_tail_x15_r0_body.patchB130 from PRE_first_tail_x15_r0_body.s480 to PRE_first_tail_x15_r0_body.s481 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s480).run PRE_first_tail_x15_r0_body.S480 = some (PRE_first_tail_x15_r0_body.s481, PRE_first_tail_x15_r0_body.S481)
boot_rfl PRE_first_tail_x15_r0_body.k481 from PRE_first_tail_x15_r0_body.s481 to PRE_first_tail_x15_r0_body.s482 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB130 ((nth? PRE_first_tail_x15_r0_body.ks 481).getD 0) PRE_first_tail_x15_r0_body.s481 PRE_first_tail_x15_r0_body.S481 = some (PRE_first_tail_x15_r0_body.s482, PRE_first_tail_x15_r0_body.S482)
boot_rfl PRE_first_tail_x15_r0_body.k482 from PRE_first_tail_x15_r0_body.s482 to PRE_first_tail_x15_r0_body.s483 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB130 ((nth? PRE_first_tail_x15_r0_body.ks 482).getD 0) PRE_first_tail_x15_r0_body.s482 PRE_first_tail_x15_r0_body.S482 = some (PRE_first_tail_x15_r0_body.s483, PRE_first_tail_x15_r0_body.S483)
boot_rfl PRE_first_tail_x15_r0_body.stepA131 from PRE_first_tail_x15_r0_body.s483 to PRE_first_tail_x15_r0_body.s484 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s483).run PRE_first_tail_x15_r0_body.S483 = some (PRE_first_tail_x15_r0_body.s484, PRE_first_tail_x15_r0_body.S484)
end Host.Load.Run.Tpl
