import host.sim.template.a4pre_first_tail_x15_r0_body.H2
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
boot_rfl PRE_first_tail_x15_r0_body.k77 from PRE_first_tail_x15_r0_body.s77 to PRE_first_tail_x15_r0_body.s78 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB23 ((nth? PRE_first_tail_x15_r0_body.ks 77).getD 0) PRE_first_tail_x15_r0_body.s77 PRE_first_tail_x15_r0_body.S77 = some (PRE_first_tail_x15_r0_body.s78, PRE_first_tail_x15_r0_body.S78)
boot_rfl PRE_first_tail_x15_r0_body.stepA24 from PRE_first_tail_x15_r0_body.s78 to PRE_first_tail_x15_r0_body.s79 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s78).run PRE_first_tail_x15_r0_body.S78 = some (PRE_first_tail_x15_r0_body.s79, PRE_first_tail_x15_r0_body.S79)
end Host.Load.Run.Tpl
