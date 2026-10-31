import host.sim.template.a4pre_first_tail_x15_r0_body.H12
import host.sim.template.a4pre_first_tail_x15_r0_body.H13
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA110 from PRE_first_tail_x15_r0_body.s406 to PRE_first_tail_x15_r0_body.s407 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s406).run PRE_first_tail_x15_r0_body.S406 = some (PRE_first_tail_x15_r0_body.s407, PRE_first_tail_x15_r0_body.S407)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB110 from PRE_first_tail_x15_r0_body.s407 to PRE_first_tail_x15_r0_body.s408 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s407).run PRE_first_tail_x15_r0_body.S407 = some (PRE_first_tail_x15_r0_body.s408, PRE_first_tail_x15_r0_body.S408)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA111 from PRE_first_tail_x15_r0_body.s409 to PRE_first_tail_x15_r0_body.s410 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s409).run PRE_first_tail_x15_r0_body.S409 = some (PRE_first_tail_x15_r0_body.s410, PRE_first_tail_x15_r0_body.S410)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB111 from PRE_first_tail_x15_r0_body.s410 to PRE_first_tail_x15_r0_body.s411 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s410).run PRE_first_tail_x15_r0_body.S410 = some (PRE_first_tail_x15_r0_body.s411, PRE_first_tail_x15_r0_body.S411)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA112 from PRE_first_tail_x15_r0_body.s412 to PRE_first_tail_x15_r0_body.s413 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s412).run PRE_first_tail_x15_r0_body.S412 = some (PRE_first_tail_x15_r0_body.s413, PRE_first_tail_x15_r0_body.S413)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB112 from PRE_first_tail_x15_r0_body.s413 to PRE_first_tail_x15_r0_body.s414 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s413).run PRE_first_tail_x15_r0_body.S413 = some (PRE_first_tail_x15_r0_body.s414, PRE_first_tail_x15_r0_body.S414)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA113 from PRE_first_tail_x15_r0_body.s415 to PRE_first_tail_x15_r0_body.s416 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s415).run PRE_first_tail_x15_r0_body.S415 = some (PRE_first_tail_x15_r0_body.s416, PRE_first_tail_x15_r0_body.S416)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB113 from PRE_first_tail_x15_r0_body.s416 to PRE_first_tail_x15_r0_body.s417 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s416).run PRE_first_tail_x15_r0_body.S416 = some (PRE_first_tail_x15_r0_body.s417, PRE_first_tail_x15_r0_body.S417)
end Host.Load.Run.Tpl
