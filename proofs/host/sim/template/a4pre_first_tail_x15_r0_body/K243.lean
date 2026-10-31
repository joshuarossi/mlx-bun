import host.sim.template.a4pre_first_tail_x15_r0_body.H30
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
boot_rfl PRE_first_tail_x15_r0_body.stepA263 from PRE_first_tail_x15_r0_body.s972 to PRE_first_tail_x15_r0_body.s973 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s972).run PRE_first_tail_x15_r0_body.S972 = some (PRE_first_tail_x15_r0_body.s973, PRE_first_tail_x15_r0_body.S973)
boot_rfl PRE_first_tail_x15_r0_body.k975 from PRE_first_tail_x15_r0_body.s975 to PRE_first_tail_x15_r0_body.s976 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB263 ((nth? PRE_first_tail_x15_r0_body.ks 975).getD 0) PRE_first_tail_x15_r0_body.s975 PRE_first_tail_x15_r0_body.S975 = some (PRE_first_tail_x15_r0_body.s976, PRE_first_tail_x15_r0_body.S976)
end Host.Load.Run.Tpl
