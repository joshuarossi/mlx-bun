import host.sim.template.a4pre_first_tail_x15_r0_body.H1
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
boot_rfl PRE_first_tail_x15_r0_body.stepA9 from PRE_first_tail_x15_r0_body.s28 to PRE_first_tail_x15_r0_body.s29 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s28).run PRE_first_tail_x15_r0_body.S28 = some (PRE_first_tail_x15_r0_body.s29, PRE_first_tail_x15_r0_body.S29)
boot_rfl PRE_first_tail_x15_r0_body.patchB9 from PRE_first_tail_x15_r0_body.s29 to PRE_first_tail_x15_r0_body.s30 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s29).run PRE_first_tail_x15_r0_body.S29 = some (PRE_first_tail_x15_r0_body.s30, PRE_first_tail_x15_r0_body.S30)
boot_rfl PRE_first_tail_x15_r0_body.k30 from PRE_first_tail_x15_r0_body.s30 to PRE_first_tail_x15_r0_body.s31 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB9 ((nth? PRE_first_tail_x15_r0_body.ks 30).getD 0) PRE_first_tail_x15_r0_body.s30 PRE_first_tail_x15_r0_body.S30 = some (PRE_first_tail_x15_r0_body.s31, PRE_first_tail_x15_r0_body.S31)
boot_rfl PRE_first_tail_x15_r0_body.stepA10 from PRE_first_tail_x15_r0_body.s31 to PRE_first_tail_x15_r0_body.s32 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s31).run PRE_first_tail_x15_r0_body.S31 = some (PRE_first_tail_x15_r0_body.s32, PRE_first_tail_x15_r0_body.S32)
end Host.Load.Run.Tpl
