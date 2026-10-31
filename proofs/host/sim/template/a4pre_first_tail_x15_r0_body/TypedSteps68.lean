import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.a4pre_first_tail_x15_r0_body.H36
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB337 from PRE_first_tail_x15_r0_body.s1139 to PRE_first_tail_x15_r0_body.s1140 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1139).run PRE_first_tail_x15_r0_body.S1139 = some (PRE_first_tail_x15_r0_body.s1140, PRE_first_tail_x15_r0_body.S1140)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA338 from PRE_first_tail_x15_r0_body.s1141 to PRE_first_tail_x15_r0_body.s1142 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1141).run PRE_first_tail_x15_r0_body.S1141 = some (PRE_first_tail_x15_r0_body.s1142, PRE_first_tail_x15_r0_body.S1142)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA339 from PRE_first_tail_x15_r0_body.s1145 to PRE_first_tail_x15_r0_body.s1146 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1145).run PRE_first_tail_x15_r0_body.S1145 = some (PRE_first_tail_x15_r0_body.s1146, PRE_first_tail_x15_r0_body.S1146)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB339 from PRE_first_tail_x15_r0_body.s1146 to PRE_first_tail_x15_r0_body.s1147 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1146).run PRE_first_tail_x15_r0_body.S1146 = some (PRE_first_tail_x15_r0_body.s1147, PRE_first_tail_x15_r0_body.S1147)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA340 from PRE_first_tail_x15_r0_body.s1148 to PRE_first_tail_x15_r0_body.s1149 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1148).run PRE_first_tail_x15_r0_body.S1148 = some (PRE_first_tail_x15_r0_body.s1149, PRE_first_tail_x15_r0_body.S1149)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA341 from PRE_first_tail_x15_r0_body.s1152 to PRE_first_tail_x15_r0_body.s1153 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1152).run PRE_first_tail_x15_r0_body.S1152 = some (PRE_first_tail_x15_r0_body.s1153, PRE_first_tail_x15_r0_body.S1153)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA342 from PRE_first_tail_x15_r0_body.s1156 to PRE_first_tail_x15_r0_body.s1157 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1156).run PRE_first_tail_x15_r0_body.S1156 = some (PRE_first_tail_x15_r0_body.s1157, PRE_first_tail_x15_r0_body.S1157)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB342 from PRE_first_tail_x15_r0_body.s1157 to PRE_first_tail_x15_r0_body.s1158 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1157).run PRE_first_tail_x15_r0_body.S1157 = some (PRE_first_tail_x15_r0_body.s1158, PRE_first_tail_x15_r0_body.S1158)
end Host.Load.Run.Tpl
