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
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB397 from PRE_first_tail_x15_r0_body.s1343 to PRE_first_tail_x15_r0_body.s1344 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1343).run PRE_first_tail_x15_r0_body.S1343 = some (PRE_first_tail_x15_r0_body.s1344, PRE_first_tail_x15_r0_body.S1344)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA398 from PRE_first_tail_x15_r0_body.s1345 to PRE_first_tail_x15_r0_body.s1346 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1345).run PRE_first_tail_x15_r0_body.S1345 = some (PRE_first_tail_x15_r0_body.s1346, PRE_first_tail_x15_r0_body.S1346)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB398 from PRE_first_tail_x15_r0_body.s1346 to PRE_first_tail_x15_r0_body.s1347 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1346).run PRE_first_tail_x15_r0_body.S1346 = some (PRE_first_tail_x15_r0_body.s1347, PRE_first_tail_x15_r0_body.S1347)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA399 from PRE_first_tail_x15_r0_body.s1348 to PRE_first_tail_x15_r0_body.s1349 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1348).run PRE_first_tail_x15_r0_body.S1348 = some (PRE_first_tail_x15_r0_body.s1349, PRE_first_tail_x15_r0_body.S1349)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB399 from PRE_first_tail_x15_r0_body.s1349 to PRE_first_tail_x15_r0_body.s1350 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1349).run PRE_first_tail_x15_r0_body.S1349 = some (PRE_first_tail_x15_r0_body.s1350, PRE_first_tail_x15_r0_body.S1350)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA400 from PRE_first_tail_x15_r0_body.s1351 to PRE_first_tail_x15_r0_body.s1352 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1351).run PRE_first_tail_x15_r0_body.S1351 = some (PRE_first_tail_x15_r0_body.s1352, PRE_first_tail_x15_r0_body.S1352)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA401 from PRE_first_tail_x15_r0_body.s1355 to PRE_first_tail_x15_r0_body.s1356 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1355).run PRE_first_tail_x15_r0_body.S1355 = some (PRE_first_tail_x15_r0_body.s1356, PRE_first_tail_x15_r0_body.S1356)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB401 from PRE_first_tail_x15_r0_body.s1356 to PRE_first_tail_x15_r0_body.s1357 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1356).run PRE_first_tail_x15_r0_body.S1356 = some (PRE_first_tail_x15_r0_body.s1357, PRE_first_tail_x15_r0_body.S1357)
end Host.Load.Run.Tpl
