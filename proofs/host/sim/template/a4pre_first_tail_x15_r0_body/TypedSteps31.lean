import host.sim.template.a4pre_first_tail_x15_r0_body.H17
import host.sim.template.a4pre_first_tail_x15_r0_body.H18
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA154 from PRE_first_tail_x15_r0_body.s569 to PRE_first_tail_x15_r0_body.s570 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s569).run PRE_first_tail_x15_r0_body.S569 = some (PRE_first_tail_x15_r0_body.s570, PRE_first_tail_x15_r0_body.S570)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA155 from PRE_first_tail_x15_r0_body.s573 to PRE_first_tail_x15_r0_body.s574 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s573).run PRE_first_tail_x15_r0_body.S573 = some (PRE_first_tail_x15_r0_body.s574, PRE_first_tail_x15_r0_body.S574)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA156 from PRE_first_tail_x15_r0_body.s578 to PRE_first_tail_x15_r0_body.s579 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s578).run PRE_first_tail_x15_r0_body.S578 = some (PRE_first_tail_x15_r0_body.s579, PRE_first_tail_x15_r0_body.S579)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB156 from PRE_first_tail_x15_r0_body.s579 to PRE_first_tail_x15_r0_body.s580 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s579).run PRE_first_tail_x15_r0_body.S579 = some (PRE_first_tail_x15_r0_body.s580, PRE_first_tail_x15_r0_body.S580)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA157 from PRE_first_tail_x15_r0_body.s581 to PRE_first_tail_x15_r0_body.s582 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s581).run PRE_first_tail_x15_r0_body.S581 = some (PRE_first_tail_x15_r0_body.s582, PRE_first_tail_x15_r0_body.S582)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB157 from PRE_first_tail_x15_r0_body.s582 to PRE_first_tail_x15_r0_body.s583 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s582).run PRE_first_tail_x15_r0_body.S582 = some (PRE_first_tail_x15_r0_body.s583, PRE_first_tail_x15_r0_body.S583)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA158 from PRE_first_tail_x15_r0_body.s584 to PRE_first_tail_x15_r0_body.s585 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s584).run PRE_first_tail_x15_r0_body.S584 = some (PRE_first_tail_x15_r0_body.s585, PRE_first_tail_x15_r0_body.S585)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB158 from PRE_first_tail_x15_r0_body.s585 to PRE_first_tail_x15_r0_body.s586 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s585).run PRE_first_tail_x15_r0_body.S585 = some (PRE_first_tail_x15_r0_body.s586, PRE_first_tail_x15_r0_body.S586)
end Host.Load.Run.Tpl
