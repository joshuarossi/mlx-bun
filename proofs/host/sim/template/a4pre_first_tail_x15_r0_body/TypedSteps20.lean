import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB99 from PRE_first_tail_x15_r0_body.s333 to PRE_first_tail_x15_r0_body.s334 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s333).run PRE_first_tail_x15_r0_body.S333 = some (PRE_first_tail_x15_r0_body.s334, PRE_first_tail_x15_r0_body.S334)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA100 from PRE_first_tail_x15_r0_body.s335 to PRE_first_tail_x15_r0_body.s336 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s335).run PRE_first_tail_x15_r0_body.S335 = some (PRE_first_tail_x15_r0_body.s336, PRE_first_tail_x15_r0_body.S336)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA101 from PRE_first_tail_x15_r0_body.s339 to PRE_first_tail_x15_r0_body.s340 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s339).run PRE_first_tail_x15_r0_body.S339 = some (PRE_first_tail_x15_r0_body.s340, PRE_first_tail_x15_r0_body.S340)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA102 from PRE_first_tail_x15_r0_body.s343 to PRE_first_tail_x15_r0_body.s344 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s343).run PRE_first_tail_x15_r0_body.S343 = some (PRE_first_tail_x15_r0_body.s344, PRE_first_tail_x15_r0_body.S344)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB102 from PRE_first_tail_x15_r0_body.s344 to PRE_first_tail_x15_r0_body.s345 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s344).run PRE_first_tail_x15_r0_body.S344 = some (PRE_first_tail_x15_r0_body.s345, PRE_first_tail_x15_r0_body.S345)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA103 from PRE_first_tail_x15_r0_body.s346 to PRE_first_tail_x15_r0_body.s347 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s346).run PRE_first_tail_x15_r0_body.S346 = some (PRE_first_tail_x15_r0_body.s347, PRE_first_tail_x15_r0_body.S347)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB103 from PRE_first_tail_x15_r0_body.s347 to PRE_first_tail_x15_r0_body.s348 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s347).run PRE_first_tail_x15_r0_body.S347 = some (PRE_first_tail_x15_r0_body.s348, PRE_first_tail_x15_r0_body.S348)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA104 from PRE_first_tail_x15_r0_body.s349 to PRE_first_tail_x15_r0_body.s350 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s349).run PRE_first_tail_x15_r0_body.S349 = some (PRE_first_tail_x15_r0_body.s350, PRE_first_tail_x15_r0_body.S350)
end Host.Load.Run.Tpl
