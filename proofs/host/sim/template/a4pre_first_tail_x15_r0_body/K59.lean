import host.sim.template.a4pre_first_tail_x15_r0_body.H7
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
boot_rfl PRE_first_tail_x15_r0_body.k237 from PRE_first_tail_x15_r0_body.s237 to PRE_first_tail_x15_r0_body.s238 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB70 ((nth? PRE_first_tail_x15_r0_body.ks 237).getD 0) PRE_first_tail_x15_r0_body.s237 PRE_first_tail_x15_r0_body.S237 = some (PRE_first_tail_x15_r0_body.s238, PRE_first_tail_x15_r0_body.S238)
boot_rfl PRE_first_tail_x15_r0_body.stepA71 from PRE_first_tail_x15_r0_body.s238 to PRE_first_tail_x15_r0_body.s239 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s238).run PRE_first_tail_x15_r0_body.S238 = some (PRE_first_tail_x15_r0_body.s239, PRE_first_tail_x15_r0_body.S239)
boot_rfl PRE_first_tail_x15_r0_body.patchB71 from PRE_first_tail_x15_r0_body.s239 to PRE_first_tail_x15_r0_body.s240 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s239).run PRE_first_tail_x15_r0_body.S239 = some (PRE_first_tail_x15_r0_body.s240, PRE_first_tail_x15_r0_body.S240)
end Host.Load.Run.Tpl
