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
boot_rfl PRE_first_tail_x15_r0_body.k568 from PRE_first_tail_x15_r0_body.s568 to PRE_first_tail_x15_r0_body.s569 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB168 ((nth? PRE_first_tail_x15_r0_body.ks 568).getD 0) PRE_first_tail_x15_r0_body.s568 PRE_first_tail_x15_r0_body.S568 = some (PRE_first_tail_x15_r0_body.s569, PRE_first_tail_x15_r0_body.S569)
boot_rfl PRE_first_tail_x15_r0_body.stepA169 from PRE_first_tail_x15_r0_body.s569 to PRE_first_tail_x15_r0_body.s570 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s569).run PRE_first_tail_x15_r0_body.S569 = some (PRE_first_tail_x15_r0_body.s570, PRE_first_tail_x15_r0_body.S570)
boot_rfl PRE_first_tail_x15_r0_body.patchB169 from PRE_first_tail_x15_r0_body.s570 to PRE_first_tail_x15_r0_body.s571 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s570).run PRE_first_tail_x15_r0_body.S570 = some (PRE_first_tail_x15_r0_body.s571, PRE_first_tail_x15_r0_body.S571)
boot_rfl PRE_first_tail_x15_r0_body.k571 from PRE_first_tail_x15_r0_body.s571 to PRE_first_tail_x15_r0_body.s572 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB169 ((nth? PRE_first_tail_x15_r0_body.ks 571).getD 0) PRE_first_tail_x15_r0_body.s571 PRE_first_tail_x15_r0_body.S571 = some (PRE_first_tail_x15_r0_body.s572, PRE_first_tail_x15_r0_body.S572)
end Host.Load.Run.Tpl
