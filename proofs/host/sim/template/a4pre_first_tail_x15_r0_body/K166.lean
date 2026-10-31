import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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
boot_rfl PRE_first_tail_x15_r0_body.stepA197 from PRE_first_tail_x15_r0_body.s664 to PRE_first_tail_x15_r0_body.s665 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s664).run PRE_first_tail_x15_r0_body.S664 = some (PRE_first_tail_x15_r0_body.s665, PRE_first_tail_x15_r0_body.S665)
boot_rfl PRE_first_tail_x15_r0_body.patchB197 from PRE_first_tail_x15_r0_body.s665 to PRE_first_tail_x15_r0_body.s666 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s665).run PRE_first_tail_x15_r0_body.S665 = some (PRE_first_tail_x15_r0_body.s666, PRE_first_tail_x15_r0_body.S666)
boot_rfl PRE_first_tail_x15_r0_body.k666 from PRE_first_tail_x15_r0_body.s666 to PRE_first_tail_x15_r0_body.s667 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB197 ((nth? PRE_first_tail_x15_r0_body.ks 666).getD 0) PRE_first_tail_x15_r0_body.s666 PRE_first_tail_x15_r0_body.S666 = some (PRE_first_tail_x15_r0_body.s667, PRE_first_tail_x15_r0_body.S667)
boot_rfl PRE_first_tail_x15_r0_body.stepA198 from PRE_first_tail_x15_r0_body.s667 to PRE_first_tail_x15_r0_body.s668 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s667).run PRE_first_tail_x15_r0_body.S667 = some (PRE_first_tail_x15_r0_body.s668, PRE_first_tail_x15_r0_body.S668)
end Host.Load.Run.Tpl
