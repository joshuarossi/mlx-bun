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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA432 from PRE_first_tail_x15_r0_body.s1460 to PRE_first_tail_x15_r0_body.s1461 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1460).run PRE_first_tail_x15_r0_body.S1460 = some (PRE_first_tail_x15_r0_body.s1461, PRE_first_tail_x15_r0_body.S1461)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB432 from PRE_first_tail_x15_r0_body.s1461 to PRE_first_tail_x15_r0_body.s1462 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1461).run PRE_first_tail_x15_r0_body.S1461 = some (PRE_first_tail_x15_r0_body.s1462, PRE_first_tail_x15_r0_body.S1462)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA433 from PRE_first_tail_x15_r0_body.s1463 to PRE_first_tail_x15_r0_body.s1464 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1463).run PRE_first_tail_x15_r0_body.S1463 = some (PRE_first_tail_x15_r0_body.s1464, PRE_first_tail_x15_r0_body.S1464)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA434 from PRE_first_tail_x15_r0_body.s1467 to PRE_first_tail_x15_r0_body.s1468 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1467).run PRE_first_tail_x15_r0_body.S1467 = some (PRE_first_tail_x15_r0_body.s1468, PRE_first_tail_x15_r0_body.S1468)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA435 from PRE_first_tail_x15_r0_body.s1471 to PRE_first_tail_x15_r0_body.s1472 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1471).run PRE_first_tail_x15_r0_body.S1471 = some (PRE_first_tail_x15_r0_body.s1472, PRE_first_tail_x15_r0_body.S1472)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB435 from PRE_first_tail_x15_r0_body.s1472 to PRE_first_tail_x15_r0_body.s1473 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1472).run PRE_first_tail_x15_r0_body.S1472 = some (PRE_first_tail_x15_r0_body.s1473, PRE_first_tail_x15_r0_body.S1473)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA436 from PRE_first_tail_x15_r0_body.s1474 to PRE_first_tail_x15_r0_body.s1475 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1474).run PRE_first_tail_x15_r0_body.S1474 = some (PRE_first_tail_x15_r0_body.s1475, PRE_first_tail_x15_r0_body.S1475)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB436 from PRE_first_tail_x15_r0_body.s1475 to PRE_first_tail_x15_r0_body.s1476 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1475).run PRE_first_tail_x15_r0_body.S1475 = some (PRE_first_tail_x15_r0_body.s1476, PRE_first_tail_x15_r0_body.S1476)
end Host.Load.Run.Tpl
