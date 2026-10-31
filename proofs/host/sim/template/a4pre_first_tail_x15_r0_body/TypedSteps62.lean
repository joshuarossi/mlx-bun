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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA308 from PRE_first_tail_x15_r0_body.s1140 to PRE_first_tail_x15_r0_body.s1141 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1140).run PRE_first_tail_x15_r0_body.S1140 = some (PRE_first_tail_x15_r0_body.s1141, PRE_first_tail_x15_r0_body.S1141)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB308 from PRE_first_tail_x15_r0_body.s1141 to PRE_first_tail_x15_r0_body.s1142 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1141).run PRE_first_tail_x15_r0_body.S1141 = some (PRE_first_tail_x15_r0_body.s1142, PRE_first_tail_x15_r0_body.S1142)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA309 from PRE_first_tail_x15_r0_body.s1144 to PRE_first_tail_x15_r0_body.s1145 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1144).run PRE_first_tail_x15_r0_body.S1144 = some (PRE_first_tail_x15_r0_body.s1145, PRE_first_tail_x15_r0_body.S1145)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA310 from PRE_first_tail_x15_r0_body.s1148 to PRE_first_tail_x15_r0_body.s1149 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1148).run PRE_first_tail_x15_r0_body.S1148 = some (PRE_first_tail_x15_r0_body.s1149, PRE_first_tail_x15_r0_body.S1149)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA311 from PRE_first_tail_x15_r0_body.s1153 to PRE_first_tail_x15_r0_body.s1154 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1153).run PRE_first_tail_x15_r0_body.S1153 = some (PRE_first_tail_x15_r0_body.s1154, PRE_first_tail_x15_r0_body.S1154)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB311 from PRE_first_tail_x15_r0_body.s1154 to PRE_first_tail_x15_r0_body.s1155 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1154).run PRE_first_tail_x15_r0_body.S1154 = some (PRE_first_tail_x15_r0_body.s1155, PRE_first_tail_x15_r0_body.S1155)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA312 from PRE_first_tail_x15_r0_body.s1156 to PRE_first_tail_x15_r0_body.s1157 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1156).run PRE_first_tail_x15_r0_body.S1156 = some (PRE_first_tail_x15_r0_body.s1157, PRE_first_tail_x15_r0_body.S1157)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB312 from PRE_first_tail_x15_r0_body.s1157 to PRE_first_tail_x15_r0_body.s1158 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1157).run PRE_first_tail_x15_r0_body.S1157 = some (PRE_first_tail_x15_r0_body.s1158, PRE_first_tail_x15_r0_body.S1158)
end Host.Load.Run.Tpl
