import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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
boot_rfl PRE_first_tail_x15_r0_body.k541 from PRE_first_tail_x15_r0_body.s541 to PRE_first_tail_x15_r0_body.s542 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB160 ((nth? PRE_first_tail_x15_r0_body.ks 541).getD 0) PRE_first_tail_x15_r0_body.s541 PRE_first_tail_x15_r0_body.S541 = some (PRE_first_tail_x15_r0_body.s542, PRE_first_tail_x15_r0_body.S542)
boot_rfl PRE_first_tail_x15_r0_body.stepA161 from PRE_first_tail_x15_r0_body.s542 to PRE_first_tail_x15_r0_body.s543 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s542).run PRE_first_tail_x15_r0_body.S542 = some (PRE_first_tail_x15_r0_body.s543, PRE_first_tail_x15_r0_body.S543)
boot_rfl PRE_first_tail_x15_r0_body.patchB161 from PRE_first_tail_x15_r0_body.s543 to PRE_first_tail_x15_r0_body.s544 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s543).run PRE_first_tail_x15_r0_body.S543 = some (PRE_first_tail_x15_r0_body.s544, PRE_first_tail_x15_r0_body.S544)
end Host.Load.Run.Tpl
