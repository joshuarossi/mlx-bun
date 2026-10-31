import host.sim.template.a4pre_first_tail_x15_r0_body.H51
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
boot_rfl PRE_first_tail_x15_r0_body.stepA445 from PRE_first_tail_x15_r0_body.s1648 to PRE_first_tail_x15_r0_body.s1649 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1648).run PRE_first_tail_x15_r0_body.S1648 = some (PRE_first_tail_x15_r0_body.s1649, PRE_first_tail_x15_r0_body.S1649)
boot_rfl PRE_first_tail_x15_r0_body.patchB445 from PRE_first_tail_x15_r0_body.s1649 to PRE_first_tail_x15_r0_body.s1650 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1649).run PRE_first_tail_x15_r0_body.S1649 = some (PRE_first_tail_x15_r0_body.s1650, PRE_first_tail_x15_r0_body.S1650)
boot_rfl PRE_first_tail_x15_r0_body.k1650 from PRE_first_tail_x15_r0_body.s1650 to PRE_first_tail_x15_r0_body.s1651 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB445 ((nth? PRE_first_tail_x15_r0_body.ks 1650).getD 0) PRE_first_tail_x15_r0_body.s1650 PRE_first_tail_x15_r0_body.S1650 = some (PRE_first_tail_x15_r0_body.s1651, PRE_first_tail_x15_r0_body.S1651)
boot_rfl PRE_first_tail_x15_r0_body.stepA446 from PRE_first_tail_x15_r0_body.s1651 to PRE_first_tail_x15_r0_body.s1652 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1651).run PRE_first_tail_x15_r0_body.S1651 = some (PRE_first_tail_x15_r0_body.s1652, PRE_first_tail_x15_r0_body.S1652)
end Host.Load.Run.Tpl
