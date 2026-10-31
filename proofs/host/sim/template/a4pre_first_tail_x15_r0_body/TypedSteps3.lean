import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.a4pre_first_tail_x15_r0_body.H2
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA15 from PRE_first_tail_x15_r0_body.s52 to PRE_first_tail_x15_r0_body.s53 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s52).run PRE_first_tail_x15_r0_body.S52 = some (PRE_first_tail_x15_r0_body.s53, PRE_first_tail_x15_r0_body.S53)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA16 from PRE_first_tail_x15_r0_body.s56 to PRE_first_tail_x15_r0_body.s57 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s56).run PRE_first_tail_x15_r0_body.S56 = some (PRE_first_tail_x15_r0_body.s57, PRE_first_tail_x15_r0_body.S57)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA17 from PRE_first_tail_x15_r0_body.s61 to PRE_first_tail_x15_r0_body.s62 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s61).run PRE_first_tail_x15_r0_body.S61 = some (PRE_first_tail_x15_r0_body.s62, PRE_first_tail_x15_r0_body.S62)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB17 from PRE_first_tail_x15_r0_body.s62 to PRE_first_tail_x15_r0_body.s63 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s62).run PRE_first_tail_x15_r0_body.S62 = some (PRE_first_tail_x15_r0_body.s63, PRE_first_tail_x15_r0_body.S63)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA18 from PRE_first_tail_x15_r0_body.s64 to PRE_first_tail_x15_r0_body.s65 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s64).run PRE_first_tail_x15_r0_body.S64 = some (PRE_first_tail_x15_r0_body.s65, PRE_first_tail_x15_r0_body.S65)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB18 from PRE_first_tail_x15_r0_body.s65 to PRE_first_tail_x15_r0_body.s66 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s65).run PRE_first_tail_x15_r0_body.S65 = some (PRE_first_tail_x15_r0_body.s66, PRE_first_tail_x15_r0_body.S66)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA19 from PRE_first_tail_x15_r0_body.s67 to PRE_first_tail_x15_r0_body.s68 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s67).run PRE_first_tail_x15_r0_body.S67 = some (PRE_first_tail_x15_r0_body.s68, PRE_first_tail_x15_r0_body.S68)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB19 from PRE_first_tail_x15_r0_body.s68 to PRE_first_tail_x15_r0_body.s69 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s68).run PRE_first_tail_x15_r0_body.S68 = some (PRE_first_tail_x15_r0_body.s69, PRE_first_tail_x15_r0_body.S69)
end Host.Load.Run.Tpl
