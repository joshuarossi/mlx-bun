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
boot_rfl PRE_first_tail_x15_r0_body.k206 from PRE_first_tail_x15_r0_body.s206 to PRE_first_tail_x15_r0_body.s207 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB61 ((nth? PRE_first_tail_x15_r0_body.ks 206).getD 0) PRE_first_tail_x15_r0_body.s206 PRE_first_tail_x15_r0_body.S206 = some (PRE_first_tail_x15_r0_body.s207, PRE_first_tail_x15_r0_body.S207)
boot_rfl PRE_first_tail_x15_r0_body.stepA62 from PRE_first_tail_x15_r0_body.s207 to PRE_first_tail_x15_r0_body.s208 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s207).run PRE_first_tail_x15_r0_body.S207 = some (PRE_first_tail_x15_r0_body.s208, PRE_first_tail_x15_r0_body.S208)
end Host.Load.Run.Tpl
