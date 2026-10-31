import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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
boot_rfl PRE_first_tail_x15_r0_body.stepA46 from PRE_first_tail_x15_r0_body.s152 to PRE_first_tail_x15_r0_body.s153 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s152).run PRE_first_tail_x15_r0_body.S152 = some (PRE_first_tail_x15_r0_body.s153, PRE_first_tail_x15_r0_body.S153)
boot_rfl PRE_first_tail_x15_r0_body.k155 from PRE_first_tail_x15_r0_body.s155 to PRE_first_tail_x15_r0_body.s156 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB46 ((nth? PRE_first_tail_x15_r0_body.ks 155).getD 0) PRE_first_tail_x15_r0_body.s155 PRE_first_tail_x15_r0_body.S155 = some (PRE_first_tail_x15_r0_body.s156, PRE_first_tail_x15_r0_body.S156)
end Host.Load.Run.Tpl
