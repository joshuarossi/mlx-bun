import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.a4pre_first_tail_x15_r0_body.H19
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA179 from PRE_first_tail_x15_r0_body.s603 to PRE_first_tail_x15_r0_body.s604 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s603).run PRE_first_tail_x15_r0_body.S603 = some (PRE_first_tail_x15_r0_body.s604, PRE_first_tail_x15_r0_body.S604)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA180 from PRE_first_tail_x15_r0_body.s607 to PRE_first_tail_x15_r0_body.s608 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s607).run PRE_first_tail_x15_r0_body.S607 = some (PRE_first_tail_x15_r0_body.s608, PRE_first_tail_x15_r0_body.S608)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB180 from PRE_first_tail_x15_r0_body.s608 to PRE_first_tail_x15_r0_body.s609 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s608).run PRE_first_tail_x15_r0_body.S608 = some (PRE_first_tail_x15_r0_body.s609, PRE_first_tail_x15_r0_body.S609)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA181 from PRE_first_tail_x15_r0_body.s610 to PRE_first_tail_x15_r0_body.s611 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s610).run PRE_first_tail_x15_r0_body.S610 = some (PRE_first_tail_x15_r0_body.s611, PRE_first_tail_x15_r0_body.S611)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB181 from PRE_first_tail_x15_r0_body.s611 to PRE_first_tail_x15_r0_body.s612 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s611).run PRE_first_tail_x15_r0_body.S611 = some (PRE_first_tail_x15_r0_body.s612, PRE_first_tail_x15_r0_body.S612)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA182 from PRE_first_tail_x15_r0_body.s613 to PRE_first_tail_x15_r0_body.s614 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s613).run PRE_first_tail_x15_r0_body.S613 = some (PRE_first_tail_x15_r0_body.s614, PRE_first_tail_x15_r0_body.S614)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB182 from PRE_first_tail_x15_r0_body.s614 to PRE_first_tail_x15_r0_body.s615 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s614).run PRE_first_tail_x15_r0_body.S614 = some (PRE_first_tail_x15_r0_body.s615, PRE_first_tail_x15_r0_body.S615)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA183 from PRE_first_tail_x15_r0_body.s616 to PRE_first_tail_x15_r0_body.s617 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s616).run PRE_first_tail_x15_r0_body.S616 = some (PRE_first_tail_x15_r0_body.s617, PRE_first_tail_x15_r0_body.S617)
end Host.Load.Run.Tpl
