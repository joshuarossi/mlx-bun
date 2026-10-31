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
boot_rfl PRE_first_tail_x15_r0_body.stepA330 from PRE_first_tail_x15_r0_body.s1220 to PRE_first_tail_x15_r0_body.s1221 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1220).run PRE_first_tail_x15_r0_body.S1220 = some (PRE_first_tail_x15_r0_body.s1221, PRE_first_tail_x15_r0_body.S1221)
boot_rfl PRE_first_tail_x15_r0_body.patchB330 from PRE_first_tail_x15_r0_body.s1221 to PRE_first_tail_x15_r0_body.s1222 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1221).run PRE_first_tail_x15_r0_body.S1221 = some (PRE_first_tail_x15_r0_body.s1222, PRE_first_tail_x15_r0_body.S1222)
boot_rfl PRE_first_tail_x15_r0_body.k1222 from PRE_first_tail_x15_r0_body.s1222 to PRE_first_tail_x15_r0_body.s1223 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB330 ((nth? PRE_first_tail_x15_r0_body.ks 1222).getD 0) PRE_first_tail_x15_r0_body.s1222 PRE_first_tail_x15_r0_body.S1222 = some (PRE_first_tail_x15_r0_body.s1223, PRE_first_tail_x15_r0_body.S1223)
boot_rfl PRE_first_tail_x15_r0_body.stepA331 from PRE_first_tail_x15_r0_body.s1223 to PRE_first_tail_x15_r0_body.s1224 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1223).run PRE_first_tail_x15_r0_body.S1223 = some (PRE_first_tail_x15_r0_body.s1224, PRE_first_tail_x15_r0_body.S1224)
end Host.Load.Run.Tpl
