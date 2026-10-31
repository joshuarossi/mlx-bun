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
boot_rfl PRE_first_tail_x15_r0_body.k1625 from PRE_first_tail_x15_r0_body.s1625 to PRE_first_tail_x15_r0_body.s1626 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB480 ((nth? PRE_first_tail_x15_r0_body.ks 1625).getD 0) PRE_first_tail_x15_r0_body.s1625 PRE_first_tail_x15_r0_body.S1625 = some (PRE_first_tail_x15_r0_body.s1626, PRE_first_tail_x15_r0_body.S1626)
end Host.Load.Run.Tpl
