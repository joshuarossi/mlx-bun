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
boot_rfl PRE_first_tail_x15_r0_body.k276 from PRE_first_tail_x15_r0_body.s276 to PRE_first_tail_x15_r0_body.s277 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB82 ((nth? PRE_first_tail_x15_r0_body.ks 276).getD 0) PRE_first_tail_x15_r0_body.s276 PRE_first_tail_x15_r0_body.S276 = some (PRE_first_tail_x15_r0_body.s277, PRE_first_tail_x15_r0_body.S277)
boot_rfl PRE_first_tail_x15_r0_body.stepA83 from PRE_first_tail_x15_r0_body.s277 to PRE_first_tail_x15_r0_body.s278 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s277).run PRE_first_tail_x15_r0_body.S277 = some (PRE_first_tail_x15_r0_body.s278, PRE_first_tail_x15_r0_body.S278)
end Host.Load.Run.Tpl
