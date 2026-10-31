import host.sim.template.a4pre_first_tail_x15_r0_body.H10
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB89 from PRE_first_tail_x15_r0_body.s328 to PRE_first_tail_x15_r0_body.s329 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s328).run PRE_first_tail_x15_r0_body.S328 = some (PRE_first_tail_x15_r0_body.s329, PRE_first_tail_x15_r0_body.S329)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA90 from PRE_first_tail_x15_r0_body.s331 to PRE_first_tail_x15_r0_body.s332 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s331).run PRE_first_tail_x15_r0_body.S331 = some (PRE_first_tail_x15_r0_body.s332, PRE_first_tail_x15_r0_body.S332)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA91 from PRE_first_tail_x15_r0_body.s335 to PRE_first_tail_x15_r0_body.s336 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s335).run PRE_first_tail_x15_r0_body.S335 = some (PRE_first_tail_x15_r0_body.s336, PRE_first_tail_x15_r0_body.S336)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB91 from PRE_first_tail_x15_r0_body.s336 to PRE_first_tail_x15_r0_body.s337 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s336).run PRE_first_tail_x15_r0_body.S336 = some (PRE_first_tail_x15_r0_body.s337, PRE_first_tail_x15_r0_body.S337)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA92 from PRE_first_tail_x15_r0_body.s339 to PRE_first_tail_x15_r0_body.s340 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s339).run PRE_first_tail_x15_r0_body.S339 = some (PRE_first_tail_x15_r0_body.s340, PRE_first_tail_x15_r0_body.S340)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA93 from PRE_first_tail_x15_r0_body.s343 to PRE_first_tail_x15_r0_body.s344 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s343).run PRE_first_tail_x15_r0_body.S343 = some (PRE_first_tail_x15_r0_body.s344, PRE_first_tail_x15_r0_body.S344)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA94 from PRE_first_tail_x15_r0_body.s348 to PRE_first_tail_x15_r0_body.s349 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s348).run PRE_first_tail_x15_r0_body.S348 = some (PRE_first_tail_x15_r0_body.s349, PRE_first_tail_x15_r0_body.S349)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB94 from PRE_first_tail_x15_r0_body.s349 to PRE_first_tail_x15_r0_body.s350 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s349).run PRE_first_tail_x15_r0_body.S349 = some (PRE_first_tail_x15_r0_body.s350, PRE_first_tail_x15_r0_body.S350)
end Host.Load.Run.Tpl
