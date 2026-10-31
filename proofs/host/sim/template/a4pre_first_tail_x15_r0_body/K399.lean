import host.sim.template.a4pre_first_tail_x15_r0_body.H50
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
boot_rfl PRE_first_tail_x15_r0_body.stepA431 from PRE_first_tail_x15_r0_body.s1596 to PRE_first_tail_x15_r0_body.s1597 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1596).run PRE_first_tail_x15_r0_body.S1596 = some (PRE_first_tail_x15_r0_body.s1597, PRE_first_tail_x15_r0_body.S1597)
boot_rfl PRE_first_tail_x15_r0_body.k1599 from PRE_first_tail_x15_r0_body.s1599 to PRE_first_tail_x15_r0_body.s1600 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB431 ((nth? PRE_first_tail_x15_r0_body.ks 1599).getD 0) PRE_first_tail_x15_r0_body.s1599 PRE_first_tail_x15_r0_body.S1599 = some (PRE_first_tail_x15_r0_body.s1600, PRE_first_tail_x15_r0_body.S1600)
end Host.Load.Run.Tpl
