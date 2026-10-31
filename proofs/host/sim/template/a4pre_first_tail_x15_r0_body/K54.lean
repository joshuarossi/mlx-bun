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
boot_rfl PRE_first_tail_x15_r0_body.stepA59 from PRE_first_tail_x15_r0_body.s216 to PRE_first_tail_x15_r0_body.s217 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s216).run PRE_first_tail_x15_r0_body.S216 = some (PRE_first_tail_x15_r0_body.s217, PRE_first_tail_x15_r0_body.S217)
boot_rfl PRE_first_tail_x15_r0_body.k219 from PRE_first_tail_x15_r0_body.s219 to PRE_first_tail_x15_r0_body.s220 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB59 ((nth? PRE_first_tail_x15_r0_body.ks 219).getD 0) PRE_first_tail_x15_r0_body.s219 PRE_first_tail_x15_r0_body.S219 = some (PRE_first_tail_x15_r0_body.s220, PRE_first_tail_x15_r0_body.S220)
end Host.Load.Run.Tpl
