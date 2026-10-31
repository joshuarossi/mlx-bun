import host.sim.template.a4pre_first_tail_x15_r0_body.H38
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
boot_rfl PRE_first_tail_x15_r0_body.k1238 from PRE_first_tail_x15_r0_body.s1238 to PRE_first_tail_x15_r0_body.s1239 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB334 ((nth? PRE_first_tail_x15_r0_body.ks 1238).getD 0) PRE_first_tail_x15_r0_body.s1238 PRE_first_tail_x15_r0_body.S1238 = some (PRE_first_tail_x15_r0_body.s1239, PRE_first_tail_x15_r0_body.S1239)
boot_rfl PRE_first_tail_x15_r0_body.k1239 from PRE_first_tail_x15_r0_body.s1239 to PRE_first_tail_x15_r0_body.s1240 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB334 ((nth? PRE_first_tail_x15_r0_body.ks 1239).getD 0) PRE_first_tail_x15_r0_body.s1239 PRE_first_tail_x15_r0_body.S1239 = some (PRE_first_tail_x15_r0_body.s1240, PRE_first_tail_x15_r0_body.S1240)
end Host.Load.Run.Tpl
