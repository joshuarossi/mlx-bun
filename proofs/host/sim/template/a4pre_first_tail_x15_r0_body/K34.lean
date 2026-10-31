import host.sim.template.a4pre_first_tail_x15_r0_body.H4
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
boot_rfl PRE_first_tail_x15_r0_body.k136 from PRE_first_tail_x15_r0_body.s136 to PRE_first_tail_x15_r0_body.s137 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB37 ((nth? PRE_first_tail_x15_r0_body.ks 136).getD 0) PRE_first_tail_x15_r0_body.s136 PRE_first_tail_x15_r0_body.S136 = some (PRE_first_tail_x15_r0_body.s137, PRE_first_tail_x15_r0_body.S137)
boot_rfl PRE_first_tail_x15_r0_body.k137 from PRE_first_tail_x15_r0_body.s137 to PRE_first_tail_x15_r0_body.s138 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB37 ((nth? PRE_first_tail_x15_r0_body.ks 137).getD 0) PRE_first_tail_x15_r0_body.s137 PRE_first_tail_x15_r0_body.S137 = some (PRE_first_tail_x15_r0_body.s138, PRE_first_tail_x15_r0_body.S138)
boot_rfl PRE_first_tail_x15_r0_body.stepA38 from PRE_first_tail_x15_r0_body.s138 to PRE_first_tail_x15_r0_body.s139 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s138).run PRE_first_tail_x15_r0_body.S138 = some (PRE_first_tail_x15_r0_body.s139, PRE_first_tail_x15_r0_body.S139)
end Host.Load.Run.Tpl
