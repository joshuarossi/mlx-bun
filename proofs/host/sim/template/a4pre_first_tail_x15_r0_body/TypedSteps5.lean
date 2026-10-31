import host.sim.template.a4pre_first_tail_x15_r0_body.H2
import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB25 from PRE_first_tail_x15_r0_body.s91 to PRE_first_tail_x15_r0_body.s92 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s91).run PRE_first_tail_x15_r0_body.S91 = some (PRE_first_tail_x15_r0_body.s92, PRE_first_tail_x15_r0_body.S92)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA26 from PRE_first_tail_x15_r0_body.s94 to PRE_first_tail_x15_r0_body.s95 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s94).run PRE_first_tail_x15_r0_body.S94 = some (PRE_first_tail_x15_r0_body.s95, PRE_first_tail_x15_r0_body.S95)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB26 from PRE_first_tail_x15_r0_body.s95 to PRE_first_tail_x15_r0_body.s96 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s95).run PRE_first_tail_x15_r0_body.S95 = some (PRE_first_tail_x15_r0_body.s96, PRE_first_tail_x15_r0_body.S96)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA27 from PRE_first_tail_x15_r0_body.s97 to PRE_first_tail_x15_r0_body.s98 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s97).run PRE_first_tail_x15_r0_body.S97 = some (PRE_first_tail_x15_r0_body.s98, PRE_first_tail_x15_r0_body.S98)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB27 from PRE_first_tail_x15_r0_body.s98 to PRE_first_tail_x15_r0_body.s99 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s98).run PRE_first_tail_x15_r0_body.S98 = some (PRE_first_tail_x15_r0_body.s99, PRE_first_tail_x15_r0_body.S99)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA28 from PRE_first_tail_x15_r0_body.s101 to PRE_first_tail_x15_r0_body.s102 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s101).run PRE_first_tail_x15_r0_body.S101 = some (PRE_first_tail_x15_r0_body.s102, PRE_first_tail_x15_r0_body.S102)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA29 from PRE_first_tail_x15_r0_body.s105 to PRE_first_tail_x15_r0_body.s106 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s105).run PRE_first_tail_x15_r0_body.S105 = some (PRE_first_tail_x15_r0_body.s106, PRE_first_tail_x15_r0_body.S106)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB29 from PRE_first_tail_x15_r0_body.s106 to PRE_first_tail_x15_r0_body.s107 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s106).run PRE_first_tail_x15_r0_body.S106 = some (PRE_first_tail_x15_r0_body.s107, PRE_first_tail_x15_r0_body.S107)
end Host.Load.Run.Tpl
