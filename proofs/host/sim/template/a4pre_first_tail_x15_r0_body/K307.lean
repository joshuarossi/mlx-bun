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
boot_rfl PRE_first_tail_x15_r0_body.k1228 from PRE_first_tail_x15_r0_body.s1228 to PRE_first_tail_x15_r0_body.s1229 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB363 ((nth? PRE_first_tail_x15_r0_body.ks 1228).getD 0) PRE_first_tail_x15_r0_body.s1228 PRE_first_tail_x15_r0_body.S1228 = some (PRE_first_tail_x15_r0_body.s1229, PRE_first_tail_x15_r0_body.S1229)
boot_rfl PRE_first_tail_x15_r0_body.stepA364 from PRE_first_tail_x15_r0_body.s1229 to PRE_first_tail_x15_r0_body.s1230 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1229).run PRE_first_tail_x15_r0_body.S1229 = some (PRE_first_tail_x15_r0_body.s1230, PRE_first_tail_x15_r0_body.S1230)
end Host.Load.Run.Tpl
