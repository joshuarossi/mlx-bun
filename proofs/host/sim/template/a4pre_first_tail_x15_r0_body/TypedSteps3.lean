import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA15 from PRE_first_tail_x15_r0_body.s47 to PRE_first_tail_x15_r0_body.s48 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s47).run PRE_first_tail_x15_r0_body.S47 = some (PRE_first_tail_x15_r0_body.s48, PRE_first_tail_x15_r0_body.S48)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA16 from PRE_first_tail_x15_r0_body.s51 to PRE_first_tail_x15_r0_body.s52 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s51).run PRE_first_tail_x15_r0_body.S51 = some (PRE_first_tail_x15_r0_body.s52, PRE_first_tail_x15_r0_body.S52)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA17 from PRE_first_tail_x15_r0_body.s55 to PRE_first_tail_x15_r0_body.s56 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s55).run PRE_first_tail_x15_r0_body.S55 = some (PRE_first_tail_x15_r0_body.s56, PRE_first_tail_x15_r0_body.S56)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB17 from PRE_first_tail_x15_r0_body.s56 to PRE_first_tail_x15_r0_body.s57 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s56).run PRE_first_tail_x15_r0_body.S56 = some (PRE_first_tail_x15_r0_body.s57, PRE_first_tail_x15_r0_body.S57)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA18 from PRE_first_tail_x15_r0_body.s58 to PRE_first_tail_x15_r0_body.s59 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s58).run PRE_first_tail_x15_r0_body.S58 = some (PRE_first_tail_x15_r0_body.s59, PRE_first_tail_x15_r0_body.S59)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB18 from PRE_first_tail_x15_r0_body.s59 to PRE_first_tail_x15_r0_body.s60 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s59).run PRE_first_tail_x15_r0_body.S59 = some (PRE_first_tail_x15_r0_body.s60, PRE_first_tail_x15_r0_body.S60)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA19 from PRE_first_tail_x15_r0_body.s61 to PRE_first_tail_x15_r0_body.s62 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s61).run PRE_first_tail_x15_r0_body.S61 = some (PRE_first_tail_x15_r0_body.s62, PRE_first_tail_x15_r0_body.S62)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB19 from PRE_first_tail_x15_r0_body.s62 to PRE_first_tail_x15_r0_body.s63 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s62).run PRE_first_tail_x15_r0_body.S62 = some (PRE_first_tail_x15_r0_body.s63, PRE_first_tail_x15_r0_body.S63)
end Host.Load.Run.Tpl
