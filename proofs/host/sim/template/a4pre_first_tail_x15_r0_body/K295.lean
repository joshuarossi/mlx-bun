import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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
boot_rfl PRE_first_tail_x15_r0_body.k1182 from PRE_first_tail_x15_r0_body.s1182 to PRE_first_tail_x15_r0_body.s1183 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB349 ((nth? PRE_first_tail_x15_r0_body.ks 1182).getD 0) PRE_first_tail_x15_r0_body.s1182 PRE_first_tail_x15_r0_body.S1182 = some (PRE_first_tail_x15_r0_body.s1183, PRE_first_tail_x15_r0_body.S1183)
boot_rfl PRE_first_tail_x15_r0_body.stepA350 from PRE_first_tail_x15_r0_body.s1183 to PRE_first_tail_x15_r0_body.s1184 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1183).run PRE_first_tail_x15_r0_body.S1183 = some (PRE_first_tail_x15_r0_body.s1184, PRE_first_tail_x15_r0_body.S1184)
end Host.Load.Run.Tpl
