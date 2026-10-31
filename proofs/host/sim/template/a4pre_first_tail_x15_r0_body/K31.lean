import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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
boot_rfl PRE_first_tail_x15_r0_body.k124 from PRE_first_tail_x15_r0_body.s124 to PRE_first_tail_x15_r0_body.s125 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB37 ((nth? PRE_first_tail_x15_r0_body.ks 124).getD 0) PRE_first_tail_x15_r0_body.s124 PRE_first_tail_x15_r0_body.S124 = some (PRE_first_tail_x15_r0_body.s125, PRE_first_tail_x15_r0_body.S125)
boot_rfl PRE_first_tail_x15_r0_body.stepA38 from PRE_first_tail_x15_r0_body.s125 to PRE_first_tail_x15_r0_body.s126 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s125).run PRE_first_tail_x15_r0_body.S125 = some (PRE_first_tail_x15_r0_body.s126, PRE_first_tail_x15_r0_body.S126)
end Host.Load.Run.Tpl
