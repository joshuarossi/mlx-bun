import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA432 from PRE_first_tail_x15_r0_body.s1600 to PRE_first_tail_x15_r0_body.s1601 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1600).run PRE_first_tail_x15_r0_body.S1600 = some (PRE_first_tail_x15_r0_body.s1601, PRE_first_tail_x15_r0_body.S1601)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB432 from PRE_first_tail_x15_r0_body.s1601 to PRE_first_tail_x15_r0_body.s1602 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1601).run PRE_first_tail_x15_r0_body.S1601 = some (PRE_first_tail_x15_r0_body.s1602, PRE_first_tail_x15_r0_body.S1602)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA433 from PRE_first_tail_x15_r0_body.s1604 to PRE_first_tail_x15_r0_body.s1605 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1604).run PRE_first_tail_x15_r0_body.S1604 = some (PRE_first_tail_x15_r0_body.s1605, PRE_first_tail_x15_r0_body.S1605)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA434 from PRE_first_tail_x15_r0_body.s1608 to PRE_first_tail_x15_r0_body.s1609 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1608).run PRE_first_tail_x15_r0_body.S1608 = some (PRE_first_tail_x15_r0_body.s1609, PRE_first_tail_x15_r0_body.S1609)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA435 from PRE_first_tail_x15_r0_body.s1613 to PRE_first_tail_x15_r0_body.s1614 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1613).run PRE_first_tail_x15_r0_body.S1613 = some (PRE_first_tail_x15_r0_body.s1614, PRE_first_tail_x15_r0_body.S1614)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB435 from PRE_first_tail_x15_r0_body.s1614 to PRE_first_tail_x15_r0_body.s1615 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1614).run PRE_first_tail_x15_r0_body.S1614 = some (PRE_first_tail_x15_r0_body.s1615, PRE_first_tail_x15_r0_body.S1615)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA436 from PRE_first_tail_x15_r0_body.s1616 to PRE_first_tail_x15_r0_body.s1617 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1616).run PRE_first_tail_x15_r0_body.S1616 = some (PRE_first_tail_x15_r0_body.s1617, PRE_first_tail_x15_r0_body.S1617)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB436 from PRE_first_tail_x15_r0_body.s1617 to PRE_first_tail_x15_r0_body.s1618 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1617).run PRE_first_tail_x15_r0_body.S1617 = some (PRE_first_tail_x15_r0_body.s1618, PRE_first_tail_x15_r0_body.S1618)
end Host.Load.Run.Tpl
