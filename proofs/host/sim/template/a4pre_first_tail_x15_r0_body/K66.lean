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
boot_rfl PRE_first_tail_x15_r0_body.k264 from PRE_first_tail_x15_r0_body.s264 to PRE_first_tail_x15_r0_body.s265 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB78 ((nth? PRE_first_tail_x15_r0_body.ks 264).getD 0) PRE_first_tail_x15_r0_body.s264 PRE_first_tail_x15_r0_body.S264 = some (PRE_first_tail_x15_r0_body.s265, PRE_first_tail_x15_r0_body.S265)
boot_rfl PRE_first_tail_x15_r0_body.stepA79 from PRE_first_tail_x15_r0_body.s265 to PRE_first_tail_x15_r0_body.s266 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s265).run PRE_first_tail_x15_r0_body.S265 = some (PRE_first_tail_x15_r0_body.s266, PRE_first_tail_x15_r0_body.S266)
boot_rfl PRE_first_tail_x15_r0_body.patchB79 from PRE_first_tail_x15_r0_body.s266 to PRE_first_tail_x15_r0_body.s267 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s266).run PRE_first_tail_x15_r0_body.S266 = some (PRE_first_tail_x15_r0_body.s267, PRE_first_tail_x15_r0_body.S267)
boot_rfl PRE_first_tail_x15_r0_body.k267 from PRE_first_tail_x15_r0_body.s267 to PRE_first_tail_x15_r0_body.s268 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB79 ((nth? PRE_first_tail_x15_r0_body.ks 267).getD 0) PRE_first_tail_x15_r0_body.s267 PRE_first_tail_x15_r0_body.S267 = some (PRE_first_tail_x15_r0_body.s268, PRE_first_tail_x15_r0_body.S268)
end Host.Load.Run.Tpl
