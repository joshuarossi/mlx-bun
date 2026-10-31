import host.sim.template.a4pre_first_tail_x15_r0_body.H34
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
boot_rfl PRE_first_tail_x15_r0_body.stepA300 from PRE_first_tail_x15_r0_body.s1108 to PRE_first_tail_x15_r0_body.s1109 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s1108).run PRE_first_tail_x15_r0_body.S1108 = some (PRE_first_tail_x15_r0_body.s1109, PRE_first_tail_x15_r0_body.S1109)
boot_rfl PRE_first_tail_x15_r0_body.k1111 from PRE_first_tail_x15_r0_body.s1111 to PRE_first_tail_x15_r0_body.s1112 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB300 ((nth? PRE_first_tail_x15_r0_body.ks 1111).getD 0) PRE_first_tail_x15_r0_body.s1111 PRE_first_tail_x15_r0_body.S1111 = some (PRE_first_tail_x15_r0_body.s1112, PRE_first_tail_x15_r0_body.S1112)
end Host.Load.Run.Tpl
