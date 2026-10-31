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
boot_rfl PRE_first_tail_x15_r0_body.k1330 from PRE_first_tail_x15_r0_body.s1330 to PRE_first_tail_x15_r0_body.s1331 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB393 ((nth? PRE_first_tail_x15_r0_body.ks 1330).getD 0) PRE_first_tail_x15_r0_body.s1330 PRE_first_tail_x15_r0_body.S1330 = some (PRE_first_tail_x15_r0_body.s1331, PRE_first_tail_x15_r0_body.S1331)
boot_rfl PRE_first_tail_x15_r0_body.stepA394 from PRE_first_tail_x15_r0_body.s1331 to PRE_first_tail_x15_r0_body.s1332 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1331).run PRE_first_tail_x15_r0_body.S1331 = some (PRE_first_tail_x15_r0_body.s1332, PRE_first_tail_x15_r0_body.S1332)
end Host.Load.Run.Tpl
