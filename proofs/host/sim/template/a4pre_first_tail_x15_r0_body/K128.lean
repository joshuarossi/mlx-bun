import host.sim.template.a4pre_first_tail_x15_r0_body.H16
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
boot_rfl PRE_first_tail_x15_r0_body.k514 from PRE_first_tail_x15_r0_body.s514 to PRE_first_tail_x15_r0_body.s515 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB152 ((nth? PRE_first_tail_x15_r0_body.ks 514).getD 0) PRE_first_tail_x15_r0_body.s514 PRE_first_tail_x15_r0_body.S514 = some (PRE_first_tail_x15_r0_body.s515, PRE_first_tail_x15_r0_body.S515)
boot_rfl PRE_first_tail_x15_r0_body.stepA153 from PRE_first_tail_x15_r0_body.s515 to PRE_first_tail_x15_r0_body.s516 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s515).run PRE_first_tail_x15_r0_body.S515 = some (PRE_first_tail_x15_r0_body.s516, PRE_first_tail_x15_r0_body.S516)
end Host.Load.Run.Tpl
