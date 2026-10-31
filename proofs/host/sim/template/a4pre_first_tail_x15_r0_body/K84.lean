import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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
boot_rfl PRE_first_tail_x15_r0_body.k338 from PRE_first_tail_x15_r0_body.s338 to PRE_first_tail_x15_r0_body.s339 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB100 ((nth? PRE_first_tail_x15_r0_body.ks 338).getD 0) PRE_first_tail_x15_r0_body.s338 PRE_first_tail_x15_r0_body.S338 = some (PRE_first_tail_x15_r0_body.s339, PRE_first_tail_x15_r0_body.S339)
boot_rfl PRE_first_tail_x15_r0_body.stepA101 from PRE_first_tail_x15_r0_body.s339 to PRE_first_tail_x15_r0_body.s340 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s339).run PRE_first_tail_x15_r0_body.S339 = some (PRE_first_tail_x15_r0_body.s340, PRE_first_tail_x15_r0_body.S340)
end Host.Load.Run.Tpl
