import host.sim.template.a4pre_first_tail_x15_r0_body.H39
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA373 from PRE_first_tail_x15_r0_body.s1261 to PRE_first_tail_x15_r0_body.s1262 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1261).run PRE_first_tail_x15_r0_body.S1261 = some (PRE_first_tail_x15_r0_body.s1262, PRE_first_tail_x15_r0_body.S1262)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB373 from PRE_first_tail_x15_r0_body.s1262 to PRE_first_tail_x15_r0_body.s1263 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1262).run PRE_first_tail_x15_r0_body.S1262 = some (PRE_first_tail_x15_r0_body.s1263, PRE_first_tail_x15_r0_body.S1263)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA374 from PRE_first_tail_x15_r0_body.s1264 to PRE_first_tail_x15_r0_body.s1265 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1264).run PRE_first_tail_x15_r0_body.S1264 = some (PRE_first_tail_x15_r0_body.s1265, PRE_first_tail_x15_r0_body.S1265)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB374 from PRE_first_tail_x15_r0_body.s1265 to PRE_first_tail_x15_r0_body.s1266 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1265).run PRE_first_tail_x15_r0_body.S1265 = some (PRE_first_tail_x15_r0_body.s1266, PRE_first_tail_x15_r0_body.S1266)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA375 from PRE_first_tail_x15_r0_body.s1267 to PRE_first_tail_x15_r0_body.s1268 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1267).run PRE_first_tail_x15_r0_body.S1267 = some (PRE_first_tail_x15_r0_body.s1268, PRE_first_tail_x15_r0_body.S1268)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB375 from PRE_first_tail_x15_r0_body.s1268 to PRE_first_tail_x15_r0_body.s1269 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1268).run PRE_first_tail_x15_r0_body.S1268 = some (PRE_first_tail_x15_r0_body.s1269, PRE_first_tail_x15_r0_body.S1269)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA376 from PRE_first_tail_x15_r0_body.s1270 to PRE_first_tail_x15_r0_body.s1271 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1270).run PRE_first_tail_x15_r0_body.S1270 = some (PRE_first_tail_x15_r0_body.s1271, PRE_first_tail_x15_r0_body.S1271)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB376 from PRE_first_tail_x15_r0_body.s1271 to PRE_first_tail_x15_r0_body.s1272 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1271).run PRE_first_tail_x15_r0_body.S1271 = some (PRE_first_tail_x15_r0_body.s1272, PRE_first_tail_x15_r0_body.S1272)
end Host.Load.Run.Tpl
