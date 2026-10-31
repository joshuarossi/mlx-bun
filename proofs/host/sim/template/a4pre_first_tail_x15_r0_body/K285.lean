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
boot_rfl PRE_first_tail_x15_r0_body.stepA308 from PRE_first_tail_x15_r0_body.s1140 to PRE_first_tail_x15_r0_body.s1141 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1140).run PRE_first_tail_x15_r0_body.S1140 = some (PRE_first_tail_x15_r0_body.s1141, PRE_first_tail_x15_r0_body.S1141)
boot_rfl PRE_first_tail_x15_r0_body.patchB308 from PRE_first_tail_x15_r0_body.s1141 to PRE_first_tail_x15_r0_body.s1142 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1141).run PRE_first_tail_x15_r0_body.S1141 = some (PRE_first_tail_x15_r0_body.s1142, PRE_first_tail_x15_r0_body.S1142)
boot_rfl PRE_first_tail_x15_r0_body.k1142 from PRE_first_tail_x15_r0_body.s1142 to PRE_first_tail_x15_r0_body.s1143 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB308 ((nth? PRE_first_tail_x15_r0_body.ks 1142).getD 0) PRE_first_tail_x15_r0_body.s1142 PRE_first_tail_x15_r0_body.S1142 = some (PRE_first_tail_x15_r0_body.s1143, PRE_first_tail_x15_r0_body.S1143)
boot_rfl PRE_first_tail_x15_r0_body.k1143 from PRE_first_tail_x15_r0_body.s1143 to PRE_first_tail_x15_r0_body.s1144 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB308 ((nth? PRE_first_tail_x15_r0_body.ks 1143).getD 0) PRE_first_tail_x15_r0_body.s1143 PRE_first_tail_x15_r0_body.S1143 = some (PRE_first_tail_x15_r0_body.s1144, PRE_first_tail_x15_r0_body.S1144)
end Host.Load.Run.Tpl
