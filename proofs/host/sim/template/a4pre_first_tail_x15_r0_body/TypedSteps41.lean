import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA204 from PRE_first_tail_x15_r0_body.s688 to PRE_first_tail_x15_r0_body.s689 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s688).run PRE_first_tail_x15_r0_body.S688 = some (PRE_first_tail_x15_r0_body.s689, PRE_first_tail_x15_r0_body.S689)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB204 from PRE_first_tail_x15_r0_body.s689 to PRE_first_tail_x15_r0_body.s690 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s689).run PRE_first_tail_x15_r0_body.S689 = some (PRE_first_tail_x15_r0_body.s690, PRE_first_tail_x15_r0_body.S690)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA205 from PRE_first_tail_x15_r0_body.s691 to PRE_first_tail_x15_r0_body.s692 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s691).run PRE_first_tail_x15_r0_body.S691 = some (PRE_first_tail_x15_r0_body.s692, PRE_first_tail_x15_r0_body.S692)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB205 from PRE_first_tail_x15_r0_body.s692 to PRE_first_tail_x15_r0_body.s693 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s692).run PRE_first_tail_x15_r0_body.S692 = some (PRE_first_tail_x15_r0_body.s693, PRE_first_tail_x15_r0_body.S693)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA206 from PRE_first_tail_x15_r0_body.s694 to PRE_first_tail_x15_r0_body.s695 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s694).run PRE_first_tail_x15_r0_body.S694 = some (PRE_first_tail_x15_r0_body.s695, PRE_first_tail_x15_r0_body.S695)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB206 from PRE_first_tail_x15_r0_body.s695 to PRE_first_tail_x15_r0_body.s696 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s695).run PRE_first_tail_x15_r0_body.S695 = some (PRE_first_tail_x15_r0_body.s696, PRE_first_tail_x15_r0_body.S696)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA207 from PRE_first_tail_x15_r0_body.s697 to PRE_first_tail_x15_r0_body.s698 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s697).run PRE_first_tail_x15_r0_body.S697 = some (PRE_first_tail_x15_r0_body.s698, PRE_first_tail_x15_r0_body.S698)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA208 from PRE_first_tail_x15_r0_body.s701 to PRE_first_tail_x15_r0_body.s702 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s701).run PRE_first_tail_x15_r0_body.S701 = some (PRE_first_tail_x15_r0_body.s702, PRE_first_tail_x15_r0_body.S702)
end Host.Load.Run.Tpl
