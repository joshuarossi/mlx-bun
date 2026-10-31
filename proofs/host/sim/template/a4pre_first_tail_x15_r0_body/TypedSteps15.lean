import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB74 from PRE_first_tail_x15_r0_body.s248 to PRE_first_tail_x15_r0_body.s249 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s248).run PRE_first_tail_x15_r0_body.S248 = some (PRE_first_tail_x15_r0_body.s249, PRE_first_tail_x15_r0_body.S249)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA75 from PRE_first_tail_x15_r0_body.s250 to PRE_first_tail_x15_r0_body.s251 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s250).run PRE_first_tail_x15_r0_body.S250 = some (PRE_first_tail_x15_r0_body.s251, PRE_first_tail_x15_r0_body.S251)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA76 from PRE_first_tail_x15_r0_body.s254 to PRE_first_tail_x15_r0_body.s255 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s254).run PRE_first_tail_x15_r0_body.S254 = some (PRE_first_tail_x15_r0_body.s255, PRE_first_tail_x15_r0_body.S255)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB76 from PRE_first_tail_x15_r0_body.s255 to PRE_first_tail_x15_r0_body.s256 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s255).run PRE_first_tail_x15_r0_body.S255 = some (PRE_first_tail_x15_r0_body.s256, PRE_first_tail_x15_r0_body.S256)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA77 from PRE_first_tail_x15_r0_body.s257 to PRE_first_tail_x15_r0_body.s258 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s257).run PRE_first_tail_x15_r0_body.S257 = some (PRE_first_tail_x15_r0_body.s258, PRE_first_tail_x15_r0_body.S258)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA78 from PRE_first_tail_x15_r0_body.s261 to PRE_first_tail_x15_r0_body.s262 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s261).run PRE_first_tail_x15_r0_body.S261 = some (PRE_first_tail_x15_r0_body.s262, PRE_first_tail_x15_r0_body.S262)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA79 from PRE_first_tail_x15_r0_body.s265 to PRE_first_tail_x15_r0_body.s266 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s265).run PRE_first_tail_x15_r0_body.S265 = some (PRE_first_tail_x15_r0_body.s266, PRE_first_tail_x15_r0_body.S266)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB79 from PRE_first_tail_x15_r0_body.s266 to PRE_first_tail_x15_r0_body.s267 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s266).run PRE_first_tail_x15_r0_body.S266 = some (PRE_first_tail_x15_r0_body.s267, PRE_first_tail_x15_r0_body.S267)
end Host.Load.Run.Tpl
