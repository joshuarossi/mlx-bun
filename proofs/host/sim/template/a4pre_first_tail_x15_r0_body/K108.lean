import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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
boot_rfl PRE_first_tail_x15_r0_body.k432 from PRE_first_tail_x15_r0_body.s432 to PRE_first_tail_x15_r0_body.s433 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB128 ((nth? PRE_first_tail_x15_r0_body.ks 432).getD 0) PRE_first_tail_x15_r0_body.s432 PRE_first_tail_x15_r0_body.S432 = some (PRE_first_tail_x15_r0_body.s433, PRE_first_tail_x15_r0_body.S433)
boot_rfl PRE_first_tail_x15_r0_body.stepA129 from PRE_first_tail_x15_r0_body.s433 to PRE_first_tail_x15_r0_body.s434 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s433).run PRE_first_tail_x15_r0_body.S433 = some (PRE_first_tail_x15_r0_body.s434, PRE_first_tail_x15_r0_body.S434)
end Host.Load.Run.Tpl
