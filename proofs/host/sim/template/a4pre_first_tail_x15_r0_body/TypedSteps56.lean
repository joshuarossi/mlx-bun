import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA278 from PRE_first_tail_x15_r0_body.s1029 to PRE_first_tail_x15_r0_body.s1030 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1029).run PRE_first_tail_x15_r0_body.S1029 = some (PRE_first_tail_x15_r0_body.s1030, PRE_first_tail_x15_r0_body.S1030)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA279 from PRE_first_tail_x15_r0_body.s1033 to PRE_first_tail_x15_r0_body.s1034 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1033).run PRE_first_tail_x15_r0_body.S1033 = some (PRE_first_tail_x15_r0_body.s1034, PRE_first_tail_x15_r0_body.S1034)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA280 from PRE_first_tail_x15_r0_body.s1038 to PRE_first_tail_x15_r0_body.s1039 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1038).run PRE_first_tail_x15_r0_body.S1038 = some (PRE_first_tail_x15_r0_body.s1039, PRE_first_tail_x15_r0_body.S1039)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB280 from PRE_first_tail_x15_r0_body.s1039 to PRE_first_tail_x15_r0_body.s1040 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1039).run PRE_first_tail_x15_r0_body.S1039 = some (PRE_first_tail_x15_r0_body.s1040, PRE_first_tail_x15_r0_body.S1040)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA281 from PRE_first_tail_x15_r0_body.s1041 to PRE_first_tail_x15_r0_body.s1042 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1041).run PRE_first_tail_x15_r0_body.S1041 = some (PRE_first_tail_x15_r0_body.s1042, PRE_first_tail_x15_r0_body.S1042)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB281 from PRE_first_tail_x15_r0_body.s1042 to PRE_first_tail_x15_r0_body.s1043 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1042).run PRE_first_tail_x15_r0_body.S1042 = some (PRE_first_tail_x15_r0_body.s1043, PRE_first_tail_x15_r0_body.S1043)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA282 from PRE_first_tail_x15_r0_body.s1044 to PRE_first_tail_x15_r0_body.s1045 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1044).run PRE_first_tail_x15_r0_body.S1044 = some (PRE_first_tail_x15_r0_body.s1045, PRE_first_tail_x15_r0_body.S1045)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB282 from PRE_first_tail_x15_r0_body.s1045 to PRE_first_tail_x15_r0_body.s1046 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1045).run PRE_first_tail_x15_r0_body.S1045 = some (PRE_first_tail_x15_r0_body.s1046, PRE_first_tail_x15_r0_body.S1046)
end Host.Load.Run.Tpl
