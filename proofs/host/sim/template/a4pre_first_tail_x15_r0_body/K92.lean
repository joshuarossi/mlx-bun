import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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
boot_rfl PRE_first_tail_x15_r0_body.stepA100 from PRE_first_tail_x15_r0_body.s368 to PRE_first_tail_x15_r0_body.s369 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s368).run PRE_first_tail_x15_r0_body.S368 = some (PRE_first_tail_x15_r0_body.s369, PRE_first_tail_x15_r0_body.S369)
boot_rfl PRE_first_tail_x15_r0_body.k371 from PRE_first_tail_x15_r0_body.s371 to PRE_first_tail_x15_r0_body.s372 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB100 ((nth? PRE_first_tail_x15_r0_body.ks 371).getD 0) PRE_first_tail_x15_r0_body.s371 PRE_first_tail_x15_r0_body.S371 = some (PRE_first_tail_x15_r0_body.s372, PRE_first_tail_x15_r0_body.S372)
end Host.Load.Run.Tpl
