import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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
boot_rfl PRE_first_tail_x15_r0_body.patchB29 from PRE_first_tail_x15_r0_body.s96 to PRE_first_tail_x15_r0_body.s97 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s96).run PRE_first_tail_x15_r0_body.S96 = some (PRE_first_tail_x15_r0_body.s97, PRE_first_tail_x15_r0_body.S97)
boot_rfl PRE_first_tail_x15_r0_body.k97 from PRE_first_tail_x15_r0_body.s97 to PRE_first_tail_x15_r0_body.s98 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB29 ((nth? PRE_first_tail_x15_r0_body.ks 97).getD 0) PRE_first_tail_x15_r0_body.s97 PRE_first_tail_x15_r0_body.S97 = some (PRE_first_tail_x15_r0_body.s98, PRE_first_tail_x15_r0_body.S98)
boot_rfl PRE_first_tail_x15_r0_body.stepA30 from PRE_first_tail_x15_r0_body.s98 to PRE_first_tail_x15_r0_body.s99 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s98).run PRE_first_tail_x15_r0_body.S98 = some (PRE_first_tail_x15_r0_body.s99, PRE_first_tail_x15_r0_body.S99)
end Host.Load.Run.Tpl
