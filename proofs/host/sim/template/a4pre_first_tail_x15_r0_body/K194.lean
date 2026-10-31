import host.sim.template.a4pre_first_tail_x15_r0_body.H24
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
boot_rfl PRE_first_tail_x15_r0_body.k778 from PRE_first_tail_x15_r0_body.s778 to PRE_first_tail_x15_r0_body.s779 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB230 ((nth? PRE_first_tail_x15_r0_body.ks 778).getD 0) PRE_first_tail_x15_r0_body.s778 PRE_first_tail_x15_r0_body.S778 = some (PRE_first_tail_x15_r0_body.s779, PRE_first_tail_x15_r0_body.S779)
boot_rfl PRE_first_tail_x15_r0_body.stepA231 from PRE_first_tail_x15_r0_body.s779 to PRE_first_tail_x15_r0_body.s780 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s779).run PRE_first_tail_x15_r0_body.S779 = some (PRE_first_tail_x15_r0_body.s780, PRE_first_tail_x15_r0_body.S780)
end Host.Load.Run.Tpl
