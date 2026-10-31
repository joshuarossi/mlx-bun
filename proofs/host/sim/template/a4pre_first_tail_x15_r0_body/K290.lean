import host.sim.template.a4pre_first_tail_x15_r0_body.H36
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
boot_rfl PRE_first_tail_x15_r0_body.patchB313 from PRE_first_tail_x15_r0_body.s1160 to PRE_first_tail_x15_r0_body.s1161 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1160).run PRE_first_tail_x15_r0_body.S1160 = some (PRE_first_tail_x15_r0_body.s1161, PRE_first_tail_x15_r0_body.S1161)
boot_rfl PRE_first_tail_x15_r0_body.k1161 from PRE_first_tail_x15_r0_body.s1161 to PRE_first_tail_x15_r0_body.s1162 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB313 ((nth? PRE_first_tail_x15_r0_body.ks 1161).getD 0) PRE_first_tail_x15_r0_body.s1161 PRE_first_tail_x15_r0_body.S1161 = some (PRE_first_tail_x15_r0_body.s1162, PRE_first_tail_x15_r0_body.S1162)
boot_rfl PRE_first_tail_x15_r0_body.stepA314 from PRE_first_tail_x15_r0_body.s1162 to PRE_first_tail_x15_r0_body.s1163 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1162).run PRE_first_tail_x15_r0_body.S1162 = some (PRE_first_tail_x15_r0_body.s1163, PRE_first_tail_x15_r0_body.S1163)
boot_rfl PRE_first_tail_x15_r0_body.patchB314 from PRE_first_tail_x15_r0_body.s1163 to PRE_first_tail_x15_r0_body.s1164 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1163).run PRE_first_tail_x15_r0_body.S1163 = some (PRE_first_tail_x15_r0_body.s1164, PRE_first_tail_x15_r0_body.S1164)
end Host.Load.Run.Tpl
