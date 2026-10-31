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
boot_rfl PRE_first_tail_x15_r0_body.k1256 from PRE_first_tail_x15_r0_body.s1256 to PRE_first_tail_x15_r0_body.s1257 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB371 ((nth? PRE_first_tail_x15_r0_body.ks 1256).getD 0) PRE_first_tail_x15_r0_body.s1256 PRE_first_tail_x15_r0_body.S1256 = some (PRE_first_tail_x15_r0_body.s1257, PRE_first_tail_x15_r0_body.S1257)
boot_rfl PRE_first_tail_x15_r0_body.stepA372 from PRE_first_tail_x15_r0_body.s1257 to PRE_first_tail_x15_r0_body.s1258 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1257).run PRE_first_tail_x15_r0_body.S1257 = some (PRE_first_tail_x15_r0_body.s1258, PRE_first_tail_x15_r0_body.S1258)
end Host.Load.Run.Tpl
