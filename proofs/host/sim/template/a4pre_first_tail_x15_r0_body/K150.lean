import host.sim.template.a4pre_first_tail_x15_r0_body.H18
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
boot_rfl PRE_first_tail_x15_r0_body.k601 from PRE_first_tail_x15_r0_body.s601 to PRE_first_tail_x15_r0_body.s602 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB162 ((nth? PRE_first_tail_x15_r0_body.ks 601).getD 0) PRE_first_tail_x15_r0_body.s601 PRE_first_tail_x15_r0_body.S601 = some (PRE_first_tail_x15_r0_body.s602, PRE_first_tail_x15_r0_body.S602)
boot_rfl PRE_first_tail_x15_r0_body.stepA163 from PRE_first_tail_x15_r0_body.s602 to PRE_first_tail_x15_r0_body.s603 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s602).run PRE_first_tail_x15_r0_body.S602 = some (PRE_first_tail_x15_r0_body.s603, PRE_first_tail_x15_r0_body.S603)
end Host.Load.Run.Tpl
