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
boot_rfl PRE_first_tail_x15_r0_body.stepA59 from PRE_first_tail_x15_r0_body.s196 to PRE_first_tail_x15_r0_body.s197 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s196).run PRE_first_tail_x15_r0_body.S196 = some (PRE_first_tail_x15_r0_body.s197, PRE_first_tail_x15_r0_body.S197)
boot_rfl PRE_first_tail_x15_r0_body.k199 from PRE_first_tail_x15_r0_body.s199 to PRE_first_tail_x15_r0_body.s200 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB59 ((nth? PRE_first_tail_x15_r0_body.ks 199).getD 0) PRE_first_tail_x15_r0_body.s199 PRE_first_tail_x15_r0_body.S199 = some (PRE_first_tail_x15_r0_body.s200, PRE_first_tail_x15_r0_body.S200)
end Host.Load.Run.Tpl
