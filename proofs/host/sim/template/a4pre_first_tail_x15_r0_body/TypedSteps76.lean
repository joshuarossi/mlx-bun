import host.sim.template.a4pre_first_tail_x15_r0_body.H43
import host.sim.template.a4pre_first_tail_x15_r0_body.H44
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA377 from PRE_first_tail_x15_r0_body.s1395 to PRE_first_tail_x15_r0_body.s1396 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1395).run PRE_first_tail_x15_r0_body.S1395 = some (PRE_first_tail_x15_r0_body.s1396, PRE_first_tail_x15_r0_body.S1396)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA378 from PRE_first_tail_x15_r0_body.s1399 to PRE_first_tail_x15_r0_body.s1400 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1399).run PRE_first_tail_x15_r0_body.S1399 = some (PRE_first_tail_x15_r0_body.s1400, PRE_first_tail_x15_r0_body.S1400)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB378 from PRE_first_tail_x15_r0_body.s1400 to PRE_first_tail_x15_r0_body.s1401 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1400).run PRE_first_tail_x15_r0_body.S1400 = some (PRE_first_tail_x15_r0_body.s1401, PRE_first_tail_x15_r0_body.S1401)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA379 from PRE_first_tail_x15_r0_body.s1403 to PRE_first_tail_x15_r0_body.s1404 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1403).run PRE_first_tail_x15_r0_body.S1403 = some (PRE_first_tail_x15_r0_body.s1404, PRE_first_tail_x15_r0_body.S1404)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA380 from PRE_first_tail_x15_r0_body.s1407 to PRE_first_tail_x15_r0_body.s1408 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1407).run PRE_first_tail_x15_r0_body.S1407 = some (PRE_first_tail_x15_r0_body.s1408, PRE_first_tail_x15_r0_body.S1408)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA381 from PRE_first_tail_x15_r0_body.s1412 to PRE_first_tail_x15_r0_body.s1413 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1412).run PRE_first_tail_x15_r0_body.S1412 = some (PRE_first_tail_x15_r0_body.s1413, PRE_first_tail_x15_r0_body.S1413)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB381 from PRE_first_tail_x15_r0_body.s1413 to PRE_first_tail_x15_r0_body.s1414 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1413).run PRE_first_tail_x15_r0_body.S1413 = some (PRE_first_tail_x15_r0_body.s1414, PRE_first_tail_x15_r0_body.S1414)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA382 from PRE_first_tail_x15_r0_body.s1415 to PRE_first_tail_x15_r0_body.s1416 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1415).run PRE_first_tail_x15_r0_body.S1415 = some (PRE_first_tail_x15_r0_body.s1416, PRE_first_tail_x15_r0_body.S1416)
end Host.Load.Run.Tpl
