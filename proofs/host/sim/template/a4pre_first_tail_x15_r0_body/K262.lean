import host.sim.template.a4pre_first_tail_x15_r0_body.H32
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
boot_rfl PRE_first_tail_x15_r0_body.patchB283 from PRE_first_tail_x15_r0_body.s1048 to PRE_first_tail_x15_r0_body.s1049 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1048).run PRE_first_tail_x15_r0_body.S1048 = some (PRE_first_tail_x15_r0_body.s1049, PRE_first_tail_x15_r0_body.S1049)
boot_rfl PRE_first_tail_x15_r0_body.k1049 from PRE_first_tail_x15_r0_body.s1049 to PRE_first_tail_x15_r0_body.s1050 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB283 ((nth? PRE_first_tail_x15_r0_body.ks 1049).getD 0) PRE_first_tail_x15_r0_body.s1049 PRE_first_tail_x15_r0_body.S1049 = some (PRE_first_tail_x15_r0_body.s1050, PRE_first_tail_x15_r0_body.S1050)
boot_rfl PRE_first_tail_x15_r0_body.stepA284 from PRE_first_tail_x15_r0_body.s1050 to PRE_first_tail_x15_r0_body.s1051 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1050).run PRE_first_tail_x15_r0_body.S1050 = some (PRE_first_tail_x15_r0_body.s1051, PRE_first_tail_x15_r0_body.S1051)
end Host.Load.Run.Tpl
