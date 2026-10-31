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
boot_rfl PRE_first_tail_x15_r0_body.k1188 from PRE_first_tail_x15_r0_body.s1188 to PRE_first_tail_x15_r0_body.s1189 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB351 ((nth? PRE_first_tail_x15_r0_body.ks 1188).getD 0) PRE_first_tail_x15_r0_body.s1188 PRE_first_tail_x15_r0_body.S1188 = some (PRE_first_tail_x15_r0_body.s1189, PRE_first_tail_x15_r0_body.S1189)
boot_rfl PRE_first_tail_x15_r0_body.stepA352 from PRE_first_tail_x15_r0_body.s1189 to PRE_first_tail_x15_r0_body.s1190 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1189).run PRE_first_tail_x15_r0_body.S1189 = some (PRE_first_tail_x15_r0_body.s1190, PRE_first_tail_x15_r0_body.S1190)
boot_rfl PRE_first_tail_x15_r0_body.patchB352 from PRE_first_tail_x15_r0_body.s1190 to PRE_first_tail_x15_r0_body.s1191 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1190).run PRE_first_tail_x15_r0_body.S1190 = some (PRE_first_tail_x15_r0_body.s1191, PRE_first_tail_x15_r0_body.S1191)
boot_rfl PRE_first_tail_x15_r0_body.k1191 from PRE_first_tail_x15_r0_body.s1191 to PRE_first_tail_x15_r0_body.s1192 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB352 ((nth? PRE_first_tail_x15_r0_body.ks 1191).getD 0) PRE_first_tail_x15_r0_body.s1191 PRE_first_tail_x15_r0_body.S1191 = some (PRE_first_tail_x15_r0_body.s1192, PRE_first_tail_x15_r0_body.S1192)
end Host.Load.Run.Tpl
