import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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
boot_rfl PRE_first_tail_x15_r0_body.k144 from PRE_first_tail_x15_r0_body.s144 to PRE_first_tail_x15_r0_body.s145 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB43 ((nth? PRE_first_tail_x15_r0_body.ks 144).getD 0) PRE_first_tail_x15_r0_body.s144 PRE_first_tail_x15_r0_body.S144 = some (PRE_first_tail_x15_r0_body.s145, PRE_first_tail_x15_r0_body.S145)
boot_rfl PRE_first_tail_x15_r0_body.stepA44 from PRE_first_tail_x15_r0_body.s145 to PRE_first_tail_x15_r0_body.s146 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s145).run PRE_first_tail_x15_r0_body.S145 = some (PRE_first_tail_x15_r0_body.s146, PRE_first_tail_x15_r0_body.S146)
end Host.Load.Run.Tpl
