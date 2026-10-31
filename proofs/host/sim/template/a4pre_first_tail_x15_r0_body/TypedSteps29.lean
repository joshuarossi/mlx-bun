import host.sim.template.a4pre_first_tail_x15_r0_body.H15
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA144 from PRE_first_tail_x15_r0_body.s484 to PRE_first_tail_x15_r0_body.s485 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s484).run PRE_first_tail_x15_r0_body.S484 = some (PRE_first_tail_x15_r0_body.s485, PRE_first_tail_x15_r0_body.S485)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB144 from PRE_first_tail_x15_r0_body.s485 to PRE_first_tail_x15_r0_body.s486 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s485).run PRE_first_tail_x15_r0_body.S485 = some (PRE_first_tail_x15_r0_body.s486, PRE_first_tail_x15_r0_body.S486)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA145 from PRE_first_tail_x15_r0_body.s487 to PRE_first_tail_x15_r0_body.s488 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s487).run PRE_first_tail_x15_r0_body.S487 = some (PRE_first_tail_x15_r0_body.s488, PRE_first_tail_x15_r0_body.S488)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA146 from PRE_first_tail_x15_r0_body.s491 to PRE_first_tail_x15_r0_body.s492 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s491).run PRE_first_tail_x15_r0_body.S491 = some (PRE_first_tail_x15_r0_body.s492, PRE_first_tail_x15_r0_body.S492)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB146 from PRE_first_tail_x15_r0_body.s492 to PRE_first_tail_x15_r0_body.s493 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s492).run PRE_first_tail_x15_r0_body.S492 = some (PRE_first_tail_x15_r0_body.s493, PRE_first_tail_x15_r0_body.S493)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA147 from PRE_first_tail_x15_r0_body.s494 to PRE_first_tail_x15_r0_body.s495 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s494).run PRE_first_tail_x15_r0_body.S494 = some (PRE_first_tail_x15_r0_body.s495, PRE_first_tail_x15_r0_body.S495)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA148 from PRE_first_tail_x15_r0_body.s498 to PRE_first_tail_x15_r0_body.s499 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s498).run PRE_first_tail_x15_r0_body.S498 = some (PRE_first_tail_x15_r0_body.s499, PRE_first_tail_x15_r0_body.S499)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA149 from PRE_first_tail_x15_r0_body.s502 to PRE_first_tail_x15_r0_body.s503 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s502).run PRE_first_tail_x15_r0_body.S502 = some (PRE_first_tail_x15_r0_body.s503, PRE_first_tail_x15_r0_body.S503)
end Host.Load.Run.Tpl
