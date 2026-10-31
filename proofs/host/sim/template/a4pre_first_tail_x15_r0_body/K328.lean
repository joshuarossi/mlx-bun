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
boot_rfl PRE_first_tail_x15_r0_body.k1312 from PRE_first_tail_x15_r0_body.s1312 to PRE_first_tail_x15_r0_body.s1313 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB354 ((nth? PRE_first_tail_x15_r0_body.ks 1312).getD 0) PRE_first_tail_x15_r0_body.s1312 PRE_first_tail_x15_r0_body.S1312 = some (PRE_first_tail_x15_r0_body.s1313, PRE_first_tail_x15_r0_body.S1313)
boot_rfl PRE_first_tail_x15_r0_body.stepA355 from PRE_first_tail_x15_r0_body.s1313 to PRE_first_tail_x15_r0_body.s1314 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1313).run PRE_first_tail_x15_r0_body.S1313 = some (PRE_first_tail_x15_r0_body.s1314, PRE_first_tail_x15_r0_body.S1314)
boot_rfl PRE_first_tail_x15_r0_body.patchB355 from PRE_first_tail_x15_r0_body.s1314 to PRE_first_tail_x15_r0_body.s1315 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1314).run PRE_first_tail_x15_r0_body.S1314 = some (PRE_first_tail_x15_r0_body.s1315, PRE_first_tail_x15_r0_body.S1315)
boot_rfl PRE_first_tail_x15_r0_body.k1315 from PRE_first_tail_x15_r0_body.s1315 to PRE_first_tail_x15_r0_body.s1316 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB355 ((nth? PRE_first_tail_x15_r0_body.ks 1315).getD 0) PRE_first_tail_x15_r0_body.s1315 PRE_first_tail_x15_r0_body.S1315 = some (PRE_first_tail_x15_r0_body.s1316, PRE_first_tail_x15_r0_body.S1316)
end Host.Load.Run.Tpl
