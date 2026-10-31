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
boot_rfl PRE_first_tail_x15_r0_body.k1028 from PRE_first_tail_x15_r0_body.s1028 to PRE_first_tail_x15_r0_body.s1029 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB277 ((nth? PRE_first_tail_x15_r0_body.ks 1028).getD 0) PRE_first_tail_x15_r0_body.s1028 PRE_first_tail_x15_r0_body.S1028 = some (PRE_first_tail_x15_r0_body.s1029, PRE_first_tail_x15_r0_body.S1029)
boot_rfl PRE_first_tail_x15_r0_body.stepA278 from PRE_first_tail_x15_r0_body.s1029 to PRE_first_tail_x15_r0_body.s1030 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1029).run PRE_first_tail_x15_r0_body.S1029 = some (PRE_first_tail_x15_r0_body.s1030, PRE_first_tail_x15_r0_body.S1030)
end Host.Load.Run.Tpl
