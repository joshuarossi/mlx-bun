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
boot_rfl PRE_first_tail_x15_r0_body.k1050 from PRE_first_tail_x15_r0_body.s1050 to PRE_first_tail_x15_r0_body.s1051 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB310 ((nth? PRE_first_tail_x15_r0_body.ks 1050).getD 0) PRE_first_tail_x15_r0_body.s1050 PRE_first_tail_x15_r0_body.S1050 = some (PRE_first_tail_x15_r0_body.s1051, PRE_first_tail_x15_r0_body.S1051)
boot_rfl PRE_first_tail_x15_r0_body.stepA311 from PRE_first_tail_x15_r0_body.s1051 to PRE_first_tail_x15_r0_body.s1052 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1051).run PRE_first_tail_x15_r0_body.S1051 = some (PRE_first_tail_x15_r0_body.s1052, PRE_first_tail_x15_r0_body.S1052)
end Host.Load.Run.Tpl
