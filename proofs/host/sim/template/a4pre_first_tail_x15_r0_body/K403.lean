import host.sim.template.a4pre_first_tail_x15_r0_body.H50
import host.sim.template.a4pre_first_tail_x15_r0_body.OkB
import host.sim.Chunk
import host.sim.template.BootEq
import host.sim.template.Bridges
-- Serialized lookahead: [1,2]
set_option Elab.async false
namespace Host.Load.Run.Tpl
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.k1612 from PRE_first_tail_x15_r0_body.s1612 to PRE_first_tail_x15_r0_body.s1613 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB434 ((nth? PRE_first_tail_x15_r0_body.ks 1612).getD 0) PRE_first_tail_x15_r0_body.s1612 PRE_first_tail_x15_r0_body.S1612 = some (PRE_first_tail_x15_r0_body.s1613, PRE_first_tail_x15_r0_body.S1613)
boot_rfl PRE_first_tail_x15_r0_body.stepA435 from PRE_first_tail_x15_r0_body.s1613 to PRE_first_tail_x15_r0_body.s1614 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1613).run PRE_first_tail_x15_r0_body.S1613 = some (PRE_first_tail_x15_r0_body.s1614, PRE_first_tail_x15_r0_body.S1614)
boot_rfl PRE_first_tail_x15_r0_body.patchB435 from PRE_first_tail_x15_r0_body.s1614 to PRE_first_tail_x15_r0_body.s1615 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1614).run PRE_first_tail_x15_r0_body.S1614 = some (PRE_first_tail_x15_r0_body.s1615, PRE_first_tail_x15_r0_body.S1615)
boot_rfl PRE_first_tail_x15_r0_body.k1615 from PRE_first_tail_x15_r0_body.s1615 to PRE_first_tail_x15_r0_body.s1616 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB435 ((nth? PRE_first_tail_x15_r0_body.ks 1615).getD 0) PRE_first_tail_x15_r0_body.s1615 PRE_first_tail_x15_r0_body.S1615 = some (PRE_first_tail_x15_r0_body.s1616, PRE_first_tail_x15_r0_body.S1616)
end Host.Load.Run.Tpl
