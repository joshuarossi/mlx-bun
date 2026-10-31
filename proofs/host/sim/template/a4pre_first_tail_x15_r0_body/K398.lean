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
boot_rfl PRE_first_tail_x15_r0_body.stepA430 from PRE_first_tail_x15_r0_body.s1592 to PRE_first_tail_x15_r0_body.s1593 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1592).run PRE_first_tail_x15_r0_body.S1592 = some (PRE_first_tail_x15_r0_body.s1593, PRE_first_tail_x15_r0_body.S1593)
boot_rfl PRE_first_tail_x15_r0_body.patchB430 from PRE_first_tail_x15_r0_body.s1593 to PRE_first_tail_x15_r0_body.s1594 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1593).run PRE_first_tail_x15_r0_body.S1593 = some (PRE_first_tail_x15_r0_body.s1594, PRE_first_tail_x15_r0_body.S1594)
boot_rfl PRE_first_tail_x15_r0_body.k1594 from PRE_first_tail_x15_r0_body.s1594 to PRE_first_tail_x15_r0_body.s1595 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB430 ((nth? PRE_first_tail_x15_r0_body.ks 1594).getD 0) PRE_first_tail_x15_r0_body.s1594 PRE_first_tail_x15_r0_body.S1594 = some (PRE_first_tail_x15_r0_body.s1595, PRE_first_tail_x15_r0_body.S1595)
boot_rfl PRE_first_tail_x15_r0_body.k1595 from PRE_first_tail_x15_r0_body.s1595 to PRE_first_tail_x15_r0_body.s1596 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB430 ((nth? PRE_first_tail_x15_r0_body.ks 1595).getD 0) PRE_first_tail_x15_r0_body.s1595 PRE_first_tail_x15_r0_body.S1595 = some (PRE_first_tail_x15_r0_body.s1596, PRE_first_tail_x15_r0_body.S1596)
end Host.Load.Run.Tpl
