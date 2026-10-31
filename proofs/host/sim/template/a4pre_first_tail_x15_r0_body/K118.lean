import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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
boot_rfl PRE_first_tail_x15_r0_body.k474 from PRE_first_tail_x15_r0_body.s474 to PRE_first_tail_x15_r0_body.s475 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB140 ((nth? PRE_first_tail_x15_r0_body.ks 474).getD 0) PRE_first_tail_x15_r0_body.s474 PRE_first_tail_x15_r0_body.S474 = some (PRE_first_tail_x15_r0_body.s475, PRE_first_tail_x15_r0_body.S475)
boot_rfl PRE_first_tail_x15_r0_body.stepA141 from PRE_first_tail_x15_r0_body.s475 to PRE_first_tail_x15_r0_body.s476 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s475).run PRE_first_tail_x15_r0_body.S475 = some (PRE_first_tail_x15_r0_body.s476, PRE_first_tail_x15_r0_body.S476)
end Host.Load.Run.Tpl
