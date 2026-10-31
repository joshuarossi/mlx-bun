import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA303 from PRE_first_tail_x15_r0_body.s1120 to PRE_first_tail_x15_r0_body.s1121 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1120).run PRE_first_tail_x15_r0_body.S1120 = some (PRE_first_tail_x15_r0_body.s1121, PRE_first_tail_x15_r0_body.S1121)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA304 from PRE_first_tail_x15_r0_body.s1125 to PRE_first_tail_x15_r0_body.s1126 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1125).run PRE_first_tail_x15_r0_body.S1125 = some (PRE_first_tail_x15_r0_body.s1126, PRE_first_tail_x15_r0_body.S1126)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB304 from PRE_first_tail_x15_r0_body.s1126 to PRE_first_tail_x15_r0_body.s1127 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1126).run PRE_first_tail_x15_r0_body.S1126 = some (PRE_first_tail_x15_r0_body.s1127, PRE_first_tail_x15_r0_body.S1127)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA305 from PRE_first_tail_x15_r0_body.s1129 to PRE_first_tail_x15_r0_body.s1130 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1129).run PRE_first_tail_x15_r0_body.S1129 = some (PRE_first_tail_x15_r0_body.s1130, PRE_first_tail_x15_r0_body.S1130)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB305 from PRE_first_tail_x15_r0_body.s1130 to PRE_first_tail_x15_r0_body.s1131 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1130).run PRE_first_tail_x15_r0_body.S1130 = some (PRE_first_tail_x15_r0_body.s1131, PRE_first_tail_x15_r0_body.S1131)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA306 from PRE_first_tail_x15_r0_body.s1132 to PRE_first_tail_x15_r0_body.s1133 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1132).run PRE_first_tail_x15_r0_body.S1132 = some (PRE_first_tail_x15_r0_body.s1133, PRE_first_tail_x15_r0_body.S1133)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB306 from PRE_first_tail_x15_r0_body.s1133 to PRE_first_tail_x15_r0_body.s1134 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1133).run PRE_first_tail_x15_r0_body.S1133 = some (PRE_first_tail_x15_r0_body.s1134, PRE_first_tail_x15_r0_body.S1134)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA307 from PRE_first_tail_x15_r0_body.s1136 to PRE_first_tail_x15_r0_body.s1137 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1136).run PRE_first_tail_x15_r0_body.S1136 = some (PRE_first_tail_x15_r0_body.s1137, PRE_first_tail_x15_r0_body.S1137)
end Host.Load.Run.Tpl
