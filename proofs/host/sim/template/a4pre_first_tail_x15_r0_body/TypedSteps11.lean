import host.sim.template.a4pre_first_tail_x15_r0_body.H5
import host.sim.template.a4pre_first_tail_x15_r0_body.H6
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA55 from PRE_first_tail_x15_r0_body.s183 to PRE_first_tail_x15_r0_body.s184 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s183).run PRE_first_tail_x15_r0_body.S183 = some (PRE_first_tail_x15_r0_body.s184, PRE_first_tail_x15_r0_body.S184)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA56 from PRE_first_tail_x15_r0_body.s187 to PRE_first_tail_x15_r0_body.s188 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s187).run PRE_first_tail_x15_r0_body.S187 = some (PRE_first_tail_x15_r0_body.s188, PRE_first_tail_x15_r0_body.S188)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB56 from PRE_first_tail_x15_r0_body.s188 to PRE_first_tail_x15_r0_body.s189 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s188).run PRE_first_tail_x15_r0_body.S188 = some (PRE_first_tail_x15_r0_body.s189, PRE_first_tail_x15_r0_body.S189)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA57 from PRE_first_tail_x15_r0_body.s190 to PRE_first_tail_x15_r0_body.s191 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s190).run PRE_first_tail_x15_r0_body.S190 = some (PRE_first_tail_x15_r0_body.s191, PRE_first_tail_x15_r0_body.S191)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB57 from PRE_first_tail_x15_r0_body.s191 to PRE_first_tail_x15_r0_body.s192 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s191).run PRE_first_tail_x15_r0_body.S191 = some (PRE_first_tail_x15_r0_body.s192, PRE_first_tail_x15_r0_body.S192)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA58 from PRE_first_tail_x15_r0_body.s193 to PRE_first_tail_x15_r0_body.s194 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s193).run PRE_first_tail_x15_r0_body.S193 = some (PRE_first_tail_x15_r0_body.s194, PRE_first_tail_x15_r0_body.S194)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB58 from PRE_first_tail_x15_r0_body.s194 to PRE_first_tail_x15_r0_body.s195 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s194).run PRE_first_tail_x15_r0_body.S194 = some (PRE_first_tail_x15_r0_body.s195, PRE_first_tail_x15_r0_body.S195)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA59 from PRE_first_tail_x15_r0_body.s196 to PRE_first_tail_x15_r0_body.s197 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s196).run PRE_first_tail_x15_r0_body.S196 = some (PRE_first_tail_x15_r0_body.s197, PRE_first_tail_x15_r0_body.S197)
end Host.Load.Run.Tpl
