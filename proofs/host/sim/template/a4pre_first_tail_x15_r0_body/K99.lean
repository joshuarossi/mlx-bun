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
boot_rfl PRE_first_tail_x15_r0_body.k396 from PRE_first_tail_x15_r0_body.s396 to PRE_first_tail_x15_r0_body.s397 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB107 ((nth? PRE_first_tail_x15_r0_body.ks 396).getD 0) PRE_first_tail_x15_r0_body.s396 PRE_first_tail_x15_r0_body.S396 = some (PRE_first_tail_x15_r0_body.s397, PRE_first_tail_x15_r0_body.S397)
boot_rfl PRE_first_tail_x15_r0_body.stepA108 from PRE_first_tail_x15_r0_body.s397 to PRE_first_tail_x15_r0_body.s398 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s397).run PRE_first_tail_x15_r0_body.S397 = some (PRE_first_tail_x15_r0_body.s398, PRE_first_tail_x15_r0_body.S398)
end Host.Load.Run.Tpl
