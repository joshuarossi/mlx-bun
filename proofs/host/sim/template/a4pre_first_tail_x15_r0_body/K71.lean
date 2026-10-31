import host.sim.template.a4pre_first_tail_x15_r0_body.H9
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
boot_rfl PRE_first_tail_x15_r0_body.k285 from PRE_first_tail_x15_r0_body.s285 to PRE_first_tail_x15_r0_body.s286 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB77 ((nth? PRE_first_tail_x15_r0_body.ks 285).getD 0) PRE_first_tail_x15_r0_body.s285 PRE_first_tail_x15_r0_body.S285 = some (PRE_first_tail_x15_r0_body.s286, PRE_first_tail_x15_r0_body.S286)
boot_rfl PRE_first_tail_x15_r0_body.stepA78 from PRE_first_tail_x15_r0_body.s286 to PRE_first_tail_x15_r0_body.s287 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s286).run PRE_first_tail_x15_r0_body.S286 = some (PRE_first_tail_x15_r0_body.s287, PRE_first_tail_x15_r0_body.S287)
end Host.Load.Run.Tpl
