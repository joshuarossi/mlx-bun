import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.a4pre_first_tail_x15_r0_body.H35
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA328 from PRE_first_tail_x15_r0_body.s1108 to PRE_first_tail_x15_r0_body.s1109 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1108).run PRE_first_tail_x15_r0_body.S1108 = some (PRE_first_tail_x15_r0_body.s1109, PRE_first_tail_x15_r0_body.S1109)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB328 from PRE_first_tail_x15_r0_body.s1109 to PRE_first_tail_x15_r0_body.s1110 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1109).run PRE_first_tail_x15_r0_body.S1109 = some (PRE_first_tail_x15_r0_body.s1110, PRE_first_tail_x15_r0_body.S1110)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA329 from PRE_first_tail_x15_r0_body.s1111 to PRE_first_tail_x15_r0_body.s1112 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1111).run PRE_first_tail_x15_r0_body.S1111 = some (PRE_first_tail_x15_r0_body.s1112, PRE_first_tail_x15_r0_body.S1112)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB329 from PRE_first_tail_x15_r0_body.s1112 to PRE_first_tail_x15_r0_body.s1113 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1112).run PRE_first_tail_x15_r0_body.S1112 = some (PRE_first_tail_x15_r0_body.s1113, PRE_first_tail_x15_r0_body.S1113)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA330 from PRE_first_tail_x15_r0_body.s1114 to PRE_first_tail_x15_r0_body.s1115 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1114).run PRE_first_tail_x15_r0_body.S1114 = some (PRE_first_tail_x15_r0_body.s1115, PRE_first_tail_x15_r0_body.S1115)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB330 from PRE_first_tail_x15_r0_body.s1115 to PRE_first_tail_x15_r0_body.s1116 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1115).run PRE_first_tail_x15_r0_body.S1115 = some (PRE_first_tail_x15_r0_body.s1116, PRE_first_tail_x15_r0_body.S1116)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA331 from PRE_first_tail_x15_r0_body.s1117 to PRE_first_tail_x15_r0_body.s1118 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1117).run PRE_first_tail_x15_r0_body.S1117 = some (PRE_first_tail_x15_r0_body.s1118, PRE_first_tail_x15_r0_body.S1118)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA332 from PRE_first_tail_x15_r0_body.s1121 to PRE_first_tail_x15_r0_body.s1122 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1121).run PRE_first_tail_x15_r0_body.S1121 = some (PRE_first_tail_x15_r0_body.s1122, PRE_first_tail_x15_r0_body.S1122)
end Host.Load.Run.Tpl
