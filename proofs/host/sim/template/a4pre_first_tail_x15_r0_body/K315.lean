import host.sim.template.a4pre_first_tail_x15_r0_body.H39
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
boot_rfl PRE_first_tail_x15_r0_body.k1262 from PRE_first_tail_x15_r0_body.s1262 to PRE_first_tail_x15_r0_body.s1263 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB340 ((nth? PRE_first_tail_x15_r0_body.ks 1262).getD 0) PRE_first_tail_x15_r0_body.s1262 PRE_first_tail_x15_r0_body.S1262 = some (PRE_first_tail_x15_r0_body.s1263, PRE_first_tail_x15_r0_body.S1263)
boot_rfl PRE_first_tail_x15_r0_body.stepA341 from PRE_first_tail_x15_r0_body.s1263 to PRE_first_tail_x15_r0_body.s1264 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1263).run PRE_first_tail_x15_r0_body.S1263 = some (PRE_first_tail_x15_r0_body.s1264, PRE_first_tail_x15_r0_body.S1264)
end Host.Load.Run.Tpl
