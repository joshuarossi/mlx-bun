import host.sim.template.a4pre_first_tail_x15_r0_body.H0
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
boot_rfl PRE_first_tail_x15_r0_body.k26 from PRE_first_tail_x15_r0_body.s26 to PRE_first_tail_x15_r0_body.s27 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB7 ((nth? PRE_first_tail_x15_r0_body.ks 26).getD 0) PRE_first_tail_x15_r0_body.s26 PRE_first_tail_x15_r0_body.S26 = some (PRE_first_tail_x15_r0_body.s27, PRE_first_tail_x15_r0_body.S27)
boot_rfl PRE_first_tail_x15_r0_body.stepA8 from PRE_first_tail_x15_r0_body.s27 to PRE_first_tail_x15_r0_body.s28 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s27).run PRE_first_tail_x15_r0_body.S27 = some (PRE_first_tail_x15_r0_body.s28, PRE_first_tail_x15_r0_body.S28)
end Host.Load.Run.Tpl
