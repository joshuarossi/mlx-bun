import host.sim.template.a4pre_first_tail_x15_r0_body.H14
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
boot_rfl PRE_first_tail_x15_r0_body.stepA137 from PRE_first_tail_x15_r0_body.s460 to PRE_first_tail_x15_r0_body.s461 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s460).run PRE_first_tail_x15_r0_body.S460 = some (PRE_first_tail_x15_r0_body.s461, PRE_first_tail_x15_r0_body.S461)
boot_rfl PRE_first_tail_x15_r0_body.k463 from PRE_first_tail_x15_r0_body.s463 to PRE_first_tail_x15_r0_body.s464 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB137 ((nth? PRE_first_tail_x15_r0_body.ks 463).getD 0) PRE_first_tail_x15_r0_body.s463 PRE_first_tail_x15_r0_body.S463 = some (PRE_first_tail_x15_r0_body.s464, PRE_first_tail_x15_r0_body.S464)
end Host.Load.Run.Tpl
