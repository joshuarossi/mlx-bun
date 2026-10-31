import host.sim.template.a4pre_first_tail_x15_r0_body.H15
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
boot_rfl PRE_first_tail_x15_r0_body.patchB146 from PRE_first_tail_x15_r0_body.s492 to PRE_first_tail_x15_r0_body.s493 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s492).run PRE_first_tail_x15_r0_body.S492 = some (PRE_first_tail_x15_r0_body.s493, PRE_first_tail_x15_r0_body.S493)
boot_rfl PRE_first_tail_x15_r0_body.k493 from PRE_first_tail_x15_r0_body.s493 to PRE_first_tail_x15_r0_body.s494 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB146 ((nth? PRE_first_tail_x15_r0_body.ks 493).getD 0) PRE_first_tail_x15_r0_body.s493 PRE_first_tail_x15_r0_body.S493 = some (PRE_first_tail_x15_r0_body.s494, PRE_first_tail_x15_r0_body.S494)
boot_rfl PRE_first_tail_x15_r0_body.stepA147 from PRE_first_tail_x15_r0_body.s494 to PRE_first_tail_x15_r0_body.s495 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s494).run PRE_first_tail_x15_r0_body.S494 = some (PRE_first_tail_x15_r0_body.s495, PRE_first_tail_x15_r0_body.S495)
end Host.Load.Run.Tpl
