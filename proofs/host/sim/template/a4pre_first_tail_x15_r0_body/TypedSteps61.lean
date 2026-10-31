import host.sim.template.a4pre_first_tail_x15_r0_body.H31
import host.sim.template.a4pre_first_tail_x15_r0_body.H32
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA303 from PRE_first_tail_x15_r0_body.s1023 to PRE_first_tail_x15_r0_body.s1024 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1023).run PRE_first_tail_x15_r0_body.S1023 = some (PRE_first_tail_x15_r0_body.s1024, PRE_first_tail_x15_r0_body.S1024)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA304 from PRE_first_tail_x15_r0_body.s1027 to PRE_first_tail_x15_r0_body.s1028 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1027).run PRE_first_tail_x15_r0_body.S1027 = some (PRE_first_tail_x15_r0_body.s1028, PRE_first_tail_x15_r0_body.S1028)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB304 from PRE_first_tail_x15_r0_body.s1028 to PRE_first_tail_x15_r0_body.s1029 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1028).run PRE_first_tail_x15_r0_body.S1028 = some (PRE_first_tail_x15_r0_body.s1029, PRE_first_tail_x15_r0_body.S1029)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA305 from PRE_first_tail_x15_r0_body.s1030 to PRE_first_tail_x15_r0_body.s1031 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1030).run PRE_first_tail_x15_r0_body.S1030 = some (PRE_first_tail_x15_r0_body.s1031, PRE_first_tail_x15_r0_body.S1031)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB305 from PRE_first_tail_x15_r0_body.s1031 to PRE_first_tail_x15_r0_body.s1032 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1031).run PRE_first_tail_x15_r0_body.S1031 = some (PRE_first_tail_x15_r0_body.s1032, PRE_first_tail_x15_r0_body.S1032)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA306 from PRE_first_tail_x15_r0_body.s1033 to PRE_first_tail_x15_r0_body.s1034 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1033).run PRE_first_tail_x15_r0_body.S1033 = some (PRE_first_tail_x15_r0_body.s1034, PRE_first_tail_x15_r0_body.S1034)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB306 from PRE_first_tail_x15_r0_body.s1034 to PRE_first_tail_x15_r0_body.s1035 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1034).run PRE_first_tail_x15_r0_body.S1034 = some (PRE_first_tail_x15_r0_body.s1035, PRE_first_tail_x15_r0_body.S1035)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA307 from PRE_first_tail_x15_r0_body.s1036 to PRE_first_tail_x15_r0_body.s1037 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1036).run PRE_first_tail_x15_r0_body.S1036 = some (PRE_first_tail_x15_r0_body.s1037, PRE_first_tail_x15_r0_body.S1037)
end Host.Load.Run.Tpl
