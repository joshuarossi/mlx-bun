import host.sim.template.a4pre_first_tail_x15_r0_body.H28
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
boot_rfl PRE_first_tail_x15_r0_body.k904 from PRE_first_tail_x15_r0_body.s904 to PRE_first_tail_x15_r0_body.s905 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB244 ((nth? PRE_first_tail_x15_r0_body.ks 904).getD 0) PRE_first_tail_x15_r0_body.s904 PRE_first_tail_x15_r0_body.S904 = some (PRE_first_tail_x15_r0_body.s905, PRE_first_tail_x15_r0_body.S905)
boot_rfl PRE_first_tail_x15_r0_body.k905 from PRE_first_tail_x15_r0_body.s905 to PRE_first_tail_x15_r0_body.s906 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB244 ((nth? PRE_first_tail_x15_r0_body.ks 905).getD 0) PRE_first_tail_x15_r0_body.s905 PRE_first_tail_x15_r0_body.S905 = some (PRE_first_tail_x15_r0_body.s906, PRE_first_tail_x15_r0_body.S906)
boot_rfl PRE_first_tail_x15_r0_body.stepA245 from PRE_first_tail_x15_r0_body.s906 to PRE_first_tail_x15_r0_body.s907 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s906).run PRE_first_tail_x15_r0_body.S906 = some (PRE_first_tail_x15_r0_body.s907, PRE_first_tail_x15_r0_body.S907)
end Host.Load.Run.Tpl
