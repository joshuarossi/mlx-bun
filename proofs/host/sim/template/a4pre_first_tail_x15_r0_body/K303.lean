import host.sim.template.a4pre_first_tail_x15_r0_body.H38
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
boot_rfl PRE_first_tail_x15_r0_body.k1212 from PRE_first_tail_x15_r0_body.s1212 to PRE_first_tail_x15_r0_body.s1213 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB358 ((nth? PRE_first_tail_x15_r0_body.ks 1212).getD 0) PRE_first_tail_x15_r0_body.s1212 PRE_first_tail_x15_r0_body.S1212 = some (PRE_first_tail_x15_r0_body.s1213, PRE_first_tail_x15_r0_body.S1213)
boot_rfl PRE_first_tail_x15_r0_body.stepA359 from PRE_first_tail_x15_r0_body.s1213 to PRE_first_tail_x15_r0_body.s1214 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1213).run PRE_first_tail_x15_r0_body.S1213 = some (PRE_first_tail_x15_r0_body.s1214, PRE_first_tail_x15_r0_body.S1214)
boot_rfl PRE_first_tail_x15_r0_body.patchB359 from PRE_first_tail_x15_r0_body.s1214 to PRE_first_tail_x15_r0_body.s1215 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1214).run PRE_first_tail_x15_r0_body.S1214 = some (PRE_first_tail_x15_r0_body.s1215, PRE_first_tail_x15_r0_body.S1215)
boot_rfl PRE_first_tail_x15_r0_body.k1215 from PRE_first_tail_x15_r0_body.s1215 to PRE_first_tail_x15_r0_body.s1216 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB359 ((nth? PRE_first_tail_x15_r0_body.ks 1215).getD 0) PRE_first_tail_x15_r0_body.s1215 PRE_first_tail_x15_r0_body.S1215 = some (PRE_first_tail_x15_r0_body.s1216, PRE_first_tail_x15_r0_body.S1216)
end Host.Load.Run.Tpl
