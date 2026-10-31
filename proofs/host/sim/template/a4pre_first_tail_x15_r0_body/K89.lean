import host.sim.template.a4pre_first_tail_x15_r0_body.H11
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
boot_rfl PRE_first_tail_x15_r0_body.k356 from PRE_first_tail_x15_r0_body.s356 to PRE_first_tail_x15_r0_body.s357 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB96 ((nth? PRE_first_tail_x15_r0_body.ks 356).getD 0) PRE_first_tail_x15_r0_body.s356 PRE_first_tail_x15_r0_body.S356 = some (PRE_first_tail_x15_r0_body.s357, PRE_first_tail_x15_r0_body.S357)
boot_rfl PRE_first_tail_x15_r0_body.stepA97 from PRE_first_tail_x15_r0_body.s357 to PRE_first_tail_x15_r0_body.s358 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s357).run PRE_first_tail_x15_r0_body.S357 = some (PRE_first_tail_x15_r0_body.s358, PRE_first_tail_x15_r0_body.S358)
boot_rfl PRE_first_tail_x15_r0_body.patchB97 from PRE_first_tail_x15_r0_body.s358 to PRE_first_tail_x15_r0_body.s359 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s358).run PRE_first_tail_x15_r0_body.S358 = some (PRE_first_tail_x15_r0_body.s359, PRE_first_tail_x15_r0_body.S359)
boot_rfl PRE_first_tail_x15_r0_body.k359 from PRE_first_tail_x15_r0_body.s359 to PRE_first_tail_x15_r0_body.s360 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB97 ((nth? PRE_first_tail_x15_r0_body.ks 359).getD 0) PRE_first_tail_x15_r0_body.s359 PRE_first_tail_x15_r0_body.S359 = some (PRE_first_tail_x15_r0_body.s360, PRE_first_tail_x15_r0_body.S360)
end Host.Load.Run.Tpl
