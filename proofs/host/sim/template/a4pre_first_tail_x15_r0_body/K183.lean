import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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
boot_rfl PRE_first_tail_x15_r0_body.stepA217 from PRE_first_tail_x15_r0_body.s732 to PRE_first_tail_x15_r0_body.s733 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s732).run PRE_first_tail_x15_r0_body.S732 = some (PRE_first_tail_x15_r0_body.s733, PRE_first_tail_x15_r0_body.S733)
boot_rfl PRE_first_tail_x15_r0_body.k735 from PRE_first_tail_x15_r0_body.s735 to PRE_first_tail_x15_r0_body.s736 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB217 ((nth? PRE_first_tail_x15_r0_body.ks 735).getD 0) PRE_first_tail_x15_r0_body.s735 PRE_first_tail_x15_r0_body.S735 = some (PRE_first_tail_x15_r0_body.s736, PRE_first_tail_x15_r0_body.S736)
end Host.Load.Run.Tpl
