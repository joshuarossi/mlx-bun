import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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
boot_rfl PRE_first_tail_x15_r0_body.k408 from PRE_first_tail_x15_r0_body.s408 to PRE_first_tail_x15_r0_body.s409 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB110 ((nth? PRE_first_tail_x15_r0_body.ks 408).getD 0) PRE_first_tail_x15_r0_body.s408 PRE_first_tail_x15_r0_body.S408 = some (PRE_first_tail_x15_r0_body.s409, PRE_first_tail_x15_r0_body.S409)
boot_rfl PRE_first_tail_x15_r0_body.stepA111 from PRE_first_tail_x15_r0_body.s409 to PRE_first_tail_x15_r0_body.s410 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s409).run PRE_first_tail_x15_r0_body.S409 = some (PRE_first_tail_x15_r0_body.s410, PRE_first_tail_x15_r0_body.S410)
boot_rfl PRE_first_tail_x15_r0_body.patchB111 from PRE_first_tail_x15_r0_body.s410 to PRE_first_tail_x15_r0_body.s411 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s410).run PRE_first_tail_x15_r0_body.S410 = some (PRE_first_tail_x15_r0_body.s411, PRE_first_tail_x15_r0_body.S411)
boot_rfl PRE_first_tail_x15_r0_body.k411 from PRE_first_tail_x15_r0_body.s411 to PRE_first_tail_x15_r0_body.s412 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB111 ((nth? PRE_first_tail_x15_r0_body.ks 411).getD 0) PRE_first_tail_x15_r0_body.s411 PRE_first_tail_x15_r0_body.S411 = some (PRE_first_tail_x15_r0_body.s412, PRE_first_tail_x15_r0_body.S412)
end Host.Load.Run.Tpl
