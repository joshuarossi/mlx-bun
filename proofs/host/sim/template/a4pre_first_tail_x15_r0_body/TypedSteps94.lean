import host.sim.template.a4pre_first_tail_x15_r0_body.H49
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA467 from PRE_first_tail_x15_r0_body.s1579 to PRE_first_tail_x15_r0_body.s1580 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1579).run PRE_first_tail_x15_r0_body.S1579 = some (PRE_first_tail_x15_r0_body.s1580, PRE_first_tail_x15_r0_body.S1580)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB467 from PRE_first_tail_x15_r0_body.s1580 to PRE_first_tail_x15_r0_body.s1581 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1580).run PRE_first_tail_x15_r0_body.S1580 = some (PRE_first_tail_x15_r0_body.s1581, PRE_first_tail_x15_r0_body.S1581)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA468 from PRE_first_tail_x15_r0_body.s1582 to PRE_first_tail_x15_r0_body.s1583 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1582).run PRE_first_tail_x15_r0_body.S1582 = some (PRE_first_tail_x15_r0_body.s1583, PRE_first_tail_x15_r0_body.S1583)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB468 from PRE_first_tail_x15_r0_body.s1583 to PRE_first_tail_x15_r0_body.s1584 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1583).run PRE_first_tail_x15_r0_body.S1583 = some (PRE_first_tail_x15_r0_body.s1584, PRE_first_tail_x15_r0_body.S1584)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA469 from PRE_first_tail_x15_r0_body.s1585 to PRE_first_tail_x15_r0_body.s1586 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1585).run PRE_first_tail_x15_r0_body.S1585 = some (PRE_first_tail_x15_r0_body.s1586, PRE_first_tail_x15_r0_body.S1586)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB469 from PRE_first_tail_x15_r0_body.s1586 to PRE_first_tail_x15_r0_body.s1587 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1586).run PRE_first_tail_x15_r0_body.S1586 = some (PRE_first_tail_x15_r0_body.s1587, PRE_first_tail_x15_r0_body.S1587)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA470 from PRE_first_tail_x15_r0_body.s1588 to PRE_first_tail_x15_r0_body.s1589 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1588).run PRE_first_tail_x15_r0_body.S1588 = some (PRE_first_tail_x15_r0_body.s1589, PRE_first_tail_x15_r0_body.S1589)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA471 from PRE_first_tail_x15_r0_body.s1592 to PRE_first_tail_x15_r0_body.s1593 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1592).run PRE_first_tail_x15_r0_body.S1592 = some (PRE_first_tail_x15_r0_body.s1593, PRE_first_tail_x15_r0_body.S1593)
end Host.Load.Run.Tpl
