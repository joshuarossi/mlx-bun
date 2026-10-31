import host.sim.template.a4pre_first_tail_x15_r0_body.H49
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
boot_rfl PRE_first_tail_x15_r0_body.k1584 from PRE_first_tail_x15_r0_body.s1584 to PRE_first_tail_x15_r0_body.s1585 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB427 ((nth? PRE_first_tail_x15_r0_body.ks 1584).getD 0) PRE_first_tail_x15_r0_body.s1584 PRE_first_tail_x15_r0_body.S1584 = some (PRE_first_tail_x15_r0_body.s1585, PRE_first_tail_x15_r0_body.S1585)
boot_rfl PRE_first_tail_x15_r0_body.stepA428 from PRE_first_tail_x15_r0_body.s1585 to PRE_first_tail_x15_r0_body.s1586 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1585).run PRE_first_tail_x15_r0_body.S1585 = some (PRE_first_tail_x15_r0_body.s1586, PRE_first_tail_x15_r0_body.S1586)
boot_rfl PRE_first_tail_x15_r0_body.patchB428 from PRE_first_tail_x15_r0_body.s1586 to PRE_first_tail_x15_r0_body.s1587 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1586).run PRE_first_tail_x15_r0_body.S1586 = some (PRE_first_tail_x15_r0_body.s1587, PRE_first_tail_x15_r0_body.S1587)
boot_rfl PRE_first_tail_x15_r0_body.k1587 from PRE_first_tail_x15_r0_body.s1587 to PRE_first_tail_x15_r0_body.s1588 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB428 ((nth? PRE_first_tail_x15_r0_body.ks 1587).getD 0) PRE_first_tail_x15_r0_body.s1587 PRE_first_tail_x15_r0_body.S1587 = some (PRE_first_tail_x15_r0_body.s1588, PRE_first_tail_x15_r0_body.S1588)
end Host.Load.Run.Tpl
