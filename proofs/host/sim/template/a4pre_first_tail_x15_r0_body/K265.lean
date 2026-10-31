import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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
boot_rfl PRE_first_tail_x15_r0_body.k1061 from PRE_first_tail_x15_r0_body.s1061 to PRE_first_tail_x15_r0_body.s1062 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB286 ((nth? PRE_first_tail_x15_r0_body.ks 1061).getD 0) PRE_first_tail_x15_r0_body.s1061 PRE_first_tail_x15_r0_body.S1061 = some (PRE_first_tail_x15_r0_body.s1062, PRE_first_tail_x15_r0_body.S1062)
boot_rfl PRE_first_tail_x15_r0_body.stepA287 from PRE_first_tail_x15_r0_body.s1062 to PRE_first_tail_x15_r0_body.s1063 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1062).run PRE_first_tail_x15_r0_body.S1062 = some (PRE_first_tail_x15_r0_body.s1063, PRE_first_tail_x15_r0_body.S1063)
end Host.Load.Run.Tpl
