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
boot_rfl PRE_first_tail_x15_r0_body.k774 from PRE_first_tail_x15_r0_body.s774 to PRE_first_tail_x15_r0_body.s775 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB209 ((nth? PRE_first_tail_x15_r0_body.ks 774).getD 0) PRE_first_tail_x15_r0_body.s774 PRE_first_tail_x15_r0_body.S774 = some (PRE_first_tail_x15_r0_body.s775, PRE_first_tail_x15_r0_body.S775)
boot_rfl PRE_first_tail_x15_r0_body.stepA210 from PRE_first_tail_x15_r0_body.s775 to PRE_first_tail_x15_r0_body.s776 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s775).run PRE_first_tail_x15_r0_body.S775 = some (PRE_first_tail_x15_r0_body.s776, PRE_first_tail_x15_r0_body.S776)
end Host.Load.Run.Tpl
