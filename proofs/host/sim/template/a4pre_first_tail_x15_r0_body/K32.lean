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
boot_rfl PRE_first_tail_x15_r0_body.patchB35 from PRE_first_tail_x15_r0_body.s128 to PRE_first_tail_x15_r0_body.s129 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s128).run PRE_first_tail_x15_r0_body.S128 = some (PRE_first_tail_x15_r0_body.s129, PRE_first_tail_x15_r0_body.S129)
boot_rfl PRE_first_tail_x15_r0_body.k129 from PRE_first_tail_x15_r0_body.s129 to PRE_first_tail_x15_r0_body.s130 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB35 ((nth? PRE_first_tail_x15_r0_body.ks 129).getD 0) PRE_first_tail_x15_r0_body.s129 PRE_first_tail_x15_r0_body.S129 = some (PRE_first_tail_x15_r0_body.s130, PRE_first_tail_x15_r0_body.S130)
boot_rfl PRE_first_tail_x15_r0_body.stepA36 from PRE_first_tail_x15_r0_body.s130 to PRE_first_tail_x15_r0_body.s131 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s130).run PRE_first_tail_x15_r0_body.S130 = some (PRE_first_tail_x15_r0_body.s131, PRE_first_tail_x15_r0_body.S131)
end Host.Load.Run.Tpl
