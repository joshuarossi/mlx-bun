import host.sim.template.a4pre_first_tail_x15_r0_body.H8
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
boot_rfl PRE_first_tail_x15_r0_body.k260 from PRE_first_tail_x15_r0_body.s260 to PRE_first_tail_x15_r0_body.s261 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB70 ((nth? PRE_first_tail_x15_r0_body.ks 260).getD 0) PRE_first_tail_x15_r0_body.s260 PRE_first_tail_x15_r0_body.S260 = some (PRE_first_tail_x15_r0_body.s261, PRE_first_tail_x15_r0_body.S261)
boot_rfl PRE_first_tail_x15_r0_body.k261 from PRE_first_tail_x15_r0_body.s261 to PRE_first_tail_x15_r0_body.s262 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB70 ((nth? PRE_first_tail_x15_r0_body.ks 261).getD 0) PRE_first_tail_x15_r0_body.s261 PRE_first_tail_x15_r0_body.S261 = some (PRE_first_tail_x15_r0_body.s262, PRE_first_tail_x15_r0_body.S262)
boot_rfl PRE_first_tail_x15_r0_body.stepA71 from PRE_first_tail_x15_r0_body.s262 to PRE_first_tail_x15_r0_body.s263 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s262).run PRE_first_tail_x15_r0_body.S262 = some (PRE_first_tail_x15_r0_body.s263, PRE_first_tail_x15_r0_body.S263)
boot_rfl PRE_first_tail_x15_r0_body.patchB71 from PRE_first_tail_x15_r0_body.s263 to PRE_first_tail_x15_r0_body.s264 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s263).run PRE_first_tail_x15_r0_body.S263 = some (PRE_first_tail_x15_r0_body.s264, PRE_first_tail_x15_r0_body.S264)
end Host.Load.Run.Tpl
