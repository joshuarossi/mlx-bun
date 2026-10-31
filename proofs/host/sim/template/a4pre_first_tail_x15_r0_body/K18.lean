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
boot_rfl PRE_first_tail_x15_r0_body.k72 from PRE_first_tail_x15_r0_body.s72 to PRE_first_tail_x15_r0_body.s73 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB20 ((nth? PRE_first_tail_x15_r0_body.ks 72).getD 0) PRE_first_tail_x15_r0_body.s72 PRE_first_tail_x15_r0_body.S72 = some (PRE_first_tail_x15_r0_body.s73, PRE_first_tail_x15_r0_body.S73)
boot_rfl PRE_first_tail_x15_r0_body.stepA21 from PRE_first_tail_x15_r0_body.s73 to PRE_first_tail_x15_r0_body.s74 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s73).run PRE_first_tail_x15_r0_body.S73 = some (PRE_first_tail_x15_r0_body.s74, PRE_first_tail_x15_r0_body.S74)
end Host.Load.Run.Tpl
