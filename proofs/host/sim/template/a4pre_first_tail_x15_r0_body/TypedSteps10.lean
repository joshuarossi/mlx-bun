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
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA50 from PRE_first_tail_x15_r0_body.s182 to PRE_first_tail_x15_r0_body.s183 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s182).run PRE_first_tail_x15_r0_body.S182 = some (PRE_first_tail_x15_r0_body.s183, PRE_first_tail_x15_r0_body.S183)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB50 from PRE_first_tail_x15_r0_body.s183 to PRE_first_tail_x15_r0_body.s184 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s183).run PRE_first_tail_x15_r0_body.S183 = some (PRE_first_tail_x15_r0_body.s184, PRE_first_tail_x15_r0_body.S184)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA51 from PRE_first_tail_x15_r0_body.s185 to PRE_first_tail_x15_r0_body.s186 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s185).run PRE_first_tail_x15_r0_body.S185 = some (PRE_first_tail_x15_r0_body.s186, PRE_first_tail_x15_r0_body.S186)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB51 from PRE_first_tail_x15_r0_body.s186 to PRE_first_tail_x15_r0_body.s187 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s186).run PRE_first_tail_x15_r0_body.S186 = some (PRE_first_tail_x15_r0_body.s187, PRE_first_tail_x15_r0_body.S187)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA52 from PRE_first_tail_x15_r0_body.s188 to PRE_first_tail_x15_r0_body.s189 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s188).run PRE_first_tail_x15_r0_body.S188 = some (PRE_first_tail_x15_r0_body.s189, PRE_first_tail_x15_r0_body.S189)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA53 from PRE_first_tail_x15_r0_body.s192 to PRE_first_tail_x15_r0_body.s193 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s192).run PRE_first_tail_x15_r0_body.S192 = some (PRE_first_tail_x15_r0_body.s193, PRE_first_tail_x15_r0_body.S193)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB53 from PRE_first_tail_x15_r0_body.s193 to PRE_first_tail_x15_r0_body.s194 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s193).run PRE_first_tail_x15_r0_body.S193 = some (PRE_first_tail_x15_r0_body.s194, PRE_first_tail_x15_r0_body.S194)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA54 from PRE_first_tail_x15_r0_body.s196 to PRE_first_tail_x15_r0_body.s197 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s196).run PRE_first_tail_x15_r0_body.S196 = some (PRE_first_tail_x15_r0_body.s197, PRE_first_tail_x15_r0_body.S197)
end Host.Load.Run.Tpl
