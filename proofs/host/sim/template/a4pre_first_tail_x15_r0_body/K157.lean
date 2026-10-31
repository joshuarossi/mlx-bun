import host.sim.template.a4pre_first_tail_x15_r0_body.H19
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
boot_rfl PRE_first_tail_x15_r0_body.k630 from PRE_first_tail_x15_r0_body.s630 to PRE_first_tail_x15_r0_body.s631 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB186 ((nth? PRE_first_tail_x15_r0_body.ks 630).getD 0) PRE_first_tail_x15_r0_body.s630 PRE_first_tail_x15_r0_body.S630 = some (PRE_first_tail_x15_r0_body.s631, PRE_first_tail_x15_r0_body.S631)
boot_rfl PRE_first_tail_x15_r0_body.stepA187 from PRE_first_tail_x15_r0_body.s631 to PRE_first_tail_x15_r0_body.s632 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s631).run PRE_first_tail_x15_r0_body.S631 = some (PRE_first_tail_x15_r0_body.s632, PRE_first_tail_x15_r0_body.S632)
end Host.Load.Run.Tpl
