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
boot_rfl PRE_first_tail_x15_r0_body.k104 from PRE_first_tail_x15_r0_body.s104 to PRE_first_tail_x15_r0_body.s105 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB28 ((nth? PRE_first_tail_x15_r0_body.ks 104).getD 0) PRE_first_tail_x15_r0_body.s104 PRE_first_tail_x15_r0_body.S104 = some (PRE_first_tail_x15_r0_body.s105, PRE_first_tail_x15_r0_body.S105)
boot_rfl PRE_first_tail_x15_r0_body.stepA29 from PRE_first_tail_x15_r0_body.s105 to PRE_first_tail_x15_r0_body.s106 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s105).run PRE_first_tail_x15_r0_body.S105 = some (PRE_first_tail_x15_r0_body.s106, PRE_first_tail_x15_r0_body.S106)
boot_rfl PRE_first_tail_x15_r0_body.patchB29 from PRE_first_tail_x15_r0_body.s106 to PRE_first_tail_x15_r0_body.s107 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s106).run PRE_first_tail_x15_r0_body.S106 = some (PRE_first_tail_x15_r0_body.s107, PRE_first_tail_x15_r0_body.S107)
boot_rfl PRE_first_tail_x15_r0_body.k107 from PRE_first_tail_x15_r0_body.s107 to PRE_first_tail_x15_r0_body.s108 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB29 ((nth? PRE_first_tail_x15_r0_body.ks 107).getD 0) PRE_first_tail_x15_r0_body.s107 PRE_first_tail_x15_r0_body.S107 = some (PRE_first_tail_x15_r0_body.s108, PRE_first_tail_x15_r0_body.S108)
end Host.Load.Run.Tpl
