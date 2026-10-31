import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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
boot_rfl PRE_first_tail_x15_r0_body.k372 from PRE_first_tail_x15_r0_body.s372 to PRE_first_tail_x15_r0_body.s373 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB110 ((nth? PRE_first_tail_x15_r0_body.ks 372).getD 0) PRE_first_tail_x15_r0_body.s372 PRE_first_tail_x15_r0_body.S372 = some (PRE_first_tail_x15_r0_body.s373, PRE_first_tail_x15_r0_body.S373)
boot_rfl PRE_first_tail_x15_r0_body.stepA111 from PRE_first_tail_x15_r0_body.s373 to PRE_first_tail_x15_r0_body.s374 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s373).run PRE_first_tail_x15_r0_body.S373 = some (PRE_first_tail_x15_r0_body.s374, PRE_first_tail_x15_r0_body.S374)
boot_rfl PRE_first_tail_x15_r0_body.patchB111 from PRE_first_tail_x15_r0_body.s374 to PRE_first_tail_x15_r0_body.s375 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s374).run PRE_first_tail_x15_r0_body.S374 = some (PRE_first_tail_x15_r0_body.s375, PRE_first_tail_x15_r0_body.S375)
boot_rfl PRE_first_tail_x15_r0_body.k375 from PRE_first_tail_x15_r0_body.s375 to PRE_first_tail_x15_r0_body.s376 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB111 ((nth? PRE_first_tail_x15_r0_body.ks 375).getD 0) PRE_first_tail_x15_r0_body.s375 PRE_first_tail_x15_r0_body.S375 = some (PRE_first_tail_x15_r0_body.s376, PRE_first_tail_x15_r0_body.S376)
end Host.Load.Run.Tpl
