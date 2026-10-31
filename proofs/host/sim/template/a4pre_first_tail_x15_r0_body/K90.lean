import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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
boot_rfl PRE_first_tail_x15_r0_body.stepA98 from PRE_first_tail_x15_r0_body.s360 to PRE_first_tail_x15_r0_body.s361 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s360).run PRE_first_tail_x15_r0_body.S360 = some (PRE_first_tail_x15_r0_body.s361, PRE_first_tail_x15_r0_body.S361)
boot_rfl PRE_first_tail_x15_r0_body.k363 from PRE_first_tail_x15_r0_body.s363 to PRE_first_tail_x15_r0_body.s364 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB98 ((nth? PRE_first_tail_x15_r0_body.ks 363).getD 0) PRE_first_tail_x15_r0_body.s363 PRE_first_tail_x15_r0_body.S363 = some (PRE_first_tail_x15_r0_body.s364, PRE_first_tail_x15_r0_body.S364)
end Host.Load.Run.Tpl
