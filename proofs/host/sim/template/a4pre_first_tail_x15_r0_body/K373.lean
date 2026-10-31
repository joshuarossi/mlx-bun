import host.sim.template.a4pre_first_tail_x15_r0_body.H46
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
boot_rfl PRE_first_tail_x15_r0_body.k1492 from PRE_first_tail_x15_r0_body.s1492 to PRE_first_tail_x15_r0_body.s1493 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB402 ((nth? PRE_first_tail_x15_r0_body.ks 1492).getD 0) PRE_first_tail_x15_r0_body.s1492 PRE_first_tail_x15_r0_body.S1492 = some (PRE_first_tail_x15_r0_body.s1493, PRE_first_tail_x15_r0_body.S1493)
boot_rfl PRE_first_tail_x15_r0_body.stepA403 from PRE_first_tail_x15_r0_body.s1493 to PRE_first_tail_x15_r0_body.s1494 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1493).run PRE_first_tail_x15_r0_body.S1493 = some (PRE_first_tail_x15_r0_body.s1494, PRE_first_tail_x15_r0_body.S1494)
end Host.Load.Run.Tpl
