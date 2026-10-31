import host.sim.template.a4pre_first_tail_x15_r0_body.H47
import host.sim.template.a4pre_first_tail_x15_r0_body.H48
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB412 from PRE_first_tail_x15_r0_body.s1528 to PRE_first_tail_x15_r0_body.s1529 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1528).run PRE_first_tail_x15_r0_body.S1528 = some (PRE_first_tail_x15_r0_body.s1529, PRE_first_tail_x15_r0_body.S1529)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA413 from PRE_first_tail_x15_r0_body.s1530 to PRE_first_tail_x15_r0_body.s1531 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1530).run PRE_first_tail_x15_r0_body.S1530 = some (PRE_first_tail_x15_r0_body.s1531, PRE_first_tail_x15_r0_body.S1531)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB413 from PRE_first_tail_x15_r0_body.s1531 to PRE_first_tail_x15_r0_body.s1532 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1531).run PRE_first_tail_x15_r0_body.S1531 = some (PRE_first_tail_x15_r0_body.s1532, PRE_first_tail_x15_r0_body.S1532)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA414 from PRE_first_tail_x15_r0_body.s1533 to PRE_first_tail_x15_r0_body.s1534 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1533).run PRE_first_tail_x15_r0_body.S1533 = some (PRE_first_tail_x15_r0_body.s1534, PRE_first_tail_x15_r0_body.S1534)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB414 from PRE_first_tail_x15_r0_body.s1534 to PRE_first_tail_x15_r0_body.s1535 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1534).run PRE_first_tail_x15_r0_body.S1534 = some (PRE_first_tail_x15_r0_body.s1535, PRE_first_tail_x15_r0_body.S1535)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA415 from PRE_first_tail_x15_r0_body.s1536 to PRE_first_tail_x15_r0_body.s1537 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1536).run PRE_first_tail_x15_r0_body.S1536 = some (PRE_first_tail_x15_r0_body.s1537, PRE_first_tail_x15_r0_body.S1537)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB415 from PRE_first_tail_x15_r0_body.s1537 to PRE_first_tail_x15_r0_body.s1538 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1537).run PRE_first_tail_x15_r0_body.S1537 = some (PRE_first_tail_x15_r0_body.s1538, PRE_first_tail_x15_r0_body.S1538)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA416 from PRE_first_tail_x15_r0_body.s1539 to PRE_first_tail_x15_r0_body.s1540 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1539).run PRE_first_tail_x15_r0_body.S1539 = some (PRE_first_tail_x15_r0_body.s1540, PRE_first_tail_x15_r0_body.S1540)
end Host.Load.Run.Tpl
