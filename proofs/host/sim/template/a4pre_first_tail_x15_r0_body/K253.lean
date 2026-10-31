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
boot_rfl PRE_first_tail_x15_r0_body.stepA300 from PRE_first_tail_x15_r0_body.s1012 to PRE_first_tail_x15_r0_body.s1013 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1012).run PRE_first_tail_x15_r0_body.S1012 = some (PRE_first_tail_x15_r0_body.s1013, PRE_first_tail_x15_r0_body.S1013)
boot_rfl PRE_first_tail_x15_r0_body.k1015 from PRE_first_tail_x15_r0_body.s1015 to PRE_first_tail_x15_r0_body.s1016 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB300 ((nth? PRE_first_tail_x15_r0_body.ks 1015).getD 0) PRE_first_tail_x15_r0_body.s1015 PRE_first_tail_x15_r0_body.S1015 = some (PRE_first_tail_x15_r0_body.s1016, PRE_first_tail_x15_r0_body.S1016)
end Host.Load.Run.Tpl
