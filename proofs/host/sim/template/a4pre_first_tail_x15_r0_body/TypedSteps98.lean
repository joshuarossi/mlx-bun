import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA486 from PRE_first_tail_x15_r0_body.s1798 to PRE_first_tail_x15_r0_body.s1799 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1798).run PRE_first_tail_x15_r0_body.S1798 = some (PRE_first_tail_x15_r0_body.s1799, PRE_first_tail_x15_r0_body.S1799)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA487 from PRE_first_tail_x15_r0_body.s1802 to PRE_first_tail_x15_r0_body.s1803 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1802).run PRE_first_tail_x15_r0_body.S1802 = some (PRE_first_tail_x15_r0_body.s1803, PRE_first_tail_x15_r0_body.S1803)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB487 from PRE_first_tail_x15_r0_body.s1803 to PRE_first_tail_x15_r0_body.s1804 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1803).run PRE_first_tail_x15_r0_body.S1803 = some (PRE_first_tail_x15_r0_body.s1804, PRE_first_tail_x15_r0_body.S1804)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA488 from PRE_first_tail_x15_r0_body.s1806 to PRE_first_tail_x15_r0_body.s1807 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1806).run PRE_first_tail_x15_r0_body.S1806 = some (PRE_first_tail_x15_r0_body.s1807, PRE_first_tail_x15_r0_body.S1807)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA489 from PRE_first_tail_x15_r0_body.s1810 to PRE_first_tail_x15_r0_body.s1811 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1810).run PRE_first_tail_x15_r0_body.S1810 = some (PRE_first_tail_x15_r0_body.s1811, PRE_first_tail_x15_r0_body.S1811)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA490 from PRE_first_tail_x15_r0_body.s1815 to PRE_first_tail_x15_r0_body.s1816 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1815).run PRE_first_tail_x15_r0_body.S1815 = some (PRE_first_tail_x15_r0_body.s1816, PRE_first_tail_x15_r0_body.S1816)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB490 from PRE_first_tail_x15_r0_body.s1816 to PRE_first_tail_x15_r0_body.s1817 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1816).run PRE_first_tail_x15_r0_body.S1816 = some (PRE_first_tail_x15_r0_body.s1817, PRE_first_tail_x15_r0_body.S1817)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA491 from PRE_first_tail_x15_r0_body.s1819 to PRE_first_tail_x15_r0_body.s1820 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1819).run PRE_first_tail_x15_r0_body.S1819 = some (PRE_first_tail_x15_r0_body.s1820, PRE_first_tail_x15_r0_body.S1820)
end Host.Load.Run.Tpl
