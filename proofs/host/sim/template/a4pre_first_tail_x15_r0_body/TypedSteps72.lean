import host.sim.template.a4pre_first_tail_x15_r0_body.H37
import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA358 from PRE_first_tail_x15_r0_body.s1210 to PRE_first_tail_x15_r0_body.s1211 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1210).run PRE_first_tail_x15_r0_body.S1210 = some (PRE_first_tail_x15_r0_body.s1211, PRE_first_tail_x15_r0_body.S1211)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB358 from PRE_first_tail_x15_r0_body.s1211 to PRE_first_tail_x15_r0_body.s1212 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1211).run PRE_first_tail_x15_r0_body.S1211 = some (PRE_first_tail_x15_r0_body.s1212, PRE_first_tail_x15_r0_body.S1212)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA359 from PRE_first_tail_x15_r0_body.s1213 to PRE_first_tail_x15_r0_body.s1214 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1213).run PRE_first_tail_x15_r0_body.S1213 = some (PRE_first_tail_x15_r0_body.s1214, PRE_first_tail_x15_r0_body.S1214)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB359 from PRE_first_tail_x15_r0_body.s1214 to PRE_first_tail_x15_r0_body.s1215 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1214).run PRE_first_tail_x15_r0_body.S1214 = some (PRE_first_tail_x15_r0_body.s1215, PRE_first_tail_x15_r0_body.S1215)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA360 from PRE_first_tail_x15_r0_body.s1216 to PRE_first_tail_x15_r0_body.s1217 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1216).run PRE_first_tail_x15_r0_body.S1216 = some (PRE_first_tail_x15_r0_body.s1217, PRE_first_tail_x15_r0_body.S1217)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB360 from PRE_first_tail_x15_r0_body.s1217 to PRE_first_tail_x15_r0_body.s1218 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1217).run PRE_first_tail_x15_r0_body.S1217 = some (PRE_first_tail_x15_r0_body.s1218, PRE_first_tail_x15_r0_body.S1218)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA361 from PRE_first_tail_x15_r0_body.s1219 to PRE_first_tail_x15_r0_body.s1220 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1219).run PRE_first_tail_x15_r0_body.S1219 = some (PRE_first_tail_x15_r0_body.s1220, PRE_first_tail_x15_r0_body.S1220)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB361 from PRE_first_tail_x15_r0_body.s1220 to PRE_first_tail_x15_r0_body.s1221 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1220).run PRE_first_tail_x15_r0_body.S1220 = some (PRE_first_tail_x15_r0_body.s1221, PRE_first_tail_x15_r0_body.S1221)
end Host.Load.Run.Tpl
