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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA482 from PRE_first_tail_x15_r0_body.s1630 to PRE_first_tail_x15_r0_body.s1631 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1630).run PRE_first_tail_x15_r0_body.S1630 = some (PRE_first_tail_x15_r0_body.s1631, PRE_first_tail_x15_r0_body.S1631)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB482 from PRE_first_tail_x15_r0_body.s1631 to PRE_first_tail_x15_r0_body.s1632 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1631).run PRE_first_tail_x15_r0_body.S1631 = some (PRE_first_tail_x15_r0_body.s1632, PRE_first_tail_x15_r0_body.S1632)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA483 from PRE_first_tail_x15_r0_body.s1633 to PRE_first_tail_x15_r0_body.s1634 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1633).run PRE_first_tail_x15_r0_body.S1633 = some (PRE_first_tail_x15_r0_body.s1634, PRE_first_tail_x15_r0_body.S1634)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB483 from PRE_first_tail_x15_r0_body.s1634 to PRE_first_tail_x15_r0_body.s1635 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1634).run PRE_first_tail_x15_r0_body.S1634 = some (PRE_first_tail_x15_r0_body.s1635, PRE_first_tail_x15_r0_body.S1635)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA484 from PRE_first_tail_x15_r0_body.s1636 to PRE_first_tail_x15_r0_body.s1637 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1636).run PRE_first_tail_x15_r0_body.S1636 = some (PRE_first_tail_x15_r0_body.s1637, PRE_first_tail_x15_r0_body.S1637)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB484 from PRE_first_tail_x15_r0_body.s1637 to PRE_first_tail_x15_r0_body.s1638 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1637).run PRE_first_tail_x15_r0_body.S1637 = some (PRE_first_tail_x15_r0_body.s1638, PRE_first_tail_x15_r0_body.S1638)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA485 from PRE_first_tail_x15_r0_body.s1639 to PRE_first_tail_x15_r0_body.s1640 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1639).run PRE_first_tail_x15_r0_body.S1639 = some (PRE_first_tail_x15_r0_body.s1640, PRE_first_tail_x15_r0_body.S1640)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB485 from PRE_first_tail_x15_r0_body.s1640 to PRE_first_tail_x15_r0_body.s1641 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1640).run PRE_first_tail_x15_r0_body.S1640 = some (PRE_first_tail_x15_r0_body.s1641, PRE_first_tail_x15_r0_body.S1641)
end Host.Load.Run.Tpl
