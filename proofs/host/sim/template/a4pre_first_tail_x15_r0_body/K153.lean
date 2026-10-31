import host.sim.template.a4pre_first_tail_x15_r0_body.H19
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
boot_rfl PRE_first_tail_x15_r0_body.k612 from PRE_first_tail_x15_r0_body.s612 to PRE_first_tail_x15_r0_body.s613 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB165 ((nth? PRE_first_tail_x15_r0_body.ks 612).getD 0) PRE_first_tail_x15_r0_body.s612 PRE_first_tail_x15_r0_body.S612 = some (PRE_first_tail_x15_r0_body.s613, PRE_first_tail_x15_r0_body.S613)
boot_rfl PRE_first_tail_x15_r0_body.stepA166 from PRE_first_tail_x15_r0_body.s613 to PRE_first_tail_x15_r0_body.s614 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s613).run PRE_first_tail_x15_r0_body.S613 = some (PRE_first_tail_x15_r0_body.s614, PRE_first_tail_x15_r0_body.S614)
boot_rfl PRE_first_tail_x15_r0_body.patchB166 from PRE_first_tail_x15_r0_body.s614 to PRE_first_tail_x15_r0_body.s615 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s614).run PRE_first_tail_x15_r0_body.S614 = some (PRE_first_tail_x15_r0_body.s615, PRE_first_tail_x15_r0_body.S615)
boot_rfl PRE_first_tail_x15_r0_body.k615 from PRE_first_tail_x15_r0_body.s615 to PRE_first_tail_x15_r0_body.s616 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB166 ((nth? PRE_first_tail_x15_r0_body.ks 615).getD 0) PRE_first_tail_x15_r0_body.s615 PRE_first_tail_x15_r0_body.S615 = some (PRE_first_tail_x15_r0_body.s616, PRE_first_tail_x15_r0_body.S616)
end Host.Load.Run.Tpl
