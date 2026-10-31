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
boot_rfl PRE_first_tail_x15_r0_body.k1209 from PRE_first_tail_x15_r0_body.s1209 to PRE_first_tail_x15_r0_body.s1210 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB357 ((nth? PRE_first_tail_x15_r0_body.ks 1209).getD 0) PRE_first_tail_x15_r0_body.s1209 PRE_first_tail_x15_r0_body.S1209 = some (PRE_first_tail_x15_r0_body.s1210, PRE_first_tail_x15_r0_body.S1210)
boot_rfl PRE_first_tail_x15_r0_body.stepA358 from PRE_first_tail_x15_r0_body.s1210 to PRE_first_tail_x15_r0_body.s1211 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1210).run PRE_first_tail_x15_r0_body.S1210 = some (PRE_first_tail_x15_r0_body.s1211, PRE_first_tail_x15_r0_body.S1211)
boot_rfl PRE_first_tail_x15_r0_body.patchB358 from PRE_first_tail_x15_r0_body.s1211 to PRE_first_tail_x15_r0_body.s1212 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1211).run PRE_first_tail_x15_r0_body.S1211 = some (PRE_first_tail_x15_r0_body.s1212, PRE_first_tail_x15_r0_body.S1212)
end Host.Load.Run.Tpl
