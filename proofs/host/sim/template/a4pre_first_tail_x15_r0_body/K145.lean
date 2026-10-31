import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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
boot_rfl PRE_first_tail_x15_r0_body.k580 from PRE_first_tail_x15_r0_body.s580 to PRE_first_tail_x15_r0_body.s581 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB156 ((nth? PRE_first_tail_x15_r0_body.ks 580).getD 0) PRE_first_tail_x15_r0_body.s580 PRE_first_tail_x15_r0_body.S580 = some (PRE_first_tail_x15_r0_body.s581, PRE_first_tail_x15_r0_body.S581)
boot_rfl PRE_first_tail_x15_r0_body.stepA157 from PRE_first_tail_x15_r0_body.s581 to PRE_first_tail_x15_r0_body.s582 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s581).run PRE_first_tail_x15_r0_body.S581 = some (PRE_first_tail_x15_r0_body.s582, PRE_first_tail_x15_r0_body.S582)
boot_rfl PRE_first_tail_x15_r0_body.patchB157 from PRE_first_tail_x15_r0_body.s582 to PRE_first_tail_x15_r0_body.s583 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s582).run PRE_first_tail_x15_r0_body.S582 = some (PRE_first_tail_x15_r0_body.s583, PRE_first_tail_x15_r0_body.S583)
boot_rfl PRE_first_tail_x15_r0_body.k583 from PRE_first_tail_x15_r0_body.s583 to PRE_first_tail_x15_r0_body.s584 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB157 ((nth? PRE_first_tail_x15_r0_body.ks 583).getD 0) PRE_first_tail_x15_r0_body.s583 PRE_first_tail_x15_r0_body.S583 = some (PRE_first_tail_x15_r0_body.s584, PRE_first_tail_x15_r0_body.S584)
end Host.Load.Run.Tpl
