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
boot_rfl PRE_first_tail_x15_r0_body.k416 from PRE_first_tail_x15_r0_body.s416 to PRE_first_tail_x15_r0_body.s417 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB123 ((nth? PRE_first_tail_x15_r0_body.ks 416).getD 0) PRE_first_tail_x15_r0_body.s416 PRE_first_tail_x15_r0_body.S416 = some (PRE_first_tail_x15_r0_body.s417, PRE_first_tail_x15_r0_body.S417)
boot_rfl PRE_first_tail_x15_r0_body.stepA124 from PRE_first_tail_x15_r0_body.s417 to PRE_first_tail_x15_r0_body.s418 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s417).run PRE_first_tail_x15_r0_body.S417 = some (PRE_first_tail_x15_r0_body.s418, PRE_first_tail_x15_r0_body.S418)
end Host.Load.Run.Tpl
