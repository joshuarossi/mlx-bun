import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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
boot_rfl PRE_first_tail_x15_r0_body.k277 from PRE_first_tail_x15_r0_body.s277 to PRE_first_tail_x15_r0_body.s278 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB75 ((nth? PRE_first_tail_x15_r0_body.ks 277).getD 0) PRE_first_tail_x15_r0_body.s277 PRE_first_tail_x15_r0_body.S277 = some (PRE_first_tail_x15_r0_body.s278, PRE_first_tail_x15_r0_body.S278)
boot_rfl PRE_first_tail_x15_r0_body.stepA76 from PRE_first_tail_x15_r0_body.s278 to PRE_first_tail_x15_r0_body.s279 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s278).run PRE_first_tail_x15_r0_body.S278 = some (PRE_first_tail_x15_r0_body.s279, PRE_first_tail_x15_r0_body.S279)
boot_rfl PRE_first_tail_x15_r0_body.patchB76 from PRE_first_tail_x15_r0_body.s279 to PRE_first_tail_x15_r0_body.s280 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s279).run PRE_first_tail_x15_r0_body.S279 = some (PRE_first_tail_x15_r0_body.s280, PRE_first_tail_x15_r0_body.S280)
end Host.Load.Run.Tpl
