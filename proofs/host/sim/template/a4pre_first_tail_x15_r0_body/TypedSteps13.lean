import host.sim.template.a4pre_first_tail_x15_r0_body.H7
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA65 from PRE_first_tail_x15_r0_body.s239 to PRE_first_tail_x15_r0_body.s240 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s239).run PRE_first_tail_x15_r0_body.S239 = some (PRE_first_tail_x15_r0_body.s240, PRE_first_tail_x15_r0_body.S240)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB65 from PRE_first_tail_x15_r0_body.s240 to PRE_first_tail_x15_r0_body.s241 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s240).run PRE_first_tail_x15_r0_body.S240 = some (PRE_first_tail_x15_r0_body.s241, PRE_first_tail_x15_r0_body.S241)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA66 from PRE_first_tail_x15_r0_body.s242 to PRE_first_tail_x15_r0_body.s243 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s242).run PRE_first_tail_x15_r0_body.S242 = some (PRE_first_tail_x15_r0_body.s243, PRE_first_tail_x15_r0_body.S243)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB66 from PRE_first_tail_x15_r0_body.s243 to PRE_first_tail_x15_r0_body.s244 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s243).run PRE_first_tail_x15_r0_body.S243 = some (PRE_first_tail_x15_r0_body.s244, PRE_first_tail_x15_r0_body.S244)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA67 from PRE_first_tail_x15_r0_body.s245 to PRE_first_tail_x15_r0_body.s246 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s245).run PRE_first_tail_x15_r0_body.S245 = some (PRE_first_tail_x15_r0_body.s246, PRE_first_tail_x15_r0_body.S246)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA68 from PRE_first_tail_x15_r0_body.s249 to PRE_first_tail_x15_r0_body.s250 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s249).run PRE_first_tail_x15_r0_body.S249 = some (PRE_first_tail_x15_r0_body.s250, PRE_first_tail_x15_r0_body.S250)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB68 from PRE_first_tail_x15_r0_body.s250 to PRE_first_tail_x15_r0_body.s251 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s250).run PRE_first_tail_x15_r0_body.S250 = some (PRE_first_tail_x15_r0_body.s251, PRE_first_tail_x15_r0_body.S251)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA69 from PRE_first_tail_x15_r0_body.s253 to PRE_first_tail_x15_r0_body.s254 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s253).run PRE_first_tail_x15_r0_body.S253 = some (PRE_first_tail_x15_r0_body.s254, PRE_first_tail_x15_r0_body.S254)
end Host.Load.Run.Tpl
