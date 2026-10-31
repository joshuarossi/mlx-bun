import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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
boot_rfl PRE_first_tail_x15_r0_body.k1680 from PRE_first_tail_x15_r0_body.s1680 to PRE_first_tail_x15_r0_body.s1681 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB496 ((nth? PRE_first_tail_x15_r0_body.ks 1680).getD 0) PRE_first_tail_x15_r0_body.s1680 PRE_first_tail_x15_r0_body.S1680 = some (PRE_first_tail_x15_r0_body.s1681, PRE_first_tail_x15_r0_body.S1681)
end Host.Load.Run.Tpl
