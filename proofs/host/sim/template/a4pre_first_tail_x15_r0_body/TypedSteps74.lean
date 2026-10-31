import host.sim.template.a4pre_first_tail_x15_r0_body.H38
import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB367 from PRE_first_tail_x15_r0_body.s1241 to PRE_first_tail_x15_r0_body.s1242 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1241).run PRE_first_tail_x15_r0_body.S1241 = some (PRE_first_tail_x15_r0_body.s1242, PRE_first_tail_x15_r0_body.S1242)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA368 from PRE_first_tail_x15_r0_body.s1243 to PRE_first_tail_x15_r0_body.s1244 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1243).run PRE_first_tail_x15_r0_body.S1243 = some (PRE_first_tail_x15_r0_body.s1244, PRE_first_tail_x15_r0_body.S1244)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB368 from PRE_first_tail_x15_r0_body.s1244 to PRE_first_tail_x15_r0_body.s1245 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1244).run PRE_first_tail_x15_r0_body.S1244 = some (PRE_first_tail_x15_r0_body.s1245, PRE_first_tail_x15_r0_body.S1245)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA369 from PRE_first_tail_x15_r0_body.s1246 to PRE_first_tail_x15_r0_body.s1247 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1246).run PRE_first_tail_x15_r0_body.S1246 = some (PRE_first_tail_x15_r0_body.s1247, PRE_first_tail_x15_r0_body.S1247)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA370 from PRE_first_tail_x15_r0_body.s1250 to PRE_first_tail_x15_r0_body.s1251 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1250).run PRE_first_tail_x15_r0_body.S1250 = some (PRE_first_tail_x15_r0_body.s1251, PRE_first_tail_x15_r0_body.S1251)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB370 from PRE_first_tail_x15_r0_body.s1251 to PRE_first_tail_x15_r0_body.s1252 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1251).run PRE_first_tail_x15_r0_body.S1251 = some (PRE_first_tail_x15_r0_body.s1252, PRE_first_tail_x15_r0_body.S1252)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA371 from PRE_first_tail_x15_r0_body.s1253 to PRE_first_tail_x15_r0_body.s1254 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1253).run PRE_first_tail_x15_r0_body.S1253 = some (PRE_first_tail_x15_r0_body.s1254, PRE_first_tail_x15_r0_body.S1254)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA372 from PRE_first_tail_x15_r0_body.s1257 to PRE_first_tail_x15_r0_body.s1258 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1257).run PRE_first_tail_x15_r0_body.S1257 = some (PRE_first_tail_x15_r0_body.s1258, PRE_first_tail_x15_r0_body.S1258)
end Host.Load.Run.Tpl
