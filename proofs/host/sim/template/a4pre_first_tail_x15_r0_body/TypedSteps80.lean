import host.sim.template.a4pre_first_tail_x15_r0_body.H45
import host.sim.template.a4pre_first_tail_x15_r0_body.H46
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB397 from PRE_first_tail_x15_r0_body.s1471 to PRE_first_tail_x15_r0_body.s1472 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1471).run PRE_first_tail_x15_r0_body.S1471 = some (PRE_first_tail_x15_r0_body.s1472, PRE_first_tail_x15_r0_body.S1472)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA398 from PRE_first_tail_x15_r0_body.s1474 to PRE_first_tail_x15_r0_body.s1475 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1474).run PRE_first_tail_x15_r0_body.S1474 = some (PRE_first_tail_x15_r0_body.s1475, PRE_first_tail_x15_r0_body.S1475)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB398 from PRE_first_tail_x15_r0_body.s1475 to PRE_first_tail_x15_r0_body.s1476 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1475).run PRE_first_tail_x15_r0_body.S1475 = some (PRE_first_tail_x15_r0_body.s1476, PRE_first_tail_x15_r0_body.S1476)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA399 from PRE_first_tail_x15_r0_body.s1477 to PRE_first_tail_x15_r0_body.s1478 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1477).run PRE_first_tail_x15_r0_body.S1477 = some (PRE_first_tail_x15_r0_body.s1478, PRE_first_tail_x15_r0_body.S1478)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB399 from PRE_first_tail_x15_r0_body.s1478 to PRE_first_tail_x15_r0_body.s1479 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1478).run PRE_first_tail_x15_r0_body.S1478 = some (PRE_first_tail_x15_r0_body.s1479, PRE_first_tail_x15_r0_body.S1479)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA400 from PRE_first_tail_x15_r0_body.s1481 to PRE_first_tail_x15_r0_body.s1482 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1481).run PRE_first_tail_x15_r0_body.S1481 = some (PRE_first_tail_x15_r0_body.s1482, PRE_first_tail_x15_r0_body.S1482)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA401 from PRE_first_tail_x15_r0_body.s1485 to PRE_first_tail_x15_r0_body.s1486 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1485).run PRE_first_tail_x15_r0_body.S1485 = some (PRE_first_tail_x15_r0_body.s1486, PRE_first_tail_x15_r0_body.S1486)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB401 from PRE_first_tail_x15_r0_body.s1486 to PRE_first_tail_x15_r0_body.s1487 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1486).run PRE_first_tail_x15_r0_body.S1486 = some (PRE_first_tail_x15_r0_body.s1487, PRE_first_tail_x15_r0_body.S1487)
end Host.Load.Run.Tpl
