import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.a4pre_first_tail_x15_r0_body.H22
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB208 from PRE_first_tail_x15_r0_body.s702 to PRE_first_tail_x15_r0_body.s703 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s702).run PRE_first_tail_x15_r0_body.S702 = some (PRE_first_tail_x15_r0_body.s703, PRE_first_tail_x15_r0_body.S703)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA209 from PRE_first_tail_x15_r0_body.s704 to PRE_first_tail_x15_r0_body.s705 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s704).run PRE_first_tail_x15_r0_body.S704 = some (PRE_first_tail_x15_r0_body.s705, PRE_first_tail_x15_r0_body.S705)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA210 from PRE_first_tail_x15_r0_body.s708 to PRE_first_tail_x15_r0_body.s709 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s708).run PRE_first_tail_x15_r0_body.S708 = some (PRE_first_tail_x15_r0_body.s709, PRE_first_tail_x15_r0_body.S709)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA211 from PRE_first_tail_x15_r0_body.s712 to PRE_first_tail_x15_r0_body.s713 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s712).run PRE_first_tail_x15_r0_body.S712 = some (PRE_first_tail_x15_r0_body.s713, PRE_first_tail_x15_r0_body.S713)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB211 from PRE_first_tail_x15_r0_body.s713 to PRE_first_tail_x15_r0_body.s714 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s713).run PRE_first_tail_x15_r0_body.S713 = some (PRE_first_tail_x15_r0_body.s714, PRE_first_tail_x15_r0_body.S714)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA212 from PRE_first_tail_x15_r0_body.s715 to PRE_first_tail_x15_r0_body.s716 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s715).run PRE_first_tail_x15_r0_body.S715 = some (PRE_first_tail_x15_r0_body.s716, PRE_first_tail_x15_r0_body.S716)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB212 from PRE_first_tail_x15_r0_body.s716 to PRE_first_tail_x15_r0_body.s717 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s716).run PRE_first_tail_x15_r0_body.S716 = some (PRE_first_tail_x15_r0_body.s717, PRE_first_tail_x15_r0_body.S717)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA213 from PRE_first_tail_x15_r0_body.s718 to PRE_first_tail_x15_r0_body.s719 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s718).run PRE_first_tail_x15_r0_body.S718 = some (PRE_first_tail_x15_r0_body.s719, PRE_first_tail_x15_r0_body.S719)
end Host.Load.Run.Tpl
