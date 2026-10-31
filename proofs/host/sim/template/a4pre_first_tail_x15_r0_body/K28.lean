import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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
boot_rfl PRE_first_tail_x15_r0_body.k112 from PRE_first_tail_x15_r0_body.s112 to PRE_first_tail_x15_r0_body.s113 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB30 ((nth? PRE_first_tail_x15_r0_body.ks 112).getD 0) PRE_first_tail_x15_r0_body.s112 PRE_first_tail_x15_r0_body.S112 = some (PRE_first_tail_x15_r0_body.s113, PRE_first_tail_x15_r0_body.S113)
boot_rfl PRE_first_tail_x15_r0_body.stepA31 from PRE_first_tail_x15_r0_body.s113 to PRE_first_tail_x15_r0_body.s114 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s113).run PRE_first_tail_x15_r0_body.S113 = some (PRE_first_tail_x15_r0_body.s114, PRE_first_tail_x15_r0_body.S114)
end Host.Load.Run.Tpl
