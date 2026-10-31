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
boot_rfl PRE_first_tail_x15_r0_body.k1124 from PRE_first_tail_x15_r0_body.s1124 to PRE_first_tail_x15_r0_body.s1125 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB303 ((nth? PRE_first_tail_x15_r0_body.ks 1124).getD 0) PRE_first_tail_x15_r0_body.s1124 PRE_first_tail_x15_r0_body.S1124 = some (PRE_first_tail_x15_r0_body.s1125, PRE_first_tail_x15_r0_body.S1125)
boot_rfl PRE_first_tail_x15_r0_body.stepA304 from PRE_first_tail_x15_r0_body.s1125 to PRE_first_tail_x15_r0_body.s1126 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1125).run PRE_first_tail_x15_r0_body.S1125 = some (PRE_first_tail_x15_r0_body.s1126, PRE_first_tail_x15_r0_body.S1126)
boot_rfl PRE_first_tail_x15_r0_body.patchB304 from PRE_first_tail_x15_r0_body.s1126 to PRE_first_tail_x15_r0_body.s1127 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1126).run PRE_first_tail_x15_r0_body.S1126 = some (PRE_first_tail_x15_r0_body.s1127, PRE_first_tail_x15_r0_body.S1127)
boot_rfl PRE_first_tail_x15_r0_body.k1127 from PRE_first_tail_x15_r0_body.s1127 to PRE_first_tail_x15_r0_body.s1128 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB304 ((nth? PRE_first_tail_x15_r0_body.ks 1127).getD 0) PRE_first_tail_x15_r0_body.s1127 PRE_first_tail_x15_r0_body.S1127 = some (PRE_first_tail_x15_r0_body.s1128, PRE_first_tail_x15_r0_body.S1128)
end Host.Load.Run.Tpl
