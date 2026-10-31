import host.sim.template.a4pre_first_tail_x15_r0_body.H47
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA407 from PRE_first_tail_x15_r0_body.s1507 to PRE_first_tail_x15_r0_body.s1508 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1507).run PRE_first_tail_x15_r0_body.S1507 = some (PRE_first_tail_x15_r0_body.s1508, PRE_first_tail_x15_r0_body.S1508)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB407 from PRE_first_tail_x15_r0_body.s1508 to PRE_first_tail_x15_r0_body.s1509 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1508).run PRE_first_tail_x15_r0_body.S1508 = some (PRE_first_tail_x15_r0_body.s1509, PRE_first_tail_x15_r0_body.S1509)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA408 from PRE_first_tail_x15_r0_body.s1510 to PRE_first_tail_x15_r0_body.s1511 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1510).run PRE_first_tail_x15_r0_body.S1510 = some (PRE_first_tail_x15_r0_body.s1511, PRE_first_tail_x15_r0_body.S1511)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA409 from PRE_first_tail_x15_r0_body.s1514 to PRE_first_tail_x15_r0_body.s1515 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1514).run PRE_first_tail_x15_r0_body.S1514 = some (PRE_first_tail_x15_r0_body.s1515, PRE_first_tail_x15_r0_body.S1515)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB409 from PRE_first_tail_x15_r0_body.s1515 to PRE_first_tail_x15_r0_body.s1516 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1515).run PRE_first_tail_x15_r0_body.S1515 = some (PRE_first_tail_x15_r0_body.s1516, PRE_first_tail_x15_r0_body.S1516)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA410 from PRE_first_tail_x15_r0_body.s1518 to PRE_first_tail_x15_r0_body.s1519 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1518).run PRE_first_tail_x15_r0_body.S1518 = some (PRE_first_tail_x15_r0_body.s1519, PRE_first_tail_x15_r0_body.S1519)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA411 from PRE_first_tail_x15_r0_body.s1522 to PRE_first_tail_x15_r0_body.s1523 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1522).run PRE_first_tail_x15_r0_body.S1522 = some (PRE_first_tail_x15_r0_body.s1523, PRE_first_tail_x15_r0_body.S1523)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA412 from PRE_first_tail_x15_r0_body.s1527 to PRE_first_tail_x15_r0_body.s1528 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1527).run PRE_first_tail_x15_r0_body.S1527 = some (PRE_first_tail_x15_r0_body.s1528, PRE_first_tail_x15_r0_body.S1528)
end Host.Load.Run.Tpl
