import host.sim.template.a4pre_first_tail_x15_r0_body.H1
import host.sim.template.BootEq
import host.sim.template.Bridges
import host.sim.Chunk
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
open Host.Ts Host.Ts.Sim
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB10 from PRE_first_tail_x15_r0_body.s36 to PRE_first_tail_x15_r0_body.s37 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s36).run PRE_first_tail_x15_r0_body.S36 = some (PRE_first_tail_x15_r0_body.s37, PRE_first_tail_x15_r0_body.S37)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA11 from PRE_first_tail_x15_r0_body.s38 to PRE_first_tail_x15_r0_body.s39 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s38).run PRE_first_tail_x15_r0_body.S38 = some (PRE_first_tail_x15_r0_body.s39, PRE_first_tail_x15_r0_body.S39)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB11 from PRE_first_tail_x15_r0_body.s39 to PRE_first_tail_x15_r0_body.s40 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s39).run PRE_first_tail_x15_r0_body.S39 = some (PRE_first_tail_x15_r0_body.s40, PRE_first_tail_x15_r0_body.S40)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA12 from PRE_first_tail_x15_r0_body.s41 to PRE_first_tail_x15_r0_body.s42 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s41).run PRE_first_tail_x15_r0_body.S41 = some (PRE_first_tail_x15_r0_body.s42, PRE_first_tail_x15_r0_body.S42)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB12 from PRE_first_tail_x15_r0_body.s42 to PRE_first_tail_x15_r0_body.s43 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s42).run PRE_first_tail_x15_r0_body.S42 = some (PRE_first_tail_x15_r0_body.s43, PRE_first_tail_x15_r0_body.S43)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA13 from PRE_first_tail_x15_r0_body.s44 to PRE_first_tail_x15_r0_body.s45 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s44).run PRE_first_tail_x15_r0_body.S44 = some (PRE_first_tail_x15_r0_body.s45, PRE_first_tail_x15_r0_body.S45)
boot_rfl PRE_first_tail_x15_r0_body.bodyStepA14 from PRE_first_tail_x15_r0_body.s48 to PRE_first_tail_x15_r0_body.s49 : interpS (step PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s48).run PRE_first_tail_x15_r0_body.S48 = some (PRE_first_tail_x15_r0_body.s49, PRE_first_tail_x15_r0_body.S49)
boot_rfl PRE_first_tail_x15_r0_body.bodyPatchB14 from PRE_first_tail_x15_r0_body.s49 to PRE_first_tail_x15_r0_body.s50 : interpS (Host.Ts.Sim.Disp.sizeS PRE_first_tail_x15_r0_body.F PRE_first_tail_x15_r0_body.s49).run PRE_first_tail_x15_r0_body.S49 = some (PRE_first_tail_x15_r0_body.s50, PRE_first_tail_x15_r0_body.S50)
end Host.Load.Run.Tpl
