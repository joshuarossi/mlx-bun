import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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
boot_rfl PRE_first_tail_x15_r0_body.k478 from PRE_first_tail_x15_r0_body.s478 to PRE_first_tail_x15_r0_body.s479 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB129 ((nth? PRE_first_tail_x15_r0_body.ks 478).getD 0) PRE_first_tail_x15_r0_body.s478 PRE_first_tail_x15_r0_body.S478 = some (PRE_first_tail_x15_r0_body.s479, PRE_first_tail_x15_r0_body.S479)
boot_rfl PRE_first_tail_x15_r0_body.stepA130 from PRE_first_tail_x15_r0_body.s479 to PRE_first_tail_x15_r0_body.s480 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s479).run PRE_first_tail_x15_r0_body.S479 = some (PRE_first_tail_x15_r0_body.s480, PRE_first_tail_x15_r0_body.S480)
end Host.Load.Run.Tpl
