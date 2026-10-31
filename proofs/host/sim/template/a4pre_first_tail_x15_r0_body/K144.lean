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
boot_rfl PRE_first_tail_x15_r0_body.stepA171 from PRE_first_tail_x15_r0_body.s576 to PRE_first_tail_x15_r0_body.s577 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s576).run PRE_first_tail_x15_r0_body.S576 = some (PRE_first_tail_x15_r0_body.s577, PRE_first_tail_x15_r0_body.S577)
boot_rfl PRE_first_tail_x15_r0_body.k579 from PRE_first_tail_x15_r0_body.s579 to PRE_first_tail_x15_r0_body.s580 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB171 ((nth? PRE_first_tail_x15_r0_body.ks 579).getD 0) PRE_first_tail_x15_r0_body.s579 PRE_first_tail_x15_r0_body.S579 = some (PRE_first_tail_x15_r0_body.s580, PRE_first_tail_x15_r0_body.S580)
end Host.Load.Run.Tpl
