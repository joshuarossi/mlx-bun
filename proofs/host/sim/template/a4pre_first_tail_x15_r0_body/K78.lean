import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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
boot_rfl PRE_first_tail_x15_r0_body.k314 from PRE_first_tail_x15_r0_body.s314 to PRE_first_tail_x15_r0_body.s315 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB85 ((nth? PRE_first_tail_x15_r0_body.ks 314).getD 0) PRE_first_tail_x15_r0_body.s314 PRE_first_tail_x15_r0_body.S314 = some (PRE_first_tail_x15_r0_body.s315, PRE_first_tail_x15_r0_body.S315)
boot_rfl PRE_first_tail_x15_r0_body.stepA86 from PRE_first_tail_x15_r0_body.s315 to PRE_first_tail_x15_r0_body.s316 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s315).run PRE_first_tail_x15_r0_body.S315 = some (PRE_first_tail_x15_r0_body.s316, PRE_first_tail_x15_r0_body.S316)
end Host.Load.Run.Tpl
