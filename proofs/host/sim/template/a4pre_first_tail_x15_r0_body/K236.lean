import host.sim.template.a4pre_first_tail_x15_r0_body.H29
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
boot_rfl PRE_first_tail_x15_r0_body.k946 from PRE_first_tail_x15_r0_body.s946 to PRE_first_tail_x15_r0_body.s947 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB255 ((nth? PRE_first_tail_x15_r0_body.ks 946).getD 0) PRE_first_tail_x15_r0_body.s946 PRE_first_tail_x15_r0_body.S946 = some (PRE_first_tail_x15_r0_body.s947, PRE_first_tail_x15_r0_body.S947)
boot_rfl PRE_first_tail_x15_r0_body.stepA256 from PRE_first_tail_x15_r0_body.s947 to PRE_first_tail_x15_r0_body.s948 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s947).run PRE_first_tail_x15_r0_body.S947 = some (PRE_first_tail_x15_r0_body.s948, PRE_first_tail_x15_r0_body.S948)
end Host.Load.Run.Tpl
