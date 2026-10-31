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
boot_rfl PRE_first_tail_x15_r0_body.stepA380 from PRE_first_tail_x15_r0_body.s1284 to PRE_first_tail_x15_r0_body.s1285 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1284).run PRE_first_tail_x15_r0_body.S1284 = some (PRE_first_tail_x15_r0_body.s1285, PRE_first_tail_x15_r0_body.S1285)
boot_rfl PRE_first_tail_x15_r0_body.k1287 from PRE_first_tail_x15_r0_body.s1287 to PRE_first_tail_x15_r0_body.s1288 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB380 ((nth? PRE_first_tail_x15_r0_body.ks 1287).getD 0) PRE_first_tail_x15_r0_body.s1287 PRE_first_tail_x15_r0_body.S1287 = some (PRE_first_tail_x15_r0_body.s1288, PRE_first_tail_x15_r0_body.S1288)
end Host.Load.Run.Tpl
