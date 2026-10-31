import host.sim.template.a4pre_first_tail_x15_r0_body.H44
import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA422 from PRE_first_tail_x15_r0_body.s1426 to PRE_first_tail_x15_r0_body.s1427 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1426).run PRE_first_tail_x15_r0_body.S1426 = some (PRE_first_tail_x15_r0_body.s1427, PRE_first_tail_x15_r0_body.S1427)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB422 from PRE_first_tail_x15_r0_body.s1427 to PRE_first_tail_x15_r0_body.s1428 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1427).run PRE_first_tail_x15_r0_body.S1427 = some (PRE_first_tail_x15_r0_body.s1428, PRE_first_tail_x15_r0_body.S1428)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA423 from PRE_first_tail_x15_r0_body.s1429 to PRE_first_tail_x15_r0_body.s1430 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1429).run PRE_first_tail_x15_r0_body.S1429 = some (PRE_first_tail_x15_r0_body.s1430, PRE_first_tail_x15_r0_body.S1430)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB423 from PRE_first_tail_x15_r0_body.s1430 to PRE_first_tail_x15_r0_body.s1431 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1430).run PRE_first_tail_x15_r0_body.S1430 = some (PRE_first_tail_x15_r0_body.s1431, PRE_first_tail_x15_r0_body.S1431)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA424 from PRE_first_tail_x15_r0_body.s1432 to PRE_first_tail_x15_r0_body.s1433 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1432).run PRE_first_tail_x15_r0_body.S1432 = some (PRE_first_tail_x15_r0_body.s1433, PRE_first_tail_x15_r0_body.S1433)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA425 from PRE_first_tail_x15_r0_body.s1436 to PRE_first_tail_x15_r0_body.s1437 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1436).run PRE_first_tail_x15_r0_body.S1436 = some (PRE_first_tail_x15_r0_body.s1437, PRE_first_tail_x15_r0_body.S1437)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB425 from PRE_first_tail_x15_r0_body.s1437 to PRE_first_tail_x15_r0_body.s1438 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1437).run PRE_first_tail_x15_r0_body.S1437 = some (PRE_first_tail_x15_r0_body.s1438, PRE_first_tail_x15_r0_body.S1438)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA426 from PRE_first_tail_x15_r0_body.s1439 to PRE_first_tail_x15_r0_body.s1440 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1439).run PRE_first_tail_x15_r0_body.S1439 = some (PRE_first_tail_x15_r0_body.s1440, PRE_first_tail_x15_r0_body.S1440)
end Host.Load.Run.Tpl
