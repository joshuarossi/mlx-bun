import host.sim.template.a4pre_first_tail_x15_r0_body.H12
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
boot_rfl PRE_first_tail_x15_r0_body.k392 from PRE_first_tail_x15_r0_body.s392 to PRE_first_tail_x15_r0_body.s393 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB116 ((nth? PRE_first_tail_x15_r0_body.ks 392).getD 0) PRE_first_tail_x15_r0_body.s392 PRE_first_tail_x15_r0_body.S392 = some (PRE_first_tail_x15_r0_body.s393, PRE_first_tail_x15_r0_body.S393)
boot_rfl PRE_first_tail_x15_r0_body.stepA117 from PRE_first_tail_x15_r0_body.s393 to PRE_first_tail_x15_r0_body.s394 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s393).run PRE_first_tail_x15_r0_body.S393 = some (PRE_first_tail_x15_r0_body.s394, PRE_first_tail_x15_r0_body.S394)
end Host.Load.Run.Tpl
