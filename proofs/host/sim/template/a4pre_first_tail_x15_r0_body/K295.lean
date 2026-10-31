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
boot_rfl PRE_first_tail_x15_r0_body.k1180 from PRE_first_tail_x15_r0_body.s1180 to PRE_first_tail_x15_r0_body.s1181 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB318 ((nth? PRE_first_tail_x15_r0_body.ks 1180).getD 0) PRE_first_tail_x15_r0_body.s1180 PRE_first_tail_x15_r0_body.S1180 = some (PRE_first_tail_x15_r0_body.s1181, PRE_first_tail_x15_r0_body.S1181)
boot_rfl PRE_first_tail_x15_r0_body.k1181 from PRE_first_tail_x15_r0_body.s1181 to PRE_first_tail_x15_r0_body.s1182 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB318 ((nth? PRE_first_tail_x15_r0_body.ks 1181).getD 0) PRE_first_tail_x15_r0_body.s1181 PRE_first_tail_x15_r0_body.S1181 = some (PRE_first_tail_x15_r0_body.s1182, PRE_first_tail_x15_r0_body.S1182)
boot_rfl PRE_first_tail_x15_r0_body.stepA319 from PRE_first_tail_x15_r0_body.s1182 to PRE_first_tail_x15_r0_body.s1183 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1182).run PRE_first_tail_x15_r0_body.S1182 = some (PRE_first_tail_x15_r0_body.s1183, PRE_first_tail_x15_r0_body.S1183)
boot_rfl PRE_first_tail_x15_r0_body.patchB319 from PRE_first_tail_x15_r0_body.s1183 to PRE_first_tail_x15_r0_body.s1184 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1183).run PRE_first_tail_x15_r0_body.S1183 = some (PRE_first_tail_x15_r0_body.s1184, PRE_first_tail_x15_r0_body.S1184)
end Host.Load.Run.Tpl
