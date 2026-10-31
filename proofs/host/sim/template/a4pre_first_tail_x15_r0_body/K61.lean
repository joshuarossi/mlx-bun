import host.sim.template.a4pre_first_tail_x15_r0_body.H7
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
boot_rfl PRE_first_tail_x15_r0_body.k244 from PRE_first_tail_x15_r0_body.s244 to PRE_first_tail_x15_r0_body.s245 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB66 ((nth? PRE_first_tail_x15_r0_body.ks 244).getD 0) PRE_first_tail_x15_r0_body.s244 PRE_first_tail_x15_r0_body.S244 = some (PRE_first_tail_x15_r0_body.s245, PRE_first_tail_x15_r0_body.S245)
boot_rfl PRE_first_tail_x15_r0_body.stepA67 from PRE_first_tail_x15_r0_body.s245 to PRE_first_tail_x15_r0_body.s246 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s245).run PRE_first_tail_x15_r0_body.S245 = some (PRE_first_tail_x15_r0_body.s246, PRE_first_tail_x15_r0_body.S246)
end Host.Load.Run.Tpl
