import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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
boot_rfl PRE_first_tail_x15_r0_body.k532 from PRE_first_tail_x15_r0_body.s532 to PRE_first_tail_x15_r0_body.s533 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB144 ((nth? PRE_first_tail_x15_r0_body.ks 532).getD 0) PRE_first_tail_x15_r0_body.s532 PRE_first_tail_x15_r0_body.S532 = some (PRE_first_tail_x15_r0_body.s533, PRE_first_tail_x15_r0_body.S533)
boot_rfl PRE_first_tail_x15_r0_body.stepA145 from PRE_first_tail_x15_r0_body.s533 to PRE_first_tail_x15_r0_body.s534 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s533).run PRE_first_tail_x15_r0_body.S533 = some (PRE_first_tail_x15_r0_body.s534, PRE_first_tail_x15_r0_body.S534)
end Host.Load.Run.Tpl
