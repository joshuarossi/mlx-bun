import host.sim.template.a4pre_first_tail_x15_r0_body.H23
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
boot_rfl PRE_first_tail_x15_r0_body.stepA223 from PRE_first_tail_x15_r0_body.s752 to PRE_first_tail_x15_r0_body.s753 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s752).run PRE_first_tail_x15_r0_body.S752 = some (PRE_first_tail_x15_r0_body.s753, PRE_first_tail_x15_r0_body.S753)
boot_rfl PRE_first_tail_x15_r0_body.patchB223 from PRE_first_tail_x15_r0_body.s753 to PRE_first_tail_x15_r0_body.s754 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s753).run PRE_first_tail_x15_r0_body.S753 = some (PRE_first_tail_x15_r0_body.s754, PRE_first_tail_x15_r0_body.S754)
boot_rfl PRE_first_tail_x15_r0_body.k754 from PRE_first_tail_x15_r0_body.s754 to PRE_first_tail_x15_r0_body.s755 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB223 ((nth? PRE_first_tail_x15_r0_body.ks 754).getD 0) PRE_first_tail_x15_r0_body.s754 PRE_first_tail_x15_r0_body.S754 = some (PRE_first_tail_x15_r0_body.s755, PRE_first_tail_x15_r0_body.S755)
boot_rfl PRE_first_tail_x15_r0_body.stepA224 from PRE_first_tail_x15_r0_body.s755 to PRE_first_tail_x15_r0_body.s756 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s755).run PRE_first_tail_x15_r0_body.S755 = some (PRE_first_tail_x15_r0_body.s756, PRE_first_tail_x15_r0_body.S756)
end Host.Load.Run.Tpl
