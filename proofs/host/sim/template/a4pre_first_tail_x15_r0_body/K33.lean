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
boot_rfl PRE_first_tail_x15_r0_body.k133 from PRE_first_tail_x15_r0_body.s133 to PRE_first_tail_x15_r0_body.s134 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB36 ((nth? PRE_first_tail_x15_r0_body.ks 133).getD 0) PRE_first_tail_x15_r0_body.s133 PRE_first_tail_x15_r0_body.S133 = some (PRE_first_tail_x15_r0_body.s134, PRE_first_tail_x15_r0_body.S134)
boot_rfl PRE_first_tail_x15_r0_body.stepA37 from PRE_first_tail_x15_r0_body.s134 to PRE_first_tail_x15_r0_body.s135 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s134).run PRE_first_tail_x15_r0_body.S134 = some (PRE_first_tail_x15_r0_body.s135, PRE_first_tail_x15_r0_body.S135)
boot_rfl PRE_first_tail_x15_r0_body.patchB37 from PRE_first_tail_x15_r0_body.s135 to PRE_first_tail_x15_r0_body.s136 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s135).run PRE_first_tail_x15_r0_body.S135 = some (PRE_first_tail_x15_r0_body.s136, PRE_first_tail_x15_r0_body.S136)
end Host.Load.Run.Tpl
