import host.sim.template.a4pre_first_tail_x15_r0_body.H47
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
boot_rfl PRE_first_tail_x15_r0_body.patchB412 from PRE_first_tail_x15_r0_body.s1528 to PRE_first_tail_x15_r0_body.s1529 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1528).run PRE_first_tail_x15_r0_body.S1528 = some (PRE_first_tail_x15_r0_body.s1529, PRE_first_tail_x15_r0_body.S1529)
boot_rfl PRE_first_tail_x15_r0_body.k1529 from PRE_first_tail_x15_r0_body.s1529 to PRE_first_tail_x15_r0_body.s1530 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB412 ((nth? PRE_first_tail_x15_r0_body.ks 1529).getD 0) PRE_first_tail_x15_r0_body.s1529 PRE_first_tail_x15_r0_body.S1529 = some (PRE_first_tail_x15_r0_body.s1530, PRE_first_tail_x15_r0_body.S1530)
boot_rfl PRE_first_tail_x15_r0_body.stepA413 from PRE_first_tail_x15_r0_body.s1530 to PRE_first_tail_x15_r0_body.s1531 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1530).run PRE_first_tail_x15_r0_body.S1530 = some (PRE_first_tail_x15_r0_body.s1531, PRE_first_tail_x15_r0_body.S1531)
boot_rfl PRE_first_tail_x15_r0_body.patchB413 from PRE_first_tail_x15_r0_body.s1531 to PRE_first_tail_x15_r0_body.s1532 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1531).run PRE_first_tail_x15_r0_body.S1531 = some (PRE_first_tail_x15_r0_body.s1532, PRE_first_tail_x15_r0_body.S1532)
end Host.Load.Run.Tpl
