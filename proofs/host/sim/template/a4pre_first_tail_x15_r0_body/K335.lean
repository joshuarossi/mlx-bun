import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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
boot_rfl PRE_first_tail_x15_r0_body.k1341 from PRE_first_tail_x15_r0_body.s1341 to PRE_first_tail_x15_r0_body.s1342 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB362 ((nth? PRE_first_tail_x15_r0_body.ks 1341).getD 0) PRE_first_tail_x15_r0_body.s1341 PRE_first_tail_x15_r0_body.S1341 = some (PRE_first_tail_x15_r0_body.s1342, PRE_first_tail_x15_r0_body.S1342)
boot_rfl PRE_first_tail_x15_r0_body.stepA363 from PRE_first_tail_x15_r0_body.s1342 to PRE_first_tail_x15_r0_body.s1343 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1342).run PRE_first_tail_x15_r0_body.S1342 = some (PRE_first_tail_x15_r0_body.s1343, PRE_first_tail_x15_r0_body.S1343)
boot_rfl PRE_first_tail_x15_r0_body.patchB363 from PRE_first_tail_x15_r0_body.s1343 to PRE_first_tail_x15_r0_body.s1344 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1343).run PRE_first_tail_x15_r0_body.S1343 = some (PRE_first_tail_x15_r0_body.s1344, PRE_first_tail_x15_r0_body.S1344)
end Host.Load.Run.Tpl
