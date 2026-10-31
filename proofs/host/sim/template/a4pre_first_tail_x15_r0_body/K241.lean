import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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
boot_rfl PRE_first_tail_x15_r0_body.stepA261 from PRE_first_tail_x15_r0_body.s964 to PRE_first_tail_x15_r0_body.s965 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s964).run PRE_first_tail_x15_r0_body.S964 = some (PRE_first_tail_x15_r0_body.s965, PRE_first_tail_x15_r0_body.S965)
boot_rfl PRE_first_tail_x15_r0_body.k967 from PRE_first_tail_x15_r0_body.s967 to PRE_first_tail_x15_r0_body.s968 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB261 ((nth? PRE_first_tail_x15_r0_body.ks 967).getD 0) PRE_first_tail_x15_r0_body.s967 PRE_first_tail_x15_r0_body.S967 = some (PRE_first_tail_x15_r0_body.s968, PRE_first_tail_x15_r0_body.S968)
end Host.Load.Run.Tpl
