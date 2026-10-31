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
boot_rfl PRE_first_tail_x15_r0_body.k1328 from PRE_first_tail_x15_r0_body.s1328 to PRE_first_tail_x15_r0_body.s1329 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB358 ((nth? PRE_first_tail_x15_r0_body.ks 1328).getD 0) PRE_first_tail_x15_r0_body.s1328 PRE_first_tail_x15_r0_body.S1328 = some (PRE_first_tail_x15_r0_body.s1329, PRE_first_tail_x15_r0_body.S1329)
boot_rfl PRE_first_tail_x15_r0_body.stepA359 from PRE_first_tail_x15_r0_body.s1329 to PRE_first_tail_x15_r0_body.s1330 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1329).run PRE_first_tail_x15_r0_body.S1329 = some (PRE_first_tail_x15_r0_body.s1330, PRE_first_tail_x15_r0_body.S1330)
boot_rfl PRE_first_tail_x15_r0_body.patchB359 from PRE_first_tail_x15_r0_body.s1330 to PRE_first_tail_x15_r0_body.s1331 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1330).run PRE_first_tail_x15_r0_body.S1330 = some (PRE_first_tail_x15_r0_body.s1331, PRE_first_tail_x15_r0_body.S1331)
boot_rfl PRE_first_tail_x15_r0_body.k1331 from PRE_first_tail_x15_r0_body.s1331 to PRE_first_tail_x15_r0_body.s1332 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB359 ((nth? PRE_first_tail_x15_r0_body.ks 1331).getD 0) PRE_first_tail_x15_r0_body.s1331 PRE_first_tail_x15_r0_body.S1331 = some (PRE_first_tail_x15_r0_body.s1332, PRE_first_tail_x15_r0_body.S1332)
end Host.Load.Run.Tpl
