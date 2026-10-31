import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA313 from PRE_first_tail_x15_r0_body.s1159 to PRE_first_tail_x15_r0_body.s1160 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1159).run PRE_first_tail_x15_r0_body.S1159 = some (PRE_first_tail_x15_r0_body.s1160, PRE_first_tail_x15_r0_body.S1160)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB313 from PRE_first_tail_x15_r0_body.s1160 to PRE_first_tail_x15_r0_body.s1161 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1160).run PRE_first_tail_x15_r0_body.S1160 = some (PRE_first_tail_x15_r0_body.s1161, PRE_first_tail_x15_r0_body.S1161)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA314 from PRE_first_tail_x15_r0_body.s1162 to PRE_first_tail_x15_r0_body.s1163 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1162).run PRE_first_tail_x15_r0_body.S1162 = some (PRE_first_tail_x15_r0_body.s1163, PRE_first_tail_x15_r0_body.S1163)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB314 from PRE_first_tail_x15_r0_body.s1163 to PRE_first_tail_x15_r0_body.s1164 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1163).run PRE_first_tail_x15_r0_body.S1163 = some (PRE_first_tail_x15_r0_body.s1164, PRE_first_tail_x15_r0_body.S1164)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA315 from PRE_first_tail_x15_r0_body.s1165 to PRE_first_tail_x15_r0_body.s1166 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1165).run PRE_first_tail_x15_r0_body.S1165 = some (PRE_first_tail_x15_r0_body.s1166, PRE_first_tail_x15_r0_body.S1166)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA316 from PRE_first_tail_x15_r0_body.s1169 to PRE_first_tail_x15_r0_body.s1170 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1169).run PRE_first_tail_x15_r0_body.S1169 = some (PRE_first_tail_x15_r0_body.s1170, PRE_first_tail_x15_r0_body.S1170)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB316 from PRE_first_tail_x15_r0_body.s1170 to PRE_first_tail_x15_r0_body.s1171 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1170).run PRE_first_tail_x15_r0_body.S1170 = some (PRE_first_tail_x15_r0_body.s1171, PRE_first_tail_x15_r0_body.S1171)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA317 from PRE_first_tail_x15_r0_body.s1173 to PRE_first_tail_x15_r0_body.s1174 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1173).run PRE_first_tail_x15_r0_body.S1173 = some (PRE_first_tail_x15_r0_body.s1174, PRE_first_tail_x15_r0_body.S1174)
end Host.Load.Run.Tpl
