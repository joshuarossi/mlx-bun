import host.sim.template.a4pre_first_tail_x15_r0_body.H20
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
boot_rfl PRE_first_tail_x15_r0_body.k653 from PRE_first_tail_x15_r0_body.s653 to PRE_first_tail_x15_r0_body.s654 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB193 ((nth? PRE_first_tail_x15_r0_body.ks 653).getD 0) PRE_first_tail_x15_r0_body.s653 PRE_first_tail_x15_r0_body.S653 = some (PRE_first_tail_x15_r0_body.s654, PRE_first_tail_x15_r0_body.S654)
boot_rfl PRE_first_tail_x15_r0_body.stepA194 from PRE_first_tail_x15_r0_body.s654 to PRE_first_tail_x15_r0_body.s655 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s654).run PRE_first_tail_x15_r0_body.S654 = some (PRE_first_tail_x15_r0_body.s655, PRE_first_tail_x15_r0_body.S655)
end Host.Load.Run.Tpl
