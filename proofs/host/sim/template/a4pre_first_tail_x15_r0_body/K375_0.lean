import host.sim.template.a4pre_first_tail_x15_r0_body.H47
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
boot_rfl PRE_first_tail_x15_r0_body.k1500 from PRE_first_tail_x15_r0_body.s1500 to PRE_first_tail_x15_r0_body.s1501 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB443 ((nth? PRE_first_tail_x15_r0_body.ks 1500).getD 0) PRE_first_tail_x15_r0_body.s1500 PRE_first_tail_x15_r0_body.S1500 = some (PRE_first_tail_x15_r0_body.s1501, PRE_first_tail_x15_r0_body.S1501)
end Host.Load.Run.Tpl
