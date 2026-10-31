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
boot_rfl PRE_first_tail_x15_r0_body.stepA469 from PRE_first_tail_x15_r0_body.s1585 to PRE_first_tail_x15_r0_body.s1586 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1585).run PRE_first_tail_x15_r0_body.S1585 = some (PRE_first_tail_x15_r0_body.s1586, PRE_first_tail_x15_r0_body.S1586)
end Host.Load.Run.Tpl
