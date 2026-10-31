import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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
boot_rfl PRE_first_tail_x15_r0_body.stepA85 from PRE_first_tail_x15_r0_body.s284 to PRE_first_tail_x15_r0_body.s285 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s284).run PRE_first_tail_x15_r0_body.S284 = some (PRE_first_tail_x15_r0_body.s285, PRE_first_tail_x15_r0_body.S285)
boot_rfl PRE_first_tail_x15_r0_body.k287 from PRE_first_tail_x15_r0_body.s287 to PRE_first_tail_x15_r0_body.s288 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB85 ((nth? PRE_first_tail_x15_r0_body.ks 287).getD 0) PRE_first_tail_x15_r0_body.s287 PRE_first_tail_x15_r0_body.S287 = some (PRE_first_tail_x15_r0_body.s288, PRE_first_tail_x15_r0_body.S288)
end Host.Load.Run.Tpl
