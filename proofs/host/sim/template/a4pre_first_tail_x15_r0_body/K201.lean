import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.k806 from PRE_first_tail_x15_r0_body.s806 to PRE_first_tail_x15_r0_body.s807 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB217 ((nth? PRE_first_tail_x15_r0_body.ks 806).getD 0) PRE_first_tail_x15_r0_body.s806 PRE_first_tail_x15_r0_body.S806 = some (PRE_first_tail_x15_r0_body.s807, PRE_first_tail_x15_r0_body.S807)
boot_rfl PRE_first_tail_x15_r0_body.k807 from PRE_first_tail_x15_r0_body.s807 to PRE_first_tail_x15_r0_body.s808 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB217 ((nth? PRE_first_tail_x15_r0_body.ks 807).getD 0) PRE_first_tail_x15_r0_body.s807 PRE_first_tail_x15_r0_body.S807 = some (PRE_first_tail_x15_r0_body.s808, PRE_first_tail_x15_r0_body.S808)
end Host.Load.Run.Tpl
