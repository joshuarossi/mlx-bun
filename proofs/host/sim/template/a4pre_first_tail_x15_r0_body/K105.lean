import host.sim.template.a4pre_first_tail_x15_r0_body.H13
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
boot_rfl PRE_first_tail_x15_r0_body.k420 from PRE_first_tail_x15_r0_body.s420 to PRE_first_tail_x15_r0_body.s421 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB124 ((nth? PRE_first_tail_x15_r0_body.ks 420).getD 0) PRE_first_tail_x15_r0_body.s420 PRE_first_tail_x15_r0_body.S420 = some (PRE_first_tail_x15_r0_body.s421, PRE_first_tail_x15_r0_body.S421)
boot_rfl PRE_first_tail_x15_r0_body.stepA125 from PRE_first_tail_x15_r0_body.s421 to PRE_first_tail_x15_r0_body.s422 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s421).run PRE_first_tail_x15_r0_body.S421 = some (PRE_first_tail_x15_r0_body.s422, PRE_first_tail_x15_r0_body.S422)
boot_rfl PRE_first_tail_x15_r0_body.patchB125 from PRE_first_tail_x15_r0_body.s422 to PRE_first_tail_x15_r0_body.s423 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s422).run PRE_first_tail_x15_r0_body.S422 = some (PRE_first_tail_x15_r0_body.s423, PRE_first_tail_x15_r0_body.S423)
boot_rfl PRE_first_tail_x15_r0_body.k423 from PRE_first_tail_x15_r0_body.s423 to PRE_first_tail_x15_r0_body.s424 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB125 ((nth? PRE_first_tail_x15_r0_body.ks 423).getD 0) PRE_first_tail_x15_r0_body.s423 PRE_first_tail_x15_r0_body.S423 = some (PRE_first_tail_x15_r0_body.s424, PRE_first_tail_x15_r0_body.S424)
end Host.Load.Run.Tpl
