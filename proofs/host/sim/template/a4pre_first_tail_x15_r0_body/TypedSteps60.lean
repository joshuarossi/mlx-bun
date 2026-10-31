import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA298 from PRE_first_tail_x15_r0_body.s1006 to PRE_first_tail_x15_r0_body.s1007 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1006).run PRE_first_tail_x15_r0_body.S1006 = some (PRE_first_tail_x15_r0_body.s1007, PRE_first_tail_x15_r0_body.S1007)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB298 from PRE_first_tail_x15_r0_body.s1007 to PRE_first_tail_x15_r0_body.s1008 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1007).run PRE_first_tail_x15_r0_body.S1007 = some (PRE_first_tail_x15_r0_body.s1008, PRE_first_tail_x15_r0_body.S1008)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA299 from PRE_first_tail_x15_r0_body.s1009 to PRE_first_tail_x15_r0_body.s1010 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1009).run PRE_first_tail_x15_r0_body.S1009 = some (PRE_first_tail_x15_r0_body.s1010, PRE_first_tail_x15_r0_body.S1010)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB299 from PRE_first_tail_x15_r0_body.s1010 to PRE_first_tail_x15_r0_body.s1011 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1010).run PRE_first_tail_x15_r0_body.S1010 = some (PRE_first_tail_x15_r0_body.s1011, PRE_first_tail_x15_r0_body.S1011)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA300 from PRE_first_tail_x15_r0_body.s1012 to PRE_first_tail_x15_r0_body.s1013 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1012).run PRE_first_tail_x15_r0_body.S1012 = some (PRE_first_tail_x15_r0_body.s1013, PRE_first_tail_x15_r0_body.S1013)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA301 from PRE_first_tail_x15_r0_body.s1016 to PRE_first_tail_x15_r0_body.s1017 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1016).run PRE_first_tail_x15_r0_body.S1016 = some (PRE_first_tail_x15_r0_body.s1017, PRE_first_tail_x15_r0_body.S1017)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB301 from PRE_first_tail_x15_r0_body.s1017 to PRE_first_tail_x15_r0_body.s1018 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1017).run PRE_first_tail_x15_r0_body.S1017 = some (PRE_first_tail_x15_r0_body.s1018, PRE_first_tail_x15_r0_body.S1018)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA302 from PRE_first_tail_x15_r0_body.s1019 to PRE_first_tail_x15_r0_body.s1020 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1019).run PRE_first_tail_x15_r0_body.S1019 = some (PRE_first_tail_x15_r0_body.s1020, PRE_first_tail_x15_r0_body.S1020)
end Host.Load.Run.Tpl
