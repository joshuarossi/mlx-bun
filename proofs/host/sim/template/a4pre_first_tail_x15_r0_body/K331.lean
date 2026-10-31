import host.sim.template.a4pre_first_tail_x15_r0_body.H41
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
boot_rfl PRE_first_tail_x15_r0_body.stepA392 from PRE_first_tail_x15_r0_body.s1324 to PRE_first_tail_x15_r0_body.s1325 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1324).run PRE_first_tail_x15_r0_body.S1324 = some (PRE_first_tail_x15_r0_body.s1325, PRE_first_tail_x15_r0_body.S1325)
boot_rfl PRE_first_tail_x15_r0_body.patchB392 from PRE_first_tail_x15_r0_body.s1325 to PRE_first_tail_x15_r0_body.s1326 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1325).run PRE_first_tail_x15_r0_body.S1325 = some (PRE_first_tail_x15_r0_body.s1326, PRE_first_tail_x15_r0_body.S1326)
boot_rfl PRE_first_tail_x15_r0_body.k1326 from PRE_first_tail_x15_r0_body.s1326 to PRE_first_tail_x15_r0_body.s1327 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB392 ((nth? PRE_first_tail_x15_r0_body.ks 1326).getD 0) PRE_first_tail_x15_r0_body.s1326 PRE_first_tail_x15_r0_body.S1326 = some (PRE_first_tail_x15_r0_body.s1327, PRE_first_tail_x15_r0_body.S1327)
boot_rfl PRE_first_tail_x15_r0_body.stepA393 from PRE_first_tail_x15_r0_body.s1327 to PRE_first_tail_x15_r0_body.s1328 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1327).run PRE_first_tail_x15_r0_body.S1327 = some (PRE_first_tail_x15_r0_body.s1328, PRE_first_tail_x15_r0_body.S1328)
end Host.Load.Run.Tpl
