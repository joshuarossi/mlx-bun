import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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
boot_rfl PRE_first_tail_x15_r0_body.k128 from PRE_first_tail_x15_r0_body.s128 to PRE_first_tail_x15_r0_body.s129 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB38 ((nth? PRE_first_tail_x15_r0_body.ks 128).getD 0) PRE_first_tail_x15_r0_body.s128 PRE_first_tail_x15_r0_body.S128 = some (PRE_first_tail_x15_r0_body.s129, PRE_first_tail_x15_r0_body.S129)
boot_rfl PRE_first_tail_x15_r0_body.stepA39 from PRE_first_tail_x15_r0_body.s129 to PRE_first_tail_x15_r0_body.s130 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s129).run PRE_first_tail_x15_r0_body.S129 = some (PRE_first_tail_x15_r0_body.s130, PRE_first_tail_x15_r0_body.S130)
end Host.Load.Run.Tpl
