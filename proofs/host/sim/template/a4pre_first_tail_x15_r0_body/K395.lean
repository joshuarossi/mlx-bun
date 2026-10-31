import host.sim.template.a4pre_first_tail_x15_r0_body.H49
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
boot_rfl PRE_first_tail_x15_r0_body.stepA427 from PRE_first_tail_x15_r0_body.s1580 to PRE_first_tail_x15_r0_body.s1581 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1580).run PRE_first_tail_x15_r0_body.S1580 = some (PRE_first_tail_x15_r0_body.s1581, PRE_first_tail_x15_r0_body.S1581)
boot_rfl PRE_first_tail_x15_r0_body.k1583 from PRE_first_tail_x15_r0_body.s1583 to PRE_first_tail_x15_r0_body.s1584 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB427 ((nth? PRE_first_tail_x15_r0_body.ks 1583).getD 0) PRE_first_tail_x15_r0_body.s1583 PRE_first_tail_x15_r0_body.S1583 = some (PRE_first_tail_x15_r0_body.s1584, PRE_first_tail_x15_r0_body.S1584)
end Host.Load.Run.Tpl
