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
boot_rfl PRE_first_tail_x15_r0_body.patchB143 from PRE_first_tail_x15_r0_body.s528 to PRE_first_tail_x15_r0_body.s529 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s528).run PRE_first_tail_x15_r0_body.S528 = some (PRE_first_tail_x15_r0_body.s529, PRE_first_tail_x15_r0_body.S529)
boot_rfl PRE_first_tail_x15_r0_body.k529 from PRE_first_tail_x15_r0_body.s529 to PRE_first_tail_x15_r0_body.s530 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB143 ((nth? PRE_first_tail_x15_r0_body.ks 529).getD 0) PRE_first_tail_x15_r0_body.s529 PRE_first_tail_x15_r0_body.S529 = some (PRE_first_tail_x15_r0_body.s530, PRE_first_tail_x15_r0_body.S530)
boot_rfl PRE_first_tail_x15_r0_body.stepA144 from PRE_first_tail_x15_r0_body.s530 to PRE_first_tail_x15_r0_body.s531 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s530).run PRE_first_tail_x15_r0_body.S530 = some (PRE_first_tail_x15_r0_body.s531, PRE_first_tail_x15_r0_body.S531)
boot_rfl PRE_first_tail_x15_r0_body.patchB144 from PRE_first_tail_x15_r0_body.s531 to PRE_first_tail_x15_r0_body.s532 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s531).run PRE_first_tail_x15_r0_body.S531 = some (PRE_first_tail_x15_r0_body.s532, PRE_first_tail_x15_r0_body.S532)
end Host.Load.Run.Tpl
