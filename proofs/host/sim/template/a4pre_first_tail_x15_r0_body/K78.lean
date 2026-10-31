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
boot_rfl PRE_first_tail_x15_r0_body.stepA93 from PRE_first_tail_x15_r0_body.s312 to PRE_first_tail_x15_r0_body.s313 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s312).run PRE_first_tail_x15_r0_body.S312 = some (PRE_first_tail_x15_r0_body.s313, PRE_first_tail_x15_r0_body.S313)
boot_rfl PRE_first_tail_x15_r0_body.k315 from PRE_first_tail_x15_r0_body.s315 to PRE_first_tail_x15_r0_body.s316 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB93 ((nth? PRE_first_tail_x15_r0_body.ks 315).getD 0) PRE_first_tail_x15_r0_body.s315 PRE_first_tail_x15_r0_body.S315 = some (PRE_first_tail_x15_r0_body.s316, PRE_first_tail_x15_r0_body.S316)
end Host.Load.Run.Tpl
