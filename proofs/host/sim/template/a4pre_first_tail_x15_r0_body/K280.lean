import host.sim.template.a4pre_first_tail_x15_r0_body.H35
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
boot_rfl PRE_first_tail_x15_r0_body.k1120 from PRE_first_tail_x15_r0_body.s1120 to PRE_first_tail_x15_r0_body.s1121 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB331 ((nth? PRE_first_tail_x15_r0_body.ks 1120).getD 0) PRE_first_tail_x15_r0_body.s1120 PRE_first_tail_x15_r0_body.S1120 = some (PRE_first_tail_x15_r0_body.s1121, PRE_first_tail_x15_r0_body.S1121)
boot_rfl PRE_first_tail_x15_r0_body.stepA332 from PRE_first_tail_x15_r0_body.s1121 to PRE_first_tail_x15_r0_body.s1122 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1121).run PRE_first_tail_x15_r0_body.S1121 = some (PRE_first_tail_x15_r0_body.s1122, PRE_first_tail_x15_r0_body.S1122)
boot_rfl PRE_first_tail_x15_r0_body.patchB332 from PRE_first_tail_x15_r0_body.s1122 to PRE_first_tail_x15_r0_body.s1123 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1122).run PRE_first_tail_x15_r0_body.S1122 = some (PRE_first_tail_x15_r0_body.s1123, PRE_first_tail_x15_r0_body.S1123)
boot_rfl PRE_first_tail_x15_r0_body.k1123 from PRE_first_tail_x15_r0_body.s1123 to PRE_first_tail_x15_r0_body.s1124 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB332 ((nth? PRE_first_tail_x15_r0_body.ks 1123).getD 0) PRE_first_tail_x15_r0_body.s1123 PRE_first_tail_x15_r0_body.S1123 = some (PRE_first_tail_x15_r0_body.s1124, PRE_first_tail_x15_r0_body.S1124)
end Host.Load.Run.Tpl
