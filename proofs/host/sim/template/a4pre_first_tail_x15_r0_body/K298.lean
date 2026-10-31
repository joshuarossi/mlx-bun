import host.sim.template.a4pre_first_tail_x15_r0_body.H37
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
boot_rfl PRE_first_tail_x15_r0_body.stepA353 from PRE_first_tail_x15_r0_body.s1192 to PRE_first_tail_x15_r0_body.s1193 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1192).run PRE_first_tail_x15_r0_body.S1192 = some (PRE_first_tail_x15_r0_body.s1193, PRE_first_tail_x15_r0_body.S1193)
boot_rfl PRE_first_tail_x15_r0_body.patchB353 from PRE_first_tail_x15_r0_body.s1193 to PRE_first_tail_x15_r0_body.s1194 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1193).run PRE_first_tail_x15_r0_body.S1193 = some (PRE_first_tail_x15_r0_body.s1194, PRE_first_tail_x15_r0_body.S1194)
boot_rfl PRE_first_tail_x15_r0_body.k1194 from PRE_first_tail_x15_r0_body.s1194 to PRE_first_tail_x15_r0_body.s1195 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB353 ((nth? PRE_first_tail_x15_r0_body.ks 1194).getD 0) PRE_first_tail_x15_r0_body.s1194 PRE_first_tail_x15_r0_body.S1194 = some (PRE_first_tail_x15_r0_body.s1195, PRE_first_tail_x15_r0_body.S1195)
boot_rfl PRE_first_tail_x15_r0_body.stepA354 from PRE_first_tail_x15_r0_body.s1195 to PRE_first_tail_x15_r0_body.s1196 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1195).run PRE_first_tail_x15_r0_body.S1195 = some (PRE_first_tail_x15_r0_body.s1196, PRE_first_tail_x15_r0_body.S1196)
end Host.Load.Run.Tpl
