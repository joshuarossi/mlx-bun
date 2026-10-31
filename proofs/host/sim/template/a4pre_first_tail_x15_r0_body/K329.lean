import host.sim.template.a4pre_first_tail_x15_r0_body.H41
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
boot_rfl PRE_first_tail_x15_r0_body.k1316 from PRE_first_tail_x15_r0_body.s1316 to PRE_first_tail_x15_r0_body.s1317 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB355 ((nth? PRE_first_tail_x15_r0_body.ks 1316).getD 0) PRE_first_tail_x15_r0_body.s1316 PRE_first_tail_x15_r0_body.S1316 = some (PRE_first_tail_x15_r0_body.s1317, PRE_first_tail_x15_r0_body.S1317)
boot_rfl PRE_first_tail_x15_r0_body.stepA356 from PRE_first_tail_x15_r0_body.s1317 to PRE_first_tail_x15_r0_body.s1318 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1317).run PRE_first_tail_x15_r0_body.S1317 = some (PRE_first_tail_x15_r0_body.s1318, PRE_first_tail_x15_r0_body.S1318)
end Host.Load.Run.Tpl
