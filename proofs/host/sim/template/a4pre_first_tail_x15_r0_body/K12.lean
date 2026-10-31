import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.stepA14 from PRE_first_tail_x15_r0_body.s48 to PRE_first_tail_x15_r0_body.s49 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s48).run PRE_first_tail_x15_r0_body.S48 = some (PRE_first_tail_x15_r0_body.s49, PRE_first_tail_x15_r0_body.S49)
boot_rfl PRE_first_tail_x15_r0_body.patchB14 from PRE_first_tail_x15_r0_body.s49 to PRE_first_tail_x15_r0_body.s50 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s49).run PRE_first_tail_x15_r0_body.S49 = some (PRE_first_tail_x15_r0_body.s50, PRE_first_tail_x15_r0_body.S50)
boot_rfl PRE_first_tail_x15_r0_body.k50 from PRE_first_tail_x15_r0_body.s50 to PRE_first_tail_x15_r0_body.s51 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB14 ((nth? PRE_first_tail_x15_r0_body.ks 50).getD 0) PRE_first_tail_x15_r0_body.s50 PRE_first_tail_x15_r0_body.S50 = some (PRE_first_tail_x15_r0_body.s51, PRE_first_tail_x15_r0_body.S51)
boot_rfl PRE_first_tail_x15_r0_body.k51 from PRE_first_tail_x15_r0_body.s51 to PRE_first_tail_x15_r0_body.s52 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB14 ((nth? PRE_first_tail_x15_r0_body.ks 51).getD 0) PRE_first_tail_x15_r0_body.s51 PRE_first_tail_x15_r0_body.S51 = some (PRE_first_tail_x15_r0_body.s52, PRE_first_tail_x15_r0_body.S52)
end Host.Load.Run.Tpl
