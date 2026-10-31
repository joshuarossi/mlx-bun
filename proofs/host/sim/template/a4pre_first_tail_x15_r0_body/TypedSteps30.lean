import host.sim.template.a4pre_first_tail_x15_r0_body.H15
import host.sim.template.a4pre_first_tail_x15_r0_body.H16
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB149 from PRE_first_tail_x15_r0_body.s503 to PRE_first_tail_x15_r0_body.s504 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s503).run PRE_first_tail_x15_r0_body.S503 = some (PRE_first_tail_x15_r0_body.s504, PRE_first_tail_x15_r0_body.S504)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA150 from PRE_first_tail_x15_r0_body.s505 to PRE_first_tail_x15_r0_body.s506 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s505).run PRE_first_tail_x15_r0_body.S505 = some (PRE_first_tail_x15_r0_body.s506, PRE_first_tail_x15_r0_body.S506)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB150 from PRE_first_tail_x15_r0_body.s506 to PRE_first_tail_x15_r0_body.s507 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s506).run PRE_first_tail_x15_r0_body.S506 = some (PRE_first_tail_x15_r0_body.s507, PRE_first_tail_x15_r0_body.S507)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA151 from PRE_first_tail_x15_r0_body.s508 to PRE_first_tail_x15_r0_body.s509 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s508).run PRE_first_tail_x15_r0_body.S508 = some (PRE_first_tail_x15_r0_body.s509, PRE_first_tail_x15_r0_body.S509)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB151 from PRE_first_tail_x15_r0_body.s509 to PRE_first_tail_x15_r0_body.s510 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s509).run PRE_first_tail_x15_r0_body.S509 = some (PRE_first_tail_x15_r0_body.s510, PRE_first_tail_x15_r0_body.S510)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA152 from PRE_first_tail_x15_r0_body.s511 to PRE_first_tail_x15_r0_body.s512 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s511).run PRE_first_tail_x15_r0_body.S511 = some (PRE_first_tail_x15_r0_body.s512, PRE_first_tail_x15_r0_body.S512)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA153 from PRE_first_tail_x15_r0_body.s515 to PRE_first_tail_x15_r0_body.s516 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s515).run PRE_first_tail_x15_r0_body.S515 = some (PRE_first_tail_x15_r0_body.s516, PRE_first_tail_x15_r0_body.S516)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB153 from PRE_first_tail_x15_r0_body.s516 to PRE_first_tail_x15_r0_body.s517 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s516).run PRE_first_tail_x15_r0_body.S516 = some (PRE_first_tail_x15_r0_body.s517, PRE_first_tail_x15_r0_body.S517)
end Host.Load.Run.Tpl
