import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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
boot_rfl PRE_first_tail_x15_r0_body.patchB49 from PRE_first_tail_x15_r0_body.s180 to PRE_first_tail_x15_r0_body.s181 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s180).run PRE_first_tail_x15_r0_body.S180 = some (PRE_first_tail_x15_r0_body.s181, PRE_first_tail_x15_r0_body.S181)
boot_rfl PRE_first_tail_x15_r0_body.k181 from PRE_first_tail_x15_r0_body.s181 to PRE_first_tail_x15_r0_body.s182 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB49 ((nth? PRE_first_tail_x15_r0_body.ks 181).getD 0) PRE_first_tail_x15_r0_body.s181 PRE_first_tail_x15_r0_body.S181 = some (PRE_first_tail_x15_r0_body.s182, PRE_first_tail_x15_r0_body.S182)
boot_rfl PRE_first_tail_x15_r0_body.stepA50 from PRE_first_tail_x15_r0_body.s182 to PRE_first_tail_x15_r0_body.s183 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s182).run PRE_first_tail_x15_r0_body.S182 = some (PRE_first_tail_x15_r0_body.s183, PRE_first_tail_x15_r0_body.S183)
boot_rfl PRE_first_tail_x15_r0_body.patchB50 from PRE_first_tail_x15_r0_body.s183 to PRE_first_tail_x15_r0_body.s184 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s183).run PRE_first_tail_x15_r0_body.S183 = some (PRE_first_tail_x15_r0_body.s184, PRE_first_tail_x15_r0_body.S184)
end Host.Load.Run.Tpl
