import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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
boot_rfl PRE_first_tail_x15_r0_body.k968 from PRE_first_tail_x15_r0_body.s968 to PRE_first_tail_x15_r0_body.s969 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB286 ((nth? PRE_first_tail_x15_r0_body.ks 968).getD 0) PRE_first_tail_x15_r0_body.s968 PRE_first_tail_x15_r0_body.S968 = some (PRE_first_tail_x15_r0_body.s969, PRE_first_tail_x15_r0_body.S969)
boot_rfl PRE_first_tail_x15_r0_body.stepA287 from PRE_first_tail_x15_r0_body.s969 to PRE_first_tail_x15_r0_body.s970 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s969).run PRE_first_tail_x15_r0_body.S969 = some (PRE_first_tail_x15_r0_body.s970, PRE_first_tail_x15_r0_body.S970)
end Host.Load.Run.Tpl
