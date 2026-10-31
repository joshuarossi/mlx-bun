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
boot_rfl PRE_first_tail_x15_r0_body.k1410 from PRE_first_tail_x15_r0_body.s1410 to PRE_first_tail_x15_r0_body.s1411 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB380 ((nth? PRE_first_tail_x15_r0_body.ks 1410).getD 0) PRE_first_tail_x15_r0_body.s1410 PRE_first_tail_x15_r0_body.S1410 = some (PRE_first_tail_x15_r0_body.s1411, PRE_first_tail_x15_r0_body.S1411)
boot_rfl PRE_first_tail_x15_r0_body.k1411 from PRE_first_tail_x15_r0_body.s1411 to PRE_first_tail_x15_r0_body.s1412 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB380 ((nth? PRE_first_tail_x15_r0_body.ks 1411).getD 0) PRE_first_tail_x15_r0_body.s1411 PRE_first_tail_x15_r0_body.S1411 = some (PRE_first_tail_x15_r0_body.s1412, PRE_first_tail_x15_r0_body.S1412)
end Host.Load.Run.Tpl
