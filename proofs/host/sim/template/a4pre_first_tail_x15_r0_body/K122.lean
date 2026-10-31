import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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
boot_rfl PRE_first_tail_x15_r0_body.k490 from PRE_first_tail_x15_r0_body.s490 to PRE_first_tail_x15_r0_body.s491 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB145 ((nth? PRE_first_tail_x15_r0_body.ks 490).getD 0) PRE_first_tail_x15_r0_body.s490 PRE_first_tail_x15_r0_body.S490 = some (PRE_first_tail_x15_r0_body.s491, PRE_first_tail_x15_r0_body.S491)
boot_rfl PRE_first_tail_x15_r0_body.stepA146 from PRE_first_tail_x15_r0_body.s491 to PRE_first_tail_x15_r0_body.s492 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s491).run PRE_first_tail_x15_r0_body.S491 = some (PRE_first_tail_x15_r0_body.s492, PRE_first_tail_x15_r0_body.S492)
end Host.Load.Run.Tpl
