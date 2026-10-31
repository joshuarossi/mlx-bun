import host.sim.template.a4pre_first_tail_x15_r0_body.H34
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
boot_rfl PRE_first_tail_x15_r0_body.k1090 from PRE_first_tail_x15_r0_body.s1090 to PRE_first_tail_x15_r0_body.s1091 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB294 ((nth? PRE_first_tail_x15_r0_body.ks 1090).getD 0) PRE_first_tail_x15_r0_body.s1090 PRE_first_tail_x15_r0_body.S1090 = some (PRE_first_tail_x15_r0_body.s1091, PRE_first_tail_x15_r0_body.S1091)
boot_rfl PRE_first_tail_x15_r0_body.stepA295 from PRE_first_tail_x15_r0_body.s1091 to PRE_first_tail_x15_r0_body.s1092 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1091).run PRE_first_tail_x15_r0_body.S1091 = some (PRE_first_tail_x15_r0_body.s1092, PRE_first_tail_x15_r0_body.S1092)
end Host.Load.Run.Tpl
