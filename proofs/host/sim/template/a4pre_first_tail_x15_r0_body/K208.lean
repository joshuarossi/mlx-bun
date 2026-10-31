import host.sim.template.a4pre_first_tail_x15_r0_body.H26
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
boot_rfl PRE_first_tail_x15_r0_body.k832 from PRE_first_tail_x15_r0_body.s832 to PRE_first_tail_x15_r0_body.s833 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB246 ((nth? PRE_first_tail_x15_r0_body.ks 832).getD 0) PRE_first_tail_x15_r0_body.s832 PRE_first_tail_x15_r0_body.S832 = some (PRE_first_tail_x15_r0_body.s833, PRE_first_tail_x15_r0_body.S833)
boot_rfl PRE_first_tail_x15_r0_body.stepA247 from PRE_first_tail_x15_r0_body.s833 to PRE_first_tail_x15_r0_body.s834 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s833).run PRE_first_tail_x15_r0_body.S833 = some (PRE_first_tail_x15_r0_body.s834, PRE_first_tail_x15_r0_body.S834)
end Host.Load.Run.Tpl
