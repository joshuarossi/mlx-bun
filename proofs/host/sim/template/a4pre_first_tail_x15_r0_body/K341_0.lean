import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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
boot_rfl PRE_first_tail_x15_r0_body.k1365 from PRE_first_tail_x15_r0_body.s1365 to PRE_first_tail_x15_r0_body.s1366 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB403 ((nth? PRE_first_tail_x15_r0_body.ks 1365).getD 0) PRE_first_tail_x15_r0_body.s1365 PRE_first_tail_x15_r0_body.S1365 = some (PRE_first_tail_x15_r0_body.s1366, PRE_first_tail_x15_r0_body.S1366)
end Host.Load.Run.Tpl
