import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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
boot_rfl PRE_first_tail_x15_r0_body.patchB219 from PRE_first_tail_x15_r0_body.s740 to PRE_first_tail_x15_r0_body.s741 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s740).run PRE_first_tail_x15_r0_body.S740 = some (PRE_first_tail_x15_r0_body.s741, PRE_first_tail_x15_r0_body.S741)
boot_rfl PRE_first_tail_x15_r0_body.k741 from PRE_first_tail_x15_r0_body.s741 to PRE_first_tail_x15_r0_body.s742 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB219 ((nth? PRE_first_tail_x15_r0_body.ks 741).getD 0) PRE_first_tail_x15_r0_body.s741 PRE_first_tail_x15_r0_body.S741 = some (PRE_first_tail_x15_r0_body.s742, PRE_first_tail_x15_r0_body.S742)
boot_rfl PRE_first_tail_x15_r0_body.stepA220 from PRE_first_tail_x15_r0_body.s742 to PRE_first_tail_x15_r0_body.s743 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s742).run PRE_first_tail_x15_r0_body.S742 = some (PRE_first_tail_x15_r0_body.s743, PRE_first_tail_x15_r0_body.S743)
boot_rfl PRE_first_tail_x15_r0_body.patchB220 from PRE_first_tail_x15_r0_body.s743 to PRE_first_tail_x15_r0_body.s744 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s743).run PRE_first_tail_x15_r0_body.S743 = some (PRE_first_tail_x15_r0_body.s744, PRE_first_tail_x15_r0_body.S744)
end Host.Load.Run.Tpl
