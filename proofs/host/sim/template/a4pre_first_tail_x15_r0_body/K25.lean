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
boot_rfl PRE_first_tail_x15_r0_body.k100 from PRE_first_tail_x15_r0_body.s100 to PRE_first_tail_x15_r0_body.s101 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB27 ((nth? PRE_first_tail_x15_r0_body.ks 100).getD 0) PRE_first_tail_x15_r0_body.s100 PRE_first_tail_x15_r0_body.S100 = some (PRE_first_tail_x15_r0_body.s101, PRE_first_tail_x15_r0_body.S101)
boot_rfl PRE_first_tail_x15_r0_body.stepA28 from PRE_first_tail_x15_r0_body.s101 to PRE_first_tail_x15_r0_body.s102 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s101).run PRE_first_tail_x15_r0_body.S101 = some (PRE_first_tail_x15_r0_body.s102, PRE_first_tail_x15_r0_body.S102)
end Host.Load.Run.Tpl
