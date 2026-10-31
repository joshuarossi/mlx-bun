import host.sim.template.a4pre_first_tail_x15_r0_body.H42
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
boot_rfl PRE_first_tail_x15_r0_body.patchB366 from PRE_first_tail_x15_r0_body.s1356 to PRE_first_tail_x15_r0_body.s1357 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1356).run PRE_first_tail_x15_r0_body.S1356 = some (PRE_first_tail_x15_r0_body.s1357, PRE_first_tail_x15_r0_body.S1357)
boot_rfl PRE_first_tail_x15_r0_body.k1357 from PRE_first_tail_x15_r0_body.s1357 to PRE_first_tail_x15_r0_body.s1358 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB366 ((nth? PRE_first_tail_x15_r0_body.ks 1357).getD 0) PRE_first_tail_x15_r0_body.s1357 PRE_first_tail_x15_r0_body.S1357 = some (PRE_first_tail_x15_r0_body.s1358, PRE_first_tail_x15_r0_body.S1358)
boot_rfl PRE_first_tail_x15_r0_body.k1358 from PRE_first_tail_x15_r0_body.s1358 to PRE_first_tail_x15_r0_body.s1359 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB366 ((nth? PRE_first_tail_x15_r0_body.ks 1358).getD 0) PRE_first_tail_x15_r0_body.s1358 PRE_first_tail_x15_r0_body.S1358 = some (PRE_first_tail_x15_r0_body.s1359, PRE_first_tail_x15_r0_body.S1359)
boot_rfl PRE_first_tail_x15_r0_body.stepA367 from PRE_first_tail_x15_r0_body.s1359 to PRE_first_tail_x15_r0_body.s1360 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1359).run PRE_first_tail_x15_r0_body.S1359 = some (PRE_first_tail_x15_r0_body.s1360, PRE_first_tail_x15_r0_body.S1360)
end Host.Load.Run.Tpl
