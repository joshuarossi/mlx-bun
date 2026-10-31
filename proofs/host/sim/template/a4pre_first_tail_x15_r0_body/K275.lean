import host.sim.template.a4pre_first_tail_x15_r0_body.H34
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
boot_rfl PRE_first_tail_x15_r0_body.k1100 from PRE_first_tail_x15_r0_body.s1100 to PRE_first_tail_x15_r0_body.s1101 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB325 ((nth? PRE_first_tail_x15_r0_body.ks 1100).getD 0) PRE_first_tail_x15_r0_body.s1100 PRE_first_tail_x15_r0_body.S1100 = some (PRE_first_tail_x15_r0_body.s1101, PRE_first_tail_x15_r0_body.S1101)
boot_rfl PRE_first_tail_x15_r0_body.stepA326 from PRE_first_tail_x15_r0_body.s1101 to PRE_first_tail_x15_r0_body.s1102 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1101).run PRE_first_tail_x15_r0_body.S1101 = some (PRE_first_tail_x15_r0_body.s1102, PRE_first_tail_x15_r0_body.S1102)
end Host.Load.Run.Tpl
