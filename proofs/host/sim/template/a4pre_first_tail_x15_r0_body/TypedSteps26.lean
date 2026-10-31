import host.sim.template.a4pre_first_tail_x15_r0_body.H14
import host.sim.template.a4pre_first_tail_x15_r0_body.H15
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA129 from PRE_first_tail_x15_r0_body.s475 to PRE_first_tail_x15_r0_body.s476 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s475).run PRE_first_tail_x15_r0_body.S475 = some (PRE_first_tail_x15_r0_body.s476, PRE_first_tail_x15_r0_body.S476)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA130 from PRE_first_tail_x15_r0_body.s479 to PRE_first_tail_x15_r0_body.s480 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s479).run PRE_first_tail_x15_r0_body.S479 = some (PRE_first_tail_x15_r0_body.s480, PRE_first_tail_x15_r0_body.S480)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB130 from PRE_first_tail_x15_r0_body.s480 to PRE_first_tail_x15_r0_body.s481 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s480).run PRE_first_tail_x15_r0_body.S480 = some (PRE_first_tail_x15_r0_body.s481, PRE_first_tail_x15_r0_body.S481)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA131 from PRE_first_tail_x15_r0_body.s483 to PRE_first_tail_x15_r0_body.s484 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s483).run PRE_first_tail_x15_r0_body.S483 = some (PRE_first_tail_x15_r0_body.s484, PRE_first_tail_x15_r0_body.S484)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA132 from PRE_first_tail_x15_r0_body.s487 to PRE_first_tail_x15_r0_body.s488 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s487).run PRE_first_tail_x15_r0_body.S487 = some (PRE_first_tail_x15_r0_body.s488, PRE_first_tail_x15_r0_body.S488)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA133 from PRE_first_tail_x15_r0_body.s492 to PRE_first_tail_x15_r0_body.s493 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s492).run PRE_first_tail_x15_r0_body.S492 = some (PRE_first_tail_x15_r0_body.s493, PRE_first_tail_x15_r0_body.S493)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB133 from PRE_first_tail_x15_r0_body.s493 to PRE_first_tail_x15_r0_body.s494 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s493).run PRE_first_tail_x15_r0_body.S493 = some (PRE_first_tail_x15_r0_body.s494, PRE_first_tail_x15_r0_body.S494)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA134 from PRE_first_tail_x15_r0_body.s495 to PRE_first_tail_x15_r0_body.s496 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s495).run PRE_first_tail_x15_r0_body.S495 = some (PRE_first_tail_x15_r0_body.s496, PRE_first_tail_x15_r0_body.S496)
end Host.Load.Run.Tpl
