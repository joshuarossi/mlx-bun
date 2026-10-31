import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.a4pre_first_tail_x15_r0_body.H42
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA362 from PRE_first_tail_x15_r0_body.s1338 to PRE_first_tail_x15_r0_body.s1339 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1338).run PRE_first_tail_x15_r0_body.S1338 = some (PRE_first_tail_x15_r0_body.s1339, PRE_first_tail_x15_r0_body.S1339)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA363 from PRE_first_tail_x15_r0_body.s1342 to PRE_first_tail_x15_r0_body.s1343 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1342).run PRE_first_tail_x15_r0_body.S1342 = some (PRE_first_tail_x15_r0_body.s1343, PRE_first_tail_x15_r0_body.S1343)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB363 from PRE_first_tail_x15_r0_body.s1343 to PRE_first_tail_x15_r0_body.s1344 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1343).run PRE_first_tail_x15_r0_body.S1343 = some (PRE_first_tail_x15_r0_body.s1344, PRE_first_tail_x15_r0_body.S1344)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA364 from PRE_first_tail_x15_r0_body.s1346 to PRE_first_tail_x15_r0_body.s1347 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1346).run PRE_first_tail_x15_r0_body.S1346 = some (PRE_first_tail_x15_r0_body.s1347, PRE_first_tail_x15_r0_body.S1347)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA365 from PRE_first_tail_x15_r0_body.s1350 to PRE_first_tail_x15_r0_body.s1351 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1350).run PRE_first_tail_x15_r0_body.S1350 = some (PRE_first_tail_x15_r0_body.s1351, PRE_first_tail_x15_r0_body.S1351)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA366 from PRE_first_tail_x15_r0_body.s1355 to PRE_first_tail_x15_r0_body.s1356 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1355).run PRE_first_tail_x15_r0_body.S1355 = some (PRE_first_tail_x15_r0_body.s1356, PRE_first_tail_x15_r0_body.S1356)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB366 from PRE_first_tail_x15_r0_body.s1356 to PRE_first_tail_x15_r0_body.s1357 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1356).run PRE_first_tail_x15_r0_body.S1356 = some (PRE_first_tail_x15_r0_body.s1357, PRE_first_tail_x15_r0_body.S1357)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA367 from PRE_first_tail_x15_r0_body.s1359 to PRE_first_tail_x15_r0_body.s1360 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1359).run PRE_first_tail_x15_r0_body.S1359 = some (PRE_first_tail_x15_r0_body.s1360, PRE_first_tail_x15_r0_body.S1360)
end Host.Load.Run.Tpl
