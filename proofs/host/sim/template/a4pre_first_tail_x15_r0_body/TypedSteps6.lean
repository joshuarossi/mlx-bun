import host.sim.template.a4pre_first_tail_x15_r0_body.H3
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA30 from PRE_first_tail_x15_r0_body.s98 to PRE_first_tail_x15_r0_body.s99 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s98).run PRE_first_tail_x15_r0_body.S98 = some (PRE_first_tail_x15_r0_body.s99, PRE_first_tail_x15_r0_body.S99)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA31 from PRE_first_tail_x15_r0_body.s102 to PRE_first_tail_x15_r0_body.s103 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s102).run PRE_first_tail_x15_r0_body.S102 = some (PRE_first_tail_x15_r0_body.s103, PRE_first_tail_x15_r0_body.S103)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA32 from PRE_first_tail_x15_r0_body.s106 to PRE_first_tail_x15_r0_body.s107 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s106).run PRE_first_tail_x15_r0_body.S106 = some (PRE_first_tail_x15_r0_body.s107, PRE_first_tail_x15_r0_body.S107)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB32 from PRE_first_tail_x15_r0_body.s107 to PRE_first_tail_x15_r0_body.s108 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s107).run PRE_first_tail_x15_r0_body.S107 = some (PRE_first_tail_x15_r0_body.s108, PRE_first_tail_x15_r0_body.S108)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA33 from PRE_first_tail_x15_r0_body.s109 to PRE_first_tail_x15_r0_body.s110 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s109).run PRE_first_tail_x15_r0_body.S109 = some (PRE_first_tail_x15_r0_body.s110, PRE_first_tail_x15_r0_body.S110)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB33 from PRE_first_tail_x15_r0_body.s110 to PRE_first_tail_x15_r0_body.s111 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s110).run PRE_first_tail_x15_r0_body.S110 = some (PRE_first_tail_x15_r0_body.s111, PRE_first_tail_x15_r0_body.S111)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA34 from PRE_first_tail_x15_r0_body.s112 to PRE_first_tail_x15_r0_body.s113 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s112).run PRE_first_tail_x15_r0_body.S112 = some (PRE_first_tail_x15_r0_body.s113, PRE_first_tail_x15_r0_body.S113)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB34 from PRE_first_tail_x15_r0_body.s113 to PRE_first_tail_x15_r0_body.s114 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s113).run PRE_first_tail_x15_r0_body.S113 = some (PRE_first_tail_x15_r0_body.s114, PRE_first_tail_x15_r0_body.S114)
end Host.Load.Run.Tpl
