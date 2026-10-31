import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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
boot_rfl PRE_first_tail_x15_r0_body.k1046 from PRE_first_tail_x15_r0_body.s1046 to PRE_first_tail_x15_r0_body.s1047 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB309 ((nth? PRE_first_tail_x15_r0_body.ks 1046).getD 0) PRE_first_tail_x15_r0_body.s1046 PRE_first_tail_x15_r0_body.S1046 = some (PRE_first_tail_x15_r0_body.s1047, PRE_first_tail_x15_r0_body.S1047)
boot_rfl PRE_first_tail_x15_r0_body.stepA310 from PRE_first_tail_x15_r0_body.s1047 to PRE_first_tail_x15_r0_body.s1048 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1047).run PRE_first_tail_x15_r0_body.S1047 = some (PRE_first_tail_x15_r0_body.s1048, PRE_first_tail_x15_r0_body.S1048)
end Host.Load.Run.Tpl
