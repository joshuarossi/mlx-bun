import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA343 from PRE_first_tail_x15_r0_body.s1159 to PRE_first_tail_x15_r0_body.s1160 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1159).run PRE_first_tail_x15_r0_body.S1159 = some (PRE_first_tail_x15_r0_body.s1160, PRE_first_tail_x15_r0_body.S1160)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB343 from PRE_first_tail_x15_r0_body.s1160 to PRE_first_tail_x15_r0_body.s1161 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1160).run PRE_first_tail_x15_r0_body.S1160 = some (PRE_first_tail_x15_r0_body.s1161, PRE_first_tail_x15_r0_body.S1161)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA344 from PRE_first_tail_x15_r0_body.s1162 to PRE_first_tail_x15_r0_body.s1163 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1162).run PRE_first_tail_x15_r0_body.S1162 = some (PRE_first_tail_x15_r0_body.s1163, PRE_first_tail_x15_r0_body.S1163)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB344 from PRE_first_tail_x15_r0_body.s1163 to PRE_first_tail_x15_r0_body.s1164 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1163).run PRE_first_tail_x15_r0_body.S1163 = some (PRE_first_tail_x15_r0_body.s1164, PRE_first_tail_x15_r0_body.S1164)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA345 from PRE_first_tail_x15_r0_body.s1165 to PRE_first_tail_x15_r0_body.s1166 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1165).run PRE_first_tail_x15_r0_body.S1165 = some (PRE_first_tail_x15_r0_body.s1166, PRE_first_tail_x15_r0_body.S1166)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB345 from PRE_first_tail_x15_r0_body.s1166 to PRE_first_tail_x15_r0_body.s1167 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1166).run PRE_first_tail_x15_r0_body.S1166 = some (PRE_first_tail_x15_r0_body.s1167, PRE_first_tail_x15_r0_body.S1167)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA346 from PRE_first_tail_x15_r0_body.s1168 to PRE_first_tail_x15_r0_body.s1169 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1168).run PRE_first_tail_x15_r0_body.S1168 = some (PRE_first_tail_x15_r0_body.s1169, PRE_first_tail_x15_r0_body.S1169)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA347 from PRE_first_tail_x15_r0_body.s1172 to PRE_first_tail_x15_r0_body.s1173 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1172).run PRE_first_tail_x15_r0_body.S1172 = some (PRE_first_tail_x15_r0_body.s1173, PRE_first_tail_x15_r0_body.S1173)
end Host.Load.Run.Tpl
