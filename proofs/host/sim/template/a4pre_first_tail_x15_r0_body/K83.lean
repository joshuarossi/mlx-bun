import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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
boot_rfl PRE_first_tail_x15_r0_body.k334 from PRE_first_tail_x15_r0_body.s334 to PRE_first_tail_x15_r0_body.s335 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB90 ((nth? PRE_first_tail_x15_r0_body.ks 334).getD 0) PRE_first_tail_x15_r0_body.s334 PRE_first_tail_x15_r0_body.S334 = some (PRE_first_tail_x15_r0_body.s335, PRE_first_tail_x15_r0_body.S335)
boot_rfl PRE_first_tail_x15_r0_body.stepA91 from PRE_first_tail_x15_r0_body.s335 to PRE_first_tail_x15_r0_body.s336 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s335).run PRE_first_tail_x15_r0_body.S335 = some (PRE_first_tail_x15_r0_body.s336, PRE_first_tail_x15_r0_body.S336)
end Host.Load.Run.Tpl
