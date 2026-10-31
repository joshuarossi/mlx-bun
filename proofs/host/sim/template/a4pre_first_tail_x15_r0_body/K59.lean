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
boot_rfl PRE_first_tail_x15_r0_body.stepA64 from PRE_first_tail_x15_r0_body.s236 to PRE_first_tail_x15_r0_body.s237 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s236).run PRE_first_tail_x15_r0_body.S236 = some (PRE_first_tail_x15_r0_body.s237, PRE_first_tail_x15_r0_body.S237)
boot_rfl PRE_first_tail_x15_r0_body.patchB64 from PRE_first_tail_x15_r0_body.s237 to PRE_first_tail_x15_r0_body.s238 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s237).run PRE_first_tail_x15_r0_body.S237 = some (PRE_first_tail_x15_r0_body.s238, PRE_first_tail_x15_r0_body.S238)
boot_rfl PRE_first_tail_x15_r0_body.k238 from PRE_first_tail_x15_r0_body.s238 to PRE_first_tail_x15_r0_body.s239 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB64 ((nth? PRE_first_tail_x15_r0_body.ks 238).getD 0) PRE_first_tail_x15_r0_body.s238 PRE_first_tail_x15_r0_body.S238 = some (PRE_first_tail_x15_r0_body.s239, PRE_first_tail_x15_r0_body.S239)
boot_rfl PRE_first_tail_x15_r0_body.stepA65 from PRE_first_tail_x15_r0_body.s239 to PRE_first_tail_x15_r0_body.s240 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s239).run PRE_first_tail_x15_r0_body.S239 = some (PRE_first_tail_x15_r0_body.s240, PRE_first_tail_x15_r0_body.S240)
end Host.Load.Run.Tpl
