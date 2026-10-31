import host.sim.template.a4pre_first_tail_x15_r0_body.H3
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
boot_rfl PRE_first_tail_x15_r0_body.patchB35 from PRE_first_tail_x15_r0_body.s116 to PRE_first_tail_x15_r0_body.s117 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s116).run PRE_first_tail_x15_r0_body.S116 = some (PRE_first_tail_x15_r0_body.s117, PRE_first_tail_x15_r0_body.S117)
boot_rfl PRE_first_tail_x15_r0_body.k117 from PRE_first_tail_x15_r0_body.s117 to PRE_first_tail_x15_r0_body.s118 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB35 ((nth? PRE_first_tail_x15_r0_body.ks 117).getD 0) PRE_first_tail_x15_r0_body.s117 PRE_first_tail_x15_r0_body.S117 = some (PRE_first_tail_x15_r0_body.s118, PRE_first_tail_x15_r0_body.S118)
boot_rfl PRE_first_tail_x15_r0_body.stepA36 from PRE_first_tail_x15_r0_body.s118 to PRE_first_tail_x15_r0_body.s119 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s118).run PRE_first_tail_x15_r0_body.S118 = some (PRE_first_tail_x15_r0_body.s119, PRE_first_tail_x15_r0_body.S119)
end Host.Load.Run.Tpl
