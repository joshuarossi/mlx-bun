import host.sim.template.a4pre_first_tail_x15_r0_body.H41
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
boot_rfl PRE_first_tail_x15_r0_body.stepA360 from PRE_first_tail_x15_r0_body.s1332 to PRE_first_tail_x15_r0_body.s1333 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1332).run PRE_first_tail_x15_r0_body.S1332 = some (PRE_first_tail_x15_r0_body.s1333, PRE_first_tail_x15_r0_body.S1333)
boot_rfl PRE_first_tail_x15_r0_body.patchB360 from PRE_first_tail_x15_r0_body.s1333 to PRE_first_tail_x15_r0_body.s1334 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1333).run PRE_first_tail_x15_r0_body.S1333 = some (PRE_first_tail_x15_r0_body.s1334, PRE_first_tail_x15_r0_body.S1334)
boot_rfl PRE_first_tail_x15_r0_body.k1334 from PRE_first_tail_x15_r0_body.s1334 to PRE_first_tail_x15_r0_body.s1335 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB360 ((nth? PRE_first_tail_x15_r0_body.ks 1334).getD 0) PRE_first_tail_x15_r0_body.s1334 PRE_first_tail_x15_r0_body.S1334 = some (PRE_first_tail_x15_r0_body.s1335, PRE_first_tail_x15_r0_body.S1335)
boot_rfl PRE_first_tail_x15_r0_body.stepA361 from PRE_first_tail_x15_r0_body.s1335 to PRE_first_tail_x15_r0_body.s1336 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1335).run PRE_first_tail_x15_r0_body.S1335 = some (PRE_first_tail_x15_r0_body.s1336, PRE_first_tail_x15_r0_body.S1336)
end Host.Load.Run.Tpl
