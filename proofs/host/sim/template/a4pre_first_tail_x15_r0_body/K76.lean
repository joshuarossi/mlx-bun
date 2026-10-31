import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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
boot_rfl PRE_first_tail_x15_r0_body.k306 from PRE_first_tail_x15_r0_body.s306 to PRE_first_tail_x15_r0_body.s307 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB83 ((nth? PRE_first_tail_x15_r0_body.ks 306).getD 0) PRE_first_tail_x15_r0_body.s306 PRE_first_tail_x15_r0_body.S306 = some (PRE_first_tail_x15_r0_body.s307, PRE_first_tail_x15_r0_body.S307)
boot_rfl PRE_first_tail_x15_r0_body.stepA84 from PRE_first_tail_x15_r0_body.s307 to PRE_first_tail_x15_r0_body.s308 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s307).run PRE_first_tail_x15_r0_body.S307 = some (PRE_first_tail_x15_r0_body.s308, PRE_first_tail_x15_r0_body.S308)
end Host.Load.Run.Tpl
