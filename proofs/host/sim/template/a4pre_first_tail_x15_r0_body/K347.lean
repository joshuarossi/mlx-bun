import host.sim.template.a4pre_first_tail_x15_r0_body.H43
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
boot_rfl PRE_first_tail_x15_r0_body.k1388 from PRE_first_tail_x15_r0_body.s1388 to PRE_first_tail_x15_r0_body.s1389 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB374 ((nth? PRE_first_tail_x15_r0_body.ks 1388).getD 0) PRE_first_tail_x15_r0_body.s1388 PRE_first_tail_x15_r0_body.S1388 = some (PRE_first_tail_x15_r0_body.s1389, PRE_first_tail_x15_r0_body.S1389)
boot_rfl PRE_first_tail_x15_r0_body.stepA375 from PRE_first_tail_x15_r0_body.s1389 to PRE_first_tail_x15_r0_body.s1390 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1389).run PRE_first_tail_x15_r0_body.S1389 = some (PRE_first_tail_x15_r0_body.s1390, PRE_first_tail_x15_r0_body.S1390)
boot_rfl PRE_first_tail_x15_r0_body.patchB375 from PRE_first_tail_x15_r0_body.s1390 to PRE_first_tail_x15_r0_body.s1391 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1390).run PRE_first_tail_x15_r0_body.S1390 = some (PRE_first_tail_x15_r0_body.s1391, PRE_first_tail_x15_r0_body.S1391)
boot_rfl PRE_first_tail_x15_r0_body.k1391 from PRE_first_tail_x15_r0_body.s1391 to PRE_first_tail_x15_r0_body.s1392 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB375 ((nth? PRE_first_tail_x15_r0_body.ks 1391).getD 0) PRE_first_tail_x15_r0_body.s1391 PRE_first_tail_x15_r0_body.S1391 = some (PRE_first_tail_x15_r0_body.s1392, PRE_first_tail_x15_r0_body.S1392)
end Host.Load.Run.Tpl
