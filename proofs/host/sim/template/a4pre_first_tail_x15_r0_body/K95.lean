import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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
boot_rfl PRE_first_tail_x15_r0_body.stepA103 from PRE_first_tail_x15_r0_body.s380 to PRE_first_tail_x15_r0_body.s381 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s380).run PRE_first_tail_x15_r0_body.S380 = some (PRE_first_tail_x15_r0_body.s381, PRE_first_tail_x15_r0_body.S381)
boot_rfl PRE_first_tail_x15_r0_body.patchB103 from PRE_first_tail_x15_r0_body.s381 to PRE_first_tail_x15_r0_body.s382 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s381).run PRE_first_tail_x15_r0_body.S381 = some (PRE_first_tail_x15_r0_body.s382, PRE_first_tail_x15_r0_body.S382)
boot_rfl PRE_first_tail_x15_r0_body.k382 from PRE_first_tail_x15_r0_body.s382 to PRE_first_tail_x15_r0_body.s383 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB103 ((nth? PRE_first_tail_x15_r0_body.ks 382).getD 0) PRE_first_tail_x15_r0_body.s382 PRE_first_tail_x15_r0_body.S382 = some (PRE_first_tail_x15_r0_body.s383, PRE_first_tail_x15_r0_body.S383)
boot_rfl PRE_first_tail_x15_r0_body.stepA104 from PRE_first_tail_x15_r0_body.s383 to PRE_first_tail_x15_r0_body.s384 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s383).run PRE_first_tail_x15_r0_body.S383 = some (PRE_first_tail_x15_r0_body.s384, PRE_first_tail_x15_r0_body.S384)
end Host.Load.Run.Tpl
