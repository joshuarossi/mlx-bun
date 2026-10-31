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
boot_rfl PRE_first_tail_x15_r0_body.k1598 from PRE_first_tail_x15_r0_body.s1598 to PRE_first_tail_x15_r0_body.s1599 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB472 ((nth? PRE_first_tail_x15_r0_body.ks 1598).getD 0) PRE_first_tail_x15_r0_body.s1598 PRE_first_tail_x15_r0_body.S1598 = some (PRE_first_tail_x15_r0_body.s1599, PRE_first_tail_x15_r0_body.S1599)
end Host.Load.Run.Tpl
