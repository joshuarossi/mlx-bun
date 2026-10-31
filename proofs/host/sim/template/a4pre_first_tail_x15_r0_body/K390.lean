import host.sim.template.a4pre_first_tail_x15_r0_body.H48
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
boot_rfl PRE_first_tail_x15_r0_body.patchB421 from PRE_first_tail_x15_r0_body.s1560 to PRE_first_tail_x15_r0_body.s1561 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1560).run PRE_first_tail_x15_r0_body.S1560 = some (PRE_first_tail_x15_r0_body.s1561, PRE_first_tail_x15_r0_body.S1561)
boot_rfl PRE_first_tail_x15_r0_body.k1561 from PRE_first_tail_x15_r0_body.s1561 to PRE_first_tail_x15_r0_body.s1562 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB421 ((nth? PRE_first_tail_x15_r0_body.ks 1561).getD 0) PRE_first_tail_x15_r0_body.s1561 PRE_first_tail_x15_r0_body.S1561 = some (PRE_first_tail_x15_r0_body.s1562, PRE_first_tail_x15_r0_body.S1562)
boot_rfl PRE_first_tail_x15_r0_body.stepA422 from PRE_first_tail_x15_r0_body.s1562 to PRE_first_tail_x15_r0_body.s1563 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1562).run PRE_first_tail_x15_r0_body.S1562 = some (PRE_first_tail_x15_r0_body.s1563, PRE_first_tail_x15_r0_body.S1563)
boot_rfl PRE_first_tail_x15_r0_body.patchB422 from PRE_first_tail_x15_r0_body.s1563 to PRE_first_tail_x15_r0_body.s1564 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1563).run PRE_first_tail_x15_r0_body.S1563 = some (PRE_first_tail_x15_r0_body.s1564, PRE_first_tail_x15_r0_body.S1564)
end Host.Load.Run.Tpl
