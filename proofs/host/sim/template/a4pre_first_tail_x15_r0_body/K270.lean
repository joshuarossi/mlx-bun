import host.sim.template.a4pre_first_tail_x15_r0_body.H33
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
boot_rfl PRE_first_tail_x15_r0_body.k1080 from PRE_first_tail_x15_r0_body.s1080 to PRE_first_tail_x15_r0_body.s1081 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB319 ((nth? PRE_first_tail_x15_r0_body.ks 1080).getD 0) PRE_first_tail_x15_r0_body.s1080 PRE_first_tail_x15_r0_body.S1080 = some (PRE_first_tail_x15_r0_body.s1081, PRE_first_tail_x15_r0_body.S1081)
boot_rfl PRE_first_tail_x15_r0_body.stepA320 from PRE_first_tail_x15_r0_body.s1081 to PRE_first_tail_x15_r0_body.s1082 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1081).run PRE_first_tail_x15_r0_body.S1081 = some (PRE_first_tail_x15_r0_body.s1082, PRE_first_tail_x15_r0_body.S1082)
boot_rfl PRE_first_tail_x15_r0_body.patchB320 from PRE_first_tail_x15_r0_body.s1082 to PRE_first_tail_x15_r0_body.s1083 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1082).run PRE_first_tail_x15_r0_body.S1082 = some (PRE_first_tail_x15_r0_body.s1083, PRE_first_tail_x15_r0_body.S1083)
boot_rfl PRE_first_tail_x15_r0_body.k1083 from PRE_first_tail_x15_r0_body.s1083 to PRE_first_tail_x15_r0_body.s1084 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB320 ((nth? PRE_first_tail_x15_r0_body.ks 1083).getD 0) PRE_first_tail_x15_r0_body.s1083 PRE_first_tail_x15_r0_body.S1083 = some (PRE_first_tail_x15_r0_body.s1084, PRE_first_tail_x15_r0_body.S1084)
end Host.Load.Run.Tpl
