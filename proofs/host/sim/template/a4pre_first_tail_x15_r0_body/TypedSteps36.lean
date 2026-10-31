import host.sim.template.a4pre_first_tail_x15_r0_body.H20
import host.sim.template.a4pre_first_tail_x15_r0_body.H21
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA179 from PRE_first_tail_x15_r0_body.s660 to PRE_first_tail_x15_r0_body.s661 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s660).run PRE_first_tail_x15_r0_body.S660 = some (PRE_first_tail_x15_r0_body.s661, PRE_first_tail_x15_r0_body.S661)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA180 from PRE_first_tail_x15_r0_body.s665 to PRE_first_tail_x15_r0_body.s666 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s665).run PRE_first_tail_x15_r0_body.S665 = some (PRE_first_tail_x15_r0_body.s666, PRE_first_tail_x15_r0_body.S666)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB180 from PRE_first_tail_x15_r0_body.s666 to PRE_first_tail_x15_r0_body.s667 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s666).run PRE_first_tail_x15_r0_body.S666 = some (PRE_first_tail_x15_r0_body.s667, PRE_first_tail_x15_r0_body.S667)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA181 from PRE_first_tail_x15_r0_body.s669 to PRE_first_tail_x15_r0_body.s670 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s669).run PRE_first_tail_x15_r0_body.S669 = some (PRE_first_tail_x15_r0_body.s670, PRE_first_tail_x15_r0_body.S670)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB181 from PRE_first_tail_x15_r0_body.s670 to PRE_first_tail_x15_r0_body.s671 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s670).run PRE_first_tail_x15_r0_body.S670 = some (PRE_first_tail_x15_r0_body.s671, PRE_first_tail_x15_r0_body.S671)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA182 from PRE_first_tail_x15_r0_body.s672 to PRE_first_tail_x15_r0_body.s673 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s672).run PRE_first_tail_x15_r0_body.S672 = some (PRE_first_tail_x15_r0_body.s673, PRE_first_tail_x15_r0_body.S673)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB182 from PRE_first_tail_x15_r0_body.s673 to PRE_first_tail_x15_r0_body.s674 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s673).run PRE_first_tail_x15_r0_body.S673 = some (PRE_first_tail_x15_r0_body.s674, PRE_first_tail_x15_r0_body.S674)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA183 from PRE_first_tail_x15_r0_body.s676 to PRE_first_tail_x15_r0_body.s677 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s676).run PRE_first_tail_x15_r0_body.S676 = some (PRE_first_tail_x15_r0_body.s677, PRE_first_tail_x15_r0_body.S677)
end Host.Load.Run.Tpl
