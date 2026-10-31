import host.sim.template.a4pre_first_tail_x15_r0_body.H5
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
boot_rfl PRE_first_tail_x15_r0_body.stepA52 from PRE_first_tail_x15_r0_body.s172 to PRE_first_tail_x15_r0_body.s173 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s172).run PRE_first_tail_x15_r0_body.S172 = some (PRE_first_tail_x15_r0_body.s173, PRE_first_tail_x15_r0_body.S173)
boot_rfl PRE_first_tail_x15_r0_body.k175 from PRE_first_tail_x15_r0_body.s175 to PRE_first_tail_x15_r0_body.s176 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB52 ((nth? PRE_first_tail_x15_r0_body.ks 175).getD 0) PRE_first_tail_x15_r0_body.s175 PRE_first_tail_x15_r0_body.S175 = some (PRE_first_tail_x15_r0_body.s176, PRE_first_tail_x15_r0_body.S176)
end Host.Load.Run.Tpl
