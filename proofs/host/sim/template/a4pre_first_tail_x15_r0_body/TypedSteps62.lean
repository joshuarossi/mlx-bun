import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA308 from PRE_first_tail_x15_r0_body.s1040 to PRE_first_tail_x15_r0_body.s1041 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1040).run PRE_first_tail_x15_r0_body.S1040 = some (PRE_first_tail_x15_r0_body.s1041, PRE_first_tail_x15_r0_body.S1041)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB308 from PRE_first_tail_x15_r0_body.s1041 to PRE_first_tail_x15_r0_body.s1042 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1041).run PRE_first_tail_x15_r0_body.S1041 = some (PRE_first_tail_x15_r0_body.s1042, PRE_first_tail_x15_r0_body.S1042)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA309 from PRE_first_tail_x15_r0_body.s1043 to PRE_first_tail_x15_r0_body.s1044 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1043).run PRE_first_tail_x15_r0_body.S1043 = some (PRE_first_tail_x15_r0_body.s1044, PRE_first_tail_x15_r0_body.S1044)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA310 from PRE_first_tail_x15_r0_body.s1047 to PRE_first_tail_x15_r0_body.s1048 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1047).run PRE_first_tail_x15_r0_body.S1047 = some (PRE_first_tail_x15_r0_body.s1048, PRE_first_tail_x15_r0_body.S1048)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA311 from PRE_first_tail_x15_r0_body.s1051 to PRE_first_tail_x15_r0_body.s1052 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1051).run PRE_first_tail_x15_r0_body.S1051 = some (PRE_first_tail_x15_r0_body.s1052, PRE_first_tail_x15_r0_body.S1052)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB311 from PRE_first_tail_x15_r0_body.s1052 to PRE_first_tail_x15_r0_body.s1053 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1052).run PRE_first_tail_x15_r0_body.S1052 = some (PRE_first_tail_x15_r0_body.s1053, PRE_first_tail_x15_r0_body.S1053)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA312 from PRE_first_tail_x15_r0_body.s1054 to PRE_first_tail_x15_r0_body.s1055 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1054).run PRE_first_tail_x15_r0_body.S1054 = some (PRE_first_tail_x15_r0_body.s1055, PRE_first_tail_x15_r0_body.S1055)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB312 from PRE_first_tail_x15_r0_body.s1055 to PRE_first_tail_x15_r0_body.s1056 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1055).run PRE_first_tail_x15_r0_body.S1055 = some (PRE_first_tail_x15_r0_body.s1056, PRE_first_tail_x15_r0_body.S1056)
end Host.Load.Run.Tpl
