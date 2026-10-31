import host.sim.template.a4pre_first_tail_x15_r0_body.H44
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
boot_rfl PRE_first_tail_x15_r0_body.stepA386 from PRE_first_tail_x15_r0_body.s1428 to PRE_first_tail_x15_r0_body.s1429 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1428).run PRE_first_tail_x15_r0_body.S1428 = some (PRE_first_tail_x15_r0_body.s1429, PRE_first_tail_x15_r0_body.S1429)
boot_rfl PRE_first_tail_x15_r0_body.patchB386 from PRE_first_tail_x15_r0_body.s1429 to PRE_first_tail_x15_r0_body.s1430 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1429).run PRE_first_tail_x15_r0_body.S1429 = some (PRE_first_tail_x15_r0_body.s1430, PRE_first_tail_x15_r0_body.S1430)
boot_rfl PRE_first_tail_x15_r0_body.k1430 from PRE_first_tail_x15_r0_body.s1430 to PRE_first_tail_x15_r0_body.s1431 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB386 ((nth? PRE_first_tail_x15_r0_body.ks 1430).getD 0) PRE_first_tail_x15_r0_body.s1430 PRE_first_tail_x15_r0_body.S1430 = some (PRE_first_tail_x15_r0_body.s1431, PRE_first_tail_x15_r0_body.S1431)
boot_rfl PRE_first_tail_x15_r0_body.k1431 from PRE_first_tail_x15_r0_body.s1431 to PRE_first_tail_x15_r0_body.s1432 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB386 ((nth? PRE_first_tail_x15_r0_body.ks 1431).getD 0) PRE_first_tail_x15_r0_body.s1431 PRE_first_tail_x15_r0_body.S1431 = some (PRE_first_tail_x15_r0_body.s1432, PRE_first_tail_x15_r0_body.S1432)
end Host.Load.Run.Tpl
