import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA417 from PRE_first_tail_x15_r0_body.s1543 to PRE_first_tail_x15_r0_body.s1544 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1543).run PRE_first_tail_x15_r0_body.S1543 = some (PRE_first_tail_x15_r0_body.s1544, PRE_first_tail_x15_r0_body.S1544)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB417 from PRE_first_tail_x15_r0_body.s1544 to PRE_first_tail_x15_r0_body.s1545 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1544).run PRE_first_tail_x15_r0_body.S1544 = some (PRE_first_tail_x15_r0_body.s1545, PRE_first_tail_x15_r0_body.S1545)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA418 from PRE_first_tail_x15_r0_body.s1547 to PRE_first_tail_x15_r0_body.s1548 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1547).run PRE_first_tail_x15_r0_body.S1547 = some (PRE_first_tail_x15_r0_body.s1548, PRE_first_tail_x15_r0_body.S1548)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA419 from PRE_first_tail_x15_r0_body.s1551 to PRE_first_tail_x15_r0_body.s1552 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1551).run PRE_first_tail_x15_r0_body.S1551 = some (PRE_first_tail_x15_r0_body.s1552, PRE_first_tail_x15_r0_body.S1552)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA420 from PRE_first_tail_x15_r0_body.s1556 to PRE_first_tail_x15_r0_body.s1557 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1556).run PRE_first_tail_x15_r0_body.S1556 = some (PRE_first_tail_x15_r0_body.s1557, PRE_first_tail_x15_r0_body.S1557)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB420 from PRE_first_tail_x15_r0_body.s1557 to PRE_first_tail_x15_r0_body.s1558 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1557).run PRE_first_tail_x15_r0_body.S1557 = some (PRE_first_tail_x15_r0_body.s1558, PRE_first_tail_x15_r0_body.S1558)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA421 from PRE_first_tail_x15_r0_body.s1559 to PRE_first_tail_x15_r0_body.s1560 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1559).run PRE_first_tail_x15_r0_body.S1559 = some (PRE_first_tail_x15_r0_body.s1560, PRE_first_tail_x15_r0_body.S1560)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB421 from PRE_first_tail_x15_r0_body.s1560 to PRE_first_tail_x15_r0_body.s1561 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1560).run PRE_first_tail_x15_r0_body.S1560 = some (PRE_first_tail_x15_r0_body.s1561, PRE_first_tail_x15_r0_body.S1561)
end Host.Load.Run.Tpl
