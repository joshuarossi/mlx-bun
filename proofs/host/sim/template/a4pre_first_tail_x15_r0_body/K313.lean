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
boot_rfl PRE_first_tail_x15_r0_body.k1254 from PRE_first_tail_x15_r0_body.s1254 to PRE_first_tail_x15_r0_body.s1255 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB338 ((nth? PRE_first_tail_x15_r0_body.ks 1254).getD 0) PRE_first_tail_x15_r0_body.s1254 PRE_first_tail_x15_r0_body.S1254 = some (PRE_first_tail_x15_r0_body.s1255, PRE_first_tail_x15_r0_body.S1255)
boot_rfl PRE_first_tail_x15_r0_body.stepA339 from PRE_first_tail_x15_r0_body.s1255 to PRE_first_tail_x15_r0_body.s1256 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1255).run PRE_first_tail_x15_r0_body.S1255 = some (PRE_first_tail_x15_r0_body.s1256, PRE_first_tail_x15_r0_body.S1256)
end Host.Load.Run.Tpl
