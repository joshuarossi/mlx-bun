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
boot_rfl PRE_first_tail_x15_r0_body.stepA73 from PRE_first_tail_x15_r0_body.s244 to PRE_first_tail_x15_r0_body.s245 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s244).run PRE_first_tail_x15_r0_body.S244 = some (PRE_first_tail_x15_r0_body.s245, PRE_first_tail_x15_r0_body.S245)
boot_rfl PRE_first_tail_x15_r0_body.patchB73 from PRE_first_tail_x15_r0_body.s245 to PRE_first_tail_x15_r0_body.s246 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s245).run PRE_first_tail_x15_r0_body.S245 = some (PRE_first_tail_x15_r0_body.s246, PRE_first_tail_x15_r0_body.S246)
boot_rfl PRE_first_tail_x15_r0_body.k246 from PRE_first_tail_x15_r0_body.s246 to PRE_first_tail_x15_r0_body.s247 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB73 ((nth? PRE_first_tail_x15_r0_body.ks 246).getD 0) PRE_first_tail_x15_r0_body.s246 PRE_first_tail_x15_r0_body.S246 = some (PRE_first_tail_x15_r0_body.s247, PRE_first_tail_x15_r0_body.S247)
boot_rfl PRE_first_tail_x15_r0_body.stepA74 from PRE_first_tail_x15_r0_body.s247 to PRE_first_tail_x15_r0_body.s248 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s247).run PRE_first_tail_x15_r0_body.S247 = some (PRE_first_tail_x15_r0_body.s248, PRE_first_tail_x15_r0_body.S248)
end Host.Load.Run.Tpl
