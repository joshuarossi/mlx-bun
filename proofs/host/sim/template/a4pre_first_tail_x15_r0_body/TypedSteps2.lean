import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB10 from PRE_first_tail_x15_r0_body.s32 to PRE_first_tail_x15_r0_body.s33 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s32).run PRE_first_tail_x15_r0_body.S32 = some (PRE_first_tail_x15_r0_body.s33, PRE_first_tail_x15_r0_body.S33)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA11 from PRE_first_tail_x15_r0_body.s34 to PRE_first_tail_x15_r0_body.s35 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s34).run PRE_first_tail_x15_r0_body.S34 = some (PRE_first_tail_x15_r0_body.s35, PRE_first_tail_x15_r0_body.S35)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB11 from PRE_first_tail_x15_r0_body.s35 to PRE_first_tail_x15_r0_body.s36 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s35).run PRE_first_tail_x15_r0_body.S35 = some (PRE_first_tail_x15_r0_body.s36, PRE_first_tail_x15_r0_body.S36)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA12 from PRE_first_tail_x15_r0_body.s37 to PRE_first_tail_x15_r0_body.s38 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s37).run PRE_first_tail_x15_r0_body.S37 = some (PRE_first_tail_x15_r0_body.s38, PRE_first_tail_x15_r0_body.S38)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB12 from PRE_first_tail_x15_r0_body.s38 to PRE_first_tail_x15_r0_body.s39 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s38).run PRE_first_tail_x15_r0_body.S38 = some (PRE_first_tail_x15_r0_body.s39, PRE_first_tail_x15_r0_body.S39)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA13 from PRE_first_tail_x15_r0_body.s40 to PRE_first_tail_x15_r0_body.s41 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s40).run PRE_first_tail_x15_r0_body.S40 = some (PRE_first_tail_x15_r0_body.s41, PRE_first_tail_x15_r0_body.S41)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA14 from PRE_first_tail_x15_r0_body.s44 to PRE_first_tail_x15_r0_body.s45 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s44).run PRE_first_tail_x15_r0_body.S44 = some (PRE_first_tail_x15_r0_body.s45, PRE_first_tail_x15_r0_body.S45)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB14 from PRE_first_tail_x15_r0_body.s45 to PRE_first_tail_x15_r0_body.s46 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s45).run PRE_first_tail_x15_r0_body.S45 = some (PRE_first_tail_x15_r0_body.s46, PRE_first_tail_x15_r0_body.S46)
end Host.Load.Run.Tpl
