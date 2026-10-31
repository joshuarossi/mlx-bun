import host.sim.template.a4pre_first_tail_x15_r0_body.H8
import host.sim.template.a4pre_first_tail_x15_r0_body.H9
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB74 from PRE_first_tail_x15_r0_body.s272 to PRE_first_tail_x15_r0_body.s273 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s272).run PRE_first_tail_x15_r0_body.S272 = some (PRE_first_tail_x15_r0_body.s273, PRE_first_tail_x15_r0_body.S273)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA75 from PRE_first_tail_x15_r0_body.s274 to PRE_first_tail_x15_r0_body.s275 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s274).run PRE_first_tail_x15_r0_body.S274 = some (PRE_first_tail_x15_r0_body.s275, PRE_first_tail_x15_r0_body.S275)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA76 from PRE_first_tail_x15_r0_body.s278 to PRE_first_tail_x15_r0_body.s279 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s278).run PRE_first_tail_x15_r0_body.S278 = some (PRE_first_tail_x15_r0_body.s279, PRE_first_tail_x15_r0_body.S279)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB76 from PRE_first_tail_x15_r0_body.s279 to PRE_first_tail_x15_r0_body.s280 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s279).run PRE_first_tail_x15_r0_body.S279 = some (PRE_first_tail_x15_r0_body.s280, PRE_first_tail_x15_r0_body.S280)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA77 from PRE_first_tail_x15_r0_body.s282 to PRE_first_tail_x15_r0_body.s283 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s282).run PRE_first_tail_x15_r0_body.S282 = some (PRE_first_tail_x15_r0_body.s283, PRE_first_tail_x15_r0_body.S283)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA78 from PRE_first_tail_x15_r0_body.s286 to PRE_first_tail_x15_r0_body.s287 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s286).run PRE_first_tail_x15_r0_body.S286 = some (PRE_first_tail_x15_r0_body.s287, PRE_first_tail_x15_r0_body.S287)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA79 from PRE_first_tail_x15_r0_body.s291 to PRE_first_tail_x15_r0_body.s292 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s291).run PRE_first_tail_x15_r0_body.S291 = some (PRE_first_tail_x15_r0_body.s292, PRE_first_tail_x15_r0_body.S292)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB79 from PRE_first_tail_x15_r0_body.s292 to PRE_first_tail_x15_r0_body.s293 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s292).run PRE_first_tail_x15_r0_body.S292 = some (PRE_first_tail_x15_r0_body.s293, PRE_first_tail_x15_r0_body.S293)
end Host.Load.Run.Tpl
