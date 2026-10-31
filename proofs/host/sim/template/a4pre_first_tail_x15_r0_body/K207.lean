import host.sim.template.a4pre_first_tail_x15_r0_body.H26
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
boot_rfl PRE_first_tail_x15_r0_body.k829 from PRE_first_tail_x15_r0_body.s829 to PRE_first_tail_x15_r0_body.s830 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB245 ((nth? PRE_first_tail_x15_r0_body.ks 829).getD 0) PRE_first_tail_x15_r0_body.s829 PRE_first_tail_x15_r0_body.S829 = some (PRE_first_tail_x15_r0_body.s830, PRE_first_tail_x15_r0_body.S830)
boot_rfl PRE_first_tail_x15_r0_body.stepA246 from PRE_first_tail_x15_r0_body.s830 to PRE_first_tail_x15_r0_body.s831 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s830).run PRE_first_tail_x15_r0_body.S830 = some (PRE_first_tail_x15_r0_body.s831, PRE_first_tail_x15_r0_body.S831)
boot_rfl PRE_first_tail_x15_r0_body.patchB246 from PRE_first_tail_x15_r0_body.s831 to PRE_first_tail_x15_r0_body.s832 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s831).run PRE_first_tail_x15_r0_body.S831 = some (PRE_first_tail_x15_r0_body.s832, PRE_first_tail_x15_r0_body.S832)
end Host.Load.Run.Tpl
