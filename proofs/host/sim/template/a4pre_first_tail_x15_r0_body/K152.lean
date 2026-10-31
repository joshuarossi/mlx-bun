import host.sim.template.a4pre_first_tail_x15_r0_body.H19
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
boot_rfl PRE_first_tail_x15_r0_body.patchB180 from PRE_first_tail_x15_r0_body.s608 to PRE_first_tail_x15_r0_body.s609 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s608).run PRE_first_tail_x15_r0_body.S608 = some (PRE_first_tail_x15_r0_body.s609, PRE_first_tail_x15_r0_body.S609)
boot_rfl PRE_first_tail_x15_r0_body.k609 from PRE_first_tail_x15_r0_body.s609 to PRE_first_tail_x15_r0_body.s610 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB180 ((nth? PRE_first_tail_x15_r0_body.ks 609).getD 0) PRE_first_tail_x15_r0_body.s609 PRE_first_tail_x15_r0_body.S609 = some (PRE_first_tail_x15_r0_body.s610, PRE_first_tail_x15_r0_body.S610)
boot_rfl PRE_first_tail_x15_r0_body.stepA181 from PRE_first_tail_x15_r0_body.s610 to PRE_first_tail_x15_r0_body.s611 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s610).run PRE_first_tail_x15_r0_body.S610 = some (PRE_first_tail_x15_r0_body.s611, PRE_first_tail_x15_r0_body.S611)
boot_rfl PRE_first_tail_x15_r0_body.patchB181 from PRE_first_tail_x15_r0_body.s611 to PRE_first_tail_x15_r0_body.s612 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s611).run PRE_first_tail_x15_r0_body.S611 = some (PRE_first_tail_x15_r0_body.s612, PRE_first_tail_x15_r0_body.S612)
end Host.Load.Run.Tpl
