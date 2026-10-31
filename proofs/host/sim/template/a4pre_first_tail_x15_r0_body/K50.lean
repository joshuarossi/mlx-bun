import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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
boot_rfl PRE_first_tail_x15_r0_body.stepA55 from PRE_first_tail_x15_r0_body.s200 to PRE_first_tail_x15_r0_body.s201 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s200).run PRE_first_tail_x15_r0_body.S200 = some (PRE_first_tail_x15_r0_body.s201, PRE_first_tail_x15_r0_body.S201)
boot_rfl PRE_first_tail_x15_r0_body.k203 from PRE_first_tail_x15_r0_body.s203 to PRE_first_tail_x15_r0_body.s204 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB55 ((nth? PRE_first_tail_x15_r0_body.ks 203).getD 0) PRE_first_tail_x15_r0_body.s203 PRE_first_tail_x15_r0_body.S203 = some (PRE_first_tail_x15_r0_body.s204, PRE_first_tail_x15_r0_body.S204)
end Host.Load.Run.Tpl
