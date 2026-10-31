import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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
boot_rfl PRE_first_tail_x15_r0_body.patchB56 from PRE_first_tail_x15_r0_body.s188 to PRE_first_tail_x15_r0_body.s189 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s188).run PRE_first_tail_x15_r0_body.S188 = some (PRE_first_tail_x15_r0_body.s189, PRE_first_tail_x15_r0_body.S189)
boot_rfl PRE_first_tail_x15_r0_body.k189 from PRE_first_tail_x15_r0_body.s189 to PRE_first_tail_x15_r0_body.s190 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB56 ((nth? PRE_first_tail_x15_r0_body.ks 189).getD 0) PRE_first_tail_x15_r0_body.s189 PRE_first_tail_x15_r0_body.S189 = some (PRE_first_tail_x15_r0_body.s190, PRE_first_tail_x15_r0_body.S190)
boot_rfl PRE_first_tail_x15_r0_body.stepA57 from PRE_first_tail_x15_r0_body.s190 to PRE_first_tail_x15_r0_body.s191 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s190).run PRE_first_tail_x15_r0_body.S190 = some (PRE_first_tail_x15_r0_body.s191, PRE_first_tail_x15_r0_body.S191)
boot_rfl PRE_first_tail_x15_r0_body.patchB57 from PRE_first_tail_x15_r0_body.s191 to PRE_first_tail_x15_r0_body.s192 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s191).run PRE_first_tail_x15_r0_body.S191 = some (PRE_first_tail_x15_r0_body.s192, PRE_first_tail_x15_r0_body.S192)
end Host.Load.Run.Tpl
