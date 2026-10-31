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
boot_rfl PRE_first_tail_x15_r0_body.k668 from PRE_first_tail_x15_r0_body.s668 to PRE_first_tail_x15_r0_body.s669 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB180 ((nth? PRE_first_tail_x15_r0_body.ks 668).getD 0) PRE_first_tail_x15_r0_body.s668 PRE_first_tail_x15_r0_body.S668 = some (PRE_first_tail_x15_r0_body.s669, PRE_first_tail_x15_r0_body.S669)
boot_rfl PRE_first_tail_x15_r0_body.stepA181 from PRE_first_tail_x15_r0_body.s669 to PRE_first_tail_x15_r0_body.s670 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s669).run PRE_first_tail_x15_r0_body.S669 = some (PRE_first_tail_x15_r0_body.s670, PRE_first_tail_x15_r0_body.S670)
boot_rfl PRE_first_tail_x15_r0_body.patchB181 from PRE_first_tail_x15_r0_body.s670 to PRE_first_tail_x15_r0_body.s671 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s670).run PRE_first_tail_x15_r0_body.S670 = some (PRE_first_tail_x15_r0_body.s671, PRE_first_tail_x15_r0_body.S671)
boot_rfl PRE_first_tail_x15_r0_body.k671 from PRE_first_tail_x15_r0_body.s671 to PRE_first_tail_x15_r0_body.s672 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB181 ((nth? PRE_first_tail_x15_r0_body.ks 671).getD 0) PRE_first_tail_x15_r0_body.s671 PRE_first_tail_x15_r0_body.S671 = some (PRE_first_tail_x15_r0_body.s672, PRE_first_tail_x15_r0_body.S672)
end Host.Load.Run.Tpl
