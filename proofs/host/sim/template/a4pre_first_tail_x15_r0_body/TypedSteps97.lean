import host.sim.template.a4pre_first_tail_x15_r0_body.H55
import host.sim.template.a4pre_first_tail_x15_r0_body.H56
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA482 from PRE_first_tail_x15_r0_body.s1786 to PRE_first_tail_x15_r0_body.s1787 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1786).run PRE_first_tail_x15_r0_body.S1786 = some (PRE_first_tail_x15_r0_body.s1787, PRE_first_tail_x15_r0_body.S1787)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB482 from PRE_first_tail_x15_r0_body.s1787 to PRE_first_tail_x15_r0_body.s1788 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1787).run PRE_first_tail_x15_r0_body.S1787 = some (PRE_first_tail_x15_r0_body.s1788, PRE_first_tail_x15_r0_body.S1788)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA483 from PRE_first_tail_x15_r0_body.s1789 to PRE_first_tail_x15_r0_body.s1790 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1789).run PRE_first_tail_x15_r0_body.S1789 = some (PRE_first_tail_x15_r0_body.s1790, PRE_first_tail_x15_r0_body.S1790)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB483 from PRE_first_tail_x15_r0_body.s1790 to PRE_first_tail_x15_r0_body.s1791 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1790).run PRE_first_tail_x15_r0_body.S1790 = some (PRE_first_tail_x15_r0_body.s1791, PRE_first_tail_x15_r0_body.S1791)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA484 from PRE_first_tail_x15_r0_body.s1792 to PRE_first_tail_x15_r0_body.s1793 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1792).run PRE_first_tail_x15_r0_body.S1792 = some (PRE_first_tail_x15_r0_body.s1793, PRE_first_tail_x15_r0_body.S1793)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB484 from PRE_first_tail_x15_r0_body.s1793 to PRE_first_tail_x15_r0_body.s1794 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1793).run PRE_first_tail_x15_r0_body.S1793 = some (PRE_first_tail_x15_r0_body.s1794, PRE_first_tail_x15_r0_body.S1794)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA485 from PRE_first_tail_x15_r0_body.s1795 to PRE_first_tail_x15_r0_body.s1796 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1795).run PRE_first_tail_x15_r0_body.S1795 = some (PRE_first_tail_x15_r0_body.s1796, PRE_first_tail_x15_r0_body.S1796)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB485 from PRE_first_tail_x15_r0_body.s1796 to PRE_first_tail_x15_r0_body.s1797 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1796).run PRE_first_tail_x15_r0_body.S1796 = some (PRE_first_tail_x15_r0_body.s1797, PRE_first_tail_x15_r0_body.S1797)
end Host.Load.Run.Tpl
