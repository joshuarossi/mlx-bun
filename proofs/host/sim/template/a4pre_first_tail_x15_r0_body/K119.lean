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
boot_rfl PRE_first_tail_x15_r0_body.patchB141 from PRE_first_tail_x15_r0_body.s476 to PRE_first_tail_x15_r0_body.s477 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s476).run PRE_first_tail_x15_r0_body.S476 = some (PRE_first_tail_x15_r0_body.s477, PRE_first_tail_x15_r0_body.S477)
boot_rfl PRE_first_tail_x15_r0_body.k477 from PRE_first_tail_x15_r0_body.s477 to PRE_first_tail_x15_r0_body.s478 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB141 ((nth? PRE_first_tail_x15_r0_body.ks 477).getD 0) PRE_first_tail_x15_r0_body.s477 PRE_first_tail_x15_r0_body.S477 = some (PRE_first_tail_x15_r0_body.s478, PRE_first_tail_x15_r0_body.S478)
boot_rfl PRE_first_tail_x15_r0_body.stepA142 from PRE_first_tail_x15_r0_body.s478 to PRE_first_tail_x15_r0_body.s479 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s478).run PRE_first_tail_x15_r0_body.S478 = some (PRE_first_tail_x15_r0_body.s479, PRE_first_tail_x15_r0_body.S479)
boot_rfl PRE_first_tail_x15_r0_body.patchB142 from PRE_first_tail_x15_r0_body.s479 to PRE_first_tail_x15_r0_body.s480 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s479).run PRE_first_tail_x15_r0_body.S479 = some (PRE_first_tail_x15_r0_body.s480, PRE_first_tail_x15_r0_body.S480)
end Host.Load.Run.Tpl
