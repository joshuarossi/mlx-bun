import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.a4pre_first_tail_x15_r0_body.H37
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA318 from PRE_first_tail_x15_r0_body.s1177 to PRE_first_tail_x15_r0_body.s1178 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1177).run PRE_first_tail_x15_r0_body.S1177 = some (PRE_first_tail_x15_r0_body.s1178, PRE_first_tail_x15_r0_body.S1178)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA319 from PRE_first_tail_x15_r0_body.s1182 to PRE_first_tail_x15_r0_body.s1183 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1182).run PRE_first_tail_x15_r0_body.S1182 = some (PRE_first_tail_x15_r0_body.s1183, PRE_first_tail_x15_r0_body.S1183)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB319 from PRE_first_tail_x15_r0_body.s1183 to PRE_first_tail_x15_r0_body.s1184 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1183).run PRE_first_tail_x15_r0_body.S1183 = some (PRE_first_tail_x15_r0_body.s1184, PRE_first_tail_x15_r0_body.S1184)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA320 from PRE_first_tail_x15_r0_body.s1185 to PRE_first_tail_x15_r0_body.s1186 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1185).run PRE_first_tail_x15_r0_body.S1185 = some (PRE_first_tail_x15_r0_body.s1186, PRE_first_tail_x15_r0_body.S1186)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB320 from PRE_first_tail_x15_r0_body.s1186 to PRE_first_tail_x15_r0_body.s1187 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1186).run PRE_first_tail_x15_r0_body.S1186 = some (PRE_first_tail_x15_r0_body.s1187, PRE_first_tail_x15_r0_body.S1187)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA321 from PRE_first_tail_x15_r0_body.s1188 to PRE_first_tail_x15_r0_body.s1189 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1188).run PRE_first_tail_x15_r0_body.S1188 = some (PRE_first_tail_x15_r0_body.s1189, PRE_first_tail_x15_r0_body.S1189)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB321 from PRE_first_tail_x15_r0_body.s1189 to PRE_first_tail_x15_r0_body.s1190 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1189).run PRE_first_tail_x15_r0_body.S1189 = some (PRE_first_tail_x15_r0_body.s1190, PRE_first_tail_x15_r0_body.S1190)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA322 from PRE_first_tail_x15_r0_body.s1191 to PRE_first_tail_x15_r0_body.s1192 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1191).run PRE_first_tail_x15_r0_body.S1191 = some (PRE_first_tail_x15_r0_body.s1192, PRE_first_tail_x15_r0_body.S1192)
end Host.Load.Run.Tpl
