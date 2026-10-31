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
boot_rfl PRE_first_tail_x15_r0_body.stepA349 from PRE_first_tail_x15_r0_body.s1292 to PRE_first_tail_x15_r0_body.s1293 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1292).run PRE_first_tail_x15_r0_body.S1292 = some (PRE_first_tail_x15_r0_body.s1293, PRE_first_tail_x15_r0_body.S1293)
boot_rfl PRE_first_tail_x15_r0_body.k1295 from PRE_first_tail_x15_r0_body.s1295 to PRE_first_tail_x15_r0_body.s1296 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB349 ((nth? PRE_first_tail_x15_r0_body.ks 1295).getD 0) PRE_first_tail_x15_r0_body.s1295 PRE_first_tail_x15_r0_body.S1295 = some (PRE_first_tail_x15_r0_body.s1296, PRE_first_tail_x15_r0_body.S1296)
end Host.Load.Run.Tpl
