import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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
boot_rfl PRE_first_tail_x15_r0_body.stepA385 from PRE_first_tail_x15_r0_body.s1424 to PRE_first_tail_x15_r0_body.s1425 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1424).run PRE_first_tail_x15_r0_body.S1424 = some (PRE_first_tail_x15_r0_body.s1425, PRE_first_tail_x15_r0_body.S1425)
boot_rfl PRE_first_tail_x15_r0_body.k1427 from PRE_first_tail_x15_r0_body.s1427 to PRE_first_tail_x15_r0_body.s1428 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB385 ((nth? PRE_first_tail_x15_r0_body.ks 1427).getD 0) PRE_first_tail_x15_r0_body.s1427 PRE_first_tail_x15_r0_body.S1427 = some (PRE_first_tail_x15_r0_body.s1428, PRE_first_tail_x15_r0_body.S1428)
end Host.Load.Run.Tpl
