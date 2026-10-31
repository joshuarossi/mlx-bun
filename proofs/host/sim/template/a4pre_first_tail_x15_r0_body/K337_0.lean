import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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
boot_rfl PRE_first_tail_x15_r0_body.stepA399 from PRE_first_tail_x15_r0_body.s1348 to PRE_first_tail_x15_r0_body.s1349 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1348).run PRE_first_tail_x15_r0_body.S1348 = some (PRE_first_tail_x15_r0_body.s1349, PRE_first_tail_x15_r0_body.S1349)
end Host.Load.Run.Tpl
