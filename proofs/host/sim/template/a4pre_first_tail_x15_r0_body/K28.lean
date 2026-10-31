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
boot_rfl PRE_first_tail_x15_r0_body.stepA34 from PRE_first_tail_x15_r0_body.s112 to PRE_first_tail_x15_r0_body.s113 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s112).run PRE_first_tail_x15_r0_body.S112 = some (PRE_first_tail_x15_r0_body.s113, PRE_first_tail_x15_r0_body.S113)
boot_rfl PRE_first_tail_x15_r0_body.patchB34 from PRE_first_tail_x15_r0_body.s113 to PRE_first_tail_x15_r0_body.s114 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s113).run PRE_first_tail_x15_r0_body.S113 = some (PRE_first_tail_x15_r0_body.s114, PRE_first_tail_x15_r0_body.S114)
boot_rfl PRE_first_tail_x15_r0_body.k114 from PRE_first_tail_x15_r0_body.s114 to PRE_first_tail_x15_r0_body.s115 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB34 ((nth? PRE_first_tail_x15_r0_body.ks 114).getD 0) PRE_first_tail_x15_r0_body.s114 PRE_first_tail_x15_r0_body.S114 = some (PRE_first_tail_x15_r0_body.s115, PRE_first_tail_x15_r0_body.S115)
boot_rfl PRE_first_tail_x15_r0_body.stepA35 from PRE_first_tail_x15_r0_body.s115 to PRE_first_tail_x15_r0_body.s116 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s115).run PRE_first_tail_x15_r0_body.S115 = some (PRE_first_tail_x15_r0_body.s116, PRE_first_tail_x15_r0_body.S116)
end Host.Load.Run.Tpl
