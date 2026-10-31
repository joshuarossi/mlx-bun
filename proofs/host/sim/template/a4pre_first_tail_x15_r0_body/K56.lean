import host.sim.template.a4pre_first_tail_x15_r0_body.H7
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
boot_rfl PRE_first_tail_x15_r0_body.stepA61 from PRE_first_tail_x15_r0_body.s224 to PRE_first_tail_x15_r0_body.s225 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s224).run PRE_first_tail_x15_r0_body.S224 = some (PRE_first_tail_x15_r0_body.s225, PRE_first_tail_x15_r0_body.S225)
boot_rfl PRE_first_tail_x15_r0_body.k227 from PRE_first_tail_x15_r0_body.s227 to PRE_first_tail_x15_r0_body.s228 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB61 ((nth? PRE_first_tail_x15_r0_body.ks 227).getD 0) PRE_first_tail_x15_r0_body.s227 PRE_first_tail_x15_r0_body.S227 = some (PRE_first_tail_x15_r0_body.s228, PRE_first_tail_x15_r0_body.S228)
end Host.Load.Run.Tpl
