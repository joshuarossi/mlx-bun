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
boot_rfl PRE_first_tail_x15_r0_body.patchB113 from PRE_first_tail_x15_r0_body.s416 to PRE_first_tail_x15_r0_body.s417 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s416).run PRE_first_tail_x15_r0_body.S416 = some (PRE_first_tail_x15_r0_body.s417, PRE_first_tail_x15_r0_body.S417)
boot_rfl PRE_first_tail_x15_r0_body.k417 from PRE_first_tail_x15_r0_body.s417 to PRE_first_tail_x15_r0_body.s418 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB113 ((nth? PRE_first_tail_x15_r0_body.ks 417).getD 0) PRE_first_tail_x15_r0_body.s417 PRE_first_tail_x15_r0_body.S417 = some (PRE_first_tail_x15_r0_body.s418, PRE_first_tail_x15_r0_body.S418)
boot_rfl PRE_first_tail_x15_r0_body.stepA114 from PRE_first_tail_x15_r0_body.s418 to PRE_first_tail_x15_r0_body.s419 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s418).run PRE_first_tail_x15_r0_body.S418 = some (PRE_first_tail_x15_r0_body.s419, PRE_first_tail_x15_r0_body.S419)
end Host.Load.Run.Tpl
