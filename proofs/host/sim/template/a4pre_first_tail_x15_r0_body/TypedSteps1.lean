import host.sim.template.a4pre_first_tail_x15_r0_body.H0
import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA5 from PRE_first_tail_x15_r0_body.s13 to PRE_first_tail_x15_r0_body.s14 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s13).run PRE_first_tail_x15_r0_body.S13 = some (PRE_first_tail_x15_r0_body.s14, PRE_first_tail_x15_r0_body.S14)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA6 from PRE_first_tail_x15_r0_body.s17 to PRE_first_tail_x15_r0_body.s18 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s17).run PRE_first_tail_x15_r0_body.S17 = some (PRE_first_tail_x15_r0_body.s18, PRE_first_tail_x15_r0_body.S18)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB6 from PRE_first_tail_x15_r0_body.s18 to PRE_first_tail_x15_r0_body.s19 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s18).run PRE_first_tail_x15_r0_body.S18 = some (PRE_first_tail_x15_r0_body.s19, PRE_first_tail_x15_r0_body.S19)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA7 from PRE_first_tail_x15_r0_body.s20 to PRE_first_tail_x15_r0_body.s21 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s20).run PRE_first_tail_x15_r0_body.S20 = some (PRE_first_tail_x15_r0_body.s21, PRE_first_tail_x15_r0_body.S21)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA8 from PRE_first_tail_x15_r0_body.s24 to PRE_first_tail_x15_r0_body.s25 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s24).run PRE_first_tail_x15_r0_body.S24 = some (PRE_first_tail_x15_r0_body.s25, PRE_first_tail_x15_r0_body.S25)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA9 from PRE_first_tail_x15_r0_body.s28 to PRE_first_tail_x15_r0_body.s29 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s28).run PRE_first_tail_x15_r0_body.S28 = some (PRE_first_tail_x15_r0_body.s29, PRE_first_tail_x15_r0_body.S29)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB9 from PRE_first_tail_x15_r0_body.s29 to PRE_first_tail_x15_r0_body.s30 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s29).run PRE_first_tail_x15_r0_body.S29 = some (PRE_first_tail_x15_r0_body.s30, PRE_first_tail_x15_r0_body.S30)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA10 from PRE_first_tail_x15_r0_body.s31 to PRE_first_tail_x15_r0_body.s32 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s31).run PRE_first_tail_x15_r0_body.S31 = some (PRE_first_tail_x15_r0_body.s32, PRE_first_tail_x15_r0_body.S32)
end Host.Load.Run.Tpl
