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
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB347 from PRE_first_tail_x15_r0_body.s1173 to PRE_first_tail_x15_r0_body.s1174 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1173).run PRE_first_tail_x15_r0_body.S1173 = some (PRE_first_tail_x15_r0_body.s1174, PRE_first_tail_x15_r0_body.S1174)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA348 from PRE_first_tail_x15_r0_body.s1175 to PRE_first_tail_x15_r0_body.s1176 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1175).run PRE_first_tail_x15_r0_body.S1175 = some (PRE_first_tail_x15_r0_body.s1176, PRE_first_tail_x15_r0_body.S1176)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA349 from PRE_first_tail_x15_r0_body.s1179 to PRE_first_tail_x15_r0_body.s1180 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1179).run PRE_first_tail_x15_r0_body.S1179 = some (PRE_first_tail_x15_r0_body.s1180, PRE_first_tail_x15_r0_body.S1180)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA350 from PRE_first_tail_x15_r0_body.s1183 to PRE_first_tail_x15_r0_body.s1184 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1183).run PRE_first_tail_x15_r0_body.S1183 = some (PRE_first_tail_x15_r0_body.s1184, PRE_first_tail_x15_r0_body.S1184)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB350 from PRE_first_tail_x15_r0_body.s1184 to PRE_first_tail_x15_r0_body.s1185 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1184).run PRE_first_tail_x15_r0_body.S1184 = some (PRE_first_tail_x15_r0_body.s1185, PRE_first_tail_x15_r0_body.S1185)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA351 from PRE_first_tail_x15_r0_body.s1186 to PRE_first_tail_x15_r0_body.s1187 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1186).run PRE_first_tail_x15_r0_body.S1186 = some (PRE_first_tail_x15_r0_body.s1187, PRE_first_tail_x15_r0_body.S1187)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB351 from PRE_first_tail_x15_r0_body.s1187 to PRE_first_tail_x15_r0_body.s1188 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1187).run PRE_first_tail_x15_r0_body.S1187 = some (PRE_first_tail_x15_r0_body.s1188, PRE_first_tail_x15_r0_body.S1188)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA352 from PRE_first_tail_x15_r0_body.s1189 to PRE_first_tail_x15_r0_body.s1190 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1189).run PRE_first_tail_x15_r0_body.S1189 = some (PRE_first_tail_x15_r0_body.s1190, PRE_first_tail_x15_r0_body.S1190)
end Host.Load.Run.Tpl
