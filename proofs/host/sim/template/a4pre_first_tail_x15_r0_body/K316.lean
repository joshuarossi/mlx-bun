import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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
boot_rfl PRE_first_tail_x15_r0_body.stepA374 from PRE_first_tail_x15_r0_body.s1264 to PRE_first_tail_x15_r0_body.s1265 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1264).run PRE_first_tail_x15_r0_body.S1264 = some (PRE_first_tail_x15_r0_body.s1265, PRE_first_tail_x15_r0_body.S1265)
boot_rfl PRE_first_tail_x15_r0_body.patchB374 from PRE_first_tail_x15_r0_body.s1265 to PRE_first_tail_x15_r0_body.s1266 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1265).run PRE_first_tail_x15_r0_body.S1265 = some (PRE_first_tail_x15_r0_body.s1266, PRE_first_tail_x15_r0_body.S1266)
boot_rfl PRE_first_tail_x15_r0_body.k1266 from PRE_first_tail_x15_r0_body.s1266 to PRE_first_tail_x15_r0_body.s1267 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB374 ((nth? PRE_first_tail_x15_r0_body.ks 1266).getD 0) PRE_first_tail_x15_r0_body.s1266 PRE_first_tail_x15_r0_body.S1266 = some (PRE_first_tail_x15_r0_body.s1267, PRE_first_tail_x15_r0_body.S1267)
boot_rfl PRE_first_tail_x15_r0_body.stepA375 from PRE_first_tail_x15_r0_body.s1267 to PRE_first_tail_x15_r0_body.s1268 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1267).run PRE_first_tail_x15_r0_body.S1267 = some (PRE_first_tail_x15_r0_body.s1268, PRE_first_tail_x15_r0_body.S1268)
end Host.Load.Run.Tpl
