import host.sim.template.a4pre_first_tail_x15_r0_body.H52
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
boot_rfl PRE_first_tail_x15_r0_body.stepA496 from PRE_first_tail_x15_r0_body.s1677 to PRE_first_tail_x15_r0_body.s1678 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1677).run PRE_first_tail_x15_r0_body.S1677 = some (PRE_first_tail_x15_r0_body.s1678, PRE_first_tail_x15_r0_body.S1678)
end Host.Load.Run.Tpl
