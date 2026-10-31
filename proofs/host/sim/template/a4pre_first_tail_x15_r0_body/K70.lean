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
boot_rfl PRE_first_tail_x15_r0_body.k280 from PRE_first_tail_x15_r0_body.s280 to PRE_first_tail_x15_r0_body.s281 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB76 ((nth? PRE_first_tail_x15_r0_body.ks 280).getD 0) PRE_first_tail_x15_r0_body.s280 PRE_first_tail_x15_r0_body.S280 = some (PRE_first_tail_x15_r0_body.s281, PRE_first_tail_x15_r0_body.S281)
boot_rfl PRE_first_tail_x15_r0_body.k281 from PRE_first_tail_x15_r0_body.s281 to PRE_first_tail_x15_r0_body.s282 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB76 ((nth? PRE_first_tail_x15_r0_body.ks 281).getD 0) PRE_first_tail_x15_r0_body.s281 PRE_first_tail_x15_r0_body.S281 = some (PRE_first_tail_x15_r0_body.s282, PRE_first_tail_x15_r0_body.S282)
boot_rfl PRE_first_tail_x15_r0_body.stepA77 from PRE_first_tail_x15_r0_body.s282 to PRE_first_tail_x15_r0_body.s283 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s282).run PRE_first_tail_x15_r0_body.S282 = some (PRE_first_tail_x15_r0_body.s283, PRE_first_tail_x15_r0_body.S283)
end Host.Load.Run.Tpl
