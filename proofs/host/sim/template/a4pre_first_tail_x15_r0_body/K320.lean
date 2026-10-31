import host.sim.template.a4pre_first_tail_x15_r0_body.H40
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
boot_rfl PRE_first_tail_x15_r0_body.stepA346 from PRE_first_tail_x15_r0_body.s1280 to PRE_first_tail_x15_r0_body.s1281 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1280).run PRE_first_tail_x15_r0_body.S1280 = some (PRE_first_tail_x15_r0_body.s1281, PRE_first_tail_x15_r0_body.S1281)
boot_rfl PRE_first_tail_x15_r0_body.k1283 from PRE_first_tail_x15_r0_body.s1283 to PRE_first_tail_x15_r0_body.s1284 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB346 ((nth? PRE_first_tail_x15_r0_body.ks 1283).getD 0) PRE_first_tail_x15_r0_body.s1283 PRE_first_tail_x15_r0_body.S1283 = some (PRE_first_tail_x15_r0_body.s1284, PRE_first_tail_x15_r0_body.S1284)
end Host.Load.Run.Tpl
