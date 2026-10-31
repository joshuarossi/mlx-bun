import host.sim.template.a4pre_first_tail_x15_r0_body.H25
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
boot_rfl PRE_first_tail_x15_r0_body.k802 from PRE_first_tail_x15_r0_body.s802 to PRE_first_tail_x15_r0_body.s803 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB216 ((nth? PRE_first_tail_x15_r0_body.ks 802).getD 0) PRE_first_tail_x15_r0_body.s802 PRE_first_tail_x15_r0_body.S802 = some (PRE_first_tail_x15_r0_body.s803, PRE_first_tail_x15_r0_body.S803)
boot_rfl PRE_first_tail_x15_r0_body.stepA217 from PRE_first_tail_x15_r0_body.s803 to PRE_first_tail_x15_r0_body.s804 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s803).run PRE_first_tail_x15_r0_body.S803 = some (PRE_first_tail_x15_r0_body.s804, PRE_first_tail_x15_r0_body.S804)
end Host.Load.Run.Tpl
