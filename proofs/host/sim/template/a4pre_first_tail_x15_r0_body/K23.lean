import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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
boot_rfl PRE_first_tail_x15_r0_body.k92 from PRE_first_tail_x15_r0_body.s92 to PRE_first_tail_x15_r0_body.s93 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB25 ((nth? PRE_first_tail_x15_r0_body.ks 92).getD 0) PRE_first_tail_x15_r0_body.s92 PRE_first_tail_x15_r0_body.S92 = some (PRE_first_tail_x15_r0_body.s93, PRE_first_tail_x15_r0_body.S93)
boot_rfl PRE_first_tail_x15_r0_body.k93 from PRE_first_tail_x15_r0_body.s93 to PRE_first_tail_x15_r0_body.s94 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB25 ((nth? PRE_first_tail_x15_r0_body.ks 93).getD 0) PRE_first_tail_x15_r0_body.s93 PRE_first_tail_x15_r0_body.S93 = some (PRE_first_tail_x15_r0_body.s94, PRE_first_tail_x15_r0_body.S94)
boot_rfl PRE_first_tail_x15_r0_body.stepA26 from PRE_first_tail_x15_r0_body.s94 to PRE_first_tail_x15_r0_body.s95 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s94).run PRE_first_tail_x15_r0_body.S94 = some (PRE_first_tail_x15_r0_body.s95, PRE_first_tail_x15_r0_body.S95)
boot_rfl PRE_first_tail_x15_r0_body.patchB26 from PRE_first_tail_x15_r0_body.s95 to PRE_first_tail_x15_r0_body.s96 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s95).run PRE_first_tail_x15_r0_body.S95 = some (PRE_first_tail_x15_r0_body.s96, PRE_first_tail_x15_r0_body.S96)
end Host.Load.Run.Tpl
