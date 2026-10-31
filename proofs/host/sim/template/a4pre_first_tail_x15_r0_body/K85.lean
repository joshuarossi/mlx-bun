import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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
boot_rfl PRE_first_tail_x15_r0_body.k342 from PRE_first_tail_x15_r0_body.s342 to PRE_first_tail_x15_r0_body.s343 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB92 ((nth? PRE_first_tail_x15_r0_body.ks 342).getD 0) PRE_first_tail_x15_r0_body.s342 PRE_first_tail_x15_r0_body.S342 = some (PRE_first_tail_x15_r0_body.s343, PRE_first_tail_x15_r0_body.S343)
boot_rfl PRE_first_tail_x15_r0_body.stepA93 from PRE_first_tail_x15_r0_body.s343 to PRE_first_tail_x15_r0_body.s344 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s343).run PRE_first_tail_x15_r0_body.S343 = some (PRE_first_tail_x15_r0_body.s344, PRE_first_tail_x15_r0_body.S344)
end Host.Load.Run.Tpl
