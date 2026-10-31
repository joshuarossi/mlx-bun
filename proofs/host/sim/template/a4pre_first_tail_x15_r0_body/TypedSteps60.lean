import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA298 from PRE_first_tail_x15_r0_body.s1102 to PRE_first_tail_x15_r0_body.s1103 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1102).run PRE_first_tail_x15_r0_body.S1102 = some (PRE_first_tail_x15_r0_body.s1103, PRE_first_tail_x15_r0_body.S1103)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB298 from PRE_first_tail_x15_r0_body.s1103 to PRE_first_tail_x15_r0_body.s1104 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1103).run PRE_first_tail_x15_r0_body.S1103 = some (PRE_first_tail_x15_r0_body.s1104, PRE_first_tail_x15_r0_body.S1104)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA299 from PRE_first_tail_x15_r0_body.s1105 to PRE_first_tail_x15_r0_body.s1106 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1105).run PRE_first_tail_x15_r0_body.S1105 = some (PRE_first_tail_x15_r0_body.s1106, PRE_first_tail_x15_r0_body.S1106)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB299 from PRE_first_tail_x15_r0_body.s1106 to PRE_first_tail_x15_r0_body.s1107 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1106).run PRE_first_tail_x15_r0_body.S1106 = some (PRE_first_tail_x15_r0_body.s1107, PRE_first_tail_x15_r0_body.S1107)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA300 from PRE_first_tail_x15_r0_body.s1108 to PRE_first_tail_x15_r0_body.s1109 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1108).run PRE_first_tail_x15_r0_body.S1108 = some (PRE_first_tail_x15_r0_body.s1109, PRE_first_tail_x15_r0_body.S1109)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA301 from PRE_first_tail_x15_r0_body.s1112 to PRE_first_tail_x15_r0_body.s1113 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1112).run PRE_first_tail_x15_r0_body.S1112 = some (PRE_first_tail_x15_r0_body.s1113, PRE_first_tail_x15_r0_body.S1113)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB301 from PRE_first_tail_x15_r0_body.s1113 to PRE_first_tail_x15_r0_body.s1114 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1113).run PRE_first_tail_x15_r0_body.S1113 = some (PRE_first_tail_x15_r0_body.s1114, PRE_first_tail_x15_r0_body.S1114)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA302 from PRE_first_tail_x15_r0_body.s1116 to PRE_first_tail_x15_r0_body.s1117 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1116).run PRE_first_tail_x15_r0_body.S1116 = some (PRE_first_tail_x15_r0_body.s1117, PRE_first_tail_x15_r0_body.S1117)
end Host.Load.Run.Tpl
