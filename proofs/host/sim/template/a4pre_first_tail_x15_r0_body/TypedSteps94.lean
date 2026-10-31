import host.sim.template.a4pre_first_tail_x15_r0_body.H54
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA467 from PRE_first_tail_x15_r0_body.s1731 to PRE_first_tail_x15_r0_body.s1732 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1731).run PRE_first_tail_x15_r0_body.S1731 = some (PRE_first_tail_x15_r0_body.s1732, PRE_first_tail_x15_r0_body.S1732)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB467 from PRE_first_tail_x15_r0_body.s1732 to PRE_first_tail_x15_r0_body.s1733 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1732).run PRE_first_tail_x15_r0_body.S1732 = some (PRE_first_tail_x15_r0_body.s1733, PRE_first_tail_x15_r0_body.S1733)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA468 from PRE_first_tail_x15_r0_body.s1734 to PRE_first_tail_x15_r0_body.s1735 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1734).run PRE_first_tail_x15_r0_body.S1734 = some (PRE_first_tail_x15_r0_body.s1735, PRE_first_tail_x15_r0_body.S1735)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB468 from PRE_first_tail_x15_r0_body.s1735 to PRE_first_tail_x15_r0_body.s1736 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1735).run PRE_first_tail_x15_r0_body.S1735 = some (PRE_first_tail_x15_r0_body.s1736, PRE_first_tail_x15_r0_body.S1736)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA469 from PRE_first_tail_x15_r0_body.s1737 to PRE_first_tail_x15_r0_body.s1738 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1737).run PRE_first_tail_x15_r0_body.S1737 = some (PRE_first_tail_x15_r0_body.s1738, PRE_first_tail_x15_r0_body.S1738)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB469 from PRE_first_tail_x15_r0_body.s1738 to PRE_first_tail_x15_r0_body.s1739 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1738).run PRE_first_tail_x15_r0_body.S1738 = some (PRE_first_tail_x15_r0_body.s1739, PRE_first_tail_x15_r0_body.S1739)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA470 from PRE_first_tail_x15_r0_body.s1740 to PRE_first_tail_x15_r0_body.s1741 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1740).run PRE_first_tail_x15_r0_body.S1740 = some (PRE_first_tail_x15_r0_body.s1741, PRE_first_tail_x15_r0_body.S1741)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA471 from PRE_first_tail_x15_r0_body.s1744 to PRE_first_tail_x15_r0_body.s1745 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1744).run PRE_first_tail_x15_r0_body.S1744 = some (PRE_first_tail_x15_r0_body.s1745, PRE_first_tail_x15_r0_body.S1745)
end Host.Load.Run.Tpl
