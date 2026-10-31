import host.sim.template.a4pre_first_tail_x15_r0_body.H17
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
boot_rfl PRE_first_tail_x15_r0_body.stepA165 from PRE_first_tail_x15_r0_body.s556 to PRE_first_tail_x15_r0_body.s557 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s556).run PRE_first_tail_x15_r0_body.S556 = some (PRE_first_tail_x15_r0_body.s557, PRE_first_tail_x15_r0_body.S557)
boot_rfl PRE_first_tail_x15_r0_body.patchB165 from PRE_first_tail_x15_r0_body.s557 to PRE_first_tail_x15_r0_body.s558 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s557).run PRE_first_tail_x15_r0_body.S557 = some (PRE_first_tail_x15_r0_body.s558, PRE_first_tail_x15_r0_body.S558)
boot_rfl PRE_first_tail_x15_r0_body.k558 from PRE_first_tail_x15_r0_body.s558 to PRE_first_tail_x15_r0_body.s559 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB165 ((nth? PRE_first_tail_x15_r0_body.ks 558).getD 0) PRE_first_tail_x15_r0_body.s558 PRE_first_tail_x15_r0_body.S558 = some (PRE_first_tail_x15_r0_body.s559, PRE_first_tail_x15_r0_body.S559)
boot_rfl PRE_first_tail_x15_r0_body.stepA166 from PRE_first_tail_x15_r0_body.s559 to PRE_first_tail_x15_r0_body.s560 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s559).run PRE_first_tail_x15_r0_body.S559 = some (PRE_first_tail_x15_r0_body.s560, PRE_first_tail_x15_r0_body.S560)
end Host.Load.Run.Tpl
