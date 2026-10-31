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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA328 from PRE_first_tail_x15_r0_body.s1214 to PRE_first_tail_x15_r0_body.s1215 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1214).run PRE_first_tail_x15_r0_body.S1214 = some (PRE_first_tail_x15_r0_body.s1215, PRE_first_tail_x15_r0_body.S1215)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB328 from PRE_first_tail_x15_r0_body.s1215 to PRE_first_tail_x15_r0_body.s1216 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1215).run PRE_first_tail_x15_r0_body.S1215 = some (PRE_first_tail_x15_r0_body.s1216, PRE_first_tail_x15_r0_body.S1216)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA329 from PRE_first_tail_x15_r0_body.s1217 to PRE_first_tail_x15_r0_body.s1218 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1217).run PRE_first_tail_x15_r0_body.S1217 = some (PRE_first_tail_x15_r0_body.s1218, PRE_first_tail_x15_r0_body.S1218)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB329 from PRE_first_tail_x15_r0_body.s1218 to PRE_first_tail_x15_r0_body.s1219 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1218).run PRE_first_tail_x15_r0_body.S1218 = some (PRE_first_tail_x15_r0_body.s1219, PRE_first_tail_x15_r0_body.S1219)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA330 from PRE_first_tail_x15_r0_body.s1220 to PRE_first_tail_x15_r0_body.s1221 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1220).run PRE_first_tail_x15_r0_body.S1220 = some (PRE_first_tail_x15_r0_body.s1221, PRE_first_tail_x15_r0_body.S1221)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB330 from PRE_first_tail_x15_r0_body.s1221 to PRE_first_tail_x15_r0_body.s1222 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1221).run PRE_first_tail_x15_r0_body.S1221 = some (PRE_first_tail_x15_r0_body.s1222, PRE_first_tail_x15_r0_body.S1222)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA331 from PRE_first_tail_x15_r0_body.s1223 to PRE_first_tail_x15_r0_body.s1224 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1223).run PRE_first_tail_x15_r0_body.S1223 = some (PRE_first_tail_x15_r0_body.s1224, PRE_first_tail_x15_r0_body.S1224)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA332 from PRE_first_tail_x15_r0_body.s1227 to PRE_first_tail_x15_r0_body.s1228 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1227).run PRE_first_tail_x15_r0_body.S1227 = some (PRE_first_tail_x15_r0_body.s1228, PRE_first_tail_x15_r0_body.S1228)
end Host.Load.Run.Tpl
