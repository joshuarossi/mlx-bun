import host.sim.template.a4pre_first_tail_x15_r0_body.H33
import host.sim.template.a4pre_first_tail_x15_r0_body.H34
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA318 from PRE_first_tail_x15_r0_body.s1074 to PRE_first_tail_x15_r0_body.s1075 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1074).run PRE_first_tail_x15_r0_body.S1074 = some (PRE_first_tail_x15_r0_body.s1075, PRE_first_tail_x15_r0_body.S1075)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA319 from PRE_first_tail_x15_r0_body.s1078 to PRE_first_tail_x15_r0_body.s1079 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1078).run PRE_first_tail_x15_r0_body.S1078 = some (PRE_first_tail_x15_r0_body.s1079, PRE_first_tail_x15_r0_body.S1079)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB319 from PRE_first_tail_x15_r0_body.s1079 to PRE_first_tail_x15_r0_body.s1080 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1079).run PRE_first_tail_x15_r0_body.S1079 = some (PRE_first_tail_x15_r0_body.s1080, PRE_first_tail_x15_r0_body.S1080)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA320 from PRE_first_tail_x15_r0_body.s1081 to PRE_first_tail_x15_r0_body.s1082 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1081).run PRE_first_tail_x15_r0_body.S1081 = some (PRE_first_tail_x15_r0_body.s1082, PRE_first_tail_x15_r0_body.S1082)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB320 from PRE_first_tail_x15_r0_body.s1082 to PRE_first_tail_x15_r0_body.s1083 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1082).run PRE_first_tail_x15_r0_body.S1082 = some (PRE_first_tail_x15_r0_body.s1083, PRE_first_tail_x15_r0_body.S1083)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA321 from PRE_first_tail_x15_r0_body.s1084 to PRE_first_tail_x15_r0_body.s1085 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1084).run PRE_first_tail_x15_r0_body.S1084 = some (PRE_first_tail_x15_r0_body.s1085, PRE_first_tail_x15_r0_body.S1085)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB321 from PRE_first_tail_x15_r0_body.s1085 to PRE_first_tail_x15_r0_body.s1086 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1085).run PRE_first_tail_x15_r0_body.S1085 = some (PRE_first_tail_x15_r0_body.s1086, PRE_first_tail_x15_r0_body.S1086)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA322 from PRE_first_tail_x15_r0_body.s1087 to PRE_first_tail_x15_r0_body.s1088 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1087).run PRE_first_tail_x15_r0_body.S1087 = some (PRE_first_tail_x15_r0_body.s1088, PRE_first_tail_x15_r0_body.S1088)
end Host.Load.Run.Tpl
