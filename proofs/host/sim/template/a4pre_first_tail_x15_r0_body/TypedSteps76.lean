import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.a4pre_first_tail_x15_r0_body.H40
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA377 from PRE_first_tail_x15_r0_body.s1273 to PRE_first_tail_x15_r0_body.s1274 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1273).run PRE_first_tail_x15_r0_body.S1273 = some (PRE_first_tail_x15_r0_body.s1274, PRE_first_tail_x15_r0_body.S1274)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA378 from PRE_first_tail_x15_r0_body.s1277 to PRE_first_tail_x15_r0_body.s1278 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1277).run PRE_first_tail_x15_r0_body.S1277 = some (PRE_first_tail_x15_r0_body.s1278, PRE_first_tail_x15_r0_body.S1278)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB378 from PRE_first_tail_x15_r0_body.s1278 to PRE_first_tail_x15_r0_body.s1279 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1278).run PRE_first_tail_x15_r0_body.S1278 = some (PRE_first_tail_x15_r0_body.s1279, PRE_first_tail_x15_r0_body.S1279)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA379 from PRE_first_tail_x15_r0_body.s1280 to PRE_first_tail_x15_r0_body.s1281 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1280).run PRE_first_tail_x15_r0_body.S1280 = some (PRE_first_tail_x15_r0_body.s1281, PRE_first_tail_x15_r0_body.S1281)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA380 from PRE_first_tail_x15_r0_body.s1284 to PRE_first_tail_x15_r0_body.s1285 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1284).run PRE_first_tail_x15_r0_body.S1284 = some (PRE_first_tail_x15_r0_body.s1285, PRE_first_tail_x15_r0_body.S1285)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA381 from PRE_first_tail_x15_r0_body.s1288 to PRE_first_tail_x15_r0_body.s1289 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1288).run PRE_first_tail_x15_r0_body.S1288 = some (PRE_first_tail_x15_r0_body.s1289, PRE_first_tail_x15_r0_body.S1289)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB381 from PRE_first_tail_x15_r0_body.s1289 to PRE_first_tail_x15_r0_body.s1290 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1289).run PRE_first_tail_x15_r0_body.S1289 = some (PRE_first_tail_x15_r0_body.s1290, PRE_first_tail_x15_r0_body.S1290)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA382 from PRE_first_tail_x15_r0_body.s1291 to PRE_first_tail_x15_r0_body.s1292 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1291).run PRE_first_tail_x15_r0_body.S1291 = some (PRE_first_tail_x15_r0_body.s1292, PRE_first_tail_x15_r0_body.S1292)
end Host.Load.Run.Tpl
