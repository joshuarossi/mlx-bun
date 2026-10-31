import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA70 from PRE_first_tail_x15_r0_body.s234 to PRE_first_tail_x15_r0_body.s235 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s234).run PRE_first_tail_x15_r0_body.S234 = some (PRE_first_tail_x15_r0_body.s235, PRE_first_tail_x15_r0_body.S235)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA71 from PRE_first_tail_x15_r0_body.s238 to PRE_first_tail_x15_r0_body.s239 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s238).run PRE_first_tail_x15_r0_body.S238 = some (PRE_first_tail_x15_r0_body.s239, PRE_first_tail_x15_r0_body.S239)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB71 from PRE_first_tail_x15_r0_body.s239 to PRE_first_tail_x15_r0_body.s240 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s239).run PRE_first_tail_x15_r0_body.S239 = some (PRE_first_tail_x15_r0_body.s240, PRE_first_tail_x15_r0_body.S240)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA72 from PRE_first_tail_x15_r0_body.s241 to PRE_first_tail_x15_r0_body.s242 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s241).run PRE_first_tail_x15_r0_body.S241 = some (PRE_first_tail_x15_r0_body.s242, PRE_first_tail_x15_r0_body.S242)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB72 from PRE_first_tail_x15_r0_body.s242 to PRE_first_tail_x15_r0_body.s243 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s242).run PRE_first_tail_x15_r0_body.S242 = some (PRE_first_tail_x15_r0_body.s243, PRE_first_tail_x15_r0_body.S243)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA73 from PRE_first_tail_x15_r0_body.s244 to PRE_first_tail_x15_r0_body.s245 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s244).run PRE_first_tail_x15_r0_body.S244 = some (PRE_first_tail_x15_r0_body.s245, PRE_first_tail_x15_r0_body.S245)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB73 from PRE_first_tail_x15_r0_body.s245 to PRE_first_tail_x15_r0_body.s246 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s245).run PRE_first_tail_x15_r0_body.S245 = some (PRE_first_tail_x15_r0_body.s246, PRE_first_tail_x15_r0_body.S246)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA74 from PRE_first_tail_x15_r0_body.s247 to PRE_first_tail_x15_r0_body.s248 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s247).run PRE_first_tail_x15_r0_body.S247 = some (PRE_first_tail_x15_r0_body.s248, PRE_first_tail_x15_r0_body.S248)
end Host.Load.Run.Tpl
