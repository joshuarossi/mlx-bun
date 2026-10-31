import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB99 from PRE_first_tail_x15_r0_body.s365 to PRE_first_tail_x15_r0_body.s366 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s365).run PRE_first_tail_x15_r0_body.S365 = some (PRE_first_tail_x15_r0_body.s366, PRE_first_tail_x15_r0_body.S366)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA100 from PRE_first_tail_x15_r0_body.s368 to PRE_first_tail_x15_r0_body.s369 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s368).run PRE_first_tail_x15_r0_body.S368 = some (PRE_first_tail_x15_r0_body.s369, PRE_first_tail_x15_r0_body.S369)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA101 from PRE_first_tail_x15_r0_body.s372 to PRE_first_tail_x15_r0_body.s373 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s372).run PRE_first_tail_x15_r0_body.S372 = some (PRE_first_tail_x15_r0_body.s373, PRE_first_tail_x15_r0_body.S373)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA102 from PRE_first_tail_x15_r0_body.s377 to PRE_first_tail_x15_r0_body.s378 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s377).run PRE_first_tail_x15_r0_body.S377 = some (PRE_first_tail_x15_r0_body.s378, PRE_first_tail_x15_r0_body.S378)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB102 from PRE_first_tail_x15_r0_body.s378 to PRE_first_tail_x15_r0_body.s379 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s378).run PRE_first_tail_x15_r0_body.S378 = some (PRE_first_tail_x15_r0_body.s379, PRE_first_tail_x15_r0_body.S379)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA103 from PRE_first_tail_x15_r0_body.s380 to PRE_first_tail_x15_r0_body.s381 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s380).run PRE_first_tail_x15_r0_body.S380 = some (PRE_first_tail_x15_r0_body.s381, PRE_first_tail_x15_r0_body.S381)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB103 from PRE_first_tail_x15_r0_body.s381 to PRE_first_tail_x15_r0_body.s382 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s381).run PRE_first_tail_x15_r0_body.S381 = some (PRE_first_tail_x15_r0_body.s382, PRE_first_tail_x15_r0_body.S382)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA104 from PRE_first_tail_x15_r0_body.s383 to PRE_first_tail_x15_r0_body.s384 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s383).run PRE_first_tail_x15_r0_body.S383 = some (PRE_first_tail_x15_r0_body.s384, PRE_first_tail_x15_r0_body.S384)
end Host.Load.Run.Tpl
