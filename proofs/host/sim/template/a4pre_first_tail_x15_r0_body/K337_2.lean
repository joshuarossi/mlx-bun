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
boot_rfl PRE_first_tail_x15_r0_body.k1350 from PRE_first_tail_x15_r0_body.s1350 to PRE_first_tail_x15_r0_body.s1351 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB399 ((nth? PRE_first_tail_x15_r0_body.ks 1350).getD 0) PRE_first_tail_x15_r0_body.s1350 PRE_first_tail_x15_r0_body.S1350 = some (PRE_first_tail_x15_r0_body.s1351, PRE_first_tail_x15_r0_body.S1351)
end Host.Load.Run.Tpl
