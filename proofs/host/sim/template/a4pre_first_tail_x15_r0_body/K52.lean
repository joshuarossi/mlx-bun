import host.sim.template.a4pre_first_tail_x15_r0_body.H6
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
boot_rfl PRE_first_tail_x15_r0_body.k210 from PRE_first_tail_x15_r0_body.s210 to PRE_first_tail_x15_r0_body.s211 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB62 ((nth? PRE_first_tail_x15_r0_body.ks 210).getD 0) PRE_first_tail_x15_r0_body.s210 PRE_first_tail_x15_r0_body.S210 = some (PRE_first_tail_x15_r0_body.s211, PRE_first_tail_x15_r0_body.S211)
boot_rfl PRE_first_tail_x15_r0_body.stepA63 from PRE_first_tail_x15_r0_body.s211 to PRE_first_tail_x15_r0_body.s212 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s211).run PRE_first_tail_x15_r0_body.S211 = some (PRE_first_tail_x15_r0_body.s212, PRE_first_tail_x15_r0_body.S212)
end Host.Load.Run.Tpl
