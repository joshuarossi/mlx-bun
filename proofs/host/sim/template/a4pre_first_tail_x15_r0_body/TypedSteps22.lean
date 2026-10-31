import host.sim.template.a4pre_first_tail_x15_r0_body.H11
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA110 from PRE_first_tail_x15_r0_body.s370 to PRE_first_tail_x15_r0_body.s371 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s370).run PRE_first_tail_x15_r0_body.S370 = some (PRE_first_tail_x15_r0_body.s371, PRE_first_tail_x15_r0_body.S371)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB110 from PRE_first_tail_x15_r0_body.s371 to PRE_first_tail_x15_r0_body.s372 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s371).run PRE_first_tail_x15_r0_body.S371 = some (PRE_first_tail_x15_r0_body.s372, PRE_first_tail_x15_r0_body.S372)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA111 from PRE_first_tail_x15_r0_body.s373 to PRE_first_tail_x15_r0_body.s374 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s373).run PRE_first_tail_x15_r0_body.S373 = some (PRE_first_tail_x15_r0_body.s374, PRE_first_tail_x15_r0_body.S374)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB111 from PRE_first_tail_x15_r0_body.s374 to PRE_first_tail_x15_r0_body.s375 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s374).run PRE_first_tail_x15_r0_body.S374 = some (PRE_first_tail_x15_r0_body.s375, PRE_first_tail_x15_r0_body.S375)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA112 from PRE_first_tail_x15_r0_body.s376 to PRE_first_tail_x15_r0_body.s377 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s376).run PRE_first_tail_x15_r0_body.S376 = some (PRE_first_tail_x15_r0_body.s377, PRE_first_tail_x15_r0_body.S377)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB112 from PRE_first_tail_x15_r0_body.s377 to PRE_first_tail_x15_r0_body.s378 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s377).run PRE_first_tail_x15_r0_body.S377 = some (PRE_first_tail_x15_r0_body.s378, PRE_first_tail_x15_r0_body.S378)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA113 from PRE_first_tail_x15_r0_body.s379 to PRE_first_tail_x15_r0_body.s380 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s379).run PRE_first_tail_x15_r0_body.S379 = some (PRE_first_tail_x15_r0_body.s380, PRE_first_tail_x15_r0_body.S380)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB113 from PRE_first_tail_x15_r0_body.s380 to PRE_first_tail_x15_r0_body.s381 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s380).run PRE_first_tail_x15_r0_body.S380 = some (PRE_first_tail_x15_r0_body.s381, PRE_first_tail_x15_r0_body.S381)
end Host.Load.Run.Tpl
