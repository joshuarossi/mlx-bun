import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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
boot_rfl PRE_first_tail_x15_r0_body.k256 from PRE_first_tail_x15_r0_body.s256 to PRE_first_tail_x15_r0_body.s257 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB76 ((nth? PRE_first_tail_x15_r0_body.ks 256).getD 0) PRE_first_tail_x15_r0_body.s256 PRE_first_tail_x15_r0_body.S256 = some (PRE_first_tail_x15_r0_body.s257, PRE_first_tail_x15_r0_body.S257)
boot_rfl PRE_first_tail_x15_r0_body.stepA77 from PRE_first_tail_x15_r0_body.s257 to PRE_first_tail_x15_r0_body.s258 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s257).run PRE_first_tail_x15_r0_body.S257 = some (PRE_first_tail_x15_r0_body.s258, PRE_first_tail_x15_r0_body.S258)
end Host.Load.Run.Tpl
