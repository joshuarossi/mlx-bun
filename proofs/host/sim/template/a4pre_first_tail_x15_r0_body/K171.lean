import host.sim.template.a4pre_first_tail_x15_r0_body.H21
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
boot_rfl PRE_first_tail_x15_r0_body.stepA185 from PRE_first_tail_x15_r0_body.s684 to PRE_first_tail_x15_r0_body.s685 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s684).run PRE_first_tail_x15_r0_body.S684 = some (PRE_first_tail_x15_r0_body.s685, PRE_first_tail_x15_r0_body.S685)
boot_rfl PRE_first_tail_x15_r0_body.k687 from PRE_first_tail_x15_r0_body.s687 to PRE_first_tail_x15_r0_body.s688 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB185 ((nth? PRE_first_tail_x15_r0_body.ks 687).getD 0) PRE_first_tail_x15_r0_body.s687 PRE_first_tail_x15_r0_body.S687 = some (PRE_first_tail_x15_r0_body.s688, PRE_first_tail_x15_r0_body.S688)
end Host.Load.Run.Tpl
