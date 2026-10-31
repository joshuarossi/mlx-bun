import host.sim.template.a4pre_first_tail_x15_r0_body.H31
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
boot_rfl PRE_first_tail_x15_r0_body.k1000 from PRE_first_tail_x15_r0_body.s1000 to PRE_first_tail_x15_r0_body.s1001 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB270 ((nth? PRE_first_tail_x15_r0_body.ks 1000).getD 0) PRE_first_tail_x15_r0_body.s1000 PRE_first_tail_x15_r0_body.S1000 = some (PRE_first_tail_x15_r0_body.s1001, PRE_first_tail_x15_r0_body.S1001)
boot_rfl PRE_first_tail_x15_r0_body.stepA271 from PRE_first_tail_x15_r0_body.s1001 to PRE_first_tail_x15_r0_body.s1002 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1001).run PRE_first_tail_x15_r0_body.S1001 = some (PRE_first_tail_x15_r0_body.s1002, PRE_first_tail_x15_r0_body.S1002)
end Host.Load.Run.Tpl
