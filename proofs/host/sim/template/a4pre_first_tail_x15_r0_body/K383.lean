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
boot_rfl PRE_first_tail_x15_r0_body.k1532 from PRE_first_tail_x15_r0_body.s1532 to PRE_first_tail_x15_r0_body.s1533 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB413 ((nth? PRE_first_tail_x15_r0_body.ks 1532).getD 0) PRE_first_tail_x15_r0_body.s1532 PRE_first_tail_x15_r0_body.S1532 = some (PRE_first_tail_x15_r0_body.s1533, PRE_first_tail_x15_r0_body.S1533)
boot_rfl PRE_first_tail_x15_r0_body.stepA414 from PRE_first_tail_x15_r0_body.s1533 to PRE_first_tail_x15_r0_body.s1534 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1533).run PRE_first_tail_x15_r0_body.S1533 = some (PRE_first_tail_x15_r0_body.s1534, PRE_first_tail_x15_r0_body.S1534)
boot_rfl PRE_first_tail_x15_r0_body.patchB414 from PRE_first_tail_x15_r0_body.s1534 to PRE_first_tail_x15_r0_body.s1535 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1534).run PRE_first_tail_x15_r0_body.S1534 = some (PRE_first_tail_x15_r0_body.s1535, PRE_first_tail_x15_r0_body.S1535)
boot_rfl PRE_first_tail_x15_r0_body.k1535 from PRE_first_tail_x15_r0_body.s1535 to PRE_first_tail_x15_r0_body.s1536 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB414 ((nth? PRE_first_tail_x15_r0_body.ks 1535).getD 0) PRE_first_tail_x15_r0_body.s1535 PRE_first_tail_x15_r0_body.S1535 = some (PRE_first_tail_x15_r0_body.s1536, PRE_first_tail_x15_r0_body.S1536)
end Host.Load.Run.Tpl
