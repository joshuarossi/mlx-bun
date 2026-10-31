import host.sim.template.a4pre_first_tail_x15_r0_body.H41
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA358 from PRE_first_tail_x15_r0_body.s1326 to PRE_first_tail_x15_r0_body.s1327 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1326).run PRE_first_tail_x15_r0_body.S1326 = some (PRE_first_tail_x15_r0_body.s1327, PRE_first_tail_x15_r0_body.S1327)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB358 from PRE_first_tail_x15_r0_body.s1327 to PRE_first_tail_x15_r0_body.s1328 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1327).run PRE_first_tail_x15_r0_body.S1327 = some (PRE_first_tail_x15_r0_body.s1328, PRE_first_tail_x15_r0_body.S1328)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA359 from PRE_first_tail_x15_r0_body.s1329 to PRE_first_tail_x15_r0_body.s1330 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1329).run PRE_first_tail_x15_r0_body.S1329 = some (PRE_first_tail_x15_r0_body.s1330, PRE_first_tail_x15_r0_body.S1330)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB359 from PRE_first_tail_x15_r0_body.s1330 to PRE_first_tail_x15_r0_body.s1331 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1330).run PRE_first_tail_x15_r0_body.S1330 = some (PRE_first_tail_x15_r0_body.s1331, PRE_first_tail_x15_r0_body.S1331)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA360 from PRE_first_tail_x15_r0_body.s1332 to PRE_first_tail_x15_r0_body.s1333 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1332).run PRE_first_tail_x15_r0_body.S1332 = some (PRE_first_tail_x15_r0_body.s1333, PRE_first_tail_x15_r0_body.S1333)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB360 from PRE_first_tail_x15_r0_body.s1333 to PRE_first_tail_x15_r0_body.s1334 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1333).run PRE_first_tail_x15_r0_body.S1333 = some (PRE_first_tail_x15_r0_body.s1334, PRE_first_tail_x15_r0_body.S1334)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA361 from PRE_first_tail_x15_r0_body.s1335 to PRE_first_tail_x15_r0_body.s1336 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1335).run PRE_first_tail_x15_r0_body.S1335 = some (PRE_first_tail_x15_r0_body.s1336, PRE_first_tail_x15_r0_body.S1336)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB361 from PRE_first_tail_x15_r0_body.s1336 to PRE_first_tail_x15_r0_body.s1337 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1336).run PRE_first_tail_x15_r0_body.S1336 = some (PRE_first_tail_x15_r0_body.s1337, PRE_first_tail_x15_r0_body.S1337)
end Host.Load.Run.Tpl
