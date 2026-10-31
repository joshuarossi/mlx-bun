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
boot_rfl PRE_first_tail_x15_r0_body.k1554 from PRE_first_tail_x15_r0_body.s1554 to PRE_first_tail_x15_r0_body.s1555 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB419 ((nth? PRE_first_tail_x15_r0_body.ks 1554).getD 0) PRE_first_tail_x15_r0_body.s1554 PRE_first_tail_x15_r0_body.S1554 = some (PRE_first_tail_x15_r0_body.s1555, PRE_first_tail_x15_r0_body.S1555)
boot_rfl PRE_first_tail_x15_r0_body.k1555 from PRE_first_tail_x15_r0_body.s1555 to PRE_first_tail_x15_r0_body.s1556 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB419 ((nth? PRE_first_tail_x15_r0_body.ks 1555).getD 0) PRE_first_tail_x15_r0_body.s1555 PRE_first_tail_x15_r0_body.S1555 = some (PRE_first_tail_x15_r0_body.s1556, PRE_first_tail_x15_r0_body.S1556)
end Host.Load.Run.Tpl
