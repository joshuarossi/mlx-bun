import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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
boot_rfl PRE_first_tail_x15_r0_body.k457 from PRE_first_tail_x15_r0_body.s457 to PRE_first_tail_x15_r0_body.s458 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB123 ((nth? PRE_first_tail_x15_r0_body.ks 457).getD 0) PRE_first_tail_x15_r0_body.s457 PRE_first_tail_x15_r0_body.S457 = some (PRE_first_tail_x15_r0_body.s458, PRE_first_tail_x15_r0_body.S458)
boot_rfl PRE_first_tail_x15_r0_body.stepA124 from PRE_first_tail_x15_r0_body.s458 to PRE_first_tail_x15_r0_body.s459 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s458).run PRE_first_tail_x15_r0_body.S458 = some (PRE_first_tail_x15_r0_body.s459, PRE_first_tail_x15_r0_body.S459)
end Host.Load.Run.Tpl
