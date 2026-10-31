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
boot_rfl PRE_first_tail_x15_r0_body.stepA342 from PRE_first_tail_x15_r0_body.s1156 to PRE_first_tail_x15_r0_body.s1157 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1156).run PRE_first_tail_x15_r0_body.S1156 = some (PRE_first_tail_x15_r0_body.s1157, PRE_first_tail_x15_r0_body.S1157)
boot_rfl PRE_first_tail_x15_r0_body.patchB342 from PRE_first_tail_x15_r0_body.s1157 to PRE_first_tail_x15_r0_body.s1158 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1157).run PRE_first_tail_x15_r0_body.S1157 = some (PRE_first_tail_x15_r0_body.s1158, PRE_first_tail_x15_r0_body.S1158)
boot_rfl PRE_first_tail_x15_r0_body.k1158 from PRE_first_tail_x15_r0_body.s1158 to PRE_first_tail_x15_r0_body.s1159 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB342 ((nth? PRE_first_tail_x15_r0_body.ks 1158).getD 0) PRE_first_tail_x15_r0_body.s1158 PRE_first_tail_x15_r0_body.S1158 = some (PRE_first_tail_x15_r0_body.s1159, PRE_first_tail_x15_r0_body.S1159)
boot_rfl PRE_first_tail_x15_r0_body.stepA343 from PRE_first_tail_x15_r0_body.s1159 to PRE_first_tail_x15_r0_body.s1160 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1159).run PRE_first_tail_x15_r0_body.S1159 = some (PRE_first_tail_x15_r0_body.s1160, PRE_first_tail_x15_r0_body.S1160)
end Host.Load.Run.Tpl
