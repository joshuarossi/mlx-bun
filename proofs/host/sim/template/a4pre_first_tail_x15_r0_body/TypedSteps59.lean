import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA293 from PRE_first_tail_x15_r0_body.s1083 to PRE_first_tail_x15_r0_body.s1084 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1083).run PRE_first_tail_x15_r0_body.S1083 = some (PRE_first_tail_x15_r0_body.s1084, PRE_first_tail_x15_r0_body.S1084)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB293 from PRE_first_tail_x15_r0_body.s1084 to PRE_first_tail_x15_r0_body.s1085 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1084).run PRE_first_tail_x15_r0_body.S1084 = some (PRE_first_tail_x15_r0_body.s1085, PRE_first_tail_x15_r0_body.S1085)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA294 from PRE_first_tail_x15_r0_body.s1087 to PRE_first_tail_x15_r0_body.s1088 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1087).run PRE_first_tail_x15_r0_body.S1087 = some (PRE_first_tail_x15_r0_body.s1088, PRE_first_tail_x15_r0_body.S1088)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA295 from PRE_first_tail_x15_r0_body.s1091 to PRE_first_tail_x15_r0_body.s1092 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1091).run PRE_first_tail_x15_r0_body.S1091 = some (PRE_first_tail_x15_r0_body.s1092, PRE_first_tail_x15_r0_body.S1092)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA296 from PRE_first_tail_x15_r0_body.s1096 to PRE_first_tail_x15_r0_body.s1097 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1096).run PRE_first_tail_x15_r0_body.S1096 = some (PRE_first_tail_x15_r0_body.s1097, PRE_first_tail_x15_r0_body.S1097)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB296 from PRE_first_tail_x15_r0_body.s1097 to PRE_first_tail_x15_r0_body.s1098 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1097).run PRE_first_tail_x15_r0_body.S1097 = some (PRE_first_tail_x15_r0_body.s1098, PRE_first_tail_x15_r0_body.S1098)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA297 from PRE_first_tail_x15_r0_body.s1099 to PRE_first_tail_x15_r0_body.s1100 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1099).run PRE_first_tail_x15_r0_body.S1099 = some (PRE_first_tail_x15_r0_body.s1100, PRE_first_tail_x15_r0_body.S1100)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB297 from PRE_first_tail_x15_r0_body.s1100 to PRE_first_tail_x15_r0_body.s1101 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1100).run PRE_first_tail_x15_r0_body.S1100 = some (PRE_first_tail_x15_r0_body.s1101, PRE_first_tail_x15_r0_body.S1101)
end Host.Load.Run.Tpl
