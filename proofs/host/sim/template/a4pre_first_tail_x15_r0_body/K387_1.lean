import host.sim.template.a4pre_first_tail_x15_r0_body.H48
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
boot_rfl PRE_first_tail_x15_r0_body.k1551 from PRE_first_tail_x15_r0_body.s1551 to PRE_first_tail_x15_r0_body.s1552 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB458 ((nth? PRE_first_tail_x15_r0_body.ks 1551).getD 0) PRE_first_tail_x15_r0_body.s1551 PRE_first_tail_x15_r0_body.S1551 = some (PRE_first_tail_x15_r0_body.s1552, PRE_first_tail_x15_r0_body.S1552)
end Host.Load.Run.Tpl
