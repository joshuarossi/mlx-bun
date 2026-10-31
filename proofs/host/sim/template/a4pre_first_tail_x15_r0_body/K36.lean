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
boot_rfl PRE_first_tail_x15_r0_body.k145 from PRE_first_tail_x15_r0_body.s145 to PRE_first_tail_x15_r0_body.s146 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB39 ((nth? PRE_first_tail_x15_r0_body.ks 145).getD 0) PRE_first_tail_x15_r0_body.s145 PRE_first_tail_x15_r0_body.S145 = some (PRE_first_tail_x15_r0_body.s146, PRE_first_tail_x15_r0_body.S146)
boot_rfl PRE_first_tail_x15_r0_body.k146 from PRE_first_tail_x15_r0_body.s146 to PRE_first_tail_x15_r0_body.s147 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB39 ((nth? PRE_first_tail_x15_r0_body.ks 146).getD 0) PRE_first_tail_x15_r0_body.s146 PRE_first_tail_x15_r0_body.S146 = some (PRE_first_tail_x15_r0_body.s147, PRE_first_tail_x15_r0_body.S147)
boot_rfl PRE_first_tail_x15_r0_body.stepA40 from PRE_first_tail_x15_r0_body.s147 to PRE_first_tail_x15_r0_body.s148 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s147).run PRE_first_tail_x15_r0_body.S147 = some (PRE_first_tail_x15_r0_body.s148, PRE_first_tail_x15_r0_body.S148)
end Host.Load.Run.Tpl
