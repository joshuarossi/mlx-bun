import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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
boot_rfl PRE_first_tail_x15_r0_body.k521 from PRE_first_tail_x15_r0_body.s521 to PRE_first_tail_x15_r0_body.s522 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB154 ((nth? PRE_first_tail_x15_r0_body.ks 521).getD 0) PRE_first_tail_x15_r0_body.s521 PRE_first_tail_x15_r0_body.S521 = some (PRE_first_tail_x15_r0_body.s522, PRE_first_tail_x15_r0_body.S522)
boot_rfl PRE_first_tail_x15_r0_body.stepA155 from PRE_first_tail_x15_r0_body.s522 to PRE_first_tail_x15_r0_body.s523 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s522).run PRE_first_tail_x15_r0_body.S522 = some (PRE_first_tail_x15_r0_body.s523, PRE_first_tail_x15_r0_body.S523)
end Host.Load.Run.Tpl
