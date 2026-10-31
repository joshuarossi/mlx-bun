import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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
boot_rfl PRE_first_tail_x15_r0_body.k376 from PRE_first_tail_x15_r0_body.s376 to PRE_first_tail_x15_r0_body.s377 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB101 ((nth? PRE_first_tail_x15_r0_body.ks 376).getD 0) PRE_first_tail_x15_r0_body.s376 PRE_first_tail_x15_r0_body.S376 = some (PRE_first_tail_x15_r0_body.s377, PRE_first_tail_x15_r0_body.S377)
boot_rfl PRE_first_tail_x15_r0_body.stepA102 from PRE_first_tail_x15_r0_body.s377 to PRE_first_tail_x15_r0_body.s378 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s377).run PRE_first_tail_x15_r0_body.S377 = some (PRE_first_tail_x15_r0_body.s378, PRE_first_tail_x15_r0_body.S378)
boot_rfl PRE_first_tail_x15_r0_body.patchB102 from PRE_first_tail_x15_r0_body.s378 to PRE_first_tail_x15_r0_body.s379 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s378).run PRE_first_tail_x15_r0_body.S378 = some (PRE_first_tail_x15_r0_body.s379, PRE_first_tail_x15_r0_body.S379)
boot_rfl PRE_first_tail_x15_r0_body.k379 from PRE_first_tail_x15_r0_body.s379 to PRE_first_tail_x15_r0_body.s380 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB102 ((nth? PRE_first_tail_x15_r0_body.ks 379).getD 0) PRE_first_tail_x15_r0_body.s379 PRE_first_tail_x15_r0_body.S379 = some (PRE_first_tail_x15_r0_body.s380, PRE_first_tail_x15_r0_body.S380)
end Host.Load.Run.Tpl
