import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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
boot_rfl PRE_first_tail_x15_r0_body.k768 from PRE_first_tail_x15_r0_body.s768 to PRE_first_tail_x15_r0_body.s769 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB227 ((nth? PRE_first_tail_x15_r0_body.ks 768).getD 0) PRE_first_tail_x15_r0_body.s768 PRE_first_tail_x15_r0_body.S768 = some (PRE_first_tail_x15_r0_body.s769, PRE_first_tail_x15_r0_body.S769)
boot_rfl PRE_first_tail_x15_r0_body.stepA228 from PRE_first_tail_x15_r0_body.s769 to PRE_first_tail_x15_r0_body.s770 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s769).run PRE_first_tail_x15_r0_body.S769 = some (PRE_first_tail_x15_r0_body.s770, PRE_first_tail_x15_r0_body.S770)
boot_rfl PRE_first_tail_x15_r0_body.patchB228 from PRE_first_tail_x15_r0_body.s770 to PRE_first_tail_x15_r0_body.s771 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s770).run PRE_first_tail_x15_r0_body.S770 = some (PRE_first_tail_x15_r0_body.s771, PRE_first_tail_x15_r0_body.S771)
boot_rfl PRE_first_tail_x15_r0_body.k771 from PRE_first_tail_x15_r0_body.s771 to PRE_first_tail_x15_r0_body.s772 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB228 ((nth? PRE_first_tail_x15_r0_body.ks 771).getD 0) PRE_first_tail_x15_r0_body.s771 PRE_first_tail_x15_r0_body.S771 = some (PRE_first_tail_x15_r0_body.s772, PRE_first_tail_x15_r0_body.S772)
end Host.Load.Run.Tpl
