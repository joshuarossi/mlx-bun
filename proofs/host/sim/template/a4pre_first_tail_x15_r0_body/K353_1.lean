import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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
boot_rfl PRE_first_tail_x15_r0_body.k1415 from PRE_first_tail_x15_r0_body.s1415 to PRE_first_tail_x15_r0_body.s1416 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB418 ((nth? PRE_first_tail_x15_r0_body.ks 1415).getD 0) PRE_first_tail_x15_r0_body.s1415 PRE_first_tail_x15_r0_body.S1415 = some (PRE_first_tail_x15_r0_body.s1416, PRE_first_tail_x15_r0_body.S1416)
end Host.Load.Run.Tpl
