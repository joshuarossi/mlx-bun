import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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
boot_rfl PRE_first_tail_x15_r0_body.k540 from PRE_first_tail_x15_r0_body.s540 to PRE_first_tail_x15_r0_body.s541 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB146 ((nth? PRE_first_tail_x15_r0_body.ks 540).getD 0) PRE_first_tail_x15_r0_body.s540 PRE_first_tail_x15_r0_body.S540 = some (PRE_first_tail_x15_r0_body.s541, PRE_first_tail_x15_r0_body.S541)
boot_rfl PRE_first_tail_x15_r0_body.stepA147 from PRE_first_tail_x15_r0_body.s541 to PRE_first_tail_x15_r0_body.s542 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s541).run PRE_first_tail_x15_r0_body.S541 = some (PRE_first_tail_x15_r0_body.s542, PRE_first_tail_x15_r0_body.S542)
end Host.Load.Run.Tpl
