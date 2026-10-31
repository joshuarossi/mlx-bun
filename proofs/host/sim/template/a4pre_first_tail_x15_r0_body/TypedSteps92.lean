import host.sim.template.a4pre_first_tail_x15_r0_body.H52
import host.sim.template.a4pre_first_tail_x15_r0_body.H53
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB456 from PRE_first_tail_x15_r0_body.s1688 to PRE_first_tail_x15_r0_body.s1689 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1688).run PRE_first_tail_x15_r0_body.S1688 = some (PRE_first_tail_x15_r0_body.s1689, PRE_first_tail_x15_r0_body.S1689)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA457 from PRE_first_tail_x15_r0_body.s1691 to PRE_first_tail_x15_r0_body.s1692 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1691).run PRE_first_tail_x15_r0_body.S1691 = some (PRE_first_tail_x15_r0_body.s1692, PRE_first_tail_x15_r0_body.S1692)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA458 from PRE_first_tail_x15_r0_body.s1695 to PRE_first_tail_x15_r0_body.s1696 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1695).run PRE_first_tail_x15_r0_body.S1695 = some (PRE_first_tail_x15_r0_body.s1696, PRE_first_tail_x15_r0_body.S1696)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA459 from PRE_first_tail_x15_r0_body.s1700 to PRE_first_tail_x15_r0_body.s1701 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1700).run PRE_first_tail_x15_r0_body.S1700 = some (PRE_first_tail_x15_r0_body.s1701, PRE_first_tail_x15_r0_body.S1701)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB459 from PRE_first_tail_x15_r0_body.s1701 to PRE_first_tail_x15_r0_body.s1702 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1701).run PRE_first_tail_x15_r0_body.S1701 = some (PRE_first_tail_x15_r0_body.s1702, PRE_first_tail_x15_r0_body.S1702)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA460 from PRE_first_tail_x15_r0_body.s1704 to PRE_first_tail_x15_r0_body.s1705 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1704).run PRE_first_tail_x15_r0_body.S1704 = some (PRE_first_tail_x15_r0_body.s1705, PRE_first_tail_x15_r0_body.S1705)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB460 from PRE_first_tail_x15_r0_body.s1705 to PRE_first_tail_x15_r0_body.s1706 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1705).run PRE_first_tail_x15_r0_body.S1705 = some (PRE_first_tail_x15_r0_body.s1706, PRE_first_tail_x15_r0_body.S1706)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA461 from PRE_first_tail_x15_r0_body.s1707 to PRE_first_tail_x15_r0_body.s1708 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1707).run PRE_first_tail_x15_r0_body.S1707 = some (PRE_first_tail_x15_r0_body.s1708, PRE_first_tail_x15_r0_body.S1708)
end Host.Load.Run.Tpl
