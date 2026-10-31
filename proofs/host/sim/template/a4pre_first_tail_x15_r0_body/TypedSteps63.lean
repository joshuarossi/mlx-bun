import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA313 from PRE_first_tail_x15_r0_body.s1057 to PRE_first_tail_x15_r0_body.s1058 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1057).run PRE_first_tail_x15_r0_body.S1057 = some (PRE_first_tail_x15_r0_body.s1058, PRE_first_tail_x15_r0_body.S1058)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB313 from PRE_first_tail_x15_r0_body.s1058 to PRE_first_tail_x15_r0_body.s1059 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1058).run PRE_first_tail_x15_r0_body.S1058 = some (PRE_first_tail_x15_r0_body.s1059, PRE_first_tail_x15_r0_body.S1059)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA314 from PRE_first_tail_x15_r0_body.s1060 to PRE_first_tail_x15_r0_body.s1061 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1060).run PRE_first_tail_x15_r0_body.S1060 = some (PRE_first_tail_x15_r0_body.s1061, PRE_first_tail_x15_r0_body.S1061)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB314 from PRE_first_tail_x15_r0_body.s1061 to PRE_first_tail_x15_r0_body.s1062 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1061).run PRE_first_tail_x15_r0_body.S1061 = some (PRE_first_tail_x15_r0_body.s1062, PRE_first_tail_x15_r0_body.S1062)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA315 from PRE_first_tail_x15_r0_body.s1063 to PRE_first_tail_x15_r0_body.s1064 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1063).run PRE_first_tail_x15_r0_body.S1063 = some (PRE_first_tail_x15_r0_body.s1064, PRE_first_tail_x15_r0_body.S1064)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA316 from PRE_first_tail_x15_r0_body.s1067 to PRE_first_tail_x15_r0_body.s1068 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1067).run PRE_first_tail_x15_r0_body.S1067 = some (PRE_first_tail_x15_r0_body.s1068, PRE_first_tail_x15_r0_body.S1068)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB316 from PRE_first_tail_x15_r0_body.s1068 to PRE_first_tail_x15_r0_body.s1069 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1068).run PRE_first_tail_x15_r0_body.S1068 = some (PRE_first_tail_x15_r0_body.s1069, PRE_first_tail_x15_r0_body.S1069)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA317 from PRE_first_tail_x15_r0_body.s1070 to PRE_first_tail_x15_r0_body.s1071 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1070).run PRE_first_tail_x15_r0_body.S1070 = some (PRE_first_tail_x15_r0_body.s1071, PRE_first_tail_x15_r0_body.S1071)
end Host.Load.Run.Tpl
