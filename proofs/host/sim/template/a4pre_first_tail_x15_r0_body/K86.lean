import host.sim.template.a4pre_first_tail_x15_r0_body.H10
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
boot_rfl PRE_first_tail_x15_r0_body.patchB102 from PRE_first_tail_x15_r0_body.s344 to PRE_first_tail_x15_r0_body.s345 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s344).run PRE_first_tail_x15_r0_body.S344 = some (PRE_first_tail_x15_r0_body.s345, PRE_first_tail_x15_r0_body.S345)
boot_rfl PRE_first_tail_x15_r0_body.k345 from PRE_first_tail_x15_r0_body.s345 to PRE_first_tail_x15_r0_body.s346 : runOk PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.okB102 ((nth? PRE_first_tail_x15_r0_body.ks 345).getD 0) PRE_first_tail_x15_r0_body.s345 PRE_first_tail_x15_r0_body.S345 = some (PRE_first_tail_x15_r0_body.s346, PRE_first_tail_x15_r0_body.S346)
boot_rfl PRE_first_tail_x15_r0_body.stepA103 from PRE_first_tail_x15_r0_body.s346 to PRE_first_tail_x15_r0_body.s347 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s346).run PRE_first_tail_x15_r0_body.S346 = some (PRE_first_tail_x15_r0_body.s347, PRE_first_tail_x15_r0_body.S347)
boot_rfl PRE_first_tail_x15_r0_body.patchB103 from PRE_first_tail_x15_r0_body.s347 to PRE_first_tail_x15_r0_body.s348 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s347).run PRE_first_tail_x15_r0_body.S347 = some (PRE_first_tail_x15_r0_body.s348, PRE_first_tail_x15_r0_body.S348)
end Host.Load.Run.Tpl
