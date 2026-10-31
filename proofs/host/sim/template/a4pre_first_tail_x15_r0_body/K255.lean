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
boot_rfl PRE_first_tail_x15_r0_body.k1022 from PRE_first_tail_x15_r0_body.s1022 to PRE_first_tail_x15_r0_body.s1023 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB302 ((nth? PRE_first_tail_x15_r0_body.ks 1022).getD 0) PRE_first_tail_x15_r0_body.s1022 PRE_first_tail_x15_r0_body.S1022 = some (PRE_first_tail_x15_r0_body.s1023, PRE_first_tail_x15_r0_body.S1023)
boot_rfl PRE_first_tail_x15_r0_body.stepA303 from PRE_first_tail_x15_r0_body.s1023 to PRE_first_tail_x15_r0_body.s1024 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1023).run PRE_first_tail_x15_r0_body.S1023 = some (PRE_first_tail_x15_r0_body.s1024, PRE_first_tail_x15_r0_body.S1024)
end Host.Load.Run.Tpl
