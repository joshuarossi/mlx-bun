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
boot_rfl PRE_first_tail_x15_r0_body.stepA420 from PRE_first_tail_x15_r0_body.s1556 to PRE_first_tail_x15_r0_body.s1557 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1556).run PRE_first_tail_x15_r0_body.S1556 = some (PRE_first_tail_x15_r0_body.s1557, PRE_first_tail_x15_r0_body.S1557)
boot_rfl PRE_first_tail_x15_r0_body.patchB420 from PRE_first_tail_x15_r0_body.s1557 to PRE_first_tail_x15_r0_body.s1558 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1557).run PRE_first_tail_x15_r0_body.S1557 = some (PRE_first_tail_x15_r0_body.s1558, PRE_first_tail_x15_r0_body.S1558)
boot_rfl PRE_first_tail_x15_r0_body.k1558 from PRE_first_tail_x15_r0_body.s1558 to PRE_first_tail_x15_r0_body.s1559 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB420 ((nth? PRE_first_tail_x15_r0_body.ks 1558).getD 0) PRE_first_tail_x15_r0_body.s1558 PRE_first_tail_x15_r0_body.S1558 = some (PRE_first_tail_x15_r0_body.s1559, PRE_first_tail_x15_r0_body.S1559)
boot_rfl PRE_first_tail_x15_r0_body.stepA421 from PRE_first_tail_x15_r0_body.s1559 to PRE_first_tail_x15_r0_body.s1560 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1559).run PRE_first_tail_x15_r0_body.S1559 = some (PRE_first_tail_x15_r0_body.s1560, PRE_first_tail_x15_r0_body.S1560)
end Host.Load.Run.Tpl
