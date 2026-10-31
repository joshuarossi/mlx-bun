import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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
boot_rfl PRE_first_tail_x15_r0_body.stepA211 from PRE_first_tail_x15_r0_body.s712 to PRE_first_tail_x15_r0_body.s713 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s712).run PRE_first_tail_x15_r0_body.S712 = some (PRE_first_tail_x15_r0_body.s713, PRE_first_tail_x15_r0_body.S713)
boot_rfl PRE_first_tail_x15_r0_body.patchB211 from PRE_first_tail_x15_r0_body.s713 to PRE_first_tail_x15_r0_body.s714 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s713).run PRE_first_tail_x15_r0_body.S713 = some (PRE_first_tail_x15_r0_body.s714, PRE_first_tail_x15_r0_body.S714)
boot_rfl PRE_first_tail_x15_r0_body.k714 from PRE_first_tail_x15_r0_body.s714 to PRE_first_tail_x15_r0_body.s715 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB211 ((nth? PRE_first_tail_x15_r0_body.ks 714).getD 0) PRE_first_tail_x15_r0_body.s714 PRE_first_tail_x15_r0_body.S714 = some (PRE_first_tail_x15_r0_body.s715, PRE_first_tail_x15_r0_body.S715)
boot_rfl PRE_first_tail_x15_r0_body.stepA212 from PRE_first_tail_x15_r0_body.s715 to PRE_first_tail_x15_r0_body.s716 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s715).run PRE_first_tail_x15_r0_body.S715 = some (PRE_first_tail_x15_r0_body.s716, PRE_first_tail_x15_r0_body.S716)
end Host.Load.Run.Tpl
