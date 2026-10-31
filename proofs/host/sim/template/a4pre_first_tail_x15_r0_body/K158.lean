import host.sim.template.a4pre_first_tail_x15_r0_body.H19
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
boot_rfl PRE_first_tail_x15_r0_body.patchB187 from PRE_first_tail_x15_r0_body.s632 to PRE_first_tail_x15_r0_body.s633 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s632).run PRE_first_tail_x15_r0_body.S632 = some (PRE_first_tail_x15_r0_body.s633, PRE_first_tail_x15_r0_body.S633)
boot_rfl PRE_first_tail_x15_r0_body.k633 from PRE_first_tail_x15_r0_body.s633 to PRE_first_tail_x15_r0_body.s634 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB187 ((nth? PRE_first_tail_x15_r0_body.ks 633).getD 0) PRE_first_tail_x15_r0_body.s633 PRE_first_tail_x15_r0_body.S633 = some (PRE_first_tail_x15_r0_body.s634, PRE_first_tail_x15_r0_body.S634)
boot_rfl PRE_first_tail_x15_r0_body.stepA188 from PRE_first_tail_x15_r0_body.s634 to PRE_first_tail_x15_r0_body.s635 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s634).run PRE_first_tail_x15_r0_body.S634 = some (PRE_first_tail_x15_r0_body.s635, PRE_first_tail_x15_r0_body.S635)
boot_rfl PRE_first_tail_x15_r0_body.patchB188 from PRE_first_tail_x15_r0_body.s635 to PRE_first_tail_x15_r0_body.s636 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s635).run PRE_first_tail_x15_r0_body.S635 = some (PRE_first_tail_x15_r0_body.s636, PRE_first_tail_x15_r0_body.S636)
end Host.Load.Run.Tpl
