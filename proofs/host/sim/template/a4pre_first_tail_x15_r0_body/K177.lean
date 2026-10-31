import host.sim.template.a4pre_first_tail_x15_r0_body.H22
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
boot_rfl PRE_first_tail_x15_r0_body.stepA210 from PRE_first_tail_x15_r0_body.s708 to PRE_first_tail_x15_r0_body.s709 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s708).run PRE_first_tail_x15_r0_body.S708 = some (PRE_first_tail_x15_r0_body.s709, PRE_first_tail_x15_r0_body.S709)
boot_rfl PRE_first_tail_x15_r0_body.k711 from PRE_first_tail_x15_r0_body.s711 to PRE_first_tail_x15_r0_body.s712 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB210 ((nth? PRE_first_tail_x15_r0_body.ks 711).getD 0) PRE_first_tail_x15_r0_body.s711 PRE_first_tail_x15_r0_body.S711 = some (PRE_first_tail_x15_r0_body.s712, PRE_first_tail_x15_r0_body.S712)
end Host.Load.Run.Tpl
