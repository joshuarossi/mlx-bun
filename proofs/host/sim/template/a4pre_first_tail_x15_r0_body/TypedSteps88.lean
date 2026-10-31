import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.a4pre_first_tail_x15_r0_body.H51
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA437 from PRE_first_tail_x15_r0_body.s1619 to PRE_first_tail_x15_r0_body.s1620 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1619).run PRE_first_tail_x15_r0_body.S1619 = some (PRE_first_tail_x15_r0_body.s1620, PRE_first_tail_x15_r0_body.S1620)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB437 from PRE_first_tail_x15_r0_body.s1620 to PRE_first_tail_x15_r0_body.s1621 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1620).run PRE_first_tail_x15_r0_body.S1620 = some (PRE_first_tail_x15_r0_body.s1621, PRE_first_tail_x15_r0_body.S1621)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA438 from PRE_first_tail_x15_r0_body.s1622 to PRE_first_tail_x15_r0_body.s1623 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1622).run PRE_first_tail_x15_r0_body.S1622 = some (PRE_first_tail_x15_r0_body.s1623, PRE_first_tail_x15_r0_body.S1623)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB438 from PRE_first_tail_x15_r0_body.s1623 to PRE_first_tail_x15_r0_body.s1624 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1623).run PRE_first_tail_x15_r0_body.S1623 = some (PRE_first_tail_x15_r0_body.s1624, PRE_first_tail_x15_r0_body.S1624)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA439 from PRE_first_tail_x15_r0_body.s1625 to PRE_first_tail_x15_r0_body.s1626 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1625).run PRE_first_tail_x15_r0_body.S1625 = some (PRE_first_tail_x15_r0_body.s1626, PRE_first_tail_x15_r0_body.S1626)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA440 from PRE_first_tail_x15_r0_body.s1629 to PRE_first_tail_x15_r0_body.s1630 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1629).run PRE_first_tail_x15_r0_body.S1629 = some (PRE_first_tail_x15_r0_body.s1630, PRE_first_tail_x15_r0_body.S1630)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB440 from PRE_first_tail_x15_r0_body.s1630 to PRE_first_tail_x15_r0_body.s1631 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1630).run PRE_first_tail_x15_r0_body.S1630 = some (PRE_first_tail_x15_r0_body.s1631, PRE_first_tail_x15_r0_body.S1631)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA441 from PRE_first_tail_x15_r0_body.s1633 to PRE_first_tail_x15_r0_body.s1634 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1633).run PRE_first_tail_x15_r0_body.S1633 = some (PRE_first_tail_x15_r0_body.s1634, PRE_first_tail_x15_r0_body.S1634)
end Host.Load.Run.Tpl
