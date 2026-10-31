import host.sim.template.a4pre_first_tail_x15_r0_body.H45
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
boot_rfl PRE_first_tail_x15_r0_body.k1438 from PRE_first_tail_x15_r0_body.s1438 to PRE_first_tail_x15_r0_body.s1439 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB425 ((nth? PRE_first_tail_x15_r0_body.ks 1438).getD 0) PRE_first_tail_x15_r0_body.s1438 PRE_first_tail_x15_r0_body.S1438 = some (PRE_first_tail_x15_r0_body.s1439, PRE_first_tail_x15_r0_body.S1439)
end Host.Load.Run.Tpl
