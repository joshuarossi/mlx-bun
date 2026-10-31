import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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
boot_rfl PRE_first_tail_x15_r0_body.stepA131 from PRE_first_tail_x15_r0_body.s440 to PRE_first_tail_x15_r0_body.s441 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s440).run PRE_first_tail_x15_r0_body.S440 = some (PRE_first_tail_x15_r0_body.s441, PRE_first_tail_x15_r0_body.S441)
boot_rfl PRE_first_tail_x15_r0_body.k443 from PRE_first_tail_x15_r0_body.s443 to PRE_first_tail_x15_r0_body.s444 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB131 ((nth? PRE_first_tail_x15_r0_body.ks 443).getD 0) PRE_first_tail_x15_r0_body.s443 PRE_first_tail_x15_r0_body.S443 = some (PRE_first_tail_x15_r0_body.s444, PRE_first_tail_x15_r0_body.S444)
end Host.Load.Run.Tpl
