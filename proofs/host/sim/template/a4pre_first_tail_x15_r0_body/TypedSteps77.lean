import host.sim.template.a4pre_first_tail_x15_r0_body.H40
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB382 from PRE_first_tail_x15_r0_body.s1292 to PRE_first_tail_x15_r0_body.s1293 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1292).run PRE_first_tail_x15_r0_body.S1292 = some (PRE_first_tail_x15_r0_body.s1293, PRE_first_tail_x15_r0_body.S1293)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA383 from PRE_first_tail_x15_r0_body.s1294 to PRE_first_tail_x15_r0_body.s1295 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1294).run PRE_first_tail_x15_r0_body.S1294 = some (PRE_first_tail_x15_r0_body.s1295, PRE_first_tail_x15_r0_body.S1295)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB383 from PRE_first_tail_x15_r0_body.s1295 to PRE_first_tail_x15_r0_body.s1296 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1295).run PRE_first_tail_x15_r0_body.S1295 = some (PRE_first_tail_x15_r0_body.s1296, PRE_first_tail_x15_r0_body.S1296)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA384 from PRE_first_tail_x15_r0_body.s1297 to PRE_first_tail_x15_r0_body.s1298 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1297).run PRE_first_tail_x15_r0_body.S1297 = some (PRE_first_tail_x15_r0_body.s1298, PRE_first_tail_x15_r0_body.S1298)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB384 from PRE_first_tail_x15_r0_body.s1298 to PRE_first_tail_x15_r0_body.s1299 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1298).run PRE_first_tail_x15_r0_body.S1298 = some (PRE_first_tail_x15_r0_body.s1299, PRE_first_tail_x15_r0_body.S1299)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA385 from PRE_first_tail_x15_r0_body.s1300 to PRE_first_tail_x15_r0_body.s1301 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1300).run PRE_first_tail_x15_r0_body.S1300 = some (PRE_first_tail_x15_r0_body.s1301, PRE_first_tail_x15_r0_body.S1301)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA386 from PRE_first_tail_x15_r0_body.s1304 to PRE_first_tail_x15_r0_body.s1305 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1304).run PRE_first_tail_x15_r0_body.S1304 = some (PRE_first_tail_x15_r0_body.s1305, PRE_first_tail_x15_r0_body.S1305)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB386 from PRE_first_tail_x15_r0_body.s1305 to PRE_first_tail_x15_r0_body.s1306 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1305).run PRE_first_tail_x15_r0_body.S1305 = some (PRE_first_tail_x15_r0_body.s1306, PRE_first_tail_x15_r0_body.S1306)
end Host.Load.Run.Tpl
